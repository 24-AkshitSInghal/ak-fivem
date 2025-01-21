---@diagnostic disable: param-type-mismatch
local PlayerInventory = nil

function SpawnItem(name,count)
    local CharacterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    TriggerServerEvent('coca_inventory:Server:AddItem', CharacterId, name, count)
end

RegisterCommand('spawnitem', function(source, args)
    local name = args[1]
    local count = tonumber(args[2]) or 1
    SpawnItem(name, count)
end)

function SetNewInventory(newInventory)
    PlayerInventory = newInventory
end

function HasItemInInventory(item, count)
    itemCount = count or 1
    FetchPlayerInventory()
    Wait(250)
    local hasItem = false
    for _, invItem in pairs(PlayerInventory) do
        if invItem.name == item and invItem.count >= itemCount then
            hasItem = true
            break
        end
    end
    return hasItem
end

function HasWeaponinInventory(item)
    local hasItem = false
    for _, invItem in pairs(PlayerInventory) do
        if invItem.name == item and invItem.count >= 1 then
            hasItem = true
            break
        end
    end
    return hasItem
end

function GetItemNamefromIndex(index)
    FetchPlayerInventory()
    Wait(500)
    return PlayerInventory[index].name
end

function ReturnItemCount(item)
    FetchPlayerInventory()
    Wait(250)
    local hasItem = false
    local totalCount = 0;
    for _, invItem in pairs(PlayerInventory) do
        if invItem.name == item and invItem.count >= 1 then
            hasItem = true
            totalCount = totalCount + invItem.count;
        end
    end

    if not hasItem then return 0 end
    return totalCount
end

function GetInventoryWeight()
    local weight = 0
    for _, invItem in ipairs(PlayerInventory) do
        if invItem.name ~= '' and Config.Items[invItem.name] then
            weight = weight + (Config.Items[invItem.name].weight * invItem.count)
        end
    end
    return weight
end

function GetInventoryFreeSlot()
    local freeslot = false;

---@diagnostic disable-next-line: param-type-mismatch
    for _, invItem in ipairs(PlayerInventory) do
        if invItem.name == item and not Config.Items[item].unique then
            freeslot = true;
            break
        elseif invItem.name == '' then
            freeslot = true;
            break
        end
    end
    return freeslot
end

RegisterNetEvent('coca_inventory:Client:ReceiveInventory', function(inventory)
    PlayerInventory = inventory
    if not inventory or #inventory == 0 then
        inventory = {}
        for i = 1, 30 do
            table.insert(inventory, { name = '', count = 0 })
        end
    end
    for index, item in ipairs(inventory) do
        local itemConfig = Config.Items[item.name]
        if not itemConfig then goto continue end
        for key, value in pairs(itemConfig) do
            item[key] = value
        end
        ::continue::
    end
    RefreshNuiPlayerInventory(inventory)
end)

-- RegisterNetEvent('coca_inventory:coca_inventory:Client:setInventory', function(inventory)
--     PlayerInventory = inventory
-- end)

local function RemoveInventoryItem(itemName, count)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    local number = count or 1
    TriggerServerEvent("coca_inventory:Server:RemoveItem", characterId, itemName, number)
end

exports('phoneCheckerFunction', function()
    return HasItemInInventory('phone')
end)

exports('HasItemInInventory', HasItemInInventory)
exports('ReturnItemCount', ReturnItemCount)
exports('RemoveInventoryItem', RemoveInventoryItem)




