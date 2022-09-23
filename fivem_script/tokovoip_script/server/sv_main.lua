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
	TriggerEvent("TokoVoip:removePlayerFromAllRadio", source)
	playersData[source] = nil
	TriggerEvent("Tokovoip:refreshAllPlayerData", true)
end)

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end

	local vText = nil
	local wsText = nil
	local ReadyToUseText = nil
	local base = [[
   ^5_____________________________________________________________
  ^5| ^8 _____     _      __     __   ___ ____   __     ______      ^5|
  ^5| ^8|_   _|__ | | ____\ \   / /__|_ _|  _ \  \ \   / /___ \     ^5|
  ^5|   ^8| |/ _ \| |/ / _ \ \ / / _ \| || |_) |  \ \ / /  __) |    ^5|
  ^5|   ^8| | (_) |   < (_) \ V / (_) | ||  __/    \ V /  / __/     ^5|
  ^5|   ^8|_|\___/|_|\_\___/ \_/ \___/___|_|        \_/  |_____|    ^5|
  ^5|                                                             ^5|
  ^5|   ^7By ^3Itokoyamato^7, ^1Plactrix ^7and ^4Neon                         ^5|
  ^5|_____________________________________________________________^5|
    ]]
	local info = [[
   ^5_____________________________________________________________
  ^5| ^1TokoVoIP V2^7: Starting up                                    ^5|
	 %s
	 %s
	 %s
	 ^5|_____________________________________________________________|^7    
	]]

	Wait(1000)

	PerformHttpRequest("https://raw.githubusercontent.com/Plactrix/versions/main/tokovoip.json", function(code, res, _)
		if code == 200 then
			local data = json.decode(res)
            if data["version"] ~= GetResourceMetadata(GetCurrentResourceName(), "version") then
				vText = "^5| ^7- ^1TokoVoIP is outdated! Version " .. data["version"] .. " is now available.     ^5|"
			elseif data["version"] == GetResourceMetadata(GetCurrentResourceName(), "version") then
				vText = "^5| ^7- TokoVoIP is ^2up-to-date^7!                                   ^5|"
			end
		end
	end, "GET")

	PerformHttpRequest(Config.wsServer, function(code, _, _)
		if code == 200 then
			wsText = "^5| ^7- ^2Connected ^7to WebSocket Server!                            ^5|"
		else
			wsText = "^5| ^7- ^1Unable to connect to WebSocket Server!                    ^5|"
		end
	end, "GET")

	while vText == nil do
		Wait(5)
	end

	while wsText == nil do
		Wait(5)
	end

	if not string.find(wsText, "Unable") then
		ReadyToUseText = "^5| ^7- ^2TokoVoIP is ready for use!                                ^5|"
	else
		ReadyToUseText = "^5| ^7- ^1TokoVoIP is NOT ready for use                             ^5|"
	end

	print(base)
	print(info:format(vText, wsText, ReadyToUseText))
end)
