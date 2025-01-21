local stashData = {}
local isStashLocked = true -- New variable to track if the stash is locked

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

CreateThread(function()
    while true do
        local sleep = 1500
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local Stashes = Config.Stashes
        for k, v in pairs(Stashes) do
            local dist = #(coords - v.coords)
            if dist <= 5 then
                sleep = 0
                DrawMarker(2, v.coords.x, v.coords.y, v.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.30, 0.30, 0.30,
                    v.color.r, v.color.g, v.color.b, 155, false, false, false, 0, false, false, false)

                if IsDisabledControlJustPressed(0, Keys['K']) and dist <= 2 and not IsPedSittingInAnyVehicle(ped) then
                    local fraction = exports['coca_spawnmanager']:GetCharacterFraction()
                    local fractionPost = exports['coca_spawnmanager']:GetCharacterFractionPost()

                    print(fraction, fractionPost)

                    local requiredFraction = Stashes[v.stashname].fraction
                    local requiredFractionPost = Stashes[v.stashname].post

                    print(requiredFraction, requiredFractionPost)

                    local isFractionPostValid = false
                    if requiredFractionPost then
                        for _, post in ipairs(requiredFractionPost) do
                            if fractionPost == post then
                                isFractionPostValid = true
                                break
                            end
                        end
                    end

                    if fraction == requiredFraction or fraction == 'admin' then
                        if requiredFractionPost == nil or isFractionPostValid or fraction == 'admin' then
                            TriggerServerEvent('coca_inventory:Server:RequestStashData', v.stashname)

                            RequestAnimDict("pickup_object")
                            while not HasAnimDictLoaded("pickup_object") do
                                Wait(7)
                            end
                            TaskPlayAnim(ped, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)
                            Wait(2000)

                            ClearPedTasks(ped)

                            if not isStashLocked then
                                for _, item in ipairs(stashData) do
                                    local itemConfig = Config.Items[item.name]

                                    if not itemConfig then goto continue end

                                    for key, value in pairs(itemConfig) do
                                        item[key] = value
                                    end

                                    ::continue::
                                end

                                v.inventory = stashData

                                ToggleInventory('stash', Config.invetoryData[v.type].MaxWeight)
                                RefreshNuiOtherInventory(v)
                            end
                        else
                            drawNativeNotification('You don\'t have key')
                        end
                    else
                        drawNativeNotification('You don\'t have key')
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('coca_inventory:Server:ReceiveStash', function(recivedStash)
    stashData = recivedStash
    isStashLocked = false -- Lock the stash when data is received
end)

RegisterNetEvent('coca_inventory:Server:StashLocked', function()
    TriggerEvent('chat:addMessage', { args = { '^1Stash is currently locked.' } })
end)

RegisterNUICallback('UI-UpdateStash', function(data, cb)
    local reciviedInventory = data.inventory
    local stashname = data.stashname

    local ped = GetPlayerPed(-1)

    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do
        Wait(7)
    end
    TaskPlayAnim(ped, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)

    local StashNewInventory = {}
    for index, item in ipairs(reciviedInventory) do
        if not item.name or item.name == '' then
            table.insert(StashNewInventory, index, { name = '', count = 0 })
        else
            local newItem = { name = item.name, count = item.count }
            table.insert(StashNewInventory, index, newItem)
        end
    end

    TriggerServerEvent('coca_inventory:Server:SaveStash', stashname, StashNewInventory)
    Wait(2000)
    ClearPedTasks(ped)
    isStashLocked = true
    TriggerServerEvent('coca_inventory:Server:ReleaseStash', stashname) -- Release the lock
    cb('ok')
end)
