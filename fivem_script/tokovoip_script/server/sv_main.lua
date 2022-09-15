-- Defining Things
local playersData = {}
local channels = Config.channels
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
	print("Added [" .. playerServerId .. "] " .. (GetPlayerName(playerServerId) or "") .. " to channel " .. channelId)

	for _, subscriberServerId in pairs(channels[channelId].subscribers) do
		if subscriberServerId ~= playerServerId then
			TriggerClientEvent("TokoVoip:onPlayerJoinChannel", subscriberServerId, channelId, playerServerId)
		else
			-- Send whole channel data to new subscriber
			TriggerClientEvent("TokoVoip:onPlayerJoinChannel", subscriberServerId, channelId, playerServerId, channels[channelId])
		end
	end
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
		print("Removed [" .. playerServerId .. "] " .. (GetPlayerName(playerServerId) or "") .. " from channel " .. channelId)

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
			removePlayerFromRadio(channelId, playerServerId)
		end
	end
end)

RegisterServerEvent("TokoVoip:getServerId")
AddEventHandler("TokoVoip:getServerId", function()
	TriggerClientEvent("TokoVoip:onClientGetServerId", source, serverId)
end)

-- Add Event Handlers
AddEventHandler("playerDropped", function()
	removePlayerFromAllRadio(source)
	playersData[source] = nil
	TriggerEvent("Tokovoip:refreshAllPlayerData", true)
end)

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
    print([[
   ^5_____________________________________________________________
  ^5| ^8 _____     _      __     __   ___ ____   __     ______      ^5|
  ^5| ^8|_   _|__ | | ____\ \   / /__|_ _|  _ \  \ \   / /___ \     ^5|
  ^5|   ^8| |/ _ \| |/ / _ \ \ / / _ \| || |_) |  \ \ / /  __) |    ^5|
  ^5|   ^8| | (_) |   < (_) \ V / (_) | ||  __/    \ V /  / __/     ^5|
  ^5|   ^8|_|\___/|_|\_\___/ \_/ \___/___|_|        \_/  |_____|    ^5|
  ^5|                                                             ^5|
  ^5|   ^7By ^3Itokoyamato^7, ^1Plactrix ^7and ^4Neon                         ^5|
  ^5|_____________________________________________________________^5|
  ^5| TokoVoIP V2: Starting up                                    |
	 ^5| - Successfully connected to TS                              |
	 ^5| - Connected to Websocket Server                             |
	 ^5| - TokoVoIP is ready for use!                                |
	 ^5|_____________________________________________________________|^7
    ]])
end)
