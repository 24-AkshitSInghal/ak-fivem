local Drops = {}
local DropLocks = {}

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local alldrop = Drops
        local playerServerId = GetPlayerServerId(PlayerId())
        for k, v in pairs(alldrop) do
            local dist = #(coords - v.coords)
            if dist <= 8 then
                sleep = 0
                DrawMarker(2, v.coords.x, v.coords.y, v.coords.z - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15,
                    255, 255, 255, 155, false, false, false, 0, false, false, false)

                if IsDisabledControlJustPressed(0, Keys['TAB']) and dist <= 2 and not IsPedSittingInAnyVehicle(ped) then
                    local dropId = v.id
                    -- Request to lock the drop
                    TriggerServerEvent('coca_inventory:Server:LockDrop', dropId)

                    RequestAnimDict("pickup_object")
                    while not HasAnimDictLoaded("pickup_object") do
                        Wait(7)
                    end
                    TaskPlayAnim(ped, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)

                    Wait(2000)
                    ClearPedTasks(ped)
                    if DropLocks[dropId] == playerServerId then
                        for _, item in ipairs(v.inventory) do
                            local itemConfig = Config.Items[item.name]

                            if not itemConfig then goto continue end

                            for key, value in pairs(itemConfig) do
                                item[key] = value
                            end

                            ::continue::
                        end
                        RefreshNuiOtherInventory(v)
                    else
                        print("Drop is currently locked by another player.")
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('playerSpawned', function()
    TriggerServerEvent('coca_inventory:Server:RequestSync')
end)

RegisterNetEvent('coca_inventory:Client:AddNewDrop', function(newDropInventory)
    table.insert(Drops, newDropInventory)
end)

RegisterNetEvent('coca_inventory:Client:SyncDrops', function(droppedItems)
    Drops = droppedItems
end)

RegisterNetEvent('coca_inventory:Client:LockDrop', function(dropId, sourceId)
    DropLocks[dropId] = sourceId
end)

RegisterNetEvent('coca_inventory:Client:UnlockDrop', function(dropId)
    DropLocks[dropId] = nil
end)

function GenerateUniqueId(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local uniqueId = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        uniqueId = uniqueId .. charset:sub(rand, rand)
    end
    return uniqueId
end

RegisterNUICallback('UI-NewDropInventory', function(data, cb)
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    local recivedDropInventory = data

    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Wait(7)
    end
    TaskPlayAnim(ped, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)
    Wait(2000)
    ClearPedTasks(ped)

    -- Prepare drop inventory data
    local DropNewInventory = {}

    for index, item in ipairs(recivedDropInventory) do
        if not item.name or item.name == '' then
            table.insert(DropNewInventory, index, { name = '', count = 0 })
        else
            local newItem = { name = item.name, count = item.count }
            table.insert(DropNewInventory, index, newItem)
        end
    end

    -- Create dropdata table including DropNewInventory and coordinates
    local dropdata = {
        id = GenerateUniqueId(15),
        inventory = DropNewInventory,
        coords = vector3(coords)
    }
    -- Trigger server event to handle item drop with dropdata
    TriggerServerEvent('coca_inventory:Server:SetNewDrop', dropdata)
    cb('ok')
end)

RegisterNUICallback('UI-UpdateDroppedInventory', function(data, cb)
    local ped = GetPlayerPed(-1)
    local recivedDropInventory = data.inventory
    local dropCoords = data.coords
    local id = data.id

    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Wait(7)
    end
    TaskPlayAnim(ped, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)
    Wait(2000)
    ClearPedTasks(ped);

    -- Prepare drop inventory data
    local emptyslot = 0;

    local DropNewInventory = {}

    for index, item in ipairs(recivedDropInventory) do
        if not item.name or item.name == '' then
            table.insert(DropNewInventory, index, { name = '', count = 0 })
            emptyslot = emptyslot + 1
        else
            local newItem = { name = item.name, count = item.count }
            table.insert(DropNewInventory, index, newItem)
        end
    end

    local dropdata = {
        id = data.id,
        inventory = DropNewInventory,
        coords = vector3(dropCoords.x, dropCoords.y, dropCoords.z)
    }

    if emptyslot == 80 then
        TriggerServerEvent('coca_inventory:Server:DeleteDrop', dropdata)
    else
        TriggerServerEvent('coca_inventory:Server:UpdateDrop', dropdata)
    end
  
    TriggerServerEvent('coca_inventory:Server:UnlockDrop', data.id)
    cb('ok')
end)
