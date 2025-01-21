local engineHealth = nil
local bodyHealth = nil
local petrolTankHealth = nil
local tireHealth = nil
local brokenWindowCount = nil
local brokenDoorCount = nil
local vehicleCoords = nil
local isInspectAlreayStarted = false


-- Function to draw 3D text
function DrawText3D(x, y, z, text)
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

function GetTireHealth(vehicle)
    local tireHealth = {}
    for i = 0, 5 do
        if i ~= 3 and i ~= 2 then
            local health = IsVehicleTyreBurst(vehicle, i, false)
            print(health, i)
            table.insert(tireHealth, health)
        end
    end
    return tireHealth
end

function GetWindowStatus(vehicle)
    local count = 0
    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then
            count = count + 1
        end
    end
    return count
end

function GetDoorStatus(vehicle)
    local count = 0
    for i = 0, 5 do
        if IsVehicleDoorDamaged(vehicle, i) then
            count = count + 1
        end
    end
    return count
end

function checkRestriction(vehicle)
    local class = GetVehicleClass(vehicle)
    if Config.BlackListedVehicleClasses[class] then
        return false
    end
    return true
end

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function resetValues()
    engineHealth = nil
    bodyHealth = nil
    petrolTankHealth = nil
    tireHealth = nil
    brokenWindowCount = nil
    brokenDoorCount = nil
    vehicleCoords = nil
end


TriggerEvent('chat:addSuggestion', '/inspectcar', 'Inspect the nearest car.')

RegisterCommand("inspectcar", function(source, args, rawCommand)
    local fraction = exports['coca_spawnmanager']:GetCharacterFraction()

    if fraction ~= "mechanic" and fraction ~= 'admin' then
        drawNativeNotification('Your not ~d~skilled~w~ enough call mechanic')
        return
    end

    if isInspectAlreayStarted then return end
    isInspectAlreayStarted = true
    resetValues()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)

    if vehicle then
        -- Start inspection animation
        PlayAnimation(playerPed, 'mini@repair', 'fixing_a_ped', -1, 1)

        engineHealth = tonumber(string.format("%.2f", GetVehicleEngineHealth(vehicle) / 10))
        bodyHealth = tonumber(string.format("%.2f", GetVehicleBodyHealth(vehicle) / 10))
        petrolTankHealth = tonumber(string.format("%.2f", GetVehiclePetrolTankHealth(vehicle) / 10))
        tireHealth = GetTireHealth(vehicle)
        brokenWindowCount = GetWindowStatus(vehicle) - 2
        brokenDoorCount = GetDoorStatus(vehicle)
        vehicleCoords = GetEntityCoords(vehicle)

        local bonnet = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "engine"))
        local gasTank = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "exhaust"))
        local chassis = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "chassis_dummy"))

        local brokenDoorCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "boot"))
        local brokenWindowCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "windscreen"))

        local wheel_rr = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_rr"))
        local wheel_rf = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_rf"))
        local wheel_lr = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_lr"))
        local wheel_lf = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_lf"))
        print(#tireHealth)
        Citizen.CreateThread(function()
            local displayTime = 10000
            local endTime = GetGameTimer() + displayTime

            FreezeEntityPosition(vehicle, true)

            while GetGameTimer() < endTime do
                Citizen.Wait(0)
                if engineHealth == 100.0 then
                    DrawText3D(bonnet.x, bonnet.y, bonnet.z + 0.2, "Engine: ~b~" .. engineHealth .. "%")
                elseif engineHealth > 50.0 then
                    DrawText3D(bonnet.x, bonnet.y, bonnet.z + 0.2, "Engine: ~y~" .. engineHealth .. "%")
                else
                    DrawText3D(bonnet.x, bonnet.y, bonnet.z + 0.2, "Engine: ~r~" .. engineHealth .. "%")
                end
                if bodyHealth == 100.0 then
                    DrawText3D(chassis.x, chassis.y, chassis.z + 0.2, "Body: ~b~" .. bodyHealth .. "%")
                elseif bodyHealth > 50.0 then
                    DrawText3D(chassis.x, chassis.y, chassis.z + 0.2, "Body: ~y~" .. bodyHealth .. "%")
                else
                    DrawText3D(chassis.x, chassis.y, chassis.z + 0.2, "Body: ~r~" .. bodyHealth .. "%")
                end
                if engineHealth == 100.0 then
                    DrawText3D(gasTank.x, gasTank.y, gasTank.z + 0.2, "Tank condition: ~b~" .. petrolTankHealth .. "%")
                elseif bodyHealth > 50.0 then
                    DrawText3D(gasTank.x, gasTank.y, gasTank.z + 0.2, "Tank condition: ~y~" .. petrolTankHealth .. "%")
                else
                    DrawText3D(gasTank.x, gasTank.y, gasTank.z + 0.2, "Tank condition: ~r~" .. petrolTankHealth .. "%")
                end

                for i, health in ipairs(tireHealth) do
                    local text = nil
                    if health then
                        text = "Tire: ~r~burst"
                    else
                        text = "Tire: ~b~intact"
                    end
                    if i == 2 and checkRestriction(vehicle) then
                        DrawText3D(wheel_rf.x, wheel_rf.y, wheel_rf.z, text)
                    elseif i == 3 then
                        DrawText3D(wheel_lr.x, wheel_lr.y, wheel_lr.z, text)
                    elseif i == 4 and checkRestriction(vehicle) then
                        DrawText3D(wheel_rr.x, wheel_rr.y, wheel_rr.z, text)
                    elseif i == 1 then
                        DrawText3D(wheel_lf.x, wheel_lf.y, wheel_lf.z, text)
                    end
                end



                if checkRestriction(vehicle) then
                    if brokenWindowCount > 0 then
                        DrawText3D(brokenWindowCoords.x, brokenWindowCoords.y, brokenWindowCoords.z + 0.2,
                            "Broken Windows: ~r~" .. brokenWindowCount)
                    else
                        DrawText3D(brokenWindowCoords.x, brokenWindowCoords.y, brokenWindowCoords.z + 0.2,
                            "Broken Windows: ~b~" .. brokenWindowCount)
                    end

                    if brokenDoorCount > 0 then
                        DrawText3D(brokenDoorCoords.x, brokenDoorCoords.y, brokenDoorCoords.z + 0.2,
                            "Broken Doors: ~r~" .. brokenDoorCount)
                    else
                        DrawText3D(brokenDoorCoords.x, brokenDoorCoords.y, brokenDoorCoords.z + 0.2,
                            "Broken Doors: ~b~" .. brokenDoorCount)
                    end
                end
            end

            -- Stop the animation
            StopAnimation(playerPed, 'mini@repair', 'fixing_a_ped')

            OpenMenu(vehicle)
            FreezeEntityPosition(vehicle, false)
            isInspectAlreayStarted = false
        end)
    else
        drawNativeNotification('No vehicle nearby.')
        isInspectAlreayStarted = false
    end
end, false)

