Config = {
    refreshRate = 100, -- Rate at which the data is sent to the TSPlugin
    networkRefreshRate = 2000, -- Rate at which the network data is updated/reset on the local ped
    playerListRefreshRate = 2000, -- Rate at which the playerList is updated
    minVersion = "1.0.0", -- Version of the TS plugin required to play on the server
    enableDebug = false, -- Enable or disable tokovoip debug (Shift+9)

    distance = {
        5, -- Whisper speech distance in gta distance units
        15, -- Normal speech distance in gta distance units
        40, -- Shout speech distance in gta distance units
    },
    headingType = 0, -- headingType 0 uses GetGameplayCamRot, basing heading on the camera's heading, to match how other GTA sounds work. headingType 1 uses GetEntityHeading which is based on the character's direction
    radioKey = 137, -- Keybind used to talk on the radio
    keySwitchChannels = 20, -- Keybind used to switch the radio channels
    keySwitchChannelsSecondary = 21, -- If set, both the keySwitchChannels and keySwitchChannelsSecondary keybinds must be pressed to switch the radio channels
    keyProximity = 47, -- Keybind used to switch the proximity mode
    radioClickMaxChannel = 99, -- Set the max amount of radio channels that will have local radio clicks enabled
    radioAnim = true, -- Enable or disable the radio animation
    radioEnabled = true, -- Enable or disable using the radio
    wsServer = "xxx.xxx.xxx.xxx:xxxxx", -- IPv4 and Port of your ws_server install

    plugin_data = {
        -- TeamSpeak channel name used by the voip
        -- If the TSChannelWait is enabled, players who are currently in TSChannelWait will be automatically moved
        -- to the TSChannel once everything is running
        TSChannel = "[TokoVoIP] In-Game",
        TSPassword = "", -- TeamSpeak channel password (can be empty)

        -- Optional: TeamSpeak waiting channel name, players wait in this channel and will be moved to the TSChannel automatically
        -- If the TSChannel is public and people can join directly, you can leave this empty and not use the auto-move
        TSChannelWait = "[TokoVoIP] Waiting Room", -- You NEED tokovoip in the wait channel name!

        -- Blocking screen informations
        TSServer = "ts.example.com", -- TeamSpeak server address to be displayed on blocking screen
        TSChannelSupport = "Support 1", -- TeamSpeak support channel name displayed on blocking screen
        TSDownload = "https://api.plactrix.net/tokovoip", -- Download link displayed on blocking screen
        TSChannelWhitelist = { -- Black screen will not be displayed when users are in those TS channels
            "Support 1",
            "Support 2",
        },

        -- The following is purely TS client settings, to match states
        local_click_on = true, -- Is local click on sound active
        local_click_off = true, -- Is local click off sound active
        remote_click_on = false, -- Is remote click on sound active
        remote_click_off = true, -- Is remote click off sound active
        enableStereoAudio = true, -- If set to true, positional audio will be stereo (you can hear people more on the left or the right around you)
        localName = "", -- If set, this name will be used as the user's teamspeak display name
    },

    channels = {
        {name = "Police RTO", subscribers = {}},
        {name = "Fire/EMS RTO", subscribers = {}},
        {name = "Shared Tac 1", subscribers = {}},
        {name = "Shared Tac 2", subscribers = {}},
        {name = "Shared Tac 3", subscribers = {}}
    }
}
