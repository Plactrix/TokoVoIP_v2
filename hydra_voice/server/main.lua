------------------------------------------------------------
--  _   _           _            __     __    _           --
-- | | | |_   _  __| |_ __ __ _  \ \   / /__ (_) ___ ___  --
-- | |_| | | | |/ _` | '__/ _` |  \ \ / / _ \| |/ __/ _ \ --
-- |  _  | |_| | (_| | | | (_| |   \ V / (_) | | (_|  __/ --
-- |_| |_|\__, |\__,_|_|  \__,_|    \_/ \___/|_|\___\___| --
--        |___/                                           --
------------------------------------------------------------

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
RegisterNetEvent("hydravoice:setPlayerData")
AddEventHandler("hydravoice:setPlayerData", function(playerServerId, key, data, shared)
	if shared then
		if not playersData[playerServerId] then
			playersData[playerServerId] = {}
		end
		playersData[playerServerId][key] = data
		TriggerClientEvent("hydravoice:setPlayerData", -1, playerServerId, key, data)
	else
		TriggerClientEvent("hydravoice:setPlayerData", playerServerId, playerServerId, key, data)
	end
end)

RegisterNetEvent("hydravoice:refreshAllPlayerData")
AddEventHandler("hydravoice:refreshAllPlayerData", function(toEveryone)
	if toEveryone then
		TriggerClientEvent("hydravoice:doRefreshAllPlayerData", -1, playersData)
	else
		TriggerClientEvent("hydravoice:doRefreshAllPlayerData", source, playersData)
	end
end)

RegisterServerEvent("hydravoice:addPlayerToRadio")
AddEventHandler("hydravoice:addPlayerToRadio", function(channelId, playerServerId, radio)
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
			TriggerClientEvent("hydravoice:onPlayerJoinChannel", subscriberServerId, channelId, playerServerId)
		else
			-- Send whole channel data to new subscriber
			TriggerClientEvent("hydravoice:onPlayerJoinChannel", subscriberServerId, channelId, playerServerId, channels[channelId])
		end
	end
end)

RegisterServerEvent("hydravoice:MicClicks:Sync")
AddEventHandler("hydravoice:MicClicks:Sync", function(channelId)
	TriggerClientEvent("hydravoice:MicClicks:SyncCL", -1, channelId)
end)

RegisterServerEvent("hydravoice:removePlayerFromRadio")
AddEventHandler("hydravoice:removePlayerFromRadio", function(channelId, playerServerId)
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
		TriggerClientEvent("hydravoice:onPlayerLeaveChannel", playerServerId, channelId, playerServerId)

		-- Channel does not exist, no need to update anyone else
		if not channels[channelId] then
			return
		end

		for _, subscriberServerId in pairs(channels[channelId].subscribers) do
			TriggerClientEvent("hydravoice:onPlayerLeaveChannel", subscriberServerId, channelId, playerServerId)
		end
	end
end)

RegisterServerEvent("hydravoice:removePlayerFromAllRadio")
AddEventHandler("hydravoice:removePlayerFromAllRadio", function(playerServerId)
	for channelId, channel in pairs(channels) do
		if channel.subscribers[playerServerId] then
			TriggerEvent("hydravoice:removePlayerFromRadio", channelId, playerServerId)
		end
	end
end)

RegisterServerEvent("hydravoice:getServerId")
AddEventHandler("hydravoice:getServerId", function()
	TriggerClientEvent("hydravoice:onClientGetServerId", source, serverId)
end)

-- Add Event Handlers
AddEventHandler("playerJoined", function()
	local src = source
	updateRoutingBucket(src, 0)
end)

AddEventHandler("playerDropped", function()
	TriggerEvent("hydravoice:removePlayerFromAllRadio", source)
	playersData[source] = nil
	TriggerEvent("hydravoice:refreshAllPlayerData", true)
end)

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then return end

	for index, player in pairs(GetPlayers()) do
		updateRoutingBucket(player, 0)
	end

    local header = [[
^5╔══════════════════════════════════════════════════════════════╗
^5║ ^1hydravoice ^7by ^3Itokoyamato^7, ^4Neon^7, ^1Plactrix and ^9PinguinPocalypse ^5║
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
        ready = "^2 hydravoice is ready to use.                ^5║"
    else
        ready = "^1 hydravoice cannot be used.                 ^5║"
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