-- Function to load an animation dictionary
function LoadAnimDict(dict)
    -- Request the animation dictionary
    RequestAnimDict(dict)
    -- Wait until the dictionary has loaded
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
end

-- Function to play an animation on a ped
function PlayAnimation(ped, dict, anim, duration, flag)
    -- Load the animation dictionary
    LoadAnimDict(dict)
    -- Play the animation on the ped
    TaskPlayAnim(ped, dict, anim, 8.0, 1.0, duration or -1, flag or 0, 0, false, false, false)
end

-- Function to stop an animation on a ped
function StopAnimation(ped, dict, anim)
    StopAnimTask(ped, dict, anim, 1.0)
end

function OpenMenu(vehicle)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local tempVehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)

    if vehicle == tempVehicle then
        FreezeEntityPosition(vehicle, true)
        Wait(1000)
        while true do
            Citizen.Wait(0)
            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.9,
                "               Car Repair Menu                ")
            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.7,
                "    Press ~b~[6]~w~ to repair ~bold~Engine    ")
            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.56,
                "    Press ~b~[7]~w~ to repair ~bold~Body      ")
            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.43,
                "    Press ~b~[8]~w~ to repair ~bold~Fuel Tank ")
            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.3,
                "    Press ~b~[9]~w~ to exit repair menu       ")

            if IsDisabledControlJustReleased(0, 159) then -- Key '6'
                local isRepaired = repairPart(vehicle, "engine")
                if isRepaired then break end
            elseif IsDisabledControlJustReleased(0, 161) then -- Key '7'
                local isRepaired = repairPart(vehicle, "body")
                if isRepaired then break end
            elseif IsDisabledControlJustReleased(0, 162) then -- Key '8'
                local isRepaired = repairPart(vehicle, "fueltank")
                if isRepaired then break end
            elseif IsDisabledControlJustReleased(0, 163) then -- Key '9'
                break
            end
        end
    end
