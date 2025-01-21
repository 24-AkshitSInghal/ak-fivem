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
        print(result[1])
        return result[1]
    else
        return nil;
    end
end

RegisterServerEvent("coca_banking:FetchPlayerData", function(characterId)
    local src = source
    local data = fetchCharacterById(characterId)
    Wait(1000)
    TriggerClientEvent("coca_banking:RecivePlayerData", src, data)
end)


RegisterServerEvent("coca_banking:withdraw", function(money, characterId)
    local src = source
    local data = fetchCharacterById(characterId)

    if not data then
        print("Character data not found for ID: " .. characterId)
        return
    end

    local cash = tonumber(data.cash)
    local bankAccount = tonumber(data.bankaccount)
    local amount = tonumber(money)


    if bankAccount >= amount then
        local newBankAccountBalance = bankAccount - amount

        local query = "UPDATE characters SET bankaccount = '" ..
            newBankAccountBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        local newCashBalance = cash + amount
        query = "UPDATE characters SET cash = '" .. newCashBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        local result = fetchCharacterById(characterId)

        TriggerClientEvent('coca_banking:ShowCash', src, result.cash, true)
        TriggerClientEvent('coca_banking:addCash', src, amount)

        TriggerClientEvent("coca_banking:RecivePlayerData", src, result)

        TriggerClientEvent('coca_bank:transactionStatus', src, 'Withdrawal successful.')
    else
        TriggerClientEvent('coca_bank:transactionStatus', src, 'You do not have enough money to withdraw.')
    end
end)



RegisterServerEvent("coca_banking:deposit", function(money, characterId)
    local src = source

    local data = fetchCharacterById(characterId)
    if not data then
        print("Character data not found for ID: " .. characterId)
        return
    end

    local cash = tonumber(data.cash)
    local bankAccount = tonumber(data.bankaccount)
    local amount = tonumber(money)


    if cash >= amount then
        local newCashBalance = cash - amount

        local query = "UPDATE characters SET cash = '" .. newCashBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        local newBankAccountBalance = bankAccount + amount
        query = "UPDATE characters SET bankaccount = '" ..
            newBankAccountBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        local result = fetchCharacterById(characterId)

        TriggerClientEvent('coca_banking:ShowCash', src, result.cash, true)
        TriggerClientEvent('coca_banking:removeCash', src, amount)

        TriggerClientEvent("coca_banking:RecivePlayerData", src, result)
        TriggerClientEvent('coca_bank:transactionStatus', src, 'Deposit successful.')
    else
        TriggerClientEvent('coca_bank:transactionStatus', src, 'You do not have enough cash to deposit.')
    end
end)


RegisterServerEvent("coca_banking:transfertoBank", function(money, targetCharacterId, playerCharacterId)
    local src = source

    local playerData = fetchCharacterById(playerCharacterId)
    if not playerData then
        print("Character data not found for ID: " .. playerCharacterId)
        return
    end

    local targetData = fetchCharacterById(targetCharacterId)
    if not targetData then
        TriggerClientEvent('coca_bank:transactionStatus', src,
            "No account found for number: " .. targetCharacterId)
        return
    end

    local playerBankAccount = tonumber(playerData.bankaccount)
    local amount = tonumber(money)
    local targetBankAccount = tonumber(targetData.bankaccount)

    if playerBankAccount >= amount then
        local newBankAccountBalance = playerBankAccount - amount

        local query = "UPDATE characters SET bankaccount = '" ..
            newBankAccountBalance .. "' WHERE id = '" .. playerCharacterId .. "'"
        DBQuery(query)

        local TargetNewBankAccountBalance = targetBankAccount + amount
        query = "UPDATE characters SET bankaccount = '" ..
            TargetNewBankAccountBalance .. "' WHERE id = '" .. targetCharacterId .. "'"
        DBQuery(query)

        -- Notify the player about the successful transaction
        local result = fetchCharacterById(playerCharacterId)
        
        TriggerClientEvent('coca_banking:ShowBank', src, result.bankaccount, true)
        TriggerClientEvent('coca_banking:removeBank', src, amount)

        TriggerClientEvent("coca_banking:RecivePlayerData", src, result)
        TriggerClientEvent('coca_bank:transactionStatus', src, 'Transfer to bank successful.')
    else
        -- Insufficient cash, notify the player
        TriggerClientEvent('coca_bank:transactionStatus', src, 'You do not have enough cash to transfer.')
    end
end)

