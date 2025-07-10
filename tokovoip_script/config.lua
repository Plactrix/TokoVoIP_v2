Config = {}

-- Refresh Rates
Config.refreshRate            = 100     -- Rate at which data is sent to the TSPlugin (ms)
Config.networkRefreshRate     = 2000    -- Rate to update/reset network data on local ped (ms)
Config.playerListRefreshRate  = 5000    -- Rate at which the player list is updated (ms)

-- Versioning & Debug
Config.minVersion             = "1.0.0" --  Minimum required TS plugin version
Config.minVersion             = "1.0.0" -- Required TS plugin version
Config.enableDebug            = false   -- Enable/disable TokoVoIP debug (Shift+9)
Config.update                 = true    -- Enable/disable version check

-- Voice Distances (in GTA distance units)
Config.distance = {
    2,  -- Whisper
    5,  -- Normal
    7,  -- Shouting
    -- 40, -- Uncomment for Theater Mode
}

-- Direction Handling
Config.headingType            = 0
-- 0 uses GetGameplayCamRot, basing heading on the camera's heading, to match how other GTA sounds work. headingType 1 uses GetEntityHeading which is based on the character's direction

-- Keybinds
Config.radioKey               = "CAPITAL" -- Talk on radio
Config.keySwitchChannels      = 20        -- Switch radio channels
Config.keySwitchChannelsSecondary = 21    -- Use with keySwitchChannels for dual-keypress, or set to 0 to disable
Config.keyProximity           = "G"       -- Switch proximity mode

-- Radio Settings
Config.radioClickMaxChannel   = 99     -- Max radio channels with local click sounds
Config.radioAnim              = true   -- Enable/disable radio animation
Config.radioEnabled           = true   -- Enable/disable radio usage

-- WebSocket Server

Config.wsServer               = "XxX.XxX.XxX.XxX:XXXXX" -- WS server IP and port (IPv6 IPs need to be formatted like this: [IPv6]:Port)
Config.displayWSInfo          = true   -- Show WebSocket info on blocking screen
Config.enableBlockingScreen   = true  -- Enable/disable black background blocking screen

-- TeamSpeak Plugin Data
Config.plugin_data = {
    -- TeamSpeak Channels
    TSChannel              = "[TokoVoIP] In-Game",     -- Main TS channel
    TSPassword             = "",                       -- TS channel password for the In-Game channel (Optional)
    TSChannelWait          = "[TokoVoIP] Waiting Room", -- Optional (only if you want a separate waiting room). You NEED TokoVoIP in the wait channel name!
    
    -- Blocking Screen Info
    TSServer               = "ts.example.com",         -- Displayed TS server address
    TSChannelSupport       = "Support 1",              -- Support channel shown on blocking screen
    TSDownload             = "https://api.plactrix.net/tokovoip", -- Plugin download link

    -- Channel Whitelist (no black screen)
    TSChannelWhitelist     = {
        "Support 1",
        "Support 2"
    },

    -- Audio Settings
    enableStereoAudio      = true,   -- Enable positional stereo audio
    localName              = ""      -- Custom TeamSpeak display name (optional)
}

-- Radio Communication Channels
Config.channels = {
    { name = "Police RTO",     subscribers = {} },
    { name = "Fire/EMS RTO",   subscribers = {} },
    { name = "Shared Tac 1",   subscribers = {} },
    { name = "Shared Tac 2",   subscribers = {} },
    { name = "Shared Tac 3",   subscribers = {} }
}