end

function GetDistance(vec1, x, y, z)
    local vec2 = vector3(x, y, z)
    return #(vec1 - vec2)
end

function repairPart(vehicle, part)
    if GetDistance(GetEntityCoords(vehicle), Config.BennyLocation.x, Config.BennyLocation.y, Config.BennyLocation.z) > 25 then
        drawNativeNotification('You do not have tools here, take the vehicle to the shop')
        return
    end

    if part == 'engine' and engineHealth == 100.0 then
        drawNativeNotification("Engine Health is Already Full")
        return false
    end
    if part == 'body' and bodyHealth == 100.0 and brokenWindowCount == 0 and brokenDoorCount == 0 and burstTyre == 0 then
        drawNativeNotification("Body Health is Already Full")
        return false
    end

    local burstTyre = 0
    for i, health in ipairs(tireHealth) do
        if health then
            burstTyre = burstTyre + 1
        end
    end

    if part == 'fueltank' and petrolTankHealth == 100.0 then
        drawNativeNotification("Fuel Tank Health is Already Full")
        return false
    end

    local requiredItems = getRequiredItems(vehicle, part)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

    local hoodBone = GetEntityBoneIndexByName(vehicle, "bonnet")
    local isHoodOpen = false

    while true do
        Citizen.Wait(0)
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 2.3, "   " .. part .. " Repair Required     ")

        local offsetY = 0.13
        for index, itemData in ipairs(requiredItems) do
            local item = itemData.item
            local count = itemData.count

            local requiredText = string.format("    - %s %s%d", item, "~b~      ", count)

            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 2.12 - offsetY * (index - 1), requiredText)
        end

        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.3, "  Press ~b~[6]~w~ to start repair  ")
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.17, "  Press ~b~[9]~w~ to cancel repair ")

        if IsDisabledControlJustReleased(0, 159) then -- Key '6'
            if playerHasItem(requiredItems) then
                -- Determine animation based on part
                local repairAnim = 'fixing_a_ped'
                if part == 'body' then
                    repairAnim = 'mini@repair'
                elseif part == 'fueltank' then
                    repairAnim = 'mini@repair'
                end

                -- Play the appropriate animation
                local playerPed = PlayerPedId()
                PlayAnimation(playerPed, 'mini@repair', repairAnim, -1, 1)

                -- Open the hood if it's not already open
                if not isHoodOpen then
                    SetVehicleDoorOpen(vehicle, 4, false, false) -- Open the hood (door index 4)
                    isHoodOpen = true
                end

                TriggerServerEvent('coca_inventory:Server:RemoveMultipleItems', characterId, requiredItems,
                    part .. " Repaired Fully")
                Citizen.Wait(5000) -- Simulate repair time

                -- Stop the animation
                StopAnimation(playerPed, 'mini@repair', repairAnim)

                -- Close the hood after repair
                if isHoodOpen then
                    SetVehicleDoorShut(vehicle, 4, false) -- Close the hood (door index 4)
                    isHoodOpen = false
                end

                if part == "engine" then
                    SetVehicleEngineHealth(vehicle, 1000.0)
                    return true
                elseif part == "body" then
                    local cacheEngineHealth = GetVehicleEngineHealth(vehicle)
                    local cacheTankHealth = GetVehiclePetrolTankHealth(vehicle)
                    SetVehicleFixed(vehicle)
                    SetVehicleEngineHealth(vehicle, cacheEngineHealth)
                    SetVehiclePetrolTankHealth(vehicle, cacheTankHealth)
                    return true
                elseif part == "fueltank" then
                    SetVehiclePetrolTankHealth(vehicle, 1000.0)
                    return true
                end
            else
                drawNativeNotification("You don't have the required items.")
            end
        elseif IsDisabledControlJustReleased(0, 163) then -- Key '9'
            -- Close the hood if it's open when canceling repair
            if isHoodOpen then
                SetVehicleDoorShut(vehicle, 4, false)
                isHoodOpen = false
            end
            return false
        end
    end
end

