
local spawnedItems = 0
local Salvage = {}
local isPickingUp = false

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

local function playAnimation(playerPed, animDict, animName, flags)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, flags, 0, false, false, false)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        local coords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(coords, Config.CircleZones.SalvageField.coords, true) < 50 then
            if #Salvage == 0 then
                SpawnSalvage()
            end
        else
            spawnedItems = 0
            for k, v in pairs(Salvage) do
                DeleteObject(v)
            end
            Salvage = {}
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for i = 1, #Salvage, 1 do
            local salvageCoords = GetEntityCoords(Salvage[i])
            if GetDistanceBetweenCoords(coords, salvageCoords, false) < 1.5 then
                if IsPedOnFoot(playerPed) then
                    sleep = 5
                    if not isPickingUp then
                        DrawText3D(salvageCoords.x, salvageCoords.y, salvageCoords.z, "Press ~d~[E]~w~ to search")
                    end

                    if IsControlJustReleased(0, 38) and not isPickingUp then
                        isPickingUp = true
                        TriggerEvent('coca_inventory:stopInventoryUI', true)

                        CreateThread(function()
                            local startTime = GetGameTimer()
                            while (GetGameTimer() - startTime) < 10000 do
                                local progress = math.floor(((GetGameTimer() - startTime) / 10000) * 100)
                                DrawText3D(coords.x, coords.y, coords.z + 0.2, "Searching: ~d~" .. progress .. "%")
                                Citizen.Wait(0)
                            end
                        end)

                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_KNEEL', 0, false)
                        FreezeEntityPosition(playerPed, true)
                        playAnimation(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                            "machinic_loop_mechandplayer", 49)
                        Citizen.Wait(10000)
                        ClearPedTasks(playerPed)
                        Citizen.Wait(1500)

                        DeleteObject(Salvage[i])
                        table.remove(Salvage, i)
                        spawnedItems = spawnedItems - 1

                        if math.random(1, 4) == 4 then
                            drawNativeNotification('Found Nothing useful here!')
                        else
                            local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
                            drawNativeNotification('Found ~d~Salvage~w~!')
                            TriggerServerEvent('coca_inventory:Server:AddItem', characterId, 'salvage', 1)
                        end

                        TriggerEvent('coca_inventory:stopInventoryUI', false)
                        FreezeEntityPosition(playerPed, false)
                        isPickingUp = false
                        break
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function SpawnSalvage()
    while spawnedItems < 25 do
        Citizen.Wait(0)
        local SalvageCoords = GenerateSalvageCoords()

        local model = GetHashKey('prop_rub_litter_03c')
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end

        local obj = CreateObject(model, SalvageCoords.x, SalvageCoords.y, SalvageCoords.z, false, false, false)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)

        table.insert(Salvage, obj)
        local coord = GetEntityCoords(obj)
        local blip = AddBlipForCoord(coord)

        SetBlipSprite(blip, 486)
        SetBlipColour(blip, 0)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Mining')
        EndTextCommandSetBlipName(blip)
        spawnedItems = spawnedItems + 1
    end
end

function GenerateSalvageCoords()
    while true do
        Citizen.Wait(1)

        local SalvageCoordX, SalvageCoordY

        math.randomseed(GetGameTimer())
        local modX = math.random(-20, 20)

        Citizen.Wait(100)

        math.randomseed(GetGameTimer())
        local modY = math.random(-45, 45)

        SalvageCoordX = Config.CircleZones.SalvageField.coords.x + modX
        SalvageCoordY = Config.CircleZones.SalvageField.coords.y + modY

        local coordZ = GetCoordZ(SalvageCoordX, SalvageCoordY)
        local coord = vector3(SalvageCoordX, SalvageCoordY, coordZ)

        

        if ValidateSalvageCoord(coord) then
            return coord
        end
    end
end

function ValidateSalvageCoord(plantCoord)
    if spawnedItems > 0 then
        for k, v in pairs(Salvage) do
            if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
                return false
            end
        end

        if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.SalvageField.coords, false) > 50 then
            return false
        end
    end
    return true
end

function GetCoordZ(x, y)
    local groundCheckHeights = { 70.0, 71.0, 72.0, 73.0, 74.0, 75.0, 76.0, 77.0, 78.0, 79.0, 80.0, 81.0, 82.0, 83.0, 84.0, 85.0, 86.0, 8.0, 88.0, 89.0, 90.0 }

    for i, height in ipairs(groundCheckHeights) do
        local foundGround, z = GetGroundZFor_3dCoord(x, y, height)
        if foundGround then
            return z
        end
    end
    return 76.0
end
