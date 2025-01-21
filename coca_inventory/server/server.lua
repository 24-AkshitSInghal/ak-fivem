local playerInventories = {}

DBQuery = function(query, cb)
    local data = exports.oxmysql:fetchSync(query)
    if cb then
        cb(data)
    end
    return data
end

local function LoadPlayerInventory(CharacterId, cb)
    DBQuery("SELECT inventory FROM `characters` WHERE `id` = '" .. CharacterId .. "'",
        function(result)
            local inventory = {}
            if result and result[1] then
                inventory = json.decode(result[1].inventory)
            end
            if cb then
                cb(inventory)
            end
        end)
end

local function SavePlayerInventory(CharacterId)
    if playerInventories[CharacterId] then
        local inventory = json.encode(playerInventories[CharacterId])
        DBQuery("UPDATE `characters` SET `inventory` = '" .. inventory ..
            "' WHERE `id` = '" .. CharacterId .. "'")
    end
end

RegisterServerEvent('coca_inventory:Server:InitializeInventory', function(CharacterId)
    local src = source
    LoadPlayerInventory(CharacterId, function(inventory)
        playerInventories[CharacterId] = inventory
        TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
    end)
end)

RegisterServerEvent('coca_inventory:Server:FetchInventory', function(CharacterId)
    local src = source
    LoadPlayerInventory(CharacterId, function(inventory)
        playerInventories[CharacterId] = inventory
        TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
    end)
end)

RegisterServerEvent('coca_inventory:Server:AddItem', function(CharacterId, name, count, completeMsg)
    local src = source
    if not playerInventories[CharacterId] then
        playerInventories[CharacterId] = {}

        for i = 1, 30 do
            playerInventories[CharacterId][i] = { name = '', count = 0 }
        end
    end

    local inventory = playerInventories[CharacterId]

    if not name or not Config.Items[name] then
        TriggerClientEvent("coca_inventory:statusAlert", src, "Failed to Add Item")
        return
    end

    local currentWeight = 0
    for _, invItem in ipairs(inventory) do
        if invItem.name ~= '' and Config.Items[invItem.name] then
            currentWeight = currentWeight + (Config.Items[invItem.name].weight * invItem.count)
        end
    end

    local maxWeight = Config.invetoryData['player'].MaxWeight
    local itemWeight = Config.Items[name].weight * count

    if currentWeight + itemWeight > maxWeight then
        TriggerClientEvent("coca_inventory:statusAlert", src, "Not enough space in inventory")
        return
    end


    local firstEmptySlot = nil
    local itemadded = false

    for index, invItem in ipairs(inventory) do
        if invItem.name == name and Config.Items[name].canStack then
            invItem.count = invItem.count + count
            itemadded = true
            firstEmptySlot = nil
            break
        elseif invItem.name == '' and not firstEmptySlot then
            firstEmptySlot = index
        end
    end

    if firstEmptySlot == nil and itemadded == false then
        TriggerClientEvent("coca_inventory:statusAlert", src, "No free slot in inventory")
        return
    end

    if firstEmptySlot then
        inventory[firstEmptySlot] = { name = name, count = count }
    end

    if completeMsg then
        TriggerClientEvent("coca_inventory:statusAlert", src, completeMsg)
    end

    SavePlayerInventory(CharacterId)
    -- TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
end)

-- Helper function to calculate current inventory weight
function GetCurrentInventoryWeight(inventory)
    local currentWeight = 0
    for _, invItem in ipairs(inventory) do
        if invItem.name ~= '' and Config.Items[invItem.name] then
            currentWeight = currentWeight + (Config.Items[invItem.name].weight * invItem.count)
        end
    end
    return currentWeight
end

