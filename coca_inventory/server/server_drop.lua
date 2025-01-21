local Drops = {}
local DropLocks = {}

RegisterNetEvent('coca_inventory:Server:SetNewDrop', function(dropInventory)
    table.insert(Drops, dropInventory)
    TriggerClientEvent('coca_inventory:Client:AddNewDrop', -1, dropInventory)
end)

RegisterNetEvent('coca_inventory:Server:DeleteDrop', function(dropInventory)
    local dropCoords = dropInventory.coords
    for index, item in ipairs(Drops) do
        if item.coords == dropCoords then
            table.remove(Drops, index)
            break
        end
    end

    TriggerClientEvent('coca_inventory:Client:SyncDrops', -1, Drops)
end)

RegisterNetEvent('coca_inventory:Server:UpdateDrop', function(dropInventory)
    local dropCoords = dropInventory.coords
    for index, item in ipairs(Drops) do
        if item.coords == dropCoords then
            item.inventory = dropInventory.inventory
        end
    end

    TriggerClientEvent('coca_inventory:Client:SyncDrops', -1, Drops)
end)

RegisterNetEvent('coca_inventory:Server:RequestSync', function()
    local playerId = source
    TriggerClientEvent('coca_inventory:Client:SyncDrops', playerId, Drops)
end)

RegisterNetEvent('coca_inventory:Server:LockDrop', function(dropId)
    if DropLocks[dropId] == nil then
        -- Lock the drop
        DropLocks[dropId] = source
        TriggerClientEvent('coca_inventory:Client:LockDrop', -1, dropId, source)
    else
        -- Drop is already locked
        TriggerClientEvent('coca_inventory:Client:LockDrop', source, dropId, nil)
    end
end)

RegisterNetEvent('coca_inventory:Server:UnlockDrop', function(dropId)
    if DropLocks[dropId] == source then
        -- Unlock the drop
        DropLocks[dropId] = nil
        TriggerClientEvent('coca_inventory:Client:UnlockDrop', -1, dropId)
    end
end)
