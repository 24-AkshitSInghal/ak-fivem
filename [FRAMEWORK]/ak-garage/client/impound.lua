Citizen.CreateThread(function()
    local bliploc = Config.impound.loc
    local blip = AddBlipForCoord(vector3(bliploc.x, bliploc.y, bliploc.z))

    SetBlipSprite(blip, 635)
    SetBlipColour(blip, 0)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Impound')
    EndTextCommandSetBlipName(blip)
end)

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.35
    local factor = (string.len(text)) / 370
    local width = 0.015 + factor
    local height = 0.03

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)

    -- Draw background rectangle
    DrawRect(_x, _y + 0.0125, width, height, 41, 11, 41, 68)
end

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local isMenuClosed = true

Citizen.CreateThread(function()
    local characterId = nil

    while not characterId do
        print(characterId)
        characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
        Wait(1000)
    end


    while true do
        local sleep = 1000

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = Config.impound.loc
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))

        if isMenuClosed and distance < 5.0 then
            sleep = 5
            DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z, "Press ~b~[E]~w~ to see your impound vehicles")

            if IsControlJustReleased(0, 38) then
                isMenuClosed = false
                TriggerServerEvent('ak-garage:getOwnedVehicles', characterId)
            end
        end
        Citizen.Wait(sleep)
    end
end)

local impoundReleaseLocation = vector3(-132.832, -1178.57, 23.77)

function ReleaseVehicleFromImpound(payload)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    if exports.coca_banking:RemoveCash(characterId, 1000) then
        local model = GetHashKey(payload.vehicle_model)
        RequestModel(model)


        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end

        local vehicles = GetGamePool('CVehicle')
        print("plate", payload.plate)
        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) and GetVehicleNumberPlateText(vehicle) == payload.plate then
                DeleteEntity(vehicle)
            end
        end


        local vehicle = CreateVehicle(model, impoundReleaseLocation, 92.209, true, false)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        print("data", json.encode(payload.properties))
        if payload.properties then
            SetVehicleProperties(vehicle, json.decode(payload.properties))
        else
            SetVehicleNumberPlateText(vehicle, payload.plate)
        end
        

        SetVehicleIsStolen(vehicle, false)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleOnGroundProperly(vehicle)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehRadioStation(vehicle, "OFF")
        SetVehicleHasBeenOwnedByPlayer(vehicle, true) --SUGGESTION BY TIGODEV (FORUM)
        SetVehicleIsWanted(vehicle, false)        --SUGGESTION BY TIGODEV (FORUM)

        drawNativeNotification("~y~Shaggy~w~: Your Vehicle with plate ~y~" .. payload.plate .. "~w~ has been released from impound")
    end
end

RegisterNetEvent('ak-garage:receiveOwnedVehicles', function(ownedVehicles)
    local selected = false

    local vehicles = GetGamePool('CVehicle')

    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            for i = #ownedVehicles, 1, -1 do
                if ownedVehicles[i].plate == plate then
                    table.remove(ownedVehicles, i)
                end
            end
        end
    end

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local menuLoc = Config.impound.loc
        local distance = #(playerCoords - vector3(menuLoc.x, menuLoc.y, menuLoc.z))

        if distance < 5 then
            DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 1, "    Your Impounded vehicles - $1000   ")

            local offsetY = 0.1
            local maxDisplayed = 4
            local vehiclesDisplayed = 0

            for i, vehicle in ipairs(ownedVehicles) do
                if vehiclesDisplayed < maxDisplayed then
                    local text = string.format("%d. ~b~%s~w~ [~y~%s~w~] - Press ~b~[%d]~w~ to release from impound",
                        i,
                        vehicle.vehicle_model,
                        vehicle.plate, i + 5)
                    DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 0.9 - offsetY * vehiclesDisplayed, text)

                    if IsDisabledControlJustReleased(0, 159) then
                        ReleaseVehicleFromImpound(vehicle)
                        isMenuClosed = true
                        selected = true
                        break
                    end
                    if IsDisabledControlJustReleased(0, 161) then
                        ReleaseVehicleFromImpound(vehicle)
                        isMenuClosed = true
                        selected = true
                        break
                    end
                    if IsDisabledControlJustReleased(0, 162) then
                        ReleaseVehicleFromImpound(vehicle)
                        isMenuClosed = true
                        selected = true
                        break
                    end
                    if IsDisabledControlJustReleased(0, 163) then
                        ReleaseVehicleFromImpound(vehicle)
                        isMenuClosed = true
                        selected = true
                        break
                    end

                    vehiclesDisplayed = vehiclesDisplayed + 1
                end
            end

            if selected then
                break
            end

            if #ownedVehicles > maxDisplayed then
                local text = "Your " .. #ownedVehicles - maxDisplayed .. "are impounded here"
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 1 - offsetY * (vehiclesDisplayed + 1), text)
                DrawText3D(menuLoc.x, menuLoc.y, menuLoc.z + 1 - offsetY * (vehiclesDisplayed + 2),
                    "First release the above vehicle")
            end
        else
            isMenuClosed = true
            break
        end
        Citizen.Wait(0)
    end
end)