RegisterServerEvent('coca_inventory:Server:AddMutipleItem', function(CharacterId, itemsArray, completeMsg)
    local src = source

    if not playerInventories[CharacterId] then
        playerInventories[CharacterId] = {}
        for i = 1, 30 do
            playerInventories[CharacterId][i] = { name = '', count = 0 }
        end
    end

    local inventory = playerInventories[CharacterId]
    local maxWeight = Config.invetoryData['player'].MaxWeight
    local currentWeight = GetCurrentInventoryWeight(inventory)
    for _, itemData in ipairs(itemsArray) do
        local name = itemData.item
        local count = itemData.count

        if not name or not Config.Items[name] then
            TriggerClientEvent("coca_inventory:statusAlert", src, "Failed to Add Item")
            print('Failed to Add Item: Invalid name or item not in Config.Items')
            return
        end

        local itemWeight = Config.Items[name].weight * count

        if currentWeight + itemWeight > maxWeight then
            TriggerClientEvent("coca_inventory:statusAlert", src, "Not enough space in inventory")
            print('Not enough space in inventory: currentWeight:', currentWeight, 'itemWeight:', itemWeight, 'maxWeight:',
                maxWeight)
            return
        end

        local itemAdded = false
        local firstEmptySlot = nil

        for index, invItem in ipairs(inventory) do
            if invItem.name == name and Config.Items[name].canStack then
                invItem.count = invItem.count + count
                itemAdded = true
                print('Stacked item in inventory:', name, 'new count:', invItem.count)
                break
            elseif invItem.name == '' and not firstEmptySlot then
                firstEmptySlot = index
            end
        end

        if not itemAdded and firstEmptySlot == nil then
            TriggerClientEvent("coca_inventory:statusAlert", src, "No free slot in inventory")
            print('No free slot in inventory')
            return
        end

        if firstEmptySlot then
            inventory[firstEmptySlot] = { name = name, count = count }
            print('Added item to new slot:', firstEmptySlot, 'item:', name, 'count:', count)
        end

        currentWeight = GetCurrentInventoryWeight(inventory)
        print('Updated inventory weight:', currentWeight)
    end

    if completeMsg then
        TriggerClientEvent("coca_inventory:statusAlert", src, completeMsg)
    end

    playerInventories[CharacterId] = inventory
    SavePlayerInventory(CharacterId)
    -- TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
end)

RegisterServerEvent('coca_inventory:Server:RemoveMultipleItems', function(CharacterId, itemsArray, completeMsg)
    local src = source

    if not playerInventories[CharacterId] then
        TriggerClientEvent("coca_inventory:statusAlert", src, "Inventory does not exist")
        print('Inventory does not exist for CharacterId:', CharacterId)
        return
    end

    local inventory = playerInventories[CharacterId]

    for _, itemData in ipairs(itemsArray) do
        local name = itemData.item
        local count = itemData.count

        if not name or not Config.Items[name] then
            TriggerClientEvent("coca_inventory:statusAlert", src, "Failed to Remove Item")
            return
        end

        local itemRemoved = false

        for index, invItem in ipairs(inventory) do
            if invItem.name == name then
                if invItem.count >= count then
                    invItem.count = invItem.count - count
                    itemRemoved = true
                    print('Removed item from inventory:', name, 'new count:', invItem.count)
                    if invItem.count == 0 then
                        inventory[index] = { name = '', count = 0 }
                        print('Cleared slot as item count is 0:', index)
                    end
                    break
                else
                    TriggerClientEvent("coca_inventory:statusAlert", src, "Not enough items to remove")
                    print('Not enough items to remove: required count:', count, 'available count:', invItem.count)
                    return
                end
            end
        end

        if not itemRemoved then
            TriggerClientEvent("coca_inventory:statusAlert", src, "Item not found in inventory")
            print('Item not found in inventory:', name)
            return
        end
    end

    if completeMsg then
        TriggerClientEvent("coca_inventory:statusAlert", src, completeMsg)
    end

    playerInventories[CharacterId] = inventory
    SavePlayerInventory(CharacterId)
    -- TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
end)



RegisterServerEvent('coca_inventory:Server:RemoveItembyIndex', function(CharacterId, itemIndex, count)
    local src = source
    LoadPlayerInventory(CharacterId, function(inventory)
        playerInventories[CharacterId] = inventory
    end)

    if not playerInventories[CharacterId] then
        print("no inventory found while Remove Item by Index")
        return
    end

    local inventory = playerInventories[CharacterId]
    local invItem = inventory[itemIndex]

    if invItem and invItem.name ~= '' then
        invItem.count = invItem.count - count
        if invItem.count <= 0 then
            inventory[itemIndex] = { name = '', count = 0 } -- Remove the item if count is zero or less
        end

        -- TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
        playerInventories[CharacterId] = inventory
        SavePlayerInventory(CharacterId)
    else
        print("Item does not exist in the specified index or index is invalid.")
    end
end)

