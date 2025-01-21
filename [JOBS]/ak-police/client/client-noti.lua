local onDuty = false
local policeBlips = {}

-- Function to draw native notification
local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

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

-- Function to add a blip to a location
local function addBlipToLocation(x, y, z)
    CreateThread(function()
        local blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 1)  -- Standard Blip icon (default: 1)
        SetBlipColour(blip, 3)  -- Blip color (default: 1 = red)
        SetBlipScale(blip, 1.0) -- Blip size (default: 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Emergency Distress Signal")
        EndTextCommandSetBlipName(blip)
        SetBlipAsShortRange(blip, false)        -- Show blip from longer distance
        SetBlipAsMissionCreatorBlip(blip, true) -- Mark blip as important
        Wait(1000 * 60)
        RemoveBlip(blip)
    end)
end

RegisterNetEvent("notifyPolice", function(playerCoords, msg)
    local zone = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z);
    local var1, var2 = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z, Citizen.ResultAsInteger(),
        Citizen.ResultAsInteger())
    local hash1 = GetStreetNameFromHashKey(var1);
    local hash2 = GetStreetNameFromHashKey(var2);

    local street2;
    if (hash2 == '') then
        street2 = GetLabelText(zone);
    else
        street2 = hash2 .. ', ' .. GetLabelText(zone);
    end

    drawNativeNotification("~d~ PD Radio~w~~n~ Msg: " .. msg .. "~n~ Loc: ~d~" .. hash1 .. "~w~, ~d~ " .. street2)
    addBlipToLocation(playerCoords.x, playerCoords.y, playerCoords.z)
end)

TriggerEvent('chat:addSuggestion', '/911', 'usage: /911 [enter message]')
RegisterCommand('911', function(source, args, raw)
    local msg = table.concat(args, " ")
    if msg == "" then
        drawNativeNotification("Please enter a message.")
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('sendNotificationToAllPolice', coords, msg)
end)

-- New event to handle updating police locations
RegisterNetEvent("updatePoliceLocations", function(policeLocations)
    if onDuty then
        -- Clear previous blips
        for _, blip in ipairs(policeBlips) do
            RemoveBlip(blip)
        end
        policeBlips = {} -- Reset the blip array

        -- Add new blips for all police locations
        for _, location in ipairs(policeLocations) do
            if location.id ~= GetPlayerServerId(PlayerId()) then
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, 42) -- Set the blip sprite to police icon
                SetBlipColour(blip, 3)  -- Set the blip color to blue
                SetBlipScale(blip, 0.6) -- Set the blip scale
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Police Officer Raider")
                EndTextCommandSetBlipName(blip)
                table.insert(policeBlips, blip) -- Add blip to the list
            end
        end
    end
end)

CreateThread(function()
    local loc = vector3(440.99, -975.72, 30.69)

    local fraction = nil

    while not fraction do
        Wait(1000)
        fraction = exports['coca_spawnmanager']:GetCharacterFraction()
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dis = #(loc - playerCoords)
        local sleep = 1500

        if dis < 2 and fraction == 'police' then
            sleep = 5
            if onDuty then
                DrawText3D(loc.x, loc.y, loc.z, "Press ~d~[E]~w~ to go off duty")
            else
                DrawText3D(loc.x, loc.y, loc.z, "Press ~d~[E]~w~ to go on duty")
            end

            if IsControlJustReleased(0, 38) then
                if onDuty then
                    onDuty = false
                    TriggerServerEvent('removePlayerFromActivePolice', GetPlayerServerId(PlayerId()))
                    drawNativeNotification("You are now off duty")
                else
                    onDuty = true
                    TriggerServerEvent('addPlayerToActivePolice', GetPlayerServerId(PlayerId()))
                    drawNativeNotification("You are now on duty")
                end
                Wait(5000)
            end
        end

        Wait(sleep)
    end
end)
