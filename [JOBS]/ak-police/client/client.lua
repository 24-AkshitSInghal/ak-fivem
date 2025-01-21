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

-- HELI SPAWM

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(449.05, -980.94, 43.59)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "police" or fraction == 'admin' then
            if distance < 5.0 and not IsPedInAnyHeli(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~d~[E]~w~ to take out Police Helicopter")

                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('ak-police:requestHeli', menuLoc, 150.0)
                    Wait(5000)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent('ak-police:spawnHeli', function(model, coords, heading)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end

    local heli = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(PlayerPedId(), heli, -1)
    SetVehicleLivery(heli, 2)
    local plate = GetVehicleNumberPlateText(heli)
    TriggerEvent("ak-carlock:addCarPlate", plate)
end)


RegisterNetEvent('ak-police:heliCooldownStatus', function(model, coords, heading)
    drawNativeNotification("Helicopter is already out please wait some time")
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(449.05, -980.94, 43.59)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "police" or fraction == 'admin' then
            if distance < 5.0 and IsPedInAnyHeli(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~d~[E]~w~ to store Heli")

                if IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    DeleteEntity(vehicle)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- Police Vehicle SPAWN

local policeVehicles = { "police", "police2", "police3", "policeb", "policet" }

function IsPoliceVehicle(model)
    print(model)
    for _, v in ipairs(policeVehicles) do
        print(GetHashKey(v))
        if model == GetHashKey(v) then
            return true
        end
    end
    return false
end

local ismenuOpen = false;
local vehicleKeys = {
    [159] = "police",
    [161] = "police2",
    [162] = "police3",
    [163] = "policeb",
    [84] = "policet" -- 311 corresponds to the 'K' key
}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(431.377, -996.75, 25.76)
        local distance = #(playerCoords - menuLoc)
        if fraction == "police" or fraction == 'admin' then
            if distance < 5.0 and not IsPedInAnyVehicle(playerPed) then
                sleep = 5
                if not ismenuOpen then
                    DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~d~[E]~w~ to open police garage")
                end

                if IsControlJustReleased(0, 38) or ismenuOpen then
                    ismenuOpen = true
                    local existingVehicle = GetClosestVehicle(menuLoc, 6.0, 0, 71)
                    if existingVehicle == 0 then
                        DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 1.0, "          Choose Police Vehicle            ")
                        DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 0.8, "Press ~d~[6]~w~ to takeout police cruiser 1")
                        DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 0.7, "Press ~d~[7]~w~ to takeout police cruiser 2")
                        DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 0.6, "Press ~d~[8]~w~ to takeout police cruiser 3")
                        DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 0.5, "Press ~d~[9]~w~ to takeout police bike")
                        DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 0.4, "Press ~d~[K]~w~ to takeout police transporter")

                        for key, model in pairs(vehicleKeys) do
                            if IsDisabledControlJustReleased(0, key) then
                                print(key)
                                spawnPoliceVehicle(model, menuLoc, 180.1) -- Adjust heading as needed
                                ismenuOpen = false
                                break
                            end
                        end
                    else
                        drawNativeNotification("Police garage entrance is busy")
                    end
                end
            else
                ismenuOpen = false
            end
        end
        Citizen.Wait(sleep)
    end
end)

function spawnPoliceVehicle(model, coords, heading)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent("ak-carlock:addCarPlate", plate)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = vector3(447.41, -996.06, 25.77)
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))
        if fraction == "police" or fraction == 'admin' then
            if distance < 5.0 and IsPedInAnyVehicle(playerPed) then
                sleep = 5
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~d~[E]~w~ to store vehicle")

                if IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if IsPoliceVehicle(GetEntityModel(vehicle)) then
                        DeleteVehicle(vehicle)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- elvator

local elevatorLocations = {
    { x = 445.83,       y = -996.754,       z = 30.690,       targetX = 436.43, targetY = -993.75, targetZ = 25.99 }, -- Example coordinates
    { targetX = 445.83, targetY = -996.754, targetZ = 30.690, x = 452.32,       y = -993.78,       z = 25.99 },       -- Example coordinates
}

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        if fraction == "police" or fraction == 'admin' then
            for _, location in ipairs(elevatorLocations) do
                local distance = #(playerCoords - vector3(location.x, location.y, location.z))

                if distance < 2.0 then
                    sleep = 5
                    DrawText3D(location.x, location.y, location.z, "Press ~d~[E]~w~ to use the Staires")

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

local changeingRoom = vector3(454.221, -989.623, 30.690)