RegisterServerEvent('coca_inventory:Server:RemoveItem', function(CharacterId, item, itemCount)
    local src = source
    local count = itemCount or 1
    LoadPlayerInventory(CharacterId, function(inventory)
        playerInventories[CharacterId] = inventory
    end)

    if not playerInventories[CharacterId] then
        print("no inventory found")
        return
    end

    local inventory = playerInventories[CharacterId]

    for index, invItem in ipairs(inventory) do
        if invItem.name == item then
            local cacheCount = invItem.count
            invItem.count = invItem.count - count
            count = count - cacheCount
            if invItem.count <= 0 then
                inventory[index] = { name = '', count = 0 }
            end
            if count <= 0 then break end
        end
    end

    -- TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
    playerInventories[CharacterId] = inventory
    SavePlayerInventory(CharacterId)
end)

RegisterServerEvent('coca_inventory:Server:SellAllItembyCategoryAndGiveCash', function(CharacterId, itemcategory)
    local src = source
    LoadPlayerInventory(CharacterId, function(inventory)
        playerInventories[CharacterId] = inventory
    end)

    if not playerInventories[CharacterId] then
        print("no inventory found")
        return
    end

    local inventory = playerInventories[CharacterId]

    local totolEarning = 0

    for index, invItem in ipairs(inventory) do
        if (invItem.name ~= '') then
            local itemData = Config.Items[invItem.name]
            if itemData.category == itemcategory then
                local cacheCount = invItem.count
                local cacheprice = itemData.price
                totolEarning = totolEarning + (cacheCount * cacheprice)
                inventory[index] = { name = '', count = 0 }
            end
        end
    end

    if totolEarning == 0 then
        TriggerClientEvent("coca_inventory:statusAlert", src, "You don't have any intersting item")
        return
    end

    TriggerEvent('coca_banking:addCashToCharacterId', CharacterId, totolEarning, src)
    -- TriggerClientEvent('coca_inventory:Client:ReceiveInventory', src, inventory)
    playerInventories[CharacterId] = inventory
    SavePlayerInventory(CharacterId)
end)

AddEventHandler("playerDropped", function()
    local sourcePlayer = source
    local characterId = exports['coca_spawnmanager']:GetCharacterIdByServerId(source)
    SavePlayerInventory(characterId)
    if playerInventories[CharacterId] then
        playerInventories[characterId] = nil
    end
    print('player ' .. sourcePlayer .. ' with id ' .. characterId .. ' inventory saved');
end)

RegisterServerEvent('coca_inventory:Server:SaveNewInventory', function(characterId, newInventory)
    local src = source
    TriggerClientEvent('coca_inventory:Client:setInventory', src, newInventory)
    playerInventories[characterId] = newInventory
    SavePlayerInventory(characterId)
end)

RegisterServerEvent('coca_inventory:Server:ItemUse', function(characterId, index, Inventory)
    local src = source
    playerInventories[characterId] = Inventory
    local itemIndex = index + 1
    local UsedItemName = playerInventories[characterId][itemIndex].name
    TriggerClientEvent('coca_inventory:Client:setInventory', src, Inventory)
    TriggerClientEvent('coca_inventory:Client:ItemUse', src, UsedItemName, itemIndex)
end)

-- Function to fetch character by ID
function FetchCharacterById(characterId)
    local result = DBQuery("SELECT * FROM characters WHERE id = '" .. characterId .. "'")
    if result and #result > 0 then
        return result[1]
    else
        return nil;
    end
end

RegisterServerEvent('coca_inventory:CashCheck', function(cost, characterId)
    local src = source
    local data = FetchCharacterById(characterId)
    local currentCash = tonumber(data.cash)

    if currentCash >= cost then
        local newCashBalance = currentCash - cost

        local query = "UPDATE characters SET cash = '" ..
            newCashBalance .. "' WHERE id = '" .. characterId .. "'"
        DBQuery(query)

        TriggerClientEvent('coca_banking:ShowCash', src, newCashBalance, true)
        TriggerClientEvent('coca_banking:removeCash', src, cost)
        TriggerClientEvent('coca_inventory:paymentReturn', src, true)
    else
        TriggerClientEvent('coca_inventory:paymentReturn', src, false)
    end
end)

