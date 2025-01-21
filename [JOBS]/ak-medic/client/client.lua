local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    return animDict
end

local characterId = nil
local fraction = nil

CreateThread(function()
    while true do
        Wait(1500)
        characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
        if characterId then
            fraction = exports['coca_spawnmanager']:GetCharacterFraction()
            break
        end
    end
end)

Citizen.CreateThread(function()
    local bliploc = vector3(312.24, -592.55, 43.28)
    local blip = AddBlipForCoord(vector3(bliploc.x, bliploc.y, bliploc.z))
    SetBlipSprite(blip, 61)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Hospital") -- Blip name
    EndTextCommandSetBlipName(blip)
end)


-- HELI SPAWM

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(352.29, -588.29, 74.16)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "ems" or fraction == 'admin' then
            if distance < 5.0 and not IsPedInAnyHeli(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~r~[E]~w~ to take out EMS Helicopter")

                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('ak-medic:requestHeli', menuLoc, 150.0)
                    Wait(5000)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent('ak-medic:spawnHeli', function(model, coords, heading)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end

    local heli = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(PlayerPedId(), heli, -1)
    SetVehicleLivery(heli, 1)
    local plate = GetVehicleNumberPlateText(heli)
    TriggerEvent("ak-carlock:addCarPlate", plate)
end)


RegisterNetEvent('ak-medic:heliCooldownStatus', function(model, coords, heading)
    drawNativeNotification("Helicopter is already out please wait some time")
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(352.29, -588.29, 74.16)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "ems" or fraction == 'admin' then
            if distance < 5.0 and IsPedInAnyHeli(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~r~[E]~w~ to store Heli")

                if IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    DeleteEntity(vehicle)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- AMBULANCE SPAWN

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(332.12, -578.19, 28.79)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "ems" or fraction == 'admin' then
            if distance < 5.0 and not IsPedInAnyVehicle(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~r~[E]~w~ to take out Ambulance")

                if IsControlJustReleased(0, 38) then
                    local existingVehicle = GetClosestVehicle(menuLoc, 6.0, 0, 71)
                    print(existingVehicle)
                    if existingVehicle == 0 then
                        TriggerServerEvent('ak-medic:requestAmbulance', menuLoc, 347.24)
                        Wait(5000)
                    else
                        drawNativeNotification("Ambulance parking area is not clear")
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent('ak-medic:spawnAmbulance', function(model, coords, heading)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end

    local heli = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(PlayerPedId(), heli, -1)
    SetVehicleLivery(heli, 0)
    local plate = GetVehicleNumberPlateText(heli)
    TriggerEvent("ak-carlock:addCarPlate", plate)
end)


RegisterNetEvent('ak-medic:AmbulanceCooldownStatus', function(model, coords, heading)
    drawNativeNotification("A Ambulance is already out please wait some time")
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(324.22, -577.41, 28.79)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "ems" or fraction == 'admin' then
            if distance < 5.0 and IsPedInAnyVehicle(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~r~[E]~w~ to store Ambulance")

                if IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if GetEntityModel(vehicle) == GetHashKey("ambulance") then
                        DeleteVehicle(vehicle)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


-- Hidden Treatment

CreateThread(function()
    local sleep = 1500
    local started = false
    local coords = vector3(-282.97, 4722.27, 136.621)
    local healCost = 8000
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    while true do
        local playerId = PlayerPedId()
        local plyCoords = GetEntityCoords(playerId, false)
        local distance = #(vector3(coords.x, coords.y, coords.z) - plyCoords)

        if distance < 3 and not IsPedInAnyVehicle(playerId, true) then
            sleep = 0
            DrawText3D(coords.x, coords.y, coords.z - 0.5, '~d~[E]~s~ - Get treated by Grandma for ~r~$' .. healCost)


            if IsControlJustReleased(0, 54) then
                if exports['coca_player_carry']:carryinprogress() then
                    drawNativeNotification('drop down')
                else
                    started = true
                end
            end

            if GetEntityHealth(playerId) < 200 and started then
                if exports.coca_banking:RemoveCash(characterId, healCost) then
                    DisableControlAction(0, 38, true)
                    DisableControlAction(0, 24, true)

                    local animDict = "timetable@tracy@sleep@"
                    local anim = "idle_c"
                    local flag = 33

                    ensureAnimDict(animDict)

                    local timer = 30000 -- in miliseconds
                    local progressStartTime = GetGameTimer()
                    local endTime = progressStartTime + timer

                    while GetGameTimer() < endTime do
                        if not IsEntityPlayingAnim(playerId, animDict, anim, 3) then
                            TaskPlayAnim(playerId, animDict, anim, 8.0, -8.0, -1, flag, 0, false, false, false)
                            FreezeEntityPosition(playerId, true)
                        end

                        local progress = (GetGameTimer() - progressStartTime) / timer
                        DrawText3D(coords.x, coords.y, coords.z - 0.5,
                            'Grandma is treating you. Progress: ~d~' .. math.floor(progress * 100) .. '%')
                        Wait(0)
                    end

                    ClearPedTasks(playerId)
                    FreezeEntityPosition(playerId, false)
                    EnableControlAction(0, 54, true)
                    SetEntityHealth(playerId, 200)
                    drawNativeNotification('You have been treated.')
                    started = false
                else
                    started = false
                end
            elseif started then
                drawNativeNotification('You do not need medical attention')
                started = false
            end
        else
            sleep = 1500
        end

        Wait(sleep)
    end
end)

-- elvator

local elevatorLocations = {
    { x = 339.60,        y = -584.62,        z = 28.79,        targetX = 330.37,  targetY = -601.019, targetZ = 43.284 }, -- Example coordinates
    { targetX = 344.682, targetY = -586.263, targetZ = 28.3,   x = 330.37,        y = -601.019,       z = 43.284 },       -- Example coordinates
    { x = 327.27,        y = -603.87,        z = 43.284,       targetX = 339.285, targetY = -584.33,  targetZ = 74.162 }, -- Example coordinates
    { targetX = 327.27,  targetY = -603.87,  targetZ = 43.284, x = 339.285,       y = -584.33,        z = 74.162 }        -- Example coordinates
}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        if fraction == "ems" or fraction == 'admin' then
            for _, location in ipairs(elevatorLocations) do
                local distance = #(playerCoords - vector3(location.x, location.y, location.z))

                if distance < 2.0 then
                    sleep = 5
                    DrawText3D(location.x, location.y, location.z, "Press ~r~[E]~w~ to use the elevator")

                    if IsControlJustReleased(0, 38) then
                        SetEntityCoords(playerPed, location.targetX, location.targetY, location.targetZ)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


-- Utility functions

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
end

function playerHasItem(requiredItems)
    local hasAllItems = true

    for _, itemData in ipairs(requiredItems) do
        local itemName = itemData.item
        local itemCount = itemData.count

        local hasItem = exports.coca_inventory:HasItemInInventory(itemName, itemCount)

        if not hasItem then
            hasAllItems = false
            break
        end
    end

    return hasAllItems
end

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = nil
    local pCoords = GetEntityCoords(PlayerPedId(), false)

    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= PlayerPedId() then
            local tCoords = GetEntityCoords(targetPed, false)
            local distance = #(pCoords - tCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = player
                closestPed = targetPed
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestPed
end

function PlayAnimation(ped, dict, anim, duration, flag)
    LoadAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, 1.0, duration or -1, flag or 0, 0, false, false, false)
end

function StopAnimation(ped, dict, anim)
    StopAnimTask(ped, dict, anim, 1.0)
end

-- Main command

RegisterCommand('checkhealth', function()
    local characterId = nil
    local fraction = nil
    while true do
        Wait(1500)
        characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
        if characterId then
            fraction = exports['coca_spawnmanager']:GetCharacterFraction()
            break
        end
    end

    local ped = GetPlayerPed(-1)
    local nearestPlayer, nearestPlayerPed = GetClosestPlayer()
    local hospitalCoords = vector3(316.52, -582.59, 43.28)

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local coords = GetEntityCoords(nearestPlayerPed)
        local sleep = 1500

        if fraction == "ems" or fraction == 'admin' then
            local dist = #(playerCoords - coords)
            if dist <= 2 then
                sleep = 0
                if nearestPlayer ~= -1 and DoesEntityExist(nearestPlayerPed) then
                    local playerHealth = GetEntityHealth(nearestPlayerPed)
                    local requiredBandages = math.ceil((200 - playerHealth) / 40)
                    local requiredMedicines = math.ceil((200 - playerHealth) / 60)

                    DrawText3D(coords.x, coords.y, coords.z + 0.7,
                        "        - Bandage x ~b~" .. requiredBandages .. "          ")
                    DrawText3D(coords.x, coords.y, coords.z + 0.8,
                        "        - Medicines x ~b~" .. requiredMedicines .. "            ")
                    DrawText3D(coords.x, coords.y, coords.z + 0.5, " Press ~b~[E]~w~ to use EMS Kit ")
                    DrawText3D(coords.x, coords.y, coords.z + 0.4, " Press ~b~[k]~w~ stop checking ")
                    if IsControlJustReleased(0, 311) then
                        break
                    end
                    print(#(hospitalCoords - coords))
                    if IsControlJustReleased(0, 38) and not IsPedSittingInAnyVehicle(ped) then
                        if (#(hospitalCoords - coords) < 20) then
                            local itemRequired = {
                                { item = "bandage",   count = requiredBandages },
                                { item = "medicines", count = requiredMedicines },
                            }
                            if playerHasItem(itemRequired) then
                                TriggerEvent('coca_inventory:stopInventoryUI', true)
                                TriggerServerEvent('coca_inventory:Server:RemoveMultipleItems', characterId, itemRequired)
                                PlayAnimation(ped, 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest', -1, 1)

                                Citizen.Wait(10000)

                                StopAnimation(ped, 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest')
                                drawNativeNotification("EMS Kit used successfully")
                                TriggerEvent('coca_inventory:stopInventoryUI', false)
                                TriggerServerEvent("healPlayer", GetPlayerServerId(nearestPlayer)) -- Heal the nearest player
                                break;
                            else
                                drawNativeNotification("You don't have the required items.")
                            end
                        else
                            drawNativeNotification("You do not have equipments here, take the player to the ~r~hospital")
                        end
                        
                   
                    end
                else
                    drawNativeNotification("No players nearby")
                end
            else
                break
            end
        else
            break
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("healPlayer", function()
    local playerPed = PlayerPedId()
    NetworkResurrectLocalPlayer(GetEntityCoords(playerPed, true), true, false)
    Wait(200)
    SetEntityHealth(playerPed, 200)
    Config.DiscordNotification = false
end)

TriggerEvent('chat:addSuggestion', '/respawn', '(admin) respawn yourself')
RegisterCommand("respawn", function()
    local playerPed = PlayerPedId()
    NetworkResurrectLocalPlayer(GetEntityCoords(playerPed, true), true, false)
    Wait(200)
    SetEntityHealth(playerPed, 200)
    Config.DiscordNotification = false
end)
