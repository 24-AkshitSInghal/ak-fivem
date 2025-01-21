-- You can implement your custom API here

-- Get player job name
-- Args: (number) player
-- Return: string
function GetPlayerJob(player)

    -- For Standalone
    return 'player'
end

-- Get player nickname
-- Args: (number) player
-- Return: string
function GetPlayerNickname(source)

    -- For Standalone
    return GetPlayerName(source)
end

-- Get player money
-- Args: (number) player
-- Return: number
function GetPlayerMoney(player, characterId)
    DBQuery = function(query, cb)
        local data = exports.oxmysql:fetchSync(query)
        if cb then
            cb(data)
        end
        return data
    end

    local result = DBQuery("SELECT * FROM characters WHERE id = '" .. characterId .. "'")
    if result and #result > 0 then
        return result[1]
    else
        return 0
    end
end

-- Remove player money
-- Args: (number) player, (number) amount
function RemovePlayerMoney(player, amount, characterId)

    TriggerEvent('coca_banking:removeCashToCharacterId', characterId, amount, player)
    -- For Standalone
    -- Do nothing
end

-- Check if player have parking card
-- Args: (number) player
-- Return: boolean
function IsPlayerHaveParkingCard(player)
    -- For ESX
    if Config.framework == 'esx' or Config.framework == 'esx1.9' then
        local xPlayer = _g.ESX.GetPlayerFromId(player)
        return xPlayer.getInventoryItem(Config.parkingCard).count > 0
    end

    -- For QBCore
    if Config.framework == 'qbcore' then
        local player = _g.QBCore.Functions.GetPlayer(player)
        if player and player.PlayerData then
            local item = player.Functions.GetItemByName(Config.parkingCard)
            return item and item.amount > 0
        end
    end

    -- For Standalone
    return false
end

-- Get player identifier
-- Args: (number) player
-- Return: string
function GetIdentifierById(player)
    -- For Standalone
    return string.match(GetPlayerIdentifierByType(player, 'license') or '', 'license:(%w+)')
end

-- Check if player is in whitelist
-- Args: (table) principal, (number) player
-- Return: boolean
function IsWhiteListPlayer(principal, player)
    local identifiers = GetPlayerIdentifiers(player)
    local ip          = GetPlayerEndpoint(player)
    local job         = GetPlayerJob(player)
    for k, v in pairs(principal) do
        if IsInTable(identifiers, v:match('identifier.(%g+)')) or v == string.format('ip.%s', ip) or v == string.format('job.%s', job) then
            return true
        end
    end
    return false
end

-- Check is blacklist car
-- Args: (string) parking, (number) model
-- Return: boolean
function IsBlackListCar(parking, model)
    local parkingData = (Config.parking[parking] or { blacklist = {} })
    for k, v in pairs(parkingData.blacklist) do
        if GetHashKey(v) == model then
            return true
        end
    end
    return false
end

-- Check is allow vehicle class
-- Args: (string) parking, (number) vehicleClass
-- Return: boolean
function IsAllowType(parking, vehicleClass)
    local parkingData = (Config.parking[parking] or { allowTypes = {} })
    for k, v in pairs(parkingData.allowTypes) do
        if v == -1 or v == vehicleClass then
            return true
        end
    end
    return false
end

-- Check is vehicle owned by player
-- Args: (number) player, (string) plate
-- Return: boolean
function IsOwnedVehicle(player, plate, characterId)
    DBQuery = function(query, cb)
        local data = exports.oxmysql:fetchSync(query)
        if cb then
            cb(data)
        end
        return data
    end

    print(plate)

    local result = DBQuery("SELECT * FROM vehicle_ownership WHERE plate = '" .. plate .. "'")

    if result and #result > 0 then
        return result[1].character_id == characterId
    else
        print(0)
        return false
    end
end

-- Send notification to player
-- Args: (number) player, (string) message
-- Return: string
function SendNotification(player, message)
    -- Only send notification to player, ignore console
    if player ~= 0 then
        -- For Standalone
        TriggerClientEvent('chat:addMessage', player, {
            color     = { 255, 255, 255 },
            multiline = true,
            args      = { message }
        })
    end
    return message
end

-- On vehicle stored
-- Args: (number) player, (string) parking, (string) plate
function OnVehicleStored(player, parking, plate)
    -- For Standalone
    -- Do nothing
end

-- On vehicle drive
-- Args: (number) player, (string) parking, (string) plate
function OnVehicleDrive(player, parking, plate)
    -- For Standalone
    -- Do nothing
end

-- On vehicle impounded
-- Args: (number) player, (string) parking, (string) plate
function OnVehicleImpounded(player, parking, plate)
    -- For Standalone
    -- Do nothing
end

-- Is allowed to parking
-- Args: (number) player, (string) parking, (string) plate
-- Return: table
function IsAllowedParking(player, parking, plate)
    -- For Standalone
    return {
        allowed = true,
        message = ''
    }
end

-- Is allowed to drive
-- Args: (number) player, (string) parking, (string) plate
-- Return: table
function IsAllowedDrive(player, parking, plate)
    -- For Standalone
    return {
        allowed = true,
        message = ''
    }
end
