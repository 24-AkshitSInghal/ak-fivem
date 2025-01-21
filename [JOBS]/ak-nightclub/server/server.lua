
local LapDanceActive = false

RegisterServerEvent('coca_nightclub:buy', function()
    if not LapDanceActive then
        TriggerClientEvent('coca_nightclub:lapdance', source)
    else
        TriggerClientEvent('coca_nightclub:showNotify', source, "The ~q~Stripper~s~ is already busy!")
    end
end)


RegisterServerEvent('coca_nightclub:active', function()
    LapDanceActive = true
end)


RegisterServerEvent('coca_nightclub:idle', function()
    LapDanceActive = false
end)

RegisterServerEvent('coca_nightclub:setEntityVisibility', function(visible)
    TriggerClientEvent('coca_nightclub:setEntityVisibility', -1, visible) -- Sends the visibility state to all clients
end)

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

RegisterServerEvent('coca_nightclub:moneyCheck', function(service, characterId)
    local cost = nil

    if service == "SERVICE_BLOWJOB" then
        cost = math.random(600,900)
    elseif service == "SERVICE_SEX_BACKDOOR" then
        cost = math.random(2500, 3000)
    else
        cost = math.random(1300, 1900)
    end


    local src = source

    local data = fetchCharacterById(characterId)
    local currentCash = tonumber(data.cash)
    print(currentCash >= cost)
    if currentCash >= cost then
        local newCashBalance = currentCash - cost

        local query = "UPDATE characters SET cash = '" ..
            newCashBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        TriggerClientEvent('coca_banking:ShowCash', src, newCashBalance, true)
        TriggerClientEvent('coca_banking:removeCash', src, cost)
        TriggerClientEvent('coca_banking:paymentReturn', src, true)
    else
        TriggerClientEvent('coca_banking:paymentReturn', src, false)
    end
end)

-- Server-side script to broadcast the animation commands to all clients

RegisterServerEvent('syncNPCAnimationServer')
AddEventHandler('syncNPCAnimationServer', function(offset, isStarted)
    TriggerClientEvent('syncNPCAnimation', -1, offset, isStarted)
end)

