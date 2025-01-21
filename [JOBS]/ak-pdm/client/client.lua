---@diagnostic disable: lowercase-global
local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.40, 0.40)
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

Citizen.CreateThread(function()
    local blipInfo = Config.blipLocation
    local blip = AddBlipForCoord(vector3(blipInfo.x, blipInfo.y, blipInfo.z))

    SetBlipSprite(blip, blipInfo.blipSprite)
    SetBlipColour(blip, blipInfo.blipColour)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blipInfo.type)

    EndTextCommandSetBlipName(blip)
end)


Citizen.CreateThread(function()
    while true do
        Sleep = 1500
        local playerid = PlayerPedId()
        local coords = GetEntityCoords(playerid)
        for _, stand in ipairs(Config.Stands) do
            local location = stand.standlocation
            local standLoc = vector3(location.x, location.y, location.z)
            local distance = #(coords - standLoc)
            if distance <= 5 then
                sleep = 5
                DrawText3D(location.x, location.y, location.z + 1.0, "Stand No : ~Bold~" .. stand.standName)
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- Function to check if it's night time
local function IsNightTime()
    local hour = GetClockHours()
    return hour >= 20 or hour < 6
end


local carAtStandOneData = nil
local carAtStandTwoData = nil
local carAtStandThreeData = nil
local carAtStandFourData = nil
local carAtStandFiveData = nil
local characterId = nil

RegisterNetEvent("ak-pdm:recivedSyncCarStand",
    function(StandOneData, StandTwoData, StandThreeData, StandFourData, StandFiveData)
        carAtStandOneData = StandOneData
        carAtStandTwoData = StandTwoData
        carAtStandThreeData = StandThreeData
        carAtStandFourData = StandFourData
        carAtStandFiveData = StandFiveData
    end)

CreateThread(function()
    while true do
        Wait(1500)
        characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
        if characterId then
            TriggerServerEvent('ak-pdm:syncPlayerSpawn')
            break
        end
    end
end)

function rotateVehicle(vehicle)
    Citizen.CreateThread(function()
        while DoesEntityExist(vehicle) do
            Citizen.Wait(50)
            local heading = GetEntityHeading(vehicle)
            heading = heading + 0.5
            SetEntityHeading(vehicle, heading)
        end
    end)
end

TriggerEvent('chat:addSuggestion', '/putcar',
    'To spawn a vehicle, /putcar [carName] [standName]')

RegisterCommand('putcar', function(source, args)
    local carName = args[1]
    local standName = args[2]

    if not carName or not standName or not characterId then
        drawNativeNotification("Invalid arguments.")
        return
    end

    local fraction = exports['coca_spawnmanager']:GetCharacterFraction()

    if fraction ~= "pdm" and fraction ~= 'admin' then
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local pdmCoords = vector3(Config.blipLocation.x, Config.blipLocation.y, Config.blipLocation.z)
    local distance = #(playerCoords - pdmCoords)

    if distance > 25 then
        drawNativeNotification("Go to PDM")
        return
    end

    local carData = nil
    for _, vehicleData in ipairs(Config.vehicles) do
        if vehicleData.spawncode == carName then
            carData = vehicleData
            carData.employeeId = characterId
            break
        end
    end

    if not carData then 
        drawNativeNotification("This car is not yet available in PDM")
        return
    end

    local stand = nil
    for _, s in ipairs(Config.Stands) do
        if s.standName == standName then
            stand = s
            break
        end
    end


    if not stand then
        drawNativeNotification("Stand not found.")
        return
    end


    local existingVehicle = GetClosestVehicle(stand.carlocation.x, stand.carlocation.y, stand.carlocation.z, 3.0, 0, 71)
    if existingVehicle ~= 0 then
        DeleteEntity(existingVehicle)
    end


    RequestModel(carName)
    while not HasModelLoaded(carName) do
        Citizen.Wait(0)
    end


    local vehicle = CreateVehicle(GetHashKey(carName), stand.carlocation.x, stand.carlocation.y, stand.carlocation.z, 0.0,
        true, true)

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, "PDM " .. characterId)
    FreezeEntityPosition(vehicle, true)
    SetEntityInvincible(vehicle, true)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleFuelLevel(vehicle, 100.0)


    SetVehicleDoorOpen(vehicle, 0, false, false)
    SetVehicleDoorOpen(vehicle, 1, false, false)


    if IsNightTime() then
        SetVehicleLights(vehicle, 2)
    end


    -- Citizen.CreateThread(function()
    --     while true do
    --         Citizen.Wait(50)
    --         local heading = GetEntityHeading(vehicle)
    --         heading = heading + 0.5
    --         SetEntityHeading(vehicle, heading)
    --     end
    -- end)


    drawNativeNotification("Vehicle set to stand " .. standName)

    NetworkRegisterEntityAsNetworked(vehicle)
    local networkId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdCanMigrate(networkId, true)
    SetNetworkIdExistsOnAllMachines(networkId, true)

    -- Wait until the network ID is valid
    while not NetworkDoesNetworkIdExist(networkId) do
        Citizen.Wait(0)
    end


    TriggerServerEvent("ak-pdm:syncCarStand", carData, stand, carName, characterId, networkId)
end)

