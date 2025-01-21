DBQuery = function(query, cb)
    local data = exports.oxmysql:fetchSync(query)
    if cb then
        cb(data)
    end
    return data
end

-- Function to fetch character by ID
function fetchCharacterById(characterId)
    local result = DBQuery("SELECT * FROM characters WHERE id = '" .. characterId .. "'")
    if result and #result > 0 then
        return result[1]
    else
        return nil;
    end
end

RegisterServerEvent('coca_ui_player:moneyCheck', function(cost, characterId)
    local src = source
    print('sserver')
    local data = fetchCharacterById(characterId)
    local currentCash = tonumber(data.cash)
    print(currentCash >= cost)

    if currentCash >= cost then
        print("cash")
        local newCashBalance = currentCash - cost

        local query = "UPDATE characters SET cash = '" ..
            newCashBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        TriggerClientEvent('coca_banking:ShowCash', src, newCashBalance, true)
        TriggerClientEvent('coca_banking:removeCash', src, cost)
        TriggerClientEvent('coca_ui_player:paymentReturn', src, true)
    else
        print("no cash")
        TriggerClientEvent('coca_ui_player:paymentReturn', src, false)
    end
end)
