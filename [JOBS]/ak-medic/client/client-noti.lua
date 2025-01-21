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
        SetBlipColour(blip, 1)  -- Blip color (default: 1 = red)
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

RegisterNetEvent("notifyEMS", function(playerCoords, msg)
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

    if not msg then
        drawNativeNotification(" ~r~Alert~w~~n~ Msg :Recivied a distrace Signal at location ~n~ Loc:~r~" ..
            hash1 .. "~w~, ~r~ " .. street2)
    else
        drawNativeNotification(" ~r~Alert~w~~n~ Msg : ~r~" .. msg .. "~n~~w~ Loc: ~r~" ..
            hash1 .. "~w~, ~r~ " .. street2)
    end
    -- Add a blip to player location
    addBlipToLocation(playerCoords.x, playerCoords.y, playerCoords.z)
end)

TriggerEvent('chat:addSuggestion', '/100', 'usage: /100 [enter message]')
RegisterCommand('100', function(source, args, raw)
    local msg = table.concat(args, " ")
    if msg == "" then
        drawNativeNotification("Please enter a message.")
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('sendNotificationToALlEMS', coords, msg)
end)

CreateThread(function()
    local loc = vector3(307.0, -597.81,43.28)
    local onDuty = false
    local fraction = nil

    while not fraction do
        Wait(1000)
        fraction = exports['coca_spawnmanager']:GetCharacterFraction()
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dis = #(loc - playerCoords)
        local sleep = 1500

        if dis < 2 and fraction == 'ems' then
            sleep = 5
            if onDuty then
                DrawText3D(loc.x, loc.y, loc.z, "Press ~r~[E]~w~ to go off duty")
            else
                DrawText3D(loc.x, loc.y, loc.z, "Press ~r~[E]~w~ to go on duty")
            end

            if IsControlJustReleased(0, 38) then
                if onDuty then
                    onDuty = false
                    TriggerServerEvent('removePlayerFromActiveEMS', GetPlayerServerId(PlayerId()))
                    drawNativeNotification("You are now off duty")
                else
                    onDuty = true
                    TriggerServerEvent('addPlayerToActiveEms', GetPlayerServerId(PlayerId()))
                    drawNativeNotification("You are now on duty")
                end
                Wait(5000)
            end
        end

        Wait(sleep)
    end
end)

local EmsBlips = {} 

-- New event to handle updating police locations
RegisterNetEvent("updateEMSLocations", function(EmsLocations)
    if onDuty then
        -- Clear previous blips
        for _, blip in ipairs(EmsBlips) do
            RemoveBlip(blip)
        end
        EmsBlips = {} -- Reset the blip array

        -- Add new blips for all police locations
        for _, location in ipairs(EmsLocations) do
            if location.id ~= GetPlayerServerId(PlayerId()) then
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, 42) -- Set the blip sprite to police icon
                SetBlipColour(blip, 1)  -- Set the blip color to blue
                SetBlipScale(blip, 0.6) -- Set the blip scale
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("EMS Raider")
                EndTextCommandSetBlipName(blip)
                table.insert(EmsBlips, blip) -- Add blip to the list
            end
        end
    end
end)

-- handle death

function respawnPed(ped, coords)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
    ClearPedBloodDamage(ped)
    Config.DiscordNotification = false
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.45, 0.45)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.03 + factor, 0.05, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DisplayRemainingTime(timeLeft, ped)
    local minutes = math.floor(timeLeft / 60000)
    local seconds = math.floor((timeLeft % 60000) / 1000)
    local timeString = string.format("Respawning in ~r~%02d:%02d", minutes, seconds)
    local playerCoords = GetEntityCoords(ped)
    DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 0.5, "Press ~r~[E]~w~ to call distress signal")
    DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 0.4, timeString)
end

function GetWeaponLabel(weaponHash)
    for k, v in pairs(Config.WeaponLabels) do
        print(GetHashKey(k) == weaponHash)
        if GetHashKey(k) == weaponHash then
            return v
        end
    end

    return weaponHash
end

Config.AutoSpawnsLocation = {
    { x = -448.0, y = -340.0,  z = 35.5, heading = 0.0 },  -- Mount Zonah
    { x = 372.0,  y = -596.0,  z = 30.0, heading = 0.0 },  -- Pillbox Hill
    { x = 335.0,  y = -1400.0, z = 34.0, heading = 0.0 },  -- Central Los Santos
    { x = 1850.0, y = 3700.0,  z = 35.0, heading = 0.0 },  -- Sandy Shores
    { x = -247.0, y = 6328.0,  z = 33.5, heading = 0.0 }   -- Paleto
}

