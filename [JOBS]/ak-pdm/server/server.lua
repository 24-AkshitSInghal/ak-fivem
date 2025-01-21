local carAtStandOneData = nil
local carAtStandTwoData = nil
local carAtStandThreeData = nil
local carAtStandFourData = nil
local carAtStandFiveData = nil

RegisterServerEvent("ak-pdm:syncCarStand", function(carData, stand, carName, characterId, vehicleNetId)
    print(stand.standName)
    print(carName)
    print(carData)

    if carData and stand.standName == '1' then
        carAtStandOneData = carData
    elseif carData and stand.standName == '2' then
        carAtStandTwoData = carData
    elseif carData and stand.standName == '3' then
        carAtStandThreeData = carData
    elseif carData and stand.standName == '4' then
        carAtStandFourData = carData
    elseif carData and stand.standName == '5' then
        carAtStandFiveData = carData
    end

    TriggerClientEvent("ak-pdm:recivedSyncCarStand", -1, carAtStandOneData, carAtStandTwoData, carAtStandThreeData,
        carAtStandFourData, carAtStandFiveData)
    TriggerClientEvent('ak-pdm:startVehicleRotation', -1, vehicleNetId)
end)

RegisterServerEvent("ak-pdm:syncPlayerSpawn", function()
    TriggerClientEvent("ak-pdm:recivedSyncCarStand", source, carAtStandOneData, carAtStandTwoData, carAtStandThreeData,
        carAtStandFourData, carAtStandFiveData)
end)


DBQuery = function(query, parameters, cb)
    local data = exports.oxmysql:executeSync(query, parameters)
    if cb then
        cb(data)
    end
    return data
end

RegisterNetEvent('ak-pdm:buyVehicle',
    function(characterId, totalprice, carModel, plate, employeeCharacterid, employerrCut)
    print("on server")
        TriggerEvent('coca_banking:addCashToCharacterId', employeeCharacterid, employerrCut)
    DBQuery(
        'INSERT INTO vehicle_ownership (character_id, sellercharater_id, vehicle_model, purchase_price, plate) VALUES (@characterId, @sellercharater_id, @model, @price, @plate)',
        {
            ['@characterId'] = characterId,
            ['@sellercharater_id'] = employeeCharacterid,
            ['@model'] = carModel,
            ['@price'] = totalprice,
            ['@plate'] = plate
        }
    -- function(result)
    --     if result.affectedRows > 0 then
    --         print("Vehicle purchased successfully.")
    --         -- Give the player the key
    --         DBQuery(
    --             'INSERT INTO vehicle_keys (character_id, plate) VALUES (@characterId, @plate)',
    --             {
    --                 ['@characterId'] = characterId,
    --                 ['@plate'] = plate
    --             },
    --             function(keyResult)
    --                 if keyResult.affectedRows > 0 then
    --                     print("Key assigned successfully.")
    --                 else
    --                     print("Key assignment failed.")
    --                 end
    --             end
    --         )
    --     else
    --         print("Vehicle purchase failed.")
    --     end
    -- end
    )
end)

-- function HasKeys(characterId, plate, cb)
--     DBQuery(
--         'SELECT * FROM vehicle_keys WHERE character_id = @characterId AND plate = @plate',
--         {
--             ['@characterId'] = characterId,
--             ['@plate'] = plate
--         },
--         function(result)
--             if result.affectedRows > 0 then
--                 cb(true)
--             else
--                 cb(false)
--             end
--         end
--     )
-- end

-- RegisterNetEvent('ak-pdm:checkVehicleKey', function(characterId, plate)
--     HasKeys(characterId, plate, function(hasKey)
--         TriggerClientEvent('ak-pdm:checkVehicleKeyResponse', source, hasKey)
--     end)
-- end)