function getRequiredItems(vehicle, part)
    local requiredItems = {}

    if part == "engine" then
        if engineHealth > 85 then
            table.insert(requiredItems, { item = "steel", count = 1 })
            table.insert(requiredItems, { item = "scrap", count = 2 })
        elseif engineHealth > 65 then
            table.insert(requiredItems, { item = "steel", count = 2 })
            table.insert(requiredItems, { item = "scrap", count = 4 })
        elseif engineHealth > 35 then
            table.insert(requiredItems, { item = "steel", count = 3 })
            table.insert(requiredItems, { item = "scrap", count = 5 })
        else
            table.insert(requiredItems, { item = "steel", count = 5 })
            table.insert(requiredItems, { item = "scrap", count = 8 })
        end
    elseif part == "body" then
        if bodyHealth > 85 then
            table.insert(requiredItems, { item = "aluminum", count = 1 })
            table.insert(requiredItems, { item = "scrap", count = 1 })
        elseif bodyHealth > 65 then
            table.insert(requiredItems, { item = "aluminum", count = 2 })
            table.insert(requiredItems, { item = "scrap", count = 2 })
        elseif bodyHealth > 35 then
            table.insert(requiredItems, { item = "aluminum", count = 3 })
            table.insert(requiredItems, { item = "scrap", count = 4 })
        else
            table.insert(requiredItems, { item = "aluminum", count = 5 })
            table.insert(requiredItems, { item = "scrap", count = 5 })
        end

        if brokenWindowCount > 0 then
            table.insert(requiredItems, { item = "glass", count = brokenWindowCount * 2 })
        end

        if brokenDoorCount > 0 then
            table.insert(requiredItems, { item = "steel", count = brokenDoorCount * 2 })
        end

        local burstTyre = 0
        for i, health in ipairs(tireHealth) do
            if health then
                burstTyre = burstTyre + 1
            end
        end

        if burstTyre > 0 then
            table.insert(requiredItems, { item = "rubber", count = burstTyre * 2 })
        end
    elseif part == "fueltank" then
        if petrolTankHealth > 85 then
            table.insert(requiredItems, { item = "aluminum", count = 2 })
        elseif petrolTankHealth > 65 then
            table.insert(requiredItems, { item = "aluminum", count = 3 })
        elseif petrolTankHealth > 35 then
            table.insert(requiredItems, { item = "aluminum", count = 4 })
        else
            table.insert(requiredItems, { item = "aluminum", count = 5 })
        end
    end

    return requiredItems
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

CreateThread(function()
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
    local itemRequired = {
        { item = "aluminum", count = 3 },
        { item = "steel",    count = 4 },
        { item = "scrap",    count = 5 },
    }
    while true do
        local coords = GetEntityCoords(ped)
        local sleep = 1500

        if fraction == "mechanic" or fraction == 'admin' then
            for k, v in pairs(Config.RepairKitCoords) do
                local markerCoords = vector3(v.x, v.y, v.z)
                local dist = #(coords - markerCoords)
                if dist <= 8 then
                    sleep = 0

                    DrawText3D(v.x, v.y, v.z + 0.5, " Press ~b~[E]~w~ to make Engine Repaire Kit ")
                    DrawText3D(v.x, v.y, v.z + 0.7, "        - Aluminum x ~b~3                   ")
                    DrawText3D(v.x, v.y, v.z + 0.8, "        - Steel x ~b~4                      ")
                    DrawText3D(v.x, v.y, v.z + 0.9, "         - Scrap x ~b~5                     ")

                    if IsDisabledControlJustPressed(0, 38) and dist <= 2 and not IsPedSittingInAnyVehicle(ped) then
                        if playerHasItem(itemRequired) then
                            TriggerEvent('coca_inventory:stopInventoryUI', true)
                            TriggerServerEvent('coca_inventory:Server:RemoveMultipleItems', characterId, itemRequired)
                            PlayAnimation(ped, 'mini@repair', 'fixing_a_ped', -1, 1)

                            Citizen.Wait(10000)

                            TriggerServerEvent('coca_inventory:Server:AddItem', characterId, "enginerepairkit", 1)

                            StopAnimation(ped, 'mini@repair', 'fixing_a_ped')
                            drawNativeNotification("Repaire Kit made sucessfuly")
                            TriggerEvent('coca_inventory:stopInventoryUI', false)
                        else
                            drawNativeNotification("You don't have the required items.")
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)
