const express = require('express');
const { createServer } = require('http');
const { Server: SocketIOServer } = require('socket.io');
const axios = require('axios');
const _ = require('lodash');
const chalk = require('chalk');
const { fileURLToPath } = require('url');
const { dirname } = require('path');
const config = require('./config.js');
const publicIp = require('public-ip');

const app = express();
const http = createServer(app);
const io = new SocketIOServer(http, { maxHttpBufferSize: 1e8 });

const bootTime = new Date();
let WSServerIP = '127.0.0.1';
let hostIP;

const ipRegex = new RegExp(
  '^((([0-9]{1,3}\\.){3}[0-9]{1,3})|' +
    '(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})|' +
    '(([0-9a-fA-F]{1,4}:){1,7}:)|' +
    '(([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})|' +
    '(([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2})|' +
    '(([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3})|' +
    '(([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4})|' +
    '(([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5})|' +
    '([0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6}))|' +
    '(:((:[0-9a-fA-F]{1,4}){1,7}|:))|' +
    '(::(ffff(:0{1,4}){0,1}:){0,1}' +
    '((25[0-5]|(2[0-4][0-9]|1?[0-9]{1,2}))\\.){3}' +
    '(25[0-5]|(2[0-4][0-9]|1?[0-9]{1,2}))))$'
);

