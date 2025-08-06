------------------------------------------------------------
--  _   _           _            __     __    _           --
-- | | | |_   _  __| |_ __ __ _  \ \   / /__ (_) ___ ___  --
-- | |_| | | | |/ _` | '__/ _` |  \ \ / / _ \| |/ __/ _ \ --
-- |  _  | |_| | (_| | | | (_| |   \ V / (_) | | (_|  __/ --
-- |_| |_|\__, |\__,_|_|  \__,_|    \_/ \___/|_|\___\___| --
--        |___/                                           --
------------------------------------------------------------

-- Functions
function tablelength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

local charset = {} do
	for c = 48, 57 do 
		table.insert(charset, string.char(c))
	end
	for c = 65, 90 do
		table.insert(charset, string.char(c))
	end
	for c = 97, 122 do
		table.insert(charset, string.char(c))
	end
end

function randomString(length)
	if not length or length <= 0 then
		return ''
	end
	math.randomseed(os.time())
	return randomString(length - 1) .. charset[math.random(1, #charset)]
end

function updateRoutingBucket(source, routingBucket)
	local route = 0

	if routingBucket then
		SetPlayerRoutingBucket(source, routingBucket)
		route = routingBucket
	else
		route = GetPlayerRoutingBucket(source)
	end
	TriggerClientEvent("hydravoice:updateRoutingBucket", source, route)
end

-- Exports
exports("updateRoutingBucket", updateRoutingBucket)