RegisterServerEvent("coca_banking:GiveCash", function(money, targetCharacterId, playerCharacterId)
    local src = source

    local playerData = fetchCharacterById(playerCharacterId)
    if not playerData then
        print("Character data not found for ID: " .. playerCharacterId)
        return
    end

    local targetData = fetchCharacterById(targetCharacterId)
    if not targetData then
        TriggerClientEvent('coca_bank:transactionStatus', src,
            "No citizenId found for number: " .. targetCharacterId)
        return
    end

    local playerCash = tonumber(playerData.cash)
    local amount = tonumber(money)
    local targetCash = tonumber(targetData.cash)

    if playerCash >= amount then
        local newCashBalance = playerCash - amount

        local query = "UPDATE characters SET cash = '" ..
            newCashBalance .. "' WHERE id = '" .. playerCharacterId .. "'"
        DBQuery(query)

        local TargetNewCashBalance = targetCash + amount
        query = "UPDATE characters SET cash = '" ..
            TargetNewCashBalance .. "' WHERE id = '" .. targetCharacterId .. "'"
        DBQuery(query)

        TriggerClientEvent('coca_banking:ShowCash', src, newCashBalance, true)
        TriggerClientEvent('coca_banking:removeCash', src, amount)
    else
        TriggerClientEvent('coca_bank:transactionStatus', src, 'You do not have enough cash.')
    end
end)

RegisterServerEvent('coca_banking:ShowCash', function(CharacterId)
    local src = source
    local data = fetchCharacterById(CharacterId)
    TriggerClientEvent('coca_banking:ShowCash', src, data.cash, true)
end)

RegisterServerEvent('coca_banking:ShowBank', function(CharacterId)
    local src = source
    local data = fetchCharacterById(CharacterId)
    TriggerClientEvent('coca_banking:ShowBank', src, data.bankaccount, data.name, true)
end)

RegisterServerEvent("coca_banking:addCashToCharacterId", function(playerCharacterId, money, givensource)
    local src = givensource or source

    local playerData = fetchCharacterById(playerCharacterId)
    if not playerData then
        print("Character data not found for ID: " .. playerCharacterId)
        return
    end

    local playerCash = tonumber(playerData.cash)
    local amount = tonumber(money)

    local newCashBalance = playerCash + amount

    local query = "UPDATE characters SET cash = '" ..
        newCashBalance .. "' WHERE id = '" .. playerCharacterId .. "'"
    DBQuery(query)


    TriggerClientEvent('coca_banking:ShowCash', src, newCashBalance, true)
    TriggerClientEvent('coca_banking:addCash', src, amount)
end)

RegisterServerEvent("coca_banking:removeCashToCharacterId", function(characterId, money, givensource)
    local src = givensource or source
    local data = fetchCharacterById(characterId)
    local currentCash = tonumber(data.cash)
    local cost = tonumber(money)
    if currentCash >= cost then
        local newCashBalance = currentCash - cost

        local query = "UPDATE characters SET cash = '" ..
            newCashBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        TriggerClientEvent('coca_banking:ShowCash', src, newCashBalance, true)
        TriggerClientEvent('coca_banking:removeCash', src, cost)
        TriggerClientEvent('coca_banking:paymentStatus', src, true)
    else
        TriggerClientEvent('coca_banking:paymentStatus', src, false)
        TriggerClientEvent('coca_bank:transactionStatus', src, 'You do not have enough cash.')
    end
end)


