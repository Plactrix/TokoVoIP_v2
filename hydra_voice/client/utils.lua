------------------------------------------------------------
--  _   _           _            __     __    _           --
-- | | | |_   _  __| |_ __ __ _  \ \   / /__ (_) ___ ___  --
-- | |_| | | | |/ _` | '__/ _` |  \ \ / / _ \| |/ __/ _ \ --
-- |  _  | |_| | (_| | | | (_| |   \ V / (_) | | (_|  __/ --
-- |_| |_|\__, |\__,_|_|  \__,_|    \_/ \___/|_|\___\___| --
--        |___/                                           --
------------------------------------------------------------

-- Functions
local playersData = {}
function setPlayerData(playerServerId, key, data, shared)
	if not key or data == nil then
		return
	end
	if not playersData[playerServerId] then
		playersData[playerServerId] = {}
	end
	playersData[playerServerId][key] = {data = data, shared = shared}
	if shared then
		TriggerServerEvent("hydravoice:setPlayerData", playerServerId, key, data, shared)
	end
end

function getPlayerData(playerServerId, key)
	if not playersData[playerServerId] or playersData[playerServerId][key] == nil then
		return false
	end
	return playersData[playerServerId][key].data
end

function refreshAllPlayerData(toEveryone)
	TriggerServerEvent("hydravoice:refreshAllPlayerData", toEveryone)
end

function doRefreshAllPlayerData(serverData)
	for playerServerId, playerData in pairs(serverData) do
		for key, data in pairs(playerData) do
			if not playersData[playerServerId] then
				playersData[playerServerId] = {}
			end
			playersData[playerServerId][key] = {data = data, shared = true}
		end
	end
	for playerServerId, playerData in pairs(playersData) do
		for key, data in pairs(playerData) do
			if not serverData[playerServerId] then
				playersData[playerServerId] = nil
			elseif serverData[playerServerId][key] == nil then
				playersData[playerServerId][key] = nil;
			end
		end
	end
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width / 2, y - height / 2 + 0.005)
end

function draw3dtext(text, posX, posY, posZ, r, g, b, a)
	local _, x, y = World3dToScreen2d(posX, posY, posZ)
	local localPos = GetEntityCoords(GetPlayerPed(localPlayer))
	local dist = GetDistanceBetweenCoords(localPos, posX, posY, posZ)
	local maxDist = 100
	local size = 0.2
	local scale = size - size * (dist / maxDist)
	local offsetX = 0.07 + 0.0235 * (dist / maxDist)
	local offsetY = 0.07 + 0.0235 * (dist / maxDist)

	if dist < maxDist then
		if x and y then
			drawTxt(x + offsetX, y + offsetY, 0.185,0.206, scale, text, r, g, b, a)
		end
	end
end

function table.val_to_str(v)
	if "string" == type(v) then
		v = string.gsub(v, "\n", "\\n")
		if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
			return "'"..v.."'"
		end
		return '"'..string.gsub(v, '"', '\\"')..'"'
	else
		return "table" == type(v) and table.tostring(v) or tostring(v)
	end
end

function table.key_to_str(k)
	if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
		return k
	else
		return "["..table.val_to_str(k).."]"
	end
end

function table.tostring(tbl)
	local result, done = {}, {}

	for k, v in ipairs(tbl) do
		table.insert(result, table.val_to_str(v))
		done[k] = true
	end
	for k, v in pairs(tbl) do
		if not done[k] then
			table.insert(result, table.key_to_str(k).."="..table.val_to_str(v))
		end
	end

	return "{"..table.concat(result, ",").."}"
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function printFunctions(t, i)
	functionSeen[t] = true
	local s = {}
	local n = 0
	for k in pairs(t) do
		n = n + 1 s[n] = k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		Citizen.Trace(i .. " " .. v .. "\n")
		v = t[v]
		if type(v) == "table" and not functionSeen[v] then
			printFunctions(v, i .. "\t")
		end
	end
end

function printAllFunctions()
	printFunctions(_G, "")
end

function escape(str)
	return str:gsub("%W", "")
end

function SetTokoProperty(key, value)
	if Config[key] ~= nil and Config[key] ~= "plugin_data" then
		Config[key] = value

		if voip then
			if voip.config then
				if voip.config[key] ~= nil then
					voip.config[key] = value
				end
			end
		end
	end
end

-- Define Things
hydravoice = {};
hydravoice.__index = hydravoice;
local lastTalkState = false
Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

RegisterKeyMapping('+radiotalk', 'Talk over Radio', 'keyboard', Config.radioKey)
RegisterKeyMapping('+cycleProximity', 'Changes proximity range for hydravoice', 'keyboard', Config.keyProximity)

-- Events
RegisterNetEvent("hydravoice:setPlayerData")
AddEventHandler("hydravoice:setPlayerData", setPlayerData)

RegisterNetEvent("hydravoice:doRefreshAllPlayerData")
AddEventHandler("hydravoice:doRefreshAllPlayerData", doRefreshAllPlayerData)

RegisterNetEvent("onClientPlayerReady")
AddEventHandler("onClientPlayerReady", refreshAllPlayerData)

-- Add Event Handlers
AddEventHandler("onClientResourceStart", function(resource)
	if resource == GetCurrentResourceName() then	--	Initialize the script when this resource is started
		CreateThread(function()
			if Config.plugin_data.localName == '' then
				Config.plugin_data.localName = escape(GetPlayerName(PlayerId())) -- Set the local name
			end
			if Config.plugin_data.localNamePrefix == nil then
				Config.plugin_data.localNamePrefix = "[" .. GetPlayerServerId(PlayerId()) .. "] "
			end
		end)
		TriggerEvent("initializeVoip")
	end
end)

-- hydravoice Functions
function hydravoice.init(self, config)
	local self = setmetatable(config, hydravoice)
	self.config = json.decode(json.encode(config))
	self.lastNetworkUpdate = 0
	self.lastPlayerListUpdate = self.playerListRefreshRate
	self.playerList = {}
	return self
end

function hydravoice.loop(self)
	CreateThread(function()
		while true do
			Wait(self.refreshRate)
			self:processFunction()
			self:sendDataToTS3()

			self.lastNetworkUpdate = self.lastNetworkUpdate + self.refreshRate
			self.lastPlayerListUpdate = self.lastPlayerListUpdate + self.refreshRate
			if self.lastNetworkUpdate >= self.networkRefreshRate then
				self.lastNetworkUpdate = 0
				self:updatehydravoiceInfo()
			end
			if self.lastPlayerListUpdate >= self.playerListRefreshRate then
				self.playerList = GetActivePlayers()
				self.lastPlayerListUpdate = 0
			end
		end
	end)
end

function hydravoice.sendDataToTS3(self)
	if self.pluginStatus == -1 then
		return
	end
	self:updatePlugin("updatehydravoice", self.plugin_data)
end

function hydravoice.updatehydravoiceInfo(self, forceUpdate)
	local info = ""
	if Config.distance[4] then
		if self.mode == 1 then
			info = "Whispering"
		elseif self.mode == 2 then
			info = "Normal"
		elseif self.mode == 3 then
			info = "Shouting"
		elseif self.mode == 4 then
			info = "Theatre"
		end
	else
		if self.mode == 1 then
			info = "Whispering"
		elseif self.mode == 2 then
			info = "Normal"
		elseif self.mode == 3 then
			info = "Shouting"
		end
	end

	if self.plugin_data.radioTalking then
		info = info .. " on radio "
	end
	if self.talking == 1 or self.plugin_data.radioTalking then
		info = "<font class='talking'>" .. info .. "</font>"
	end
	if self.plugin_data.radioChannel ~= -1 and self.myChannels[self.plugin_data.radioChannel] then
		if string.match(self.myChannels[self.plugin_data.radioChannel].name, "Call") then
			info = info  .. "<br> [Phone] " .. self.myChannels[self.plugin_data.radioChannel].name
		else
			info = info  .. "<br> [Radio] " .. self.myChannels[self.plugin_data.radioChannel].name
		end
	end
	if info == self.screenInfo and not forceUpdate then
		return
	end
	self.screenInfo = info
	self:updatePlugin("updatehydravoiceInfo", info)
end

function hydravoice.updatePlugin(self, event, payload)
	SendNUIMessage({
		type = event,
		payload = payload
	})
end

function hydravoice.updateConfig(self)
	local data = self.config
	data.plugin_data = self.plugin_data
	data.pluginVersion = self.pluginVersion
	data.pluginStatus = self.pluginStatus
	data.pluginUUID = self.pluginUUID
	self:updatePlugin("updateConfig", data)
end

function hydravoice.disconnect(self)
	self:updatePlugin("disconnect")
end

function hydravoice.initialize(self)
	self:updateConfig()
	self:updatePlugin("initializeSocket", self.wsServer)

    RegisterNetEvent("hydravoice:MicClicks:SyncCL")
    AddEventHandler("hydravoice:MicClicks:SyncCL", function(channelId)
        if self.plugin_data.radioChannel == channelId then
            SendNUIMessage({
                transactionType = "playSound",
                transactionFile  = "mic_click_off",
                transactionVolume = 0.2
            })
        end
    end)

	RegisterCommand("+RadioTalk", function()
        if self.plugin_data.radioChannel ~= -1 and self.plugin_data.radioChannel ~= 0 then
            self.plugin_data.radioTalking = true
            self.plugin_data.localRadioClicks = false
			if string.match(self.myChannels[self.plugin_data.radioChannel].name, "Call") ~= "Call" then
				SendNUIMessage({
					transactionType = "playSound",
					transactionFile  = "mic_click_on",
					transactionVolume = 0.2
				})
                wastalkingonradio = true
			end
                if not getPlayerData(self.serverId, "radio:talking") then
                    setPlayerData(self.serverId, "radio:talking", true, true)
                end
                self:updatehydravoiceInfo()
                if lastTalkState == false and self.myChannels[self.plugin_data.radioChannel] and self.config.radioAnim then
                    if not string.match(self.myChannels[self.plugin_data.radioChannel].name, "Call") and not IsPedSittingInAnyVehicle(PlayerPedId()) then
                        RequestAnimDict("random@arrests")
                        while not HasAnimDictLoaded("random@arrests") do
                            Wait(5)
                        end
                        TaskPlayAnim(PlayerPedId(),"random@arrests","generic_radio_chatter", 8.0, 0.0, -1, 49, 0, 0, 0, 0)
                    end
                lastTalkState = true
            end
        else
            self.plugin_data.radioTalking = false
            if getPlayerData(self.serverId, "radio:talking") then
                setPlayerData(self.serverId, "radio:talking", false, true)
            end
            self:updatehydravoiceInfo()

            if lastTalkState == true and self.config.radioAnim then
                lastTalkState = false
                StopAnimTask(PlayerPedId(), "random@arrests","generic_radio_chatter", -4.0)
            end
        end
    end)

    RegisterCommand("-RadioTalk", function()
        self.plugin_data.radioTalking = false
		if wastalkingonradio then
			TriggerServerEvent("hydravoice:MicClicks:Sync", self.plugin_data.radioChannel)
			wastalkingonradio = false
		end
        if getPlayerData(self.serverId, "radio:talking") then
            setPlayerData(self.serverId, "radio:talking", false, true)
        end
        self:updatehydravoiceInfo()

        if lastTalkState == true and self.config.radioAnim then
            lastTalkState = false
            StopAnimTask(PlayerPedId(), "random@arrests","generic_radio_chatter", -4.0)
        end
    end)

	RegisterCommand("-cycleProximity", function()
	end)

	RegisterCommand("+cycleProximity", function()
		if not self.mode then
			self.mode = 1
		end
		self.mode = self.mode + 1
		if Config.distance[4] then
			if self.mode > 4 then
				self.mode = 1
			end
		else
			if self.mode > 3 then
				self.mode = 1
			end
		end
		setPlayerData(self.serverId, "voip:mode", self.mode, true)
		self:updatehydravoiceInfo()
	end)
 
	CreateThread(function()
		while true do
			Wait(5)
			if ((self.keySwitchChannelsSecondary and IsControlPressed(0, self.keySwitchChannelsSecondary)) or not self.keySwitchChannelsSecondary) then
				if IsControlJustPressed(0, self.keySwitchChannels) and tablelength(self.myChannels) > 0 then
					local myChannels = {}
					local currentChannel = 0
					local currentChannelID = 0

					for channel, _ in pairs(self.myChannels) do
						if channel == self.plugin_data.radioChannel then
							currentChannel = #myChannels + 1
							currentChannelID = channel
						end
						myChannels[#myChannels + 1] = {channelID = channel}
					end
					if currentChannel == #myChannels then
						currentChannelID = myChannels[1].channelID
					else
						currentChannelID = myChannels[currentChannel + 1].channelID
					end
					self.plugin_data.radioChannel = currentChannelID
					setPlayerData(self.serverId, "radio:channel", currentChannelID, true)
					self:updatehydravoiceInfo()
				end
			end
		end
	end)
end

-- Exports
exports("getPlayerData", getPlayerData)
exports("setPlayerData", setPlayerData)
exports("refreshAllPlayerData", refreshAllPlayerData)
exports("SetTokoProperty", SetTokoProperty)
