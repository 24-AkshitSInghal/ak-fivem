DBQuery = function(query, cb)
    local data = exports.oxmysql:fetchSync(query)
    if cb then
        cb(data)
    end
    return data
end

RegisterNetEvent('ak-carlock:fetchOwnedVehicles', function(characterId)
    local src = source
    local plates = {}
    DBQuery("SELECT plate FROM `vehicle_ownership` WHERE `character_id` = '" .. characterId .. "'", function(result)
        for _, row in ipairs(result) do
            table.insert(plates, row.plate)
        end
        TriggerClientEvent('ak-carlock:receiveOwnedVehicles', src, plates)
    end)
end)

RegisterServerEvent('ak-carlock:isVehicleInParkingList', function(plate)
    local src = source
    DBQuery("SELECT * FROM `parking_vehicles` WHERE `plate` = '" .. plate .. "'", function(result)
        print(#result)
        if #result > 0 then
            TriggerClientEvent('ak-carlock:isVehicleInParkingListResult', src, true)
        else
            TriggerClientEvent('ak-carlock:isVehicleInParkingListResult', src, false)
        end
    end)
end)