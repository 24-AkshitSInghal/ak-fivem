RegisterServerEvent('coca_spawnmanager:kickplayer', function()
	DropPlayer(source, 'You have been AFK Kicked')
end)

local serverIdToCharacterId = {}

-- Event handler for setting the main character on the server
RegisterNetEvent('setServerWithCharacterId', function(serverId, characterId)
	serverIdToCharacterId[serverId] = characterId
	print("Server ID " .. serverId .. " is associated with Character ID " .. characterId)
end)

function GetCharacterIdByServerId(serverId)
	local id = tonumber(serverId)
	return serverIdToCharacterId[id]
end

exports('GetCharacterIdByServerId', GetCharacterIdByServerId)

function GetServerIdByCharacterId(characterId)
	for serverId, charId in pairs(serverIdToCharacterId) do
		if charId == characterId then
			return serverId
		end
	end
	return nil
end

exports('GetServerIdByCharacterId', GetServerIdByCharacterId)

RegisterNetEvent('coca_spawnmanager:getAllCharacterIds', function()
	local source = source
	TriggerClientEvent('coca_spawnmanager:receiveAllCharacterIds', source, serverIdToCharacterId)
end)

-- -- Function to edit character
-- local function editCharacter(characterId, updatedCharacter)
-- 	local query = 'UPDATE characters SET name = ?, age = ?, backstory = ?, clothing = ? WHERE id = ?'
-- 	local values = { updatedCharacter.name, updatedCharacter.age, updatedCharacter.backstory, json.encode(
-- 		updatedCharacter.clothing), characterId }
-- 	local success = oxmysql:fetchSync(query, values)
-- 	return success
-- end


-- -- Event to edit a character
-- RegisterServerEvent("coca_spawnmanager:edit", function(characterId, updatedCharacter)
-- 	local success = editCharacter(characterId, updatedCharacter)
-- 	if success then
-- 		-- Handle success
-- 	else
-- 		-- Handle failure
-- 	end
-- end)


DBQuery = function(query, cb)
	local data = exports.oxmysql:fetchSync(query)
	if cb then
		cb(data)
	end
	return data
end

-- Function to fetch all characters
local function fetchAllCharacters(licensekey)
	print(licensekey)
	local result = DBQuery("SELECT * FROM characters WHERE licensekey = '" .. licensekey .. "'")
	if result then
		return result
	else
		return {}
	end
end

-- Function to create a new character
local function createNewCharacter(licensekey, newCharacterData)
	local backstory = string.sub(newCharacterData.backstory, 1, 50)
	DBQuery("INSERT INTO `characters` (`licensekey`, `name`, `dob`, `backstory`) VALUES('" ..
		licensekey ..
		"','" .. newCharacterData.name .. "','" .. newCharacterData.dob .. "','" .. backstory .. "')")
end

-- Function to delete character
local function deleteCharacter(characterId)
	DBQuery("DELETE FROM characters WHERE id = '" .. characterId .. "'")
end

-- Function to update clothing
local function updateClothing(characterId, clothing)
	local data = json.encode(clothing)
	DBQuery("UPDATE characters SET clothing = '" .. data .. "' WHERE id = '" .. characterId .. "'")
end

-- Event to update clothing
RegisterServerEvent("coca_spawnmanager:updateClothing", function(characterId, clothing)
	updateClothing(characterId, clothing)
end)

-- Event to delete a character
RegisterServerEvent("coca_spawnmanager:deleteCharacter", function(data)
	local src = source;
	deleteCharacter(data.id)
	Wait(500)
	local playerLicenseId = GetPlayerIdentifierByType(src, 'license')
	local characters = fetchAllCharacters(playerLicenseId)
	Wait(500)
	TriggerClientEvent('coca_spawnmanager:updatedCharacter', src, characters)
end)

-- Event to fetch characters
RegisterServerEvent("coca_spawnmanager:fetchCharacters", function()
	local src = source;
	local playerLicenseId = GetPlayerIdentifierByType(src, 'license')
	local characters = fetchAllCharacters(playerLicenseId)
	TriggerClientEvent("coca_spawnmanager:receiveCharacters", src, characters)
end)

-- Event to create a new character
RegisterServerEvent("coca_spawnmanager:newCharacter", function(newCharacterData)
	local src = source
	local playerLicenseId = GetPlayerIdentifierByType(src, 'license')
	createNewCharacter(playerLicenseId, newCharacterData)
	Wait(500)
	local allCharacters = fetchAllCharacters(playerLicenseId)
	TriggerClientEvent('coca_spawnmanager:updatedCharacter', src, allCharacters)
end)

-- Function to update lastlocation
local function updateLocation(characterId, lastLocation)
	local data = json.encode(lastLocation)
	DBQuery("UPDATE characters SET last_position = '" .. data .. "' WHERE id = '" .. characterId .. "'")
	print("player id " .. characterId .. " last location " .. lastLocation.x .. " " .. lastLocation.y .. " Saved")
end

RegisterServerEvent("coca_spawnmanager:saveLastLoc", function(charcterId, lastLocation)
	updateLocation(charcterId, lastLocation)
end)


RegisterServerEvent('setCharacterPhoneData', function(data)
	local scr = source
	local phoneNumber = data.phone_number

	if not phoneNumber then
		phoneNumber = exports.npwd:generatePhoneNumber()
		DBQuery("UPDATE characters SET phone_number = '" .. phoneNumber .. "' WHERE id = '" .. data.id .. "'")
	end

	Wait(1000)

	local cleaned_licensekey = string.gsub(data.licensekey, "license:", "")
	local license = "" .. cleaned_licensekey .. "" .. data.id
	print(license)

	exports.npwd:newPlayer({
		source = scr,
		firstname = data.name,
		lastname = data.name,
		identifier = license,
		phoneNumber = phoneNumber
	})
end)

-- RegisterServerEvent('coca_spawnmanager:changeFraction', function(fraction, characterId)
-- 	DBQuery("UPDATE characters SET fraction = '" .. fraction .. "' WHERE id = '" .. characterId .. "'")
-- end)

-- CreateThread(function()
-- 	while true do
-- 		Wait(2000)
-- 		print(json.encode(activeEmsIds))
-- 	end
-- end)
