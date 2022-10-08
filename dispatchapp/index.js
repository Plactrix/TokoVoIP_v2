let endpoint;
let serverId;
let save;
let websocket;
let document;

const wsClient = require('ws');
const readline = require('readline');
const chalk = require('chalk');
const fs = require('fs');
const gkm = require('gkm');
const rl = readline.createInterface(process.stdin, process.stdout);


if (!fs.existsSync('./save.json')) {
    rl.question('» Please enter the endpoint provided by the server owner (Please include the port number)\n', (questionEndpoint) => {
        console.log(chalk.green('Thank you'))
        fs.writeFile('save.json', `{"wsserver": "${questionEndpoint}"}`, function (err) {
        if (err) return console.log(err);
        console.log(chalk.green("Starting Up..."))
        setTimeout(() => {startup(questionEndpoint)}, 1000)
        });
    })
} else {
    save = require('./save.json')
    console.log(chalk.yellow('[') + chalk.blue('TokoVoIP') + chalk.yellow(']') + ' ' + 'Configuration file (save.json) Found.')
    console.log(chalk.green("Starting Up..."))
    setTimeout(() => {startup(save.wsserver)}, 1000)
}

function startup(sentEndpoint) {
    console.clear()
    let ws = new wsClient(`ws://${sentEndpoint}/socket.io/?EIO=3&transport=websocket&from=dispatchclient&serverId=DSG}`);
    console.log("Ready")
    ws.on('open', function open() {
        console.log('TokoVoIP: connection opened');
    })

    ws.on('message', function message(data) {
        console.log('received: %s', data);
        if (data.includes('ping')) {
            setInterval(() => {
                ws.send(`42${JSON.stringify(['pong', ''])}`)
						}, 1000)
        }
    })

    gkm.events.on('key.*', function(keyName) {
        if(keyName == 'Left Alt') {
            if (this.event == 'key.pressed') {
                // Key was pressed, start talking and send radio click on
                console.log("Key Pressed")
                ws.send('FiveM', 0)
            } else if (this.event == 'key.released') {
                console.log("Key Released")
                // Key was released, stop talking and send radio click off
            }
        }
    });
}

process.on('unhandledRejection', (err) => { 
    fs.writeFile('error.log', `${err}`, function (erra) {
        if (erra) return console.log(erra);
        console.log('An error has occured. Please open a ticket in our Discord https://discord.gg/nBJDNTvkhS and send the error.log file.')
    });
});