local weaponNames = {
    [GetHashKey("WEAPON_UNARMED")] = "Unarmed",
    [GetHashKey("WEAPON_KNIFE")] = "Knife",
    [GetHashKey("WEAPON_NIGHTSTICK")] = "Nightstick",
    [GetHashKey("WEAPON_HAMMER")] = "Hammer",
    [GetHashKey("WEAPON_BAT")] = "Bat",
    [GetHashKey("WEAPON_GOLFCLUB")] = "Golf Club",
    [GetHashKey("WEAPON_CROWBAR")] = "Crowbar",
    [GetHashKey("WEAPON_PISTOL")] = "Pistol",
    [GetHashKey("WEAPON_COMBATPISTOL")] = "Combat Pistol",
    [GetHashKey("WEAPON_APPISTOL")] = "AP Pistol",
    [GetHashKey("WEAPON_PISTOL50")] = "Pistol .50",
    [GetHashKey("WEAPON_MICROSMG")] = "Micro SMG",
    [GetHashKey("WEAPON_SMG")] = "SMG",
    [GetHashKey("WEAPON_ASSAULTSMG")] = "Assault SMG",
    [GetHashKey("WEAPON_ASSAULTRIFLE")] = "Assault Rifle",
    [GetHashKey("WEAPON_CARBINERIFLE")] = "Carbine Rifle",
    [GetHashKey("WEAPON_ADVANCEDRIFLE")] = "Advanced Rifle",
    [GetHashKey("WEAPON_MG")] = "MG",
    [GetHashKey("WEAPON_COMBATMG")] = "Combat MG",
    [GetHashKey("WEAPON_PUMPSHOTGUN")] = "Pump Shotgun",
    [GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = "Sawed-Off Shotgun",
    [GetHashKey("WEAPON_ASSAULTSHOTGUN")] = "Assault Shotgun",
    [GetHashKey("WEAPON_BULLPUPSHOTGUN")] = "Bullpup Shotgun",
    [GetHashKey("WEAPON_STUNGUN")] = "Stun Gun",
    [GetHashKey("WEAPON_SNIPERRIFLE")] = "Sniper Rifle",
    [GetHashKey("WEAPON_HEAVYSNIPER")] = "Heavy Sniper",
    [GetHashKey("WEAPON_GRENADELAUNCHER")] = "Grenade Launcher",
    [GetHashKey("WEAPON_RPG")] = "RPG",
    [GetHashKey("WEAPON_STINGER")] = "Stinger",
    [GetHashKey("WEAPON_MINIGUN")] = "Minigun",
    [GetHashKey("WEAPON_GRENADE")] = "Grenade",
    [GetHashKey("WEAPON_STICKYBOMB")] = "Sticky Bomb",
    [GetHashKey("WEAPON_SMOKEGRENADE")] = "Smoke Grenade",
    [GetHashKey("WEAPON_BZGAS")] = "BZ Gas",
    [GetHashKey("WEAPON_MOLOTOV")] = "Molotov",
    [GetHashKey("WEAPON_FIREEXTINGUISHER")] = "Fire Extinguisher",
    [GetHashKey("WEAPON_PETROLCAN")] = "Petrol Can",
    [GetHashKey("WEAPON_BALL")] = "Ball",
    [GetHashKey("WEAPON_SNSPISTOL")] = "SNS Pistol",
    [GetHashKey("WEAPON_SPECIALCARBINE")] = "Special Carbine",
    [GetHashKey("WEAPON_HEAVYPISTOL")] = "Heavy Pistol",
    [GetHashKey("WEAPON_BULLPUPRIFLE")] = "Bullpup Rifle",
    -- Add more weapons as needed
}

-- Function to get weapon name from hash
function GetWeaponNameFromHash(hash)
    return weaponNames[hash] or "Unknown"
end

Citizen.CreateThread(function()
    local spawnPoints = Config.AutoSpawnsLocation
    local allowRespawn = false
    local diedTime = nil
    local respawnTime = 30000 -- 5 minutes in milliseconds

    while true do
        local sleep = 1500
        local ped = PlayerPedId()
        if IsEntityDead(ped) then
            if not Config.DiscordNotification then
                Config.DiscordNotification = true
                local killer = GetPedSourceOfDeath(ped)
                local deathCause = GetPedCauseOfDeath(ped)
                local killerName = GetEntityModel(killer)
                local killerSrc = nil

                if killer then
                    if IsPedAPlayer(killer) then
                        killerSrc = NetworkGetPlayerIndexFromPed(killer)
                    else
                        if not killerName then
                            killerName = "Unknown"
                        end
                    end
                end

                print(deathCause)
                local weaponName = GetWeaponNameFromHash(deathCause) or "Unknown"
                print(weaponName)
                TriggerServerEvent('ak-medic:playerDied', {
                    killerSrc = GetPlayerServerId(killerSrc),
                    killerName = killerName,
                    weaponName = weaponName,
                })
            end
            

            sleep = 2
            if diedTime == nil then
                diedTime = GetGameTimer() + respawnTime
            end

            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)

            local timeLeft = diedTime - GetGameTimer()

            if timeLeft > 0 then
                DisplayRemainingTime(timeLeft, ped) -- Display remaining time in 3D
            else
                allowRespawn = true
                local playerCoords = GetEntityCoords(ped)
                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, "Press ~r~[K]~w~ to respawn")
            end

            if allowRespawn and IsControlJustReleased(0, 311) then -- K key
                local coords = spawnPoints[math.random(#spawnPoints)]
                respawnPed(ped, coords)
                allowRespawn = false
                diedTime = nil
            elseif not allowRespawn and IsControlJustReleased(0, 38) then
                -- send signal to all online ems player
                local playerCoords = GetEntityCoords(ped)
                TriggerServerEvent("sendNotificationToALlEMS", playerCoords)
            end
        else
            allowRespawn = false
            diedTime = nil
        end

        Wait(sleep)
    end
end)