async function main() {
  if (!config.enableintegratedws) {
    console.error(
      chalk.red('Config notice:\n') +
      'Integrated WS is disabled.\n' +
      'Enable it in config.js by setting ' +
      chalk.cyan('enableintegratedws') +
      ' to ' +
      chalk.cyan('true') +
      '.'
    );
    return;
  }

  const clients = {};
  const handshakes = {};
  let masterHeartbeatInterval;

  app.use(express.json());

  config.TSServer = process.env.TSServer || config.TSServer;
  config.WSServerPort = parseInt(process.env.WSServerPort, 10) || parseInt(config.WSServerPort, 10);
  WSServerIP = process.env.WSServerIP || WSServerIP;

  try {
    hostIP = await publicIp.v4(); // bevorzugt IPv4
  } catch {
    try {
      hostIP = await publicIp.v6(); // fallback IPv6
    } catch {
      console.error(chalk.red('Unable to detect public IP (v4 or v6)'));
      return;
    }
  }

  if (!WSServerIP) {
    WSServerIP = hostIP;
    console.log(
      chalk.yellow('AUTOCONFIG:') + ' Setting ' +
      chalk.cyan('WSServerIP') + ' to ' +
      chalk.cyan(WSServerIP) + ' (you can manually edit in config.js)'
    );
    await sleep(0);
  }

  if (!config.TSServer || !WSServerIP || !config.WSServerPort) {
    console.error(chalk.red('Config error: Missing one of TSServer, WSServerIP or WSServerPort'));
    return;
  }

  http.listen(config.WSServerPort, async () => {
    let configError = false;

    if (!ipRegex.test(config.TSServer)) {
      configError = true;
      console.error(chalk.red('Config error: TSServer is invalid. Must be an IP address (IPv4 or IPv6).'));
    }

    if (config.WSServerPort < 30000) {
      console.warn(chalk.yellow('Config warning: Port under 30k may be blocked on some networks.'));
    }

    try {
      await axios.get(`http://${WSServerIP}:${config.WSServerPort}`);
    } catch {
      configError = true;
      console.error(chalk.red('Config error: WS server not reachable.'));
    }

    if (configError) return;

    console.log(
      'Websocket listening on "' +
      chalk.cyan(`${hostIP}:${config.WSServerPort}`) + '"'
    );
    masterHeartbeat();
    masterHeartbeatInterval = setInterval(masterHeartbeat, 300000);
  });

  app.get('/', (_, res) => {
    res.send({ started: bootTime.toISOString(), uptime: process.uptime() });
  });

  app.get('/playerbyip', (req, res) => {
    const player = handshakes[req.query.ip];
    return player ? res.status(204).send() : res.status(404).send();
  });

  app.get('/getmyip', (req, res) => {
    const ip =
      req.headers['x-forwarded-for'] ||
      req.headers['x-real-ip'] ||
      req.connection.remoteAddress;

    res.send(ip?.replace('::ffff:', ''));
  });

  http.on('upgrade', (req, socket) => {
    if (!req._query?.from || (req._query.from === 'ts3' && !req._query.uuid)) {
      socket.destroy();
    }
  });

  io.on('connection', async socket => {
    const rawIp = socket.handshake.address;
    socket.clientIp = rawIp.startsWith('::ffff:') ? rawIp.replace('::ffff:', '') : rawIp;
    socket.safeIp = Buffer.from(socket.clientIp).toString('base64');
    socket.from = socket.request._query.from;
    socket.fivemServerId = socket.request._query.serverId;

    if (
      socket.clientIp === '::1' ||
      socket.clientIp === '127.0.0.1' ||
      socket.clientIp.startsWith('192.168.')
    ) {
      socket.clientIp = hostIP;
    }

    socket.on('disconnect', () => onSocketDisconnect(socket));

    log('log', `${socket.from} | Connection opened - ${socket.safeIp}`);

    if (socket.from === 'ts3') {
      let client = clients[socket.request._query.uuid];
      socket.uuid = socket.request._query.uuid;

      if (!handshakes[socket.clientIp]) {
        socket.emit('disconnectMessage', 'handshakeNotFound');
        return socket.disconnect(true);
      }

      client = clients[socket.uuid] = {
        ip: socket.clientIp,
        uuid: socket.uuid,
        fivem: {},
        ts3: { uuid: socket.uuid, socket, linkedAt: new Date().toISOString() },
      };

      delete handshakes[socket.clientIp];
      log('log', `${socket.from} | Handshake successful - ${socket.safeIp}`);

      socket.on('setTS3Data', data => setTS3Data(socket, data));
      socket.on('onTalkStatusChanged', data => setTS3Data(socket, { key: 'talking', value: data }));
      socketHeartbeat(socket);
    } else if (socket.from === 'fivem') {
      socketHeartbeat(socket);

      socket.on('updateClientIP', data => {
        if (!data?.ip || !ipRegex.test(data.ip) || !clients[socket.uuid]) return;
        if (_.get(clients, `[${socket.uuid}].fivem.socket`)) {
          delete handshakes[clients[socket.uuid].fivem.socket.clientIp];
          clients[socket.uuid].fivem.socket.clientIp = data.ip;
        }
        if (_.get(clients, `[${socket.uuid}].ts3.socket`)) {
          clients[socket.uuid].ts3.socket.clientIp = data.ip;
        }
      });

      await registerHandshake(socket);
      socket.on('data', data => onIncomingData(socket, data));
    }
  });

  async function registerHandshake(socket) {
    if (socket.from === 'fivem' && handshakes[socket.clientIp]) return;
    handshakes[socket.clientIp] = socket;

    let client;
    let tries = 0;

    while (!client) {
      if (++tries > 12) {
        handshakes[socket.clientIp] = null;
        socket.emit('disconnectMessage', 'ts3HandshakeFailed');
        return socket.disconnect(true);
      }

      if (tries > 1) await sleep(5000);

      client = Object.values(clients).find(c => !c.fivem.socket && c.ip === socket.clientIp);

      try {
        await axios.post(config.masterServer.registerUrl, {
          ip: socket.clientIp,
          server: { tsServer: config.TSServer, ip: WSServerIP, port: config.WSServerPort },
        });
      } catch (e) {
        console.error(e);
        throw e;
      }
    }
  

    socket.uuid = client.uuid;
    client.fivem.socket = socket;
    client.fivem.linkedAt = new Date().toISOString();
    if (_.get(client, 'ts3.data.uuid')) {
      socket.emit('setTS3Data', client.ts3.data);
    }
  }

  function setTS3Data(socket, data) {
    const client = clients[socket.uuid];
    if (!client) return;
    _.set(client.ts3, `data.${data.key}`, data.value);
    client.fivem?.socket?.emit('setTS3Data', client.ts3.data);
  }

  function onIncomingData(socket, data) {
    const client = clients[socket.uuid];
    if (!client || !client.ts3?.socket || typeof data !== 'object') return;
    socket.tokoData = data;
    client.fivem.data = data;
    client.fivem.updatedAt = new Date().toISOString();
    client.ts3.socket.emit('processTokovoip', data);
  }

  async function onSocketDisconnect(socket) {
    log('log', `${socket.from} | Connection lost - ${socket.safeIp}`);
    if (socket.from === 'fivem') delete handshakes[socket.clientIp];

    if (socket.uuid && clients[socket.uuid]) {
      const client = clients[socket.uuid];
      delete clients[socket.uuid];
      const secondary = socket.from === 'fivem' ? 'ts3' : 'fivem';
      const other = client[secondary];

      if (other?.socket) {
        other.socket.emit('disconnectMessage', `${socket.from}Disconnected`);
        if (secondary === 'ts3') {
          await sleep(100);
          other.socket.disconnect(true);
        } else {
          await registerHandshake(other.socket);
        }
      }
    }
  }

  function socketHeartbeat(socket) {
    if (!socket) return;
    socket._lastHeartbeat = new Date();

    const id = setInterval(() => {
      if (!socket) return clearInterval(id);

      if (socket._lastHeartbeat && new Date() - socket._lastHeartbeat > 45000) {
        socket.disconnect(true);
        return clearInterval(id);
      }

      try {
        socket.emit('heartbeat');
      } catch {
        socket.disconnect(true);
        clearInterval(id);
      }
    }, 10000);

    socket.on('heartbeat', () => {
      socket._lastHeartbeat = new Date();
    });
  }
}

async function masterHeartbeat() {
  try {
    await axios.post(config.masterServer.heartbeatUrl, {
      tsServer: config.TSServer,
      WSServerIP,
      WSServerPort: config.WSServerPort,
    });
    console.log(chalk.green("Heartbeat sent"));
  } catch (e) {
    console.error(chalk.red("Sending heartbeat failed:"), e);
  }


  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  function log(type, msg) {
    const colorMap = {
      log: 'white',
      error: 'red',
      warn: 'yellow',
      info: 'blue',
    };

    console.log(chalk[colorMap[type] || 'white'](`[${new Date().toISOString()}] ${msg}`));
  }
}

main().catch(console.error);
