module.exports = {
  TSServer: '127.0.0.1', // [Required] TS3 Server IP
  WSServerIP: '',			   // [Optional] Uses Autoconfig if undefined
  WSServerPort: 33250,		   // [Required] 
  enableLogs: false,		   // Enable Logs
  masterServer: {
    registerUrl: 'https://master.tokovoip.itokoyamato.net/register',
    heartbeatUrl: 'https://master.tokovoip.itokoyamato.net/heartbeat'
  }
};