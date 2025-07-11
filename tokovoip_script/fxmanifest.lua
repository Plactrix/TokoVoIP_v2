fx_version 'cerulean'
games {'gta5', 'rdr3'}

author 'Itokoyamato, Plactrix & Neon'
description 'TokoVoIP: A simple FiveM VoIP script that uses TeamSpeak as the voice server'
version '2.5.0'
lua54 'yes'

files {
    'html/sounds/*.wav',
    'html/index.html',
    'html/script.js'
}

ui_page 'html/index.html'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/utils.lua'
}

server_scripts {
    'server/main.lua',
    'server/update.lua',
    'server/utils.lua'
}

provides {
    'mumble-voip',
    'pma-voice'
}

-- Exports
server_export 'getPlayersInRadioChannel'
server_export 'updateRoutingBucket'

export 'addPlayerToRadio'
export 'removePlayerFromRadio'
export 'removePlayerFromCall'
export 'isPlayerInChannel'
export 'getPlayerChannels'
export 'setRadioVolume'
export 'setCallVolume'
export 'setCallChannel'
export 'setRadioChannel'
export 'addPlayerToCall'
export 'getPlayerData'
export 'setPlayerData'
export 'refreshAllPlayerData'
export 'SetTokoProperty'