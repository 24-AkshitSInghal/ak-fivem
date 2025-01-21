local vehData = {}

-- Define a utility function for database queries using oxmysql
DBQuery = function(query, parameters, cb)
    local data = exports.oxmysql:fetchSync(query, parameters)
    if cb then
        cb(data)
    end
    return data
end

Citizen.CreateThread(function()
    DBQuery("SELECT * FROM kaves_mechanics", {}, function(result)
        for _, data in pairs(result) do
            vehData[data.plate] = json.decode(data.data)
        end
    end)
end)

addElement = function(section, data)
    if not vehData[data.plate] then
        vehData[data.plate] = {}
    end

    if section == "fitment" then
        vehData[data.plate][section] = data.fitment
    elseif data.component.mod == "Stock" then
        vehData[data.plate][section] = nil
    else
        vehData[data.plate][section] = data.component.mod
    end

    DBQuery("SELECT * FROM kaves_mechanics WHERE plate = ?", { data.plate }, function(output)
        if #output > 0 then
            DBQuery("UPDATE kaves_mechanics SET data = ? WHERE plate = ?", { json.encode(vehData[data.plate]), data
                .plate })
        else
            DBQuery("INSERT INTO kaves_mechanics (plate, data) VALUES (?, ?)",
                { data.plate, json.encode(vehData[data.plate]) })
        end
    end)

    return TriggerClientEvent("kaves_mechanic:client:updateVehData", -1, vehData)
end

RegisterServerEvent("kaves_mechanic:server:syncFitment", function(vehicleId, fitmentData)
    TriggerClientEvent("kaves_mechanic:client:syncFitment", -1, vehicleId, fitmentData)
end)

RegisterServerEvent("kaves_mechanic:server:useNitro", function(vehicleId)
    TriggerClientEvent("kaves_mechanic:client:useNitro", -1, vehicleId)
end)

RegisterServerEvent("kaves_mechanic:server:addElement", addElement)


RegisterServerEvent('kaves_mechanic:server:getVehData', function()
    local src = source 
    TriggerClientEvent('receiveVehicleData', src, vehData)
end)






