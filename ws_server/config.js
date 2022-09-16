module.exports = {
  // [REQUIRED] IPv4 Address of your TeamSpeak3 server
  TSServer: "127.0.0.1",

  // [REQUIRED] Port of the ws_server
  // Please use a port above 30k as some networks block any ports below it
  WSServerPort: 33250,

  // [OPTIONAL] IPv4 Address of the ws_server
	// By default, this is set by the auto-config. Only uncomment this is you need to
  // WSServerIP: "127.0.0.1",

  // Set to true to enable/disable websocket server logs
	enableLogs: false,
}
