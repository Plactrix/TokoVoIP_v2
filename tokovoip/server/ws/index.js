const config = require("./config.js");

const bootTime = new Date();

const express = require("express");
const app = express();
const http = require("http").createServer(app);
const io = require("socket.io")(http, { maxHttpBufferSize: 1e8 });
const axios = require("axios");
const lodash = require("lodash");
const chalk = require("chalk");
let WSServerIP = "127.0.0.1";
const publicIp = require("public-ip");
const IPv4Regex = new RegExp("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$");

if (config.enableintegratedws) {
  let hostIP;
  let masterHeartbeatInterval;
  const clients = {};
  const handshakes = {};

  app.use(express.json());

  (async () => {
    config.TSServer = process.env.TSServer || config.TSServer;
    config.WSServerPort = parseInt(process.env.WSServerPort, 10) || parseInt(config.WSServerPort, 10);
    WSServerIP = process.env.WSServerIP || WSServerIP;
    hostIP = await publicIp.v4();

    if (!WSServerIP) {
      WSServerIP = hostIP;
      console.log(`${chalk.yellow("AUTOCONFIG:")} Setting ${chalk.cyan("WSServerIP")} to ${chalk.cyan(WSServerIP)} (you can manually edit in config.js)`);
      await sleep(0);
    }

    if (!config.TSServer || !WSServerIP || !config.WSServerPort) {
      console.error(chalk.red(`Config error:
Missing one of TSServer, WSServerIP or WSServerPort`));
      return;
    }

    http.listen(config.WSServerPort, async () => {
      let configError = false;

      if (!IPv4Regex.test(config.TSServer)) {
        configError = true;
        console.error(chalk.red(`Config error:
TSServer is invalid.
It must be an IPv4 address.
Domain names are not supported.`));
      }

      if (config.WSServerPort < 30000) {
        console.error(chalk.yellow(`Config warning:
It is advised to use a WSServerPort above 30k, some player networks block ports below it.`));
      }

      const wsURI = `http://${WSServerIP}:${config.WSServerPort}`;
      try {
        await axios.get(wsURI);
      } catch (e) {
        configError = true;
        console.error(chalk.red(`Config error:
Could not access WS server.
Is it accessible from the internet?
Make sure your configuration is correct and your ports are open.
(${chalk.cyan(wsURI)})`));
      }

      if (configError) return;

      await sleep(0);

      console.log(chalk`Websocket listening on "{cyan ${hostIP}:${config.WSServerPort}}"`);

      masterHeartbeat();
      masterHeartbeatInterval = setInterval(masterHeartbeat, 300000);
    });
  })();

  app.get("/", (_, res) => {
    res.send({
      started: bootTime.toISOString(),
      uptime: process.uptime(),
    });
  });

  app.get("/playerbyip", (req, res) => {
    const player = handshakes[req.query.ip];
    if (!player) return res.status(404).send();
    return res.status(204).send();
  });

  app.get("/getmyip", (req, res) => {
    const ip = (
      lodash.get(req, 'headers["x-forwarded-for"]') ||
      lodash.get(req, 'headers["x-real-ip"]') ||
      lodash.get(req, "connection.remoteAddress")
    ).replace("::ffff:", "");
    res.send(ip);
  });

  http.on("upgrade", (req, socket) => {
    if (!req._query || !req._query.from) return socket.destroy();
    if (req._query.from === "ts3" && !req._query.uuid) return socket.destroy();
  });

  io.on("connection", async socket => {
    socket.from = socket.request._query.from;
    socket.clientIp =
      socket.handshake.headers["x-forwarded-for"] ||
      socket.request.connection.remoteAddress.replace("::ffff:", "");
    socket.safeIp = Buffer.from(socket.clientIp).toString("base64");
    if (
      socket.clientIp.includes("::1") ||
      socket.clientIp.includes("127.0.0.1") ||
      socket.clientIp.includes("192.168.")
    )
      socket.clientIp = hostIP;

    socket.fivemServerId = socket.request._query.serverId;

    socket.on("disconnect", () => onSocketDisconnect(socket));

    log("log", chalk`${socket.from === "ts3" ? chalk.cyan(socket.from) : chalk.yellow(socket.from)} | Connection ${chalk.cyan("opened")} - ${socket.safeIp}`);

    if (socket.from === "ts3") {
      let client = clients[socket.request._query.uuid];
      socket.uuid = socket.request._query.uuid;

      if (!handshakes[socket.clientIp]) {
        socket.emit("disconnectMessage", "handshakeNotFound");
        socket.disconnect(true);
        return;
      }

      client = clients[socket.uuid] = {
        ip: socket.clientIp,
        uuid: socket.uuid,
        fivem: {},
        ts3: {
          uuid: socket.uuid,
        },
      };

      client.ts3.socket = socket;
      client.ts3.linkedAt = new Date().toISOString();
      delete handshakes[socket.clientIp];

      log("log", chalk`${chalk.cyan(socket.from)} | Handshake ${chalk.green("successful")} - ${socket.safeIp}`);

      socket.on("setTS3Data", data => setTS3Data(socket, data));
      socket.on("onTalkStatusChanged", data => setTS3Data(socket, { key: "talking", value: data }));
      socketHeartbeat(socket);
    } else if (socket.from === "fivem") {
      socketHeartbeat(socket);
      socket.on("updateClientIP", data => {
        if (!data || !data.ip || !IPv4Regex.test(data.ip) || !clients[socket.uuid]) return;
        if (lodash.get(clients, `[${socket.uuid}].fivem.socket`)) {
          delete handshakes[clients[socket.uuid].fivem.socket.clientIp];
          clients[socket.uuid].fivem.socket.clientIp = data.ip;
        }
        if (lodash.get(clients, `[${socket.uuid}].ts3.socket`)) {
          clients[socket.uuid].ts3.socket.clientIp = data.ip;
        }
      });
      await registerHandshake(socket);
      socket.on("data", data => onIncomingData(socket, data));
    }
  });

  async function registerHandshake(socket) {
    if (socket.from === "fivem" && handshakes[socket.clientIp]) return;

    handshakes[socket.clientIp] = socket;
    let client;
    let tries = 0;

    while (!client) {
      ++tries;
      if (tries > 1) await sleep(5000);
      if (tries > 12) {
        handshakes[socket.clientIp] = null;
        socket.emit("disconnectMessage", "ts3HandshakeFailed");
        socket.disconnect(true);
        return;
      }
      client = Object.values(clients).find(item => !item.fivem.socket && item.ip === socket.clientIp);
      try {
        await axios.post(config.masterServer.registerUrl, {
          ip: socket.clientIp,
          server: {
            tsServer: config.TSServer,
            ip: WSServerIP,
            port: config.WSServerPort,
          },
        });
      } catch (e) {
        console.error(e);
        throw e;
      }
    }

    socket.uuid = client.uuid;
    client.fivem.socket = socket;
    client.fivem.linkedAt = new Date().toISOString();
    if (lodash.get(client, "ts3.data.uuid")) {
      socket.emit("setTS3Data", client.ts3.data);
    }
  }

  function setTS3Data(socket, data) {
    const client = clients[socket.uuid];
    if (!client) return;
    lodash.set(client.ts3, `data.${data.key}`, data.value);
    if (client.fivem.socket) {
      client.fivem.socket.emit("setTS3Data", client.ts3.data);
    }
  }

  function onIncomingData(socket, data) {
    const client = clients[socket.uuid];
    if (!socket.uuid || !client || !client.ts3.socket || typeof data !== "object") return;
    socket.tokoData = data;
    client.fivem.data = socket.tokoData;
    client.fivem.updatedAt = new Date().toISOString();
    client.ts3.socket.emit("processTokovoip", client.fivem.data);
  }

  async function onSocketDisconnect(socket) {
    log("log", chalk`${socket.from === "ts3" ? chalk.cyan(socket.from) : chalk.yellow(socket.from)} | Connection ${chalk.red("lost")} - ${socket.safeIp}`);
    if (socket.from === "fivem" && handshakes[socket.clientIp]) delete handshakes[socket.clientIp];
    if (socket.uuid && clients[socket.uuid]) {
      const client = clients[socket.uuid];
      delete clients[socket.uuid];
      const secondary = socket.from === "fivem" ? "ts3" : "fivem";
      if (client[secondary].socket) {
        client[secondary].socket.emit("disconnectMessage", `${socket.from}Disconnected`);
        if (secondary === "ts3") {
          await sleep(100);
          client[secondary].socket.disconnect(true);
        } else {
          await registerHandshake(client[secondary].socket);
        }
      }
    }
  }

  function socketHeartbeat(socket) {
    if (!socket) return;
    const start = new Date();
    socket.once("pong", () => {
      setTimeout(() => socketHeartbeat(socket), 1000);
      socket.latency = new Date().getTime() - start.getTime();
      if (!socket.uuid || !clients[socket.uuid]) return;
      clients[socket.uuid].latency =
        lodash.get(clients[socket.uuid], "fivem.socket.latency", 0) +
        lodash.get(clients[socket.uuid], "ts3.socket.latency", 0);

      if (socket.from === "fivem") {
        socket.emit("onLatency", {
          total: clients[socket.uuid].latency,
          fivem: lodash.get(clients[socket.uuid], "fivem.socket.latency", 0),
          ts3: lodash.get(clients[socket.uuid], "ts3.socket.latency", 0),
        });
      }
    });
    socket.emit("ping");
  }

  async function masterHeartbeat() {
    try {
      await axios.post(config.masterServer.heartbeatUrl, {
        tsServer: config.TSServer,
        WSServerIP,
        WSServerPort: config.WSServerPort,
      });
      console.log("Heartbeat sent");
    } catch (e) {
      console.error("Sending heartbeat failed with error:", e);
    }
  }

  const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

  function log(type, msg) {
    if (!config.enableLogs) return;
    console[type](msg);
  }

  console.log(chalk`Like {cyan TokoVOIP} ? Leave a Star on Github: {hex("#f96854") https://github.com/Plactrix/TokoVoIP_v2}`);
} else {
  console.error(chalk.red(`Config notice:
Integrated WS is disabled.
You can enable it in the config.js by setting ${chalk.cyan("enableintegratedws")} to ${chalk.cyan("true")}.`));
}