local carInventoryAccess = {}  -- Track which player has the car inventory opened by plate

-- Function to fetch character by ID
function FetchVehicleInventory(plate)
    local result = DBQuery("SELECT * FROM vehicle_inventories WHERE plate = '" .. plate .. "'")
    if result and #result > 0 then
        return result[1]
    else
        return nil
    end
end

-- Event to request opening the car inventory
RegisterServerEvent('coca_inventory:Server:RequestOpenCarInventory')
AddEventHandler('coca_inventory:Server:RequestOpenCarInventory', function(inventoryType, plate, vehicleClassName)
    local src = source
    print(json.encode(carInventoryAccess))
    -- Check if the car inventory is already opened by another player
    if carInventoryAccess[plate] and carInventoryAccess[plate] ~= src then
        -- Notify the player that the inventory is already opened
        TriggerClientEvent('coca_inventory:Client:AccessDenied', src, inventoryType)
    else
        -- Mark the car inventory as opened by the current player
        carInventoryAccess[plate] = src
        -- Fetch the inventory data and open the inventory for the player
        local inventoryData = FetchVehicleInventory(plate)
        TriggerClientEvent('coca_inventory:Client:OpenCarInventory', src, inventoryType, inventoryData)

        TriggerClientEvent('coca_inventory:Client:AccessGranted', src, inventoryType, vehicleClassName)
    end
end)

-- Function to update or create vehicle inventory
local function UpdateVehicleInventory(plate, newInventory, inventoryType)
    local inventoryColumn = (inventoryType == 'glovebox') and 'glovebox_inventory' or 'trunk_inventory'
    local encodedInventory = json.encode(newInventory)
    print("update", encodedInventory)

    MySQL.Async.fetchAll(
    'SELECT plate, glovebox_inventory, trunk_inventory FROM vehicle_inventories WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] then
            -- Plate exists, update the specific inventory column
            MySQL.Async.execute(
            'UPDATE vehicle_inventories SET ' .. inventoryColumn .. ' = @inventory WHERE plate = @plate', {
                ['@inventory'] = encodedInventory,
                ['@plate'] = plate
            }, function(rowsChanged)
                -- After updating inventory, release the car inventory access
                carInventoryAccess[plate] = nil
            end)
        else
            -- Plate does not exist, insert new entry with initial empty inventories
            local initialGloveboxInventory = (inventoryType == 'glovebox') and encodedInventory or json.encode({})
            local initialTrunkInventory = (inventoryType == 'trunk') and encodedInventory or json.encode({})

            local query =
            'INSERT INTO vehicle_inventories (plate, glovebox_inventory, trunk_inventory) VALUES (@plate, @glovebox_inventory, @trunk_inventory)'
            MySQL.Async.execute(query, {
                ['@plate'] = plate,
                ['@glovebox_inventory'] = initialGloveboxInventory,
                ['@trunk_inventory'] = initialTrunkInventory
            }, function(rowsChanged)
                -- After inserting inventory, release the car inventory access
                carInventoryAccess[plate] = nil
            end)
        end
    end)
end

-- Server-Side Event to Set Glovebox Inventory
RegisterNetEvent('coca_inventory:Server:SetGloveBoxInventory', function(plate, newInventory)
    local src = source
    UpdateVehicleInventory(plate, newInventory, 'glovebox')
end)

-- Server-Side Event to Set Trunk Inventory
RegisterNetEvent('coca_inventory:Server:SetTrunkInventory', function(plate, newInventory)
    local src = source
    UpdateVehicleInventory(plate, newInventory, 'trunk')
end)

-- Server-Side Event to Handle when a player closes the car inventory
RegisterNetEvent('coca_inventory:Client:CloseCarInventory')
AddEventHandler('coca_inventory:Client:CloseCarInventory', function(plate)
    local src = source
    if carInventoryAccess[plate] == src then
        carInventoryAccess[plate] = nil  -- Release the car inventory access
    end
end)
