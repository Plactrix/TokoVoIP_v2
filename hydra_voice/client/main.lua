------------------------------------------------------------
--  _   _           _            __     __    _           --
-- | | | |_   _  __| |_ __ __ _  \ \   / /__ (_) ___ ___  --
-- | |_| | | | |/ _` | '__/ _` |  \ \ / / _ \| |/ __/ _ \ --
-- |  _  | |_| | (_| | | | (_| |   \ V / (_) | | (_|  __/ --
-- |_| |_|\__, |\__,_|_|  \__,_|    \_/ \___/|_|\___\___| --
--        |___/                                           --
------------------------------------------------------------

-- Defining Things
local targetPed
local useLocalPed = true
local isRunning = false
local animStates = {}
local displayingPluginScreen = false
local HeadBone = 0x796e
local radioVolume = 0
local nuiLoaded = false
local CurrentID
voip = voip or {}

-- Commands
RegisterCommand("hydravoice:latency", function()
	SendNUIMessage({
		type = "toggleLatency"
	})
end)

-- Events
RegisterNetEvent('initializeVoip', function()
	Wait(1000)
	if isRunning then
		return Citizen.Trace("hydra_voice is already running\n")
	end
	isRunning = true

	while not hydravoice do
		Wait(5)
	end

	voip = hydravoice:init(Config)
	voip.plugin_data.Users = {}
	voip.plugin_data.radioTalking = false
	voip.plugin_data.radioChannel = 0
	voip.plugin_data.localRadioClicks = false
	voip.mode = 2
	voip.talking = false
	voip.pluginStatus = -1
	voip.pluginVersion = "0"
	voip.routingBucket = 0
	CurrentID = GetPlayerServerId(PlayerId())
	voip.myChannels = {}
	setPlayerData(CurrentID, "voip:mode", voip.mode, true)
	setPlayerData(CurrentID, "voip:talking", voip.talking, true)
	setPlayerData(CurrentID, "radio:channel", voip.plugin_data.radioChannel, true)
	setPlayerData(CurrentID, "radio:talking", voip.plugin_data.radioTalking, true)
	setPlayerData(CurrentID, "voip:pluginStatus", voip.pluginStatus, true)
	setPlayerData(CurrentID, "voip:pluginVersion", voip.pluginVersion, true)
	setPlayerData(CurrentID, "voip:routingBucket", voip.routingBucket, true)
	refreshAllPlayerData()
	targetPed = PlayerPedId()

	if GetConvar("gametype") == "gta5" then
		RequestAnimDict("mp_facial")
		RequestAnimDict("facials@gen_male@base")
	elseif GetConvar("gametype") == "rdr3" then
		RequestAnimDict("face_human@gen_male@base")
	end

	if voip.config.enableDebug then
		local debugData = false
		CreateThread(function()
			while true do
				Wait(5)
				if IsControlPressed(0, Keys["LEFTSHIFT"]) then
					if IsControlJustPressed(1, Keys["9"]) or IsDisabledControlJustPressed(1, Keys["9"]) then
						debugData = not debugData
					end
				end
				if debugData then
					local pos_y
					local pos_x
					local players = GetActivePlayers()

					for i = 1, #players do
						local player = players[i]
						local playerServerId = GetPlayerServerId(players[i])

						pos_y = 1.1 + (math.ceil(i/12) * 0.1)
						pos_x = 0.60 + ((i - (12 * math.floor(i/12)))/15)

						drawTxt(pos_x, pos_y, 1.0, 1.0, 0.2, "[" .. playerServerId .. "] " .. GetPlayerName(player) .. "\nMode: " .. tostring(getPlayerData(playerServerId, "voip:mode")) .. "\nChannel: " .. tostring(getPlayerData(playerServerId, "radio:channel")) .. "\nRadioTalking: " .. tostring(getPlayerData(playerServerId, "radio:talking")) .. "\npluginStatus: " .. tostring(getPlayerData(playerServerId, "voip:pluginStatus")) .. "\npluginVersion: " .. tostring(getPlayerData(playerServerId, "voip:pluginVersion")) .. "\nTalking: " .. tostring(getPlayerData(playerServerId, "voip:talking")), 255, 255, 255, 255)
					end
					local i = 0
					for channelIndex, channel in pairs(voip.myChannels) do
						i = i + 1
						drawTxt(0.8 + i/12, 0.5, 1.0, 1.0, 0.2, channel.name .. "(" .. channelIndex .. ")", 255, 255, 255, 255)
						local j = 0
						for _, player in pairs(channel.subscribers) do
							j = j + 1
							drawTxt(0.8 + i/12, 0.5 + j/60, 1.0, 1.0, 0.2, player, 255, 255, 255, 255)
						end
					end
				end
			end
		end)
	end
end)

RegisterNetEvent("hydravoice:onPlayerLeaveChannel", function(channelId, playerServerId)
	if playerServerId == CurrentID and voip.myChannels[channelId] then
		local previousChannel = voip.plugin_data.radioChannel
		voip.myChannels[channelId] = nil
		if voip.plugin_data.radioChannel == channelId then
			if tablelength(voip.myChannels) > 0 then
				for channelId, _ in pairs(voip.myChannels) do
					voip.plugin_data.radioChannel = channelId
					break
				end
			else
				voip.plugin_data.radioChannel = 0
			end
		end

		if previousChannel ~= voip.plugin_data.radioChannel then
			setPlayerData(CurrentID, "radio:channel", voip.plugin_data.radioChannel, true)
		end
	elseif (voip.myChannels[channelId]) then
		voip.myChannels[channelId].subscribers[playerServerId] = nil
	end
end)

RegisterNetEvent("hydravoice:onPlayerJoinChannel", function(channelId, playerServerId, channelData)
	if playerServerId == CurrentID and channelData then
		local previousChannel = voip.plugin_data.radioChannel

		voip.plugin_data.radioChannel = channelData.id
		voip.myChannels[channelData.id] = channelData

		if previousChannel ~= voip.plugin_data.radioChannel then
			setPlayerData(CurrentID, "radio:channel", voip.plugin_data.radioChannel, true)
		end
	elseif voip.myChannels[channelId] then
		voip.myChannels[channelId].subscribers[playerServerId] = playerServerId
	end
end)

RegisterNetEvent("hydravoice:setRadioVolume", setRadioVolume)

RegisterNetEvent("hydravoice:updateRoutingBucket", function(routingBucket)
	voip.routingBucket = routingBucket
	setPlayerData(CurrentID, "voip:routingBucket", voip.routingBucket, true)
end)

-- Add Event Handlers
AddEventHandler("updateVoipTargetPed", function(newTargetPed, useLocal)
	targetPed = newTargetPed
	useLocalPed = useLocal
end)

-- NUI Callbacks
RegisterNUICallback("updatePluginData", function(data, cb)
	local payload = data.payload
	if voip[payload.key] == payload.data then
		return
	end
	voip[payload.key] = payload.data
	setPlayerData(CurrentID, "voip:" .. payload.key, voip[payload.key], true)
	voip:updateConfig()
	voip:updatehydravoiceInfo(true)
	cb('ok')
end)

RegisterNUICallback("setPlayerTalking", function(data, cb)
	voip.talking = tonumber(data.state)

	if voip.talking == 1 then
		setPlayerData(CurrentID, "voip:talking", 1, true)
		if GetConvar("gametype") == "gta5" then
			PlayFacialAnim(GetPlayerPed(PlayerId()), "mic_chatter", "mp_facial")
		elseif GetConvar("gametype") == "rdr3" then
			PlayRedMFacialAnimation(GetPlayerPed(PlayerId()), "face_human@gen_male@base", "mood_talking_normal")
		end
	else
		setPlayerData(CurrentID, "voip:talking", 0, true)
		if GetConvar("gametype") == "gta5" then
			PlayFacialAnim(PlayerPedId(), "mood_normal_1", "facials@gen_male@base")
		elseif GetConvar("gametype") == "rdr3" then
			PlayRedMFacialAnimation(PlayerPedId(), "face_human@gen_male@base", "mood_normal")
		end
	end
	cb('ok')
end)

RegisterNUICallback("nuiLoaded", function(data, cb)
	nuiLoaded = true
	cb("ok")
end)

-- Threads
CreateThread(function()
	local function handler(serverId)
		response = serverId or "N/A"
	end

	RegisterNetEvent("hydravoice:onClientGetServerId", handler)

	TriggerServerEvent("hydravoice:getServerId")
        
	while not response do
		Wait(5)
	end
 
	while not voip do
		Wait(5)
	end

	voip.fivemServerId = response
	Citizen.Trace("hydravoice: FiveM Server ID is " .. voip.fivemServerId .. "\n")
	voip.processFunction = clientProcessing -- Link the processing function that will be looped
	voip:initialize() -- Initialize the websocket and controls
	while not nuiLoaded do
		Wait(5000)
	end
	voip:loop()
end)

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsPlayerTalking(PlayerId()) then
			SetPlayerTalkingOverride(PlayerId(), false)
		end
		DisableControlAction(0, 249, true) -- Disables N Key
	end
end)

-- Functions
function setPlayerTalkingState(player, playerServerId)
	local talking = tonumber(getPlayerData(playerServerId, "voip:talking"))

	if animStates[playerServerId] == 0 and talking == 1 then
		PlayFacialAnim(GetPlayerPed(player), "mic_chatter", "mp_facial")
	elseif animStates[playerServerId] == 1 and talking == 0 then
		PlayFacialAnim(GetPlayerPed(player), "mood_normal_1", "facials@gen_male@base")
	end
	animStates[playerServerId] = talking
end

function PlayRedMFacialAnimation(player, animDict, animName)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Wait(100)
	end
	SetFacialIdleAnimOverride(player, animName, animDict)
end

function clientProcessing()
	local playerList = voip.playerList
	local usersdata = {}
	local ped = PlayerPedId()
	local routingBucket = getPlayerData(GetPlayerServerId(PlayerId()), "voip:routingBucket")

	if voip.headingType == 1 then
		localHeading = math.rad(GetEntityHeading(ped))
	else
		localHeading = math.rad(GetGameplayCamRot().z % 360)
	end

	if useLocalPed then
		localPos = GetPedBoneCoords(ped, HeadBone)
	else
		localPos = GetPedBoneCoords(targetPed, HeadBone)
	end

	-- Process players in playerList
	for i = 1, #playerList do
		local player = playerList[i]
		local playerServerId = GetPlayerServerId(player)
		local playerPed = GetPlayerPed(player)

		local playerTalking = getPlayerData(playerServerId, "voip:talking")
		local playerRoutingBucket = getPlayerData(playerServerId, "voip:routingBucket") 

		if GetConvar("gametype") == "gta5" then
			setPlayerTalkingState(player, playerServerId)
		end

		-- Skip this player if any of the conditions are true (equivalent to original goto continue)
		if CurrentID ~= playerServerId and playerPed and playerTalking and playerTalking ~= 0 then
			local playerPos = GetPedBoneCoords(playerPed, HeadBone)
			local dist = #(localPos - playerPos)

			local tooFar = (Config.distance[4] and dist > voip.distance[4]) or (not Config.distance[4] and dist > voip.distance[3])

			if not tooFar then
				if not getPlayerData(playerServerId, "voip:mode") then
					setPlayerData(playerServerId, "voip:mode", 1)
				end

				local mode = tonumber(getPlayerData(playerServerId, "voip:mode"))
				if Config.distance[4] then
					if not mode or (mode ~= 1 and mode ~= 2 and mode ~= 3) then mode = 1 end
				else
					if not mode or (mode ~= 1 and mode ~= 2) then mode = 1 end
				end

				local volume = -30 + (30 - dist / voip.distance[mode] * 30)
				if volume >= 0 then volume = 0 end

				local angleToTarget = localHeading - math.atan(playerPos.y - localPos.y, playerPos.x - localPos.x)

				local userData = {
					uuid = getPlayerData(playerServerId, "voip:pluginUUID"),
					volume = volume,
					muted = 1,
					radioEffect = false,
					posX = voip.plugin_data.enableStereoAudio and math.cos(angleToTarget) * dist or 0,
					posY = voip.plugin_data.enableStereoAudio and math.sin(angleToTarget) * dist or 0,
					posZ = voip.plugin_data.enableStereoAudio and playerPos.z or 0
				}

				if dist >= voip.distance[mode] then
					userData.muted = 1
				else
					userData.volume = volume
					userData.muted = 0
				end

				usersdata[#usersdata + 1] = userData
			end
		end
	end

	-- Process channels without using goto
	for _, channel in pairs(voip.myChannels) do
		for _, subscriber in pairs(channel.subscribers) do
			if subscriber ~= CurrentID then
				local remotePlayerUsingRadio = getPlayerData(subscriber, "radio:talking")
				local remotePlayerChannel = getPlayerData(subscriber, "radio:channel")

				if remotePlayerUsingRadio and remotePlayerChannel == channel.id then
					local remotePlayerUuid = getPlayerData(subscriber, "voip:pluginUUID")

					local userData = {
						uuid = remotePlayerUuid,
						radioEffect = false,
						muted = false,
						volume = radioVolume,
						posX = 0,
						posY = 0,
						posZ = voip.plugin_data.enableStereoAudio and localPos.z or 0
					}

					if (type(remotePlayerChannel) == "number" and remotePlayerChannel <= voip.config.radioClickMaxChannel) or channel.radio then
						userData.radioEffect = true
					end

					local found = false
					for k, v in pairs(usersdata) do
						if v.uuid == remotePlayerUuid then
							usersdata[k] = userData
							found = true
							break
						end
					end

					if not found then
						usersdata[#usersdata + 1] = userData
					end
				end
			end
		end
	end

	voip.plugin_data.Users = usersdata
	voip.plugin_data.posX = 0
	voip.plugin_data.posY = 0
	voip.plugin_data.posZ = voip.plugin_data.enableStereoAudio and localPos.z or 0
end

RegisterNetEvent("hydravoice:addPlayerToRadio", addPlayerToRadio)

RegisterNetEvent("hydravoice:removePlayerFromRadio", removePlayerFromRadio)

function addPlayerToRadio(channel, radio)
	TriggerServerEvent("hydravoice:addPlayerToRadio", channel, CurrentID, radio)
end

function addPlayerToCall(channel, radio)
	TriggerServerEvent("hydravoice:addPlayerToRadio", channel, CurrentID, false)
end

function setRadioChannel(channel, radio)
	TriggerServerEvent("hydravoice:addPlayerToRadio", channel, CurrentID, true)
end

function setCallChannel(channel, radio)
	TriggerServerEvent("hydravoice:addPlayerToRadio", channel, CurrentID, false)
end

function removePlayerFromRadio(channel)
	TriggerServerEvent("hydravoice:removePlayerFromRadio", channel, CurrentID)
end

function removePlayerFromCall(channel)
	TriggerServerEvent("hydravoice:removePlayerFromRadio", channel, CurrentID)
end

function isPlayerInChannel(channel)
	if voip.myChannels[channel] then
		return true
	else
		return false
	end
end

function setRadioVolume(volume)
	radioVolume = volume
end

function setCallVolume(volume)
	radioVolume = volume
end

function getPlayerChannels()
	return voip.myChannels
end

function displayPluginScreen(toggle)
	if displayingPluginScreen ~= toggle then
		SendNUIMessage({
			type = "displayPluginScreen",
			data = toggle
		})
		displayingPluginScreen = toggle
	end
end

-- Exports
exports("addPlayerToRadio", addPlayerToRadio)
exports("removePlayerFromRadio", removePlayerFromRadio)
exports("removePlayerFromCall", removePlayerFromCall)
exports("isPlayerInChannel", isPlayerInChannel)
exports("getPlayerChannels", getPlayerChannels);
exports("setRadioVolume", setRadioVolume)
exports("setCallVolume", setCallVolume)
exports("setCallChannel", setCallChannel)
exports("setRadioChannel", setRadioChannel)
exports("addPlayerToCall", addPlayerToCall)
