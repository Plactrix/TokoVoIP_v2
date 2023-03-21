# Table of Contents
- [Original TokoVOIP](https://github.com/Itokoyamato/TokoVOIP_TS3)
- [Introduction to TokoVoIP v2](#introduction-to-tokovoip-v2)
- [TokoVoIP Installation](#tokovoip-installation)
  - [Setting up the TeamSpeak3 plugin](#setting-up-the-teamspeak3-plugin)
  - [Setting up ws-server and tokovoip_script](#setting-up-ws-server-and-tokovoip_script)
    - [Step 1: Setting up the ws-server script](#step-1-setting-up-the-ws-server-script)
    - [Step 2: Setting up tokovoip_script](#step-2-setting-up-tokovoip_script)
  - [Setting up ws-server as a standalone NodeJS application](#setting-up-ws-server-as-a-standalone-nodejs-application)
  - [Onesync Infinity](#onesync-infinity)
- [How exactly does TokoVoIP Work?](#how-exactly-does-tokovoip-work)
- [Framework Integration](#framework-integration)
  - [QBCore](#how-to-integrate-tokovoip-into-qb-hud)
- [Building the TS3 plugin](#building-the-ts3-plugin)
- [Packaging the TS3 plugin](#packaging-the-ts3-plugin)
- [Itokoyamato's Terms and Conditions](#itokoyamatos-terms-and-conditions)
- [Dependencies, sources and credits](#dependencies-sources-and-credits)


# Introduction to TokoVoIP V2
First things first, I would like to clarify <strong>I do not own the original code</strong> of TokoVoIP. I simply am just maintaining it so server owners can continue using it.\
\
TokoVoIP (originally developed by [Itokoyamato](https://github.com/Itokoyamato/TokoVOIP_TS3)) is a FiveM VoIP script that uses TeamSpeak as the voice server allowing for higher quality voice chat. After I saw the countless amount of people requesting the script to come back, I decided to continue development on the script and create a version 2 of it so that others can continue to use the script.

Here are some of the TokoVoIP V2 features:<br />
ㅤ• Higher Quality voice chat audio\
ㅤ• Phone Call and Radio Effects (With the integration of [RadioFX](https://www.myteamspeak.com/addons/f2e04859-d0db-489b-a781-19c2fab29def))\
ㅤ• Easy-to-Use TeamSpeak Plugin\
ㅤ• Proximity voice chat unique to each player\
ㅤ• Maintained Development Updates\
ㅤ• Highly Customisable\
ㅤ• Cleaner UI\
ㅤand much more!

Our To-Do List:<br />
- [ ] Add an option in the config to be able to move the "[TokoVoip]" text around (Top left, Top right, Bottom left, Bottom right, etc)
- [ ] Create an external program so you can connect to toko's radio frequencies (Useful for several things such as dispatchers)
- [ ] Completely recode the TS3 Plugin to use more modern modules
- [ ] Rewrite ws_server with updated dependencies
- [ ] Add a way for users with an ace permission to mute specific people with a command
- [ ] Add an export to enable/disable a player from talking (useful for servers who don't allow talking whilst being dead)
- [ ] Allow radio channels to have x.xx channels instead of whole number channels
- [ ] Recode NUI in react (because why not lol)
- [ ] Add voice echo effects if your in a big room for example
- [ ] Remove all vulnerable events
- [ ] Rework all README's and add an in-depth document page for installation and FAQ

Our Known-Bugs List:<br />
• ws_server has outdated modules and may not install correctly for some users. We will be recoding this completely to solve this and to enhance performance and optimization.

If you require any assistance with installation, bugs, or anything at all, feel free to create an issue on github or join our Discord server ([discord.gg/DEQ95eVmQ3](https://discord.gg/DEQ95eVmQ3))

If you like TokoVoIP, feel free to leave the original creator a donation ([Itokoyamato](https://github.com/Itokoyamato/TokoVOIP_TS3)):<br/><br/>
[![Patreon](https://img.shields.io/badge/Become%20a-patron-orange)](https://www.patreon.com/Itokoyamato)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=H2UXEZBF5KQBL&source=url)  

# TokoVoIP Installation
Firstly, you will need to head over to the [Releases](https://github.com/Plactrix/TokoVoIP_v2/releases) page and download ws-server, tokovoip_script and the matching tokovoip-x.x.x.ts3_plugin file.

## Setting up the TeamSpeak3 plugin
Every player must install Teamspeak 3 and the TokoVoIP plugin for the script to work correctly
* Download and Install the appropriate version of the plugin from the [Releases](https://github.com/Plactrix/TokoVoIP_v2/releases) page
* Connect to the FiveM server
* Launch TeamSpeak3 and connect to the server
* Join the TeamSpeak3 channel that was set in the fivem script configuration

The TeamSpeak3 Plugin will connect and move you if you are In-Game. If you are not In-Game, you will not be moved or connected\
The TeamSpeak3 Plugin will try to connect automatically if you join a TeamSpeak channel containing 'TokoVoIP' in it's name\
If you are not automatically connected, you can use the buttons in `Plugins -> TokoVoip` to manually connect/disconnect the TeamSpeak3 Plugin  

## Setting up ws-server and tokovoip_script

### Step 1: Setting up the ws-server script
  * Download ws-server from the [Releases](https://github.com/Plactrix/TokoVoIP_v2/releases) page
  * Extract it in your fivem resources folder
  * Open [ws_server/config.js](https://github.com/Plactrix/TokoVoIP_v2/blob/master/ws_server/config.js)
  * Change "`TSServer`" to your Teamspeak server IPv4 address
  * start `ws_server` in your fivem server console
  * Copy the `IP:PORT` in the console after `Listening on` and save it for [**Step 2: Setting up the fivem-script**](#step-2-setting-up-the-fivem-script)

### Step 2: Setting up tokovoip_script
  * Download tokovoip_script from the [Releases](https://github.com/Plactrix/TokoVoIP_v2/releases) page
  * Extract it in your fivem resources folder
  * Open [tokovoip_script/config.lua](https://github.com/Plactrix/TokoVoIP_v2/blob/master/fivem_script/tokovoip_script/config.lua)
    * Edit `wsServer` with the `IP:PORT` you copied from the ws-server console in [**Step 1: Setting up the ws-server**](#step-1-setting-up-the-ws-server)
    * Edit the `TSChannel` to match your Teamspeak configuration
    * Edit other settings to your preferences
  * Add `TokoVoIP` to your waiting channel name on your teamspeak server, it is [**case insensitive**](https://www.yourdictionary.com/case-insensitive)

## Setting up ws-server as a standalone NodeJS application
ws-server can be setup as a standalone NodeJS application if required. You may run it on the same machine as your FiveM server, or you may decide to run it on a seperate machine. Both will work just fine.
  * Download the latest version of [Node.js](https://nodejs.org/en/)
  * Open [config.js](https://github.com/Plactrix/TokoVoIP_v2/blob/master/ws_server/config.js)
    * Change "`TSServer`" to your Teamspeak server `IPv4`
    * If the ws-server is hosted on a separate machine:  
  * Open ws-server folder in cmd / terminal
  * Execute `npm i`
  * After its done run `node index.js`  
  A module such as `systemd`, `pm2` or `screen` can be used to run the ws-server application in the background

## Onesync Infinity
Onesync infinity is supported with all TokoVoIP V2 versions
One thing to keep in mind, Teamspeak servers by default silence everyone when more than 100 users are in a channel  
If your server has more then 100 slots, make sure your teamspeak server is configured properly:
* Right click your teamspeak server
* Press `Edit Virtual Server`
* Press `more`
* Open tab `Misc`
* Change the value of `Min clients in channel before silence`  

# How exactly does TokoVoIP Work?
The system is mainly based on websockets
In-game data is sent through websockets to the TS3 plugin
FiveM blocks websockets running on the local network, which is why we must use a remote websocket server (in this case, ws-server)

TS3 has no way to know on which fivem server you are currently on locally, a handshake system is required  
A master server is used to register handshakes  
That is it's only purpose, everything else is run on your own self-hosted ws-server and tokovoip_script

* Phase 1 - Handshake:
  * tokovoip_script -> ws-server -> register for handshake (master server)
  * ts3-plugin -> look for handshake (master server) -> ws-server

Once the fivem websocket & ts3 websocket successfully handshaked, the master server is not used anymore

* Phase 2 - Communicate:
  * tokovoip_script -> ws-server -> ts3-plugin
  * tokovoip_script <- ws-server <- ts3-plugin

**Ts3 websocket keeps saying Not connected**:
- Make sure your **waiting** channel has `TokoVoIP` in the name
- FiveM and TeamSpeak3 didn't successfuly handshake
- Make sure your websocket has proper teamspeak, fivem and ws ip
- Try manually using the connect button in **Plugins -> TokoVoIP -> Connect**

**Could not find dependency yarn for resource ws_server**:
- Install yarn resource from [cfx-server-data repo](https://github.com/citizenfx/cfx-server-data/tree/master/resources/%5Bsystem%5D/%5Bbuilders%5D)

## Framework Integration
### How to Integrate TokoVoIP Into qb-hud:
Simply replace the lines in the `client.lua` with the ones provided below:\
\
Change This line: `local talking = NetworkIsPlayerTalking(playerId)` (Roughly line 719)\
With this: `local talking = exports["tokovoip_script"]:getPlayerData(GetPlayerServerId(PlayerId()), "voip:talking") or 0`
\
\
Change This line: `voice = LocalPlayer.state['proximity'].distance` (Roughly line 722)\
With this: `voice = exports["tokovoip_script"]:getPlayerData(GetPlayerServerId(PlayerId()), "voip:mode") or 0`
\
\
Change Both of these lines: `LocalPlayer.state['radioChannel']` (Roughy lines 746 and 790)\
With this: `exports["tokovoip_script"]:getPlayerData(GetPlayerServerId(PlayerId()), "radio:channel")`
\
\
\
Alternatively you may use my forked [qb-hud](https://github.com/Plactrix/qb-hud-tokovoip) version, but it may be outdated from the original

## Building the TS3 plugin

You will need the following installed:
- [Visual Studio (Any version *should* work, I use v15 2017)](https://visualstudio.microsoft.com/vs/)
- [Qt 5.12.7](https://download.qt.io/archive/qt/5.12/5.12.7/)
- [CMake](https://cmake.org/)

Clone the repo and don't forget to initialize the submodules:
```
git submodule update --init --recursive
```

Then move to the `ts3_plugin` folder, and generate the Visual Studio solution: (set the correct path to Qt)
```
mkdir build32
cd build32
cmake -G "Visual Studio 15 2017" -DCMAKE_PREFIX_PATH="<PATH_TO>/Qt/5.12.7/msvc2017" ..
cd ..
mkdir build64
cd build64
cmake -G "Visual Studio 15 2017 Win64"  -DCMAKE_PREFIX_PATH="<PATH_TO>/Qt/5.12.7/msvc2017_64" ..
```

The visual studio solutions are available in their platform specific folders.
You're ready to go !

## Packaging the TS3 plugin

Making a TS3 plugin package is very easy, you can use the template in `ts3_package` if you want.
You will need:
- `package.ini` file which gives some info about the plugin
- `.dll` files in a `plugin` folder

The `.dll` should have a suffix `_win32` or `_win64` matching their target platforms.

Then, archive the whole thing as a `.zip` file, and rename it to `.ts3_plugin`.

It's that simple.

Archive tree example:
```
.
+-- package.ini
+-- plugins
|   +-- tokovoip
|       +-- walkie_talkie16.png
|       +-- mic_click_off.wav
|       +-- mic_click_on.wav
|   +-- plugin_win32.dll
|   +-- plugin_win64.dll
```

# Itokoyamato's Terms and Conditions

A 'TokoVOIP' watermark must be visible on screen. You can move it, change it's design however you like.  
Just keep one somewhere. Thanks  
For the rest, refer to the [license](https://github.com/Itokoyamato/TokoVOIP_TS3/blob/master/LICENSE.md)

# Dependencies, sources and credits

- [Original TokoVoIP Developer](Itokoyamatohttps://github.com/Itokoyamato/TokoVOIP_TS3) ([Itokoyamato](https://github.com/Itokoyamato/TokoVOIP_TS3))
- [RadioFX](https://github.com/thorwe/teamspeak-plugin-radiofx) by Thorwe
- [Simple-WebSocket-Server](https://gitlab.com/eidheim/Simple-WebSocket-Server) by eidheim
- [JSON for Modern C++](https://github.com/nlohmann/json.git) by nlohmann
- [cpp-httplib](https://github.com/yhirose/cpp-httplib) by yhirose
- [Task Force Arma 3 Radio](https://github.com/michail-nikolaev/task-force-arma-3-radio) by michail-nikolaev
