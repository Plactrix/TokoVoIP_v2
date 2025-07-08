fx_version 'cerulean'
games {'gta5', 'rdr3'}

author 'Itokoyamato, Plactrix & Neon'
description 'TokoVoIP V2: A simple FiveM VoIP script that uses TeamSpeak as the voice server'
version '2.5.0' -- FUTURE
lua54 'yes'

files {
    'html/sounds/*.wav',
    'html/index.html',
    'html/script.js',
    'config.js'
}

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    -- '@ox_lib/init.lua'
}

client_scripts {
    'client/cl_utils.lua',
    'client/cl_main.lua'
}

server_scripts {
    'server/sv_utils.lua',
    'server/sv_main.lua',
    'server/update.lua',
    'server/ws/index.js'
}

provides {
    'mumble-voip',
    'pma-voice'
}

dependencies {
    -- 'ox_lib',
    'yarn',
    '/server:12913'
}