fx_version "bodacious"
games { "gta5", "rdr3" }
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

author "Itokoyamato, Plactrix & Neon"
description "TokoVoIP V2: A simple FiveM VoIP script that uses TeamSpeak as the voice server"
version "2.0.3"
lua54 "yes"

files {
	"html/sounds/*.wav",
	"html/index.html",
	"html/script.js"
}

ui_page "html/index.html"

provide {
	"mumble-voip",
	"pma-voice"
}

shared_scripts {
    "config.lua"
}

client_scripts {
    "client/cl_utils.lua",
    "client/cl_main.lua"
}

server_scripts {
    "server/sv_utils.lua",
    "server/sv_main.lua"
}
