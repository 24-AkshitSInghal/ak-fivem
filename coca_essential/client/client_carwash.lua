local vehicleWashStation = {
    { x = 26.5906,  y = -1392.0261, z = 27.3634 },
    { x = 175.09,   y = -1736.53,  z = 29.29 },
    { x = -74.5693, y = 6427.8715, z = 29.4400 },
    { x = -699.6325, y = -932.7043, z = 17.0139 },
    { x = 1362.5385, y = 3592.1274, z = 33.9211 },
    { x = -28.95,   y = -1041.43,  z = 27.95 }
}

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

CreateThread(function()
    for _, info in pairs(vehicleWashStation) do
        local blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(blip, 100) -- 100 is the sprite ID for car wash
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Car Wash")
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1500;

        if IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
            for i = 1, #vehicleWashStation do
                local washStation = vehicleWashStation[i]
                if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), washStation.x, washStation.y, washStation.z, true) < 5 then
                    sleep = 5;
                    DrawText3D(washStation.x, washStation.y, washStation.z + 1.0,
                        "Press ~b~[E]~w~ to wash the car for ~g~$50~w~")
                    if IsControlJustPressed(1, 46) then
                        TriggerServerEvent('coca_banking:GetPlayerCash', characterId, function(cash)
                            if cash and cash >= healCost then
                                local playerPed = GetPlayerPed(-1)
                                local vehicle = GetVehiclePedIsUsing(playerPed)
                                local washDuration = 20000 -- 20 seconds
                                local startTime = GetGameTimer()
                                local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

                                -- Freeze the vehicle
                                FreezeEntityPosition(vehicle, true)
                                while (GetGameTimer() - startTime) < washDuration do
                                    local progress = math.floor(((GetGameTimer() - startTime) / washDuration) * 100)
                                    DrawText3D(washStation.x, washStation.y, washStation.z + 1.0,
                                        "Washing in progress: ~b~" .. progress .. "%")
                                    Citizen.Wait(0)
                                end

                                TriggerServerEvent("coca_banking:removeCashToCharacterId", characterId, 50)
                                -- Unfreeze the vehicle
                                FreezeEntityPosition(vehicle, false)

                                WashDecalsFromVehicle(vehicle, 1.0)
                                SetVehicleDirtLevel(vehicle, 0.0)
                                drawNativeNotification('Car is washed')
                            else
                                drawNativeNotification('You do not have enough cash')
                            end
                        end)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)