local clothes = {
    male = {
        [1] = {
            ['mask_1']    = 0,
            ['mask_2']    = 0,
            ['arms']      = 0,
            ['tshirt_1']  = 15,
            ['tshirt_2']  = 0,
            ['torso_1']   = 86,
            ['torso_2']   = 0,
            ['bproof_1']  = 0,
            ['bproof_2']  = 0,
            ['decals_1']  = 0,
            ['decals_2']  = 0,
            ['chain_1']   = 0,
            ['chain_2']   = 0,
            ['pants_1']   = 10,
            ['pants_2']   = 2,
            ['shoes_1']   = 56,
            ['shoes_2']   = 0,
            ['helmet_1']  = 34,
            ['helmet_2']  = 0,
            ['glasses_1'] = 34,
            ['glasses_2'] = 1,
        },
        [2] = {
            ['mask_1']    = 0,
            ['mask_2']    = 0,
            ['arms']      = 0,
            ['tshirt_1']  = 15,
            ['tshirt_2']  = 0,
            ['torso_1']   = 86,
            ['torso_2']   = 0,
            ['bproof_1']  = 0,
            ['bproof_2']  = 0,
            ['decals_1']  = 0,
            ['decals_2']  = 0,
            ['chain_1']   = 0,
            ['chain_2']   = 0,
            ['pants_1']   = 10,
            ['pants_2']   = 2,
            ['shoes_1']   = 56,
            ['shoes_2']   = 0,
            ['helmet_1']  = 34,
            ['helmet_2']  = 0,
            ['glasses_1'] = 34,
            ['glasses_2'] = 1,
        },
    },
    female = {
        [1] = {
            ['mask_1']    = 0,
            ['mask_2']    = 0,
            ['arms']      = 0,
            ['tshirt_1']  = 15,
            ['tshirt_2']  = 0,
            ['torso_1']   = 86,
            ['torso_2']   = 0,
            ['bproof_1']  = 0,
            ['bproof_2']  = 0,
            ['decals_1']  = 0,
            ['decals_2']  = 0,
            ['chain_1']   = 0,
            ['chain_2']   = 0,
            ['pants_1']   = 10,
            ['pants_2']   = 2,
            ['shoes_1']   = 56,
            ['shoes_2']   = 0,
            ['helmet_1']  = 34,
            ['helmet_2']  = 0,
            ['glasses_1'] = 34,
            ['glasses_2'] = 1,
        },
    },
}


function changePlayerClothes()
    local playerPed = PlayerPedId()
    local gender = GetEntityModel(playerPed) == GetHashKey("mp_m_freemode_01") and "male" or "female"
    -- local outfit = policeUniforms[gender]

    PlayAnimation(playerPed, "clothingshirt", "try_shirt_positive_d", 2500, 0)
    Citizen.Wait(2500) -- Wait for the animation to finish

    local model = exports["fivem-appearance"]:getPedModel(playerPed)
    local data = nil

    if model == 'mp_m_freemode_01' then
        data = clothes.male[jobGrade] or clothes.male[1]
    elseif model == 'mp_f_freemode_01' then
        data = clothes.female[jobGrade] or clothes.female[1]
    end

    exports["fivem-appearance"]:setPedProps(playerPed, {
        {
            component_id = 0,
            texture = data['helmet_2'],
            drawable = data['helmet_1']
        },
    })

    exports["fivem-appearance"]:setPedComponents(playerPed, {
        {
            component_id = 1,
            texture = data['mask_2'],
            drawable = data['mask_1']
        },
        {
            component_id = 3,
            texture = 0,
            drawable = data['arms']
        },
        {
            component_id = 8,
            texture = data['tshirt_2'],
            drawable = data['tshirt_1']
        },
        {
            component_id = 11,
            texture = data['torso_2'],
            drawable = data['torso_1']
        },
        {
            component_id = 9,
            texture = data['bproof_2'],
            drawable = data['bproof_1']
        },
        {
            component_id = 10,
            texture = data['decals_2'],
            drawable = data['decals_1']
        },
        {
            component_id = 7,
            texture = data['chain_2'],
            drawable = data['chain_1']
        },
        {
            component_id = 4,
            texture = data['pants_2'],
            drawable = data['pants_1']
        },
        {
            component_id = 6,
            texture = data['shoes_2'],
            drawable = data['shoes_1']
        },
        {
            component_id = 5,
            texture = data['bag_color'],
            drawable = data['bag']
        },
    })

    -- Refresh the ped (needed for certain components to apply correctly)
    SetPedDefaultComponentVariation(playerPed)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - changeingRoom)
        if fraction == "police" or fraction == 'admin' then
            if distance < 5.0 then
                sleep = 5
                DrawText3D(changeingRoom.x, changeingRoom.y, changeingRoom.z, "Press ~d~[E]~w~ to change clothes")

                if IsControlJustReleased(0, 38) then
                    changePlayerClothes()
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)






