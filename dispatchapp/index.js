let endpoint, serverId, save;
let radioTalking = false;

const wsClient = require("ws");
const readline = require("readline");
const chalk = require("chalk");
const fs = require("fs");
const gkm = require("gkm");
const axios = require("axios");
const rl = readline.createInterface(process.stdin, process.stdout);

if (!fs.existsSync("./save.json")) {
  rl.question(
    "» Please enter the fivem server endpoint provided by the owner (Please include the port number)\n",
    (questionEndpoint) => {
      axios
        .get(`http://${questionEndpoint}/dispatchapp`)
        .then((response) => {
          endpoint = response.data.metadata.endpoint;
          serverId = response.data.metadata.serverId;
          tokoData = response.data.metadata;
          console.log(
            chalk.yellow("[") +
              chalk.blue("TokoVoIP") +
              chalk.yellow("]") +
              " " +
              "Endpoint: " +
              chalk.green(endpoint)
          );
          console.log(
            chalk.yellow("[") +
              chalk.blue("TokoVoIP") +
              chalk.yellow("]") +
              " " +
              "Server ID: " +
              chalk.green(serverId)
          );
          fs.writeFile(
            "save.json",
            `{"wsServer": "${endpoint}", "serverIP": "${questionEndpoint}"}`,
            function (err) {
              if (err) return console.log(err);
              console.log(chalk.green("Starting Up..."));
              setTimeout(() => {
                startup(endpoint, tokoData);
              }, 1000);
            }
          );
        })
        .catch((error) => {
          console.log(
            chalk.red(
              "An error has occured. Please check the endpoint and try again."
            )
          );
          process.exit();
        });
    }
  );
} else {
  save = require("./save.json");
  axios
    .get(`http://${save.serverIP}/dispatchapp`)
    .then((response) => {
      endpoint = response.data.metadata.endpoint;
      serverId = response.data.metadata.serverId;
      tokoData = response.data.metadata;
      console.log(
        chalk.yellow("[") +
          chalk.blue("TokoVoIP") +
          chalk.yellow("]") +
          " " +
          "Endpoint: " +
          chalk.green(endpoint)
      );
      console.log(
        chalk.yellow("[") +
          chalk.blue("TokoVoIP") +
          chalk.yellow("]") +
          " " +
          "Server ID: " +
          chalk.green(serverId)
      );
      console.log(
        chalk.yellow("[") +
          chalk.blue("TokoVoIP") +
          chalk.yellow("]") +
          " " +
          "Configuration file (save.json) Found."
      );
      console.log(chalk.green("Starting Up..."));
      setTimeout(() => {
        startup(save.wsServer, tokoData);
      }, 1000);
    })
    .catch((error) => {
      console.log(
        chalk.red(
          "An error has occured. Please check the endpoint and try again."
        )
      );
      process.exit();
    });
}

function startup(sentEndpoint, tokoData) {
  let ws = new wsClient(
    `ws://${sentEndpoint}/socket.io/?EIO=3&transport=websocket&from=fivem&serverId=${tokoData.serverId}`
  );
  axios
    .get(`https://api64.ipify.org?format=json`)
    .then((response) => {
      clientIp = response.data.ip;
      console.log(
        chalk.yellow("[") +
          chalk.blue("TokoVoIP") +
          chalk.yellow("]") +
          " " +
          "Client IP: " +
          chalk.green(clientIp)
      );
    })
    .catch((error) => {
      console.log(
        chalk.red(
          "An error has occured while attempting to get client IP. Please wait a few minutes and try again."
        )
      );
      process.exit();
    });

  ws.on("open", function open() {
    console.log(
      chalk.yellow("[") +
        chalk.blue("TokoVoIP") +
        chalk.yellow("]") +
        " " +
        "Connection Opened"
    );
  });
  let first = true;
  ws.on("message", function message(data) {
    console.log("Response: %s", data);
    if (data.includes("ping")) ws.send(`42${JSON.stringify(["pong", ""])}`);

    if (data == "40") {
      if (first) {
        setInterval(() => {
          console.log(
            `42${JSON.stringify([
              "data",
              {
                local_click_off: false,
                TSDownload: tokoData.TSDownload,
                TSPassword: tokoData.TSPassword,
                posZ: tokoData.posZ,
                remote_click_off: tokoData.remote_click_off,
                localName: tokoData.localName,
                TSChannel: tokoData.TSChannel,
                TSServer: tokoData.TSServer,
                radioChannel: 1, //tokoData.radioChannel,
                localNamePrefix: tokoData.localNamePrefix,
                posY: tokoData.posY,
                posX: tokoData.posX,
                TSChannelWait: tokoData.TSChannelWait,
                radioTalking,
                local_click_on: tokoData.local_click_on,
                localRadioClicks: tokoData.localRadioClicks,
                remote_click_on: tokoData.remote_click_on,
                TSChannelWhitelist: tokoData.TSChannelWhitelist,
                TSChannelSupport: tokoData.TSChannelSupport,
                enableStereoAudio: tokoData.enableStereoAudio,
                Users: tokoData.Users,
              },
            ])}`
          );
          ws.send(
            `42${JSON.stringify([
              "data",
              {
                local_click_off: false,
                TSDownload: tokoData.TSDownload,
                TSPassword: tokoData.TSPassword,
                posZ: 30.34560394287109,
                remote_click_off: tokoData.remote_click_off,
                localName: tokoData.localName,
                TSChannel: tokoData.TSChannel,
                TSServer: tokoData.TSServer,
                radioChannel: 1, //tokoData.radioChannel,
                localNamePrefix: tokoData.localNamePrefix,
                posY: 0,
                posX: 0,
                TSChannelWait: tokoData.TSChannelWait,
                radioTalking,
                local_click_on: tokoData.local_click_on,
                localRadioClicks: tokoData.localRadioClicks,
                remote_click_on: tokoData.remote_click_on,
                TSChannelWhitelist: tokoData.TSChannelWhitelist,
                TSChannelSupport: tokoData.TSChannelSupport,
                enableStereoAudio: tokoData.enableStereoAudio,
                Users: tokoData.Users,
              },
            ])}`
          );
        }, 10);
      }
      first = false;
    }
  });

  setInterval(() => {
    ws.send(`42${JSON.stringify(["updateClientIP", { ip: clientIp }])}`);
  }, 5000);

  gkm.events.on("key.*", function (keyName) {
    if (keyName == "Left Alt") {
      if (this.event == "key.pressed") {
        radioTalking = true;
      } else if (this.event == "key.released") {
        radioTalking = false;
      }
    }
  });
}

process.on("unhandledRejection", (err) => {
  fs.writeFile("error.log", `${err}`, function (erra) {
    if (erra) return console.log(erra);
    console.log(
      "An error has occured. Please open a ticket in our Discord https://discord.gg/nBJDNTvkhS and send the error.log file."
    );
  });
});
