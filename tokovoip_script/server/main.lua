--[[ 
   _____     _      __     __   ___ ____   __     ______      
  |_   _|__ | | ____\ \   / /__|_ _|  _ \  \ \   / /___ \     
	| |/ _ \| |/ / _ \ \ / / _ \| || |_) |  \ \ / /  __) |    
    | | (_) |   < (_) \ V / (_) | ||  __/    \ V /  / __/     
	|_|\___/|_|\_\___/ \_/ \___/___|_|        \_/  |_____|    
													
	   By Itokoyamato, Plactrix, Neon and PinguinPocalypse                        
	______________________________________________________
]]

-- Defining Things
local playersData = {}
local channels = Config.channels

math.randomseed(os.time())

function randomString(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, length do
        local randIndex = math.random(1, #charset)
        result[i] = charset:sub(randIndex, randIndex)
    end
    return table.concat(result)
end

local serverId = randomString(32)

SetConvarReplicated("gametype", GetConvar("GameName", "gta5"))

-- Events
RegisterNetEvent("Tokovoip:setPlayerData")
AddEventHandler("Tokovoip:setPlayerData", function(playerServerId, key, data, shared)
	if shared then
		if not playersData[playerServerId] then
			playersData[playerServerId] = {}
		end
		playersData[playerServerId][key] = data
		TriggerClientEvent("Tokovoip:setPlayerData", -1, playerServerId, key, data)
	else
		TriggerClientEvent("Tokovoip:setPlayerData", playerServerId, playerServerId, key, data)
	end
end)

RegisterNetEvent("Tokovoip:refreshAllPlayerData")
AddEventHandler("Tokovoip:refreshAllPlayerData", function(toEveryone)
	if toEveryone then
		TriggerClientEvent("Tokovoip:doRefreshAllPlayerData", -1, playersData)
	else
		TriggerClientEvent("Tokovoip:doRefreshAllPlayerData", source, playersData)
	end
end)

RegisterServerEvent("TokoVoip:addPlayerToRadio")
AddEventHandler("TokoVoip:addPlayerToRadio", function(channelId, playerServerId, radio)
	if not channels[channelId] then
		if radio then
			channels[channelId] = {id = channelId, name = channelId .. " Mhz", subscribers = {}}
		else
			channels[channelId] = {id = channelId, name = "Call with " .. channelId, subscribers = {}}
		end
	end
	if not channels[channelId].id then
		channels[channelId].id = channelId
	end

	channels[channelId].subscribers[playerServerId] = playerServerId
	if enableDebug then
		print("Added [" .. playerServerId .. "] " .. (GetPlayerName(playerServerId) or "") .. " to channel " .. channelId)
	end

	for _, subscriberServerId in pairs(channels[channelId].subscribers) do
		if subscriberServerId ~= playerServerId then
			TriggerClientEvent("TokoVoip:onPlayerJoinChannel", subscriberServerId, channelId, playerServerId)
		else
			-- Send whole channel data to new subscriber
			TriggerClientEvent("TokoVoip:onPlayerJoinChannel", subscriberServerId, channelId, playerServerId, channels[channelId])
		end
	end
end)

RegisterServerEvent("TokoVoip:MicClicks:Sync")
AddEventHandler("TokoVoip:MicClicks:Sync", function(channelId)
	TriggerClientEvent("TokoVoip:MicClicks:SyncCL", -1, channelId)
end)

RegisterServerEvent("TokoVoip:removePlayerFromRadio")
AddEventHandler("TokoVoip:removePlayerFromRadio", function(channelId, playerServerId)
	if channels[channelId] and channels[channelId].subscribers[playerServerId] then
		channels[channelId].subscribers[playerServerId] = nil
		if channelId > 100 then
			if tablelength(channels[channelId].subscribers) == 0 then
				channels[channelId] = nil
			end
		end
		if enableDebug then
			print("Removed [" .. playerServerId .. "] " .. (GetPlayerName(playerServerId) or "") .. " from channel " .. channelId)
		end

		-- Tell unsubscribed player he's left the channel as well
		TriggerClientEvent("TokoVoip:onPlayerLeaveChannel", playerServerId, channelId, playerServerId)

		-- Channel does not exist, no need to update anyone else
		if not channels[channelId] then
			return
		end

		for _, subscriberServerId in pairs(channels[channelId].subscribers) do
			TriggerClientEvent("TokoVoip:onPlayerLeaveChannel", subscriberServerId, channelId, playerServerId)
		end
	end
end)

RegisterServerEvent("TokoVoip:removePlayerFromAllRadio")
AddEventHandler("TokoVoip:removePlayerFromAllRadio", function(playerServerId)
	for channelId, channel in pairs(channels) do
		if channel.subscribers[playerServerId] then
			TriggerEvent("TokoVoip:removePlayerFromRadio", channelId, playerServerId)
		end
	end
end)

RegisterServerEvent("TokoVoip:getServerId")
AddEventHandler("TokoVoip:getServerId", function()
	TriggerClientEvent("TokoVoip:onClientGetServerId", source, serverId)
end)

-- Add Event Handlers
AddEventHandler("playerJoined", function()
	local src = source
	updateRoutingBucket(src, 0)
end)

AddEventHandler("playerDropped", function()
	TriggerEvent("TokoVoip:removePlayerFromAllRadio", source)
	playersData[source] = nil
	TriggerEvent("Tokovoip:refreshAllPlayerData", true)
end)

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then return end

	for index, player in pairs(GetPlayers()) do
		updateRoutingBucket(player, 0)
	end

    local header = [[
^5╔══════════════════════════════════════════════════════════════╗
^5║ ^1TokoVoIP ^7by ^3Itokoyamato^7, ^4Neon^7, ^1Plactrix and ^9PinguinPocalypse ^5║
^5╚══════════════════════════════════════════════════════════════╝ ]]

	local info = [[
^5╔═══════════════════════════════════════════╗
^5║ %s
^5║ %s
^5╚═══════════════════════════════════════════╝ ]]

	local wsText  = "^7 Checking WebSocket connection...         ^5║"
	local ready   = "^7 Initializing...                          ^5║"
	
	print(info:format(wsText, ready))
    
	local wsCheckDone = false
    PerformHttpRequest(Config.wsServer, function(code)
        if code == 200 then
            wsText = "^2 Connected to WebSocket Server.           ^5║"
        else
            wsText = "^1 Failed to connect to WebSocket Server.   ^5║"
        end
        wsCheckDone = true
    end, "GET")
	
	while not wsCheckDone do Wait(10) end

    if wsText:find("Connected") then
        ready = "^2 TokoVoIP is ready to use.                ^5║"
    else
        ready = "^1 TokoVoIP cannot be used.                 ^5║"
    end

    Wait(250) -- slight delay for nicer output
    print(header)
    print(info:format(wsText, ready))
end)

-- Functions
function getPlayersInRadioChannel(channel)
	return channels[channel].subscribers
end

-- Exports
exports("getPlayersInRadioChannel", getPlayersInRadioChannel)