RegisterNetEvent('ak-pdm:startVehicleRotation', function(vehicleNetId)
    print(vehicleNetId)
    Wait(5000)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    print(vehicle)
    if DoesEntityExist(vehicle) then
        rotateVehicle(vehicle)
    end
end)


local testDriveVehicle = nil -- Variable to store the test drive vehicle
local testDriveTimer = nil   -- Variable to store the timer for despawning the test drive vehicle

-- Function to handle test drive vehicle despawning
function DespawnTestDriveVehicle()
    if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
        DeleteEntity(testDriveVehicle)
    end
    testDriveVehicle = nil
    testDriveTimer = nil
end

function DisplayRemainingTime(timeLeft)
    local minutes = math.floor(timeLeft / 60000)
    local seconds = math.floor((timeLeft % 60000) / 1000)
    local timeString = string.format("Time left: ~b~%02d:%02d", minutes, seconds)
    SetTextEntry_2("STRING")
    AddTextComponentString(timeString)
    DrawSubtitleTimed(1000, 1) -- Display the subtitle for 1 second
end

local purchaseSpawnPoint = vector3(-23.633, -1094.431, 26.89)
local testDriveVehicleKLoc = vector3(-9.943, -1083.38, 27.04)
local purchaseSpawnHeading = 341.007
local purchasedVehicle = nil

function cleanAndConvertPrice(priceStr)
    local cleanedPrice = priceStr:gsub("[^%d.]", "") -- Remove all non-numeric characters except the decimal point
    return tonumber(cleanedPrice)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if carAtStandOneData then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local standCoords = vector3(Config.Stands[1].standlocation.x, Config.Stands[1].standlocation.y,
                Config.Stands[1].standlocation.z)
            local distance = #(playerCoords - standCoords)

            if distance < 5.0 and Config.Stands[1] then
                sleep = 1
                DrawText3D(Config.Stands[1].standlocation.x, Config.Stands[1].standlocation.y,
                    Config.Stands[1].standlocation.z + 0.8, "Name : ~b~" .. carAtStandOneData.name)
                DrawText3D(Config.Stands[1].standlocation.x, Config.Stands[1].standlocation.y,
                    Config.Stands[1].standlocation.z + 0.7, "Brand : ~b~" .. carAtStandOneData.brand)
                DrawText3D(Config.Stands[1].standlocation.x, Config.Stands[1].standlocation.y,
                    Config.Stands[1].standlocation.z + 0.6, "Price : ~g~" .. carAtStandOneData.price .. "~w~ + 5%")
                DrawText3D(Config.Stands[1].standlocation.x, Config.Stands[1].standlocation.y,
                    Config.Stands[1].standlocation.z + 0.5, "Press ~b~[9]~w~ to buy")
                DrawText3D(Config.Stands[1].standlocation.x, Config.Stands[1].standlocation.y,
                    Config.Stands[1].standlocation.z + 0.4, "Press ~b~[6]~w~ to test drive")

                if IsDisabledControlJustReleased(0, 159) then -- Key [9] to test drive
                    if not testDriveVehicle then
                        -- Check for existing vehicle at the test drive spawn point
                        local existingVehicle = GetClosestVehicle(testDriveVehicleKLoc, 4.0, 0, 71)
                        if existingVehicle == 0 then
                            if exports.coca_banking:RemoveCash(characterId, 100) then
                                local carModel = GetHashKey(carAtStandOneData.spawncode)
                                RequestModel(carModel)
                                while not HasModelLoaded(carModel) do
                                    Citizen.Wait(0)
                                end

                                testDriveVehicle = CreateVehicle(carModel, testDriveVehicleKLoc, 164.57, true, false)
                                drawNativeNotification("Your vehicle is ready in no parking zone.")
                                SetEntityAsMissionEntity(testDriveVehicle, true, true)
                                SetVehicleOnGroundProperly(testDriveVehicle)
                                local plate = GetVehicleNumberPlateText(testDriveVehicle)
                                TriggerEvent("ak-carlock:addCarPlate", plate)


                                testDriveTimer = GetGameTimer() + 90000 -- 1.5min
                            end
                        else
                            drawNativeNotification("there is already a vehicle in no parking zone.")
                        end
                    else
                        drawNativeNotification("You can only test drive one vehicle at a time.")
                    end
                end

                if IsDisabledControlJustReleased(0, 163) then -- Key [6] to buy
                    -- Check for existing vehicle at the purchase spawn point
                    local existingVehicle = GetClosestVehicle(purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                        purchaseSpawnPoint.z, 3.0, 0, 71)
                    if existingVehicle == 0 then
                        local carPrice = cleanAndConvertPrice(carAtStandOneData.price)
                        local calcultePrice = tonumber(carPrice + (carPrice / 100 * 5))
                        if exports.coca_banking:RemoveCash(characterId, calcultePrice) then
                            -- Spawn the purchased vehicle
                            local employerrCut = carPrice / 100 * 5

                            local carModel = GetHashKey(carAtStandOneData.spawncode)

                            RequestModel(carModel)
                            while not HasModelLoaded(carModel) do
                                Citizen.Wait(0)
                            end

                            purchasedVehicle = CreateVehicle(carModel, purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                            purchaseSpawnPoint.z, purchaseSpawnHeading, true, false)
                            SetEntityAsMissionEntity(purchasedVehicle, true, true)
                            SetVehicleHasBeenOwnedByPlayer(PlayerPedId())
                            local plate = GetVehicleNumberPlateText(purchasedVehicle)
                           
                            -- Notify the player
                            drawNativeNotification("Congs! you purchase ~b~" ..
                            carAtStandOneData.name .. "~w~ with plate number ~b~" .. plate)

                            -- Trigger the server event to handle the purchase
                            TriggerEvent("ak-carlock:addCarPlate", plate)
                            TriggerServerEvent('ak-pdm:buyVehicle', characterId, calcultePrice,
                                carAtStandOneData.spawncode, plate, carAtStandOneData.employeeId, employerrCut)
                        end
                    else
                        drawNativeNotification("there is already a vehicle in main garage.")
                    end
                end
            end
        end

        -- Check if the test drive vehicle exists and if the timer has elapsed
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            local timeLeft = testDriveTimer - GetGameTimer()
            if timeLeft > 0 then
                DisplayRemainingTime(timeLeft) -- Display the remaining time as a subtitle
            else
                DespawnTestDriveVehicle()      -- Despawn the test drive vehicle after the timer expires
                drawNativeNotification("Test drive time expired.")
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if carAtStandTwoData then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local standCoords = vector3(Config.Stands[2].standlocation.x, Config.Stands[2].standlocation.y,
                Config.Stands[2].standlocation.z)
            local distance = #(playerCoords - standCoords)
            if distance < 5.0 then
                sleep = 1
                DrawText3D(Config.Stands[2].standlocation.x, Config.Stands[2].standlocation.y,
                    Config.Stands[2].standlocation.z + 0.8, "Name : ~b~" .. carAtStandTwoData.name)
                DrawText3D(Config.Stands[2].standlocation.x, Config.Stands[2].standlocation.y,
                    Config.Stands[2].standlocation.z + 0.7, "Brand : ~b~" .. carAtStandTwoData.brand)
                DrawText3D(Config.Stands[2].standlocation.x, Config.Stands[2].standlocation.y,
                    Config.Stands[2].standlocation.z + 0.6, "Price : ~g~" .. carAtStandTwoData.price .. "~w~ + 5%")
                DrawText3D(Config.Stands[2].standlocation.x, Config.Stands[2].standlocation.y,
                    Config.Stands[2].standlocation.z + 0.5, "Press ~b~[9]~w~ to buy")
                DrawText3D(Config.Stands[2].standlocation.x, Config.Stands[2].standlocation.y,
                    Config.Stands[2].standlocation.z + 0.4, "Press ~b~[6]~w~ to test drive")

                if IsDisabledControlJustReleased(0, 159) then -- Key [9] to test drive
                    if not testDriveVehicle then
                        -- Check for existing vehicle at the test drive spawn point
                        local existingVehicle = GetClosestVehicle(testDriveVehicleKLoc, 4.0, 0, 71)
                        if existingVehicle == 0 then
                            if exports.coca_banking:RemoveCash(characterId, 100) then
                                local carModel = GetHashKey(carAtStandTwoData.spawncode)
                                RequestModel(carModel)
                                while not HasModelLoaded(carModel) do
                                    Citizen.Wait(0)
                                end

                                testDriveVehicle = CreateVehicle(carModel, testDriveVehicleKLoc, 164.57, true, false)

                                drawNativeNotification("Your vehicle is ready in no parking zone.")

                                SetEntityAsMissionEntity(testDriveVehicle, true, true)
                                SetVehicleOnGroundProperly(testDriveVehicle)
                                local plate = GetVehicleNumberPlateText(testDriveVehicle)
                                TriggerEvent("ak-carlock:addCarPlate", plate)


                                testDriveTimer = GetGameTimer() + 90000 -- 1.5min
                            end
                        else
                            drawNativeNotification("there is already a vehicle in no parking zone.")
                        end
                    else
                        drawNativeNotification("You can only test drive one vehicle at a time.")
                    end
                end

                if IsDisabledControlJustReleased(0, 163) then -- Key [6] to buy
                    -- Check for existing vehicle at the purchase spawn point
                    local existingVehicle = GetClosestVehicle(purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                        purchaseSpawnPoint.z, 3.0, 0, 71)
                    if existingVehicle == 0 then
                        local carPrice = cleanAndConvertPrice(carAtStandTwoData.price)
                        local calcultePrice = tonumber(carPrice + (carPrice / 100 * 5))
                        if exports.coca_banking:RemoveCash(characterId, calcultePrice) then
                            -- Spawn the purchased vehicle
                            local employerrCut = carPrice / 100 * 5

                            local carModel = GetHashKey(carAtStandTwoData.spawncode)

                            RequestModel(carModel)
                            while not HasModelLoaded(carModel) do
                                Citizen.Wait(0)
                            end

                            purchasedVehicle = CreateVehicle(carModel, purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                                purchaseSpawnPoint.z, purchaseSpawnHeading, true, false)
                            SetEntityAsMissionEntity(purchasedVehicle, true, true)
                            SetVehicleHasBeenOwnedByPlayer(PlayerPedId())
                            local plate = GetVehicleNumberPlateText(purchasedVehicle)

                            -- Notify the player
                            drawNativeNotification("Congs! you purchase " ..
                            carAtStandTwoData.name .. " with plate number " .. plate)

                            -- Trigger the server event to handle the purchase
                            TriggerEvent("ak-carlock:addCarPlate", plate)
                            TriggerServerEvent('ak-pdm:buyVehicle', characterId, calcultePrice,
                                carAtStandTwoData.spawncode, plate, carAtStandTwoData.employeeId, employerrCut)
                        end
                    else
                        drawNativeNotification("there is already a vehicle in main garage.")
                    end
                end
            end
        end

        -- Check if the test drive vehicle exists and if the timer has elapsed
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            local timeLeft = testDriveTimer - GetGameTimer()
            if timeLeft > 0 then
                DisplayRemainingTime(timeLeft) -- Display the remaining time as a subtitle
            else
                DespawnTestDriveVehicle()      -- Despawn the test drive vehicle after the timer expires
                drawNativeNotification("Test drive time expired.")
            end
        end
        Citizen.Wait(sleep)
    end
end)


Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if carAtStandThreeData then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local standCoords = vector3(Config.Stands[3].standlocation.x, Config.Stands[3].standlocation.y,
                Config.Stands[3].standlocation.z)
            local distance = #(playerCoords - standCoords)

            if distance < 5.0 and Config.Stands[3] then
                sleep = 1
                DrawText3D(Config.Stands[3].standlocation.x, Config.Stands[3].standlocation.y,
                    Config.Stands[3].standlocation.z + 0.8, "Name : ~b~" .. carAtStandThreeData.name)
                DrawText3D(Config.Stands[3].standlocation.x, Config.Stands[3].standlocation.y,
                    Config.Stands[3].standlocation.z + 0.7, "Brand : ~b~" .. carAtStandThreeData.brand)
                DrawText3D(Config.Stands[3].standlocation.x, Config.Stands[3].standlocation.y,
                    Config.Stands[3].standlocation.z + 0.6, "Price : ~g~" .. carAtStandThreeData.price .. "~w~ + 5%")
                DrawText3D(Config.Stands[3].standlocation.x, Config.Stands[3].standlocation.y,
                    Config.Stands[3].standlocation.z + 0.5, "Press ~b~[9]~w~ to buy")
                DrawText3D(Config.Stands[3].standlocation.x, Config.Stands[3].standlocation.y,
                    Config.Stands[3].standlocation.z + 0.4, "Press ~b~[6]~w~ to test drive")

                if IsDisabledControlJustReleased(0, 159) then -- Key [9] to test drive
                    if not testDriveVehicle then
                        -- Check for existing vehicle at the test drive spawn point
                        local existingVehicle = GetClosestVehicle(testDriveVehicleKLoc, 4.0, 0, 71)
                        if existingVehicle == 0 then
                            if exports.coca_banking:RemoveCash(characterId, 100) then
                                local carModel = GetHashKey(carAtStandThreeData.spawncode)
                                RequestModel(carModel)
                                while not HasModelLoaded(carModel) do
                                    Citizen.Wait(0)
                                end

                                testDriveVehicle = CreateVehicle(carModel, testDriveVehicleKLoc, 164.57, true, false)

                                drawNativeNotification("Your vehicle is ready in no parking zone.")

                                SetEntityAsMissionEntity(testDriveVehicle, true, true)
                                SetVehicleOnGroundProperly(testDriveVehicle)

                                local plate = GetVehicleNumberPlateText(testDriveVehicle)
                                TriggerEvent("ak-carlock:addCarPlate", plate)


                                testDriveTimer = GetGameTimer() + 90000 -- 1.5min
                            end
                        else
                            drawNativeNotification("there is already a vehicle in no parking zone.")
                        end
                    else
                        drawNativeNotification("You can only test drive one vehicle at a time.")
                    end
                end

                if IsDisabledControlJustReleased(0, 163) then -- Key [6] to buy
                    -- Check for existing vehicle at the purchase spawn point
                    local existingVehicle = GetClosestVehicle(purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                        purchaseSpawnPoint.z, 3.0, 0, 71)
                    if existingVehicle == 0 then
                        local carPrice = cleanAndConvertPrice(carAtStandThreeData.price)
                        local calcultePrice = tonumber(carPrice + (carPrice / 100 * 5))
                        if exports.coca_banking:RemoveCash(characterId, calcultePrice) then
                            -- Spawn the purchased vehicle
                            local employerrCut = carPrice / 100 * 5

                            local carModel = GetHashKey(carAtStandThreeData.spawncode)

                            RequestModel(carModel)
                            while not HasModelLoaded(carModel) do
                                Citizen.Wait(0)
                            end

                            purchasedVehicle = CreateVehicle(carModel, purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                                purchaseSpawnPoint.z, purchaseSpawnHeading, true, false)
                            SetEntityAsMissionEntity(purchasedVehicle, true, true)
                            SetVehicleHasBeenOwnedByPlayer(PlayerPedId())
                            local plate = GetVehicleNumberPlateText(purchasedVehicle)

                            -- Notify the player
                            drawNativeNotification("Congs! you purchase " ..
                            carAtStandThreeData.name .. " with plate number " .. plate)

                            -- Trigger the server event to handle the purchase
                            TriggerEvent("ak-carlock:addCarPlate", plate)
                            TriggerServerEvent('ak-pdm:buyVehicle', characterId, calcultePrice,
                                carAtStandThreeData.spawncode, plate, carAtStandThreeData.employeeId, employerrCut)
                        end
                    else
                        drawNativeNotification("there is already a vehicle in main garage.")
                    end
                end
            end
        end

        -- Check if the test drive vehicle exists and if the timer has elapsed
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            local timeLeft = testDriveTimer - GetGameTimer()
            if timeLeft > 0 then
                DisplayRemainingTime(timeLeft) -- Display the remaining time as a subtitle
            else
                DespawnTestDriveVehicle()      -- Despawn the test drive vehicle after the timer expires
                drawNativeNotification("Test drive time expired.")
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if carAtStandFourData then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local standCoords = vector3(Config.Stands[4].standlocation.x, Config.Stands[4].standlocation.y,
                Config.Stands[4].standlocation.z)
            local distance = #(playerCoords - standCoords)

            if distance < 5.0 and Config.Stands[4] then
                sleep = 1
                DrawText3D(Config.Stands[4].standlocation.x, Config.Stands[4].standlocation.y,
                    Config.Stands[4].standlocation.z + 0.8, "Name : ~b~" .. carAtStandFourData.name)
                DrawText3D(Config.Stands[4].standlocation.x, Config.Stands[4].standlocation.y,
                    Config.Stands[4].standlocation.z + 0.7, "Brand : ~b~" .. carAtStandFourData.brand)
                DrawText3D(Config.Stands[4].standlocation.x, Config.Stands[4].standlocation.y,
                    Config.Stands[4].standlocation.z + 0.6, "Price : ~g~" .. carAtStandFourData.price .. "~w~ + 5%")
                DrawText3D(Config.Stands[4].standlocation.x, Config.Stands[4].standlocation.y,
                    Config.Stands[4].standlocation.z + 0.5, "Press ~b~[9]~w~ to buy")
                DrawText3D(Config.Stands[4].standlocation.x, Config.Stands[4].standlocation.y,
                    Config.Stands[4].standlocation.z + 0.4, "Press ~b~[6]~w~ to test drive")

                if IsDisabledControlJustReleased(0, 159) then -- Key [9] to test drive
                    if not testDriveVehicle then
                        -- Check for existing vehicle at the test drive spawn point
                        local existingVehicle = GetClosestVehicle(testDriveVehicleKLoc, 4.0, 0, 71)
                        if existingVehicle == 0 then
                            if exports.coca_banking:RemoveCash(characterId, 100) then
                                local carModel = GetHashKey(carAtStandFourData.spawncode)
                                RequestModel(carModel)
                                while not HasModelLoaded(carModel) do
                                    Citizen.Wait(0)
                                end

                                testDriveVehicle = CreateVehicle(carModel, testDriveVehicleKLoc, 164.57, true, false)

                                drawNativeNotification("Your vehicle is ready in no parking zone.")

                                SetEntityAsMissionEntity(testDriveVehicle, true, true)
                                SetVehicleOnGroundProperly(testDriveVehicle)
                                local plate = GetVehicleNumberPlateText(testDriveVehicle)
                                TriggerEvent("ak-carlock:addCarPlate", plate)


                                testDriveTimer = GetGameTimer() + 90000 -- 1.5min
                            end
                        else
                            drawNativeNotification("there is already a vehicle in no parking zone.")
                        end
                    else
                        drawNativeNotification("You can only test drive one vehicle at a time.")
                    end
                end

                if IsDisabledControlJustReleased(0, 163) then -- Key [6] to buy
                    -- Check for existing vehicle at the purchase spawn point
                    local existingVehicle = GetClosestVehicle(purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                        purchaseSpawnPoint.z, 3.0, 0, 71)
                    if existingVehicle == 0 then
                        local carPrice = cleanAndConvertPrice(carAtStandFourData.price)
                        local calcultePrice = tonumber(carPrice + (carPrice / 100 * 5))
                        if exports.coca_banking:RemoveCash(characterId, calcultePrice) then
                            -- Spawn the purchased vehicle
                            local employerrCut = carPrice / 100 * 5

                            local carModel = GetHashKey(carAtStandFourData.spawncode)

                            RequestModel(carModel)
                            while not HasModelLoaded(carModel) do
                                Citizen.Wait(0)
                            end

                            purchasedVehicle = CreateVehicle(carModel, purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                                purchaseSpawnPoint.z, purchaseSpawnHeading, true, false)
                            SetEntityAsMissionEntity(purchasedVehicle, true, true)
                            SetVehicleHasBeenOwnedByPlayer(PlayerPedId())
                            local plate = GetVehicleNumberPlateText(purchasedVehicle)

                            -- Notify the player
                            drawNativeNotification("Congs! you purchase " ..
                            carAtStandFourData.name .. " with plate number " .. plate)

                            -- Trigger the server event to handle the purchase
                            TriggerEvent("ak-carlock:addCarPlate", plate)
                            TriggerServerEvent('ak-pdm:buyVehicle', characterId, calcultePrice,
                                carAtStandFourData.spawncode, plate, carAtStandFourData.employeeId, employerrCut)
                        end
                    else
                        drawNativeNotification("there is already a vehicle in main garage.")
                    end
                end
            end
        end

        -- Check if the test drive vehicle exists and if the timer has elapsed
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            local timeLeft = testDriveTimer - GetGameTimer()
            if timeLeft > 0 then
                DisplayRemainingTime(timeLeft) -- Display the remaining time as a subtitle
            else
                DespawnTestDriveVehicle()      -- Despawn the test drive vehicle after the timer expires
                drawNativeNotification("Test drive time expired.")
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if carAtStandFiveData then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local standCoords = vector3(Config.Stands[5].standlocation.x, Config.Stands[5].standlocation.y,
                Config.Stands[5].standlocation.z)
            local distance = #(playerCoords - standCoords)

            if distance < 5.0 and Config.Stands[5] then
                sleep = 1
                DrawText3D(Config.Stands[5].standlocation.x, Config.Stands[5].standlocation.y,
                    Config.Stands[5].standlocation.z + 0.8, "Name : ~b~" .. carAtStandFiveData.name)
                DrawText3D(Config.Stands[5].standlocation.x, Config.Stands[5].standlocation.y,
                    Config.Stands[5].standlocation.z + 0.7, "Brand : ~b~" .. carAtStandFiveData.brand)
                DrawText3D(Config.Stands[5].standlocation.x, Config.Stands[5].standlocation.y,
                    Config.Stands[5].standlocation.z + 0.6, "Price : ~g~" .. carAtStandFiveData.price .. "~w~ + 5%")
                DrawText3D(Config.Stands[5].standlocation.x, Config.Stands[5].standlocation.y,
                    Config.Stands[5].standlocation.z + 0.5, "Press ~b~[9]~w~ to buy")
                DrawText3D(Config.Stands[5].standlocation.x, Config.Stands[5].standlocation.y,
                    Config.Stands[5].standlocation.z + 0.4, "Press ~b~[6]~w~ to test drive")

                if IsDisabledControlJustReleased(0, 159) then -- Key [9] to test drive
                    if not testDriveVehicle then
                        -- Check for existing vehicle at the test drive spawn point
                        local existingVehicle = GetClosestVehicle(testDriveVehicleKLoc, 4.0, 0, 71)
                        if existingVehicle == 0 then
                            if exports.coca_banking:RemoveCash(characterId, 100) then
                                local carModel = GetHashKey(carAtStandFiveData.spawncode)
                                RequestModel(carModel)
                                while not HasModelLoaded(carModel) do
                                    Citizen.Wait(0)
                                end

                                testDriveVehicle = CreateVehicle(carModel, testDriveVehicleKLoc, 164.57, true, false)

                                drawNativeNotification("Your vehicle is ready in no parking zone.")

                                SetEntityAsMissionEntity(testDriveVehicle, true, true)
                                SetVehicleOnGroundProperly(testDriveVehicle)

                                local plate = GetVehicleNumberPlateText(testDriveVehicle)
                                TriggerEvent("ak-carlock:addCarPlate", plate)

                                testDriveTimer = GetGameTimer() + 90000 -- 1.5min
                            end
                        else
                            drawNativeNotification("there is already a vehicle in no parking zone.")
                        end
                    else
                        drawNativeNotification("You can only test drive one vehicle at a time.")
                    end
                end

                if IsDisabledControlJustReleased(0, 163) then -- Key [6] to buy
                    -- Check for existing vehicle at the purchase spawn point
                    local existingVehicle = GetClosestVehicle(purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                        purchaseSpawnPoint.z, 3.0, 0, 71)
                    if existingVehicle == 0 then
                        local carPrice = cleanAndConvertPrice(carAtStandFiveData.price)
                        local calcultePrice = tonumber(carPrice + (carPrice / 100 * 5))
                        if exports.coca_banking:RemoveCash(characterId, calcultePrice) then
                            -- Spawn the purchased vehicle
                            local employerrCut = carPrice / 100 * 5

                            local carModel = GetHashKey(carAtStandFiveData.spawncode)

                            RequestModel(carModel)
                            while not HasModelLoaded(carModel) do
                                Citizen.Wait(0)
                            end

                            purchasedVehicle = CreateVehicle(carModel, purchaseSpawnPoint.x, purchaseSpawnPoint.y,
                                purchaseSpawnPoint.z, purchaseSpawnHeading, true, false)
                            SetEntityAsMissionEntity(purchasedVehicle, true, true)
                            SetVehicleHasBeenOwnedByPlayer(PlayerPedId())
                            local plate = GetVehicleNumberPlateText(purchasedVehicle)

                            -- Notify the player
                            drawNativeNotification("Congs! you purchase " ..
                            carAtStandFiveData.name .. " with plate number " .. plate)

                            -- Trigger the server event to handle the purchase
                            TriggerEvent("ak-carlock:addCarPlate", plate)
                            TriggerServerEvent('ak-pdm:buyVehicle', characterId, calcultePrice,
                                carAtStandFiveData.spawncode, plate, carAtStandFiveData.employeeId, employerrCut)
                        end
                    else
                        drawNativeNotification("there is already a vehicle in main garage.")
                    end
                end
            end
        end

        -- Check if the test drive vehicle exists and if the timer has elapsed
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            local timeLeft = testDriveTimer - GetGameTimer()
            if timeLeft > 0 then
                DisplayRemainingTime(timeLeft) -- Display the remaining time as a subtitle
            else
                DespawnTestDriveVehicle()      -- Despawn the test drive vehicle after the timer expires
                drawNativeNotification("Test drive time expired.")
            end
        end
        Citizen.Wait(sleep)
    end
end)
