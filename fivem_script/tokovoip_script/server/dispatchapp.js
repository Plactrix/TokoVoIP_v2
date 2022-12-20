var Config = global.exports[GetCurrentResourceName()].getTokoConfig()

if (Config.dispatchapp.enable) {
    const express = require("express");
    const app = express();
    app.get("/dispatchapp", (req, res) => {
        res.send({
            "metadata": {
                "endpoint": Config.wsServer,
                "serverId": global.exports[GetCurrentResourceName()].getServerId(),
                "posX": 0,
                "posY": 44.39365005493164,
                "posZ": 0,
                "radioChannel": 0,
                "Users": [],
            	"radioTalking": false,
                "localRadioClicks": false,
                "localNamePrefix": "[NOT IN GAME] ",
                "localName": "Dispatcher",
                "TSChannelWait": Config.plugin_data.TSChannelWait,
				"TSChannel": Config.plugin_data.TSChannel,
                "TSDownload": Config.plugin_data.TSDownload,
                "TSServer": Config.plugin_data.TSServer,
                "TSPassword": Config.plugin_data.TSPassword,
                "TSChannelWhitelist": Config.plugin_data.TSChannelWhitelist,
                "local_click_on": Config.plugin_data.local_click_on,
                "local_click_off": Config.plugin_data.local_click_off,
                "remote_click_on": Config.plugin_data.remote_click_on,
            	"remote_click_off": Config.plugin_data.remote_click_off,
                "enableStereoAudio": Config.plugin_data.enableStereoAudio,
                "TSChannelSupport": Config.plugin_data.TSChannelSupport
            }
        });
    });

	app.listen(Config.dispatchapp.port)
}