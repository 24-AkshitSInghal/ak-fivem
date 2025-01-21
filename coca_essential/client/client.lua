-- for hide useless hud
Citizen.CreateThread(function()
    local HUD_ELEMENTS = {
        HUD = { id = 0, hidden = false },
        HUD_WANTED_STARS = { id = 1, hidden = false },
        HUD_WEAPON_ICON = { id = 2, hidden = false },
        HUD_CASH = { id = 3, hidden = true },
        HUD_MP_CASH = { id = 4, hidden = true },
        HUD_MP_MESSAGE = { id = 5, hidden = true },
        HUD_VEHICLE_NAME = { id = 6, hidden = false },
        HUD_AREA_NAME = { id = 7, hidden = false },
        HUD_VEHICLE_CLASS = { id = 8, hidden = false },
        HUD_STREET_NAME = { id = 9, hidden = false },
        HUD_HELP_TEXT = { id = 10, hidden = false },
        HUD_FLOATING_HELP_TEXT_1 = { id = 11, hidden = false },
        HUD_FLOATING_HELP_TEXT_2 = { id = 12, hidden = false },
        HUD_CASH_CHANGE = { id = 13, hidden = true },
        HUD_RETICLE = { id = 14, hidden = false },
        HUD_SUBTITLE_TEXT = { id = 15, hidden = false },
        HUD_RADIO_STATIONS = { id = 16, hidden = false },
        HUD_SAVING_GAME = { id = 17, hidden = true },
        HUD_GAME_STREAM = { id = 18, hidden = false },
        HUD_WEAPON_WHEEL = { id = 19, hidden = true },
        HUD_WEAPON_WHEEL_STATS = { id = 20, hidden = true },
        MAX_HUD_COMPONENTS = { id = 21, hidden = true },
        MAX_HUD_WEAPONS = { id = 22, hidden = true },
        MAX_SCRIPTED_HUD_COMPONENTS = { id = 141, hidden = false }
    }

    while Config.DisableGTA5Defaults do
        for key, val in pairs(HUD_ELEMENTS) do
            if val.hidden then
                HideHudComponentThisFrame(val.id)
            else
                ShowHudComponentThisFrame(val.id)
            end
        end
        Citizen.Wait(1)
    end
end)


-- for peds not drop weapon
Citizen.CreateThread(function()
    local function SetWeaponDrops()
        local pedindex = {}
        local handle, ped = FindFirstPed()
        local finished = false
        repeat
            if not IsEntityDead(ped) then
                pedindex[ped] = true
            end
            finished, ped = FindNextPed(handle)
        until not finished
        EndFindPed(handle)

        for pedid, _ in pairs(pedindex) do
            SetPedDropsWeaponsWhenDead(pedid, false)
            SetPedSuffersCriticalHits(pedid, false)
        end
    end

    while true do
        SetWeaponDrops()
        Citizen.Wait(500)
    end
end)

-- disable controls
Citizen.CreateThread(function()
    while true do
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 157, true)
        DisableControlAction(0, 158, true)
        DisableControlAction(0, 159, true)
        DisableControlAction(0, 160, true)
        DisableControlAction(0, 161, true)
        DisableControlAction(0, 162, true)
        DisableControlAction(0, 163, true)
        DisableControlAction(0, 164, true)
        DisableControlAction(0, 165, true)
        DisableControlAction(0, 199, true)


        Citizen.Wait(1)
    end
end)

--############# WEAPON RECOIL ##############--

local weapons = {
    -- Tier 1: Low recoil
    [GetHashKey('WEAPON_PISTOL')] = { recoil = 0.3, shake = 0.06, tier = 1 },
    [GetHashKey('WEAPON_PISTOL_MK2')] = { recoil = 0.3, shake = 0.03, tier = 1 },
    [GetHashKey('WEAPON_COMBATPISTOL')] = { recoil = 0.2, shake = 0.03, tier = 1 },
    [GetHashKey('WEAPON_APPISTOL')] = { recoil = 0.1, shake = 0.03, tier = 1 },
    [GetHashKey('WEAPON_SNSPISTOL')] = { recoil = 0.2, shake = 0.02, tier = 1 },
    [GetHashKey('WEAPON_SNSPISTOL_MK2')] = { recoil = 0.25, shake = 0.025, tier = 1 },
    [GetHashKey('WEAPON_VINTAGEPISTOL')] = { recoil = 0.4, shake = 0.025, tier = 1 },
    [GetHashKey('WEAPON_MACHINEPISTOL')] = { recoil = 0.3, shake = 0.04, tier = 1 },
    [GetHashKey('WEAPON_MINISMG')] = { recoil = 0.1, shake = 0.03, tier = 1 },

    -- Tier 2: Medium recoil
    [GetHashKey('WEAPON_MICROSMG')] = { recoil = 0.2, shake = 0.035, tier = 2 },
    [GetHashKey('WEAPON_SMG')] = { recoil = 0.1, shake = 0.045, tier = 2 },
    [GetHashKey('WEAPON_SMG_MK2')] = { recoil = 0.1, shake = 0.055, tier = 2 },
    [GetHashKey('WEAPON_ASSAULTSMG')] = { recoil = 0.1, shake = 0.050, tier = 2 },
    [GetHashKey('WEAPON_ASSAULTRIFLE')] = { recoil = 0.2, shake = 0.07, tier = 2 },
    [GetHashKey('WEAPON_ASSAULTRIFLE_MK2')] = { recoil = 0.2, shake = 0.072, tier = 2 },
    [GetHashKey('WEAPON_CARBINERIFLE')] = { recoil = 0.1, shake = 0.06, tier = 2 },
    [GetHashKey('WEAPON_CARBINERIFLE_MK2')] = { recoil = 0.1, shake = 0.065, tier = 2 },
    [GetHashKey('WEAPON_ADVANCED_RIFLE')] = { recoil = 0.1, shake = 0.06, tier = 2 },
    [GetHashKey('WEAPON_MG')] = { recoil = 0.1, shake = 0.07, tier = 2 },
    [GetHashKey('WEAPON_COMBATMG')] = { recoil = 0.1, shake = 0.08, tier = 2 },
    [GetHashKey('WEAPON_COMBATMG_MK2')] = { recoil = 0.1, shake = 0.085, tier = 2 },
    [GetHashKey('WEAPON_BULLPUPRIFLE')] = { recoil = 0.2, shake = 0.05, tier = 2 },
    [GetHashKey('WEAPON_BULLPUPRIFLE_MK2')] = { recoil = 0.25, shake = 0.055, tier = 2 },
    [GetHashKey('WEAPON_MARKSMANRIFLE')] = { recoil = 0.3, shake = 0.05, tier = 2 },
    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = { recoil = 0.35, shake = 0.035, tier = 2 },
    [GetHashKey('WEAPON_SPECIALCARBINE')] = { recoil = 0.2, shake = 0.06, tier = 2 },
    [GetHashKey('WEAPON_SPECIALCARBINE_MK2')] = { recoil = 0.25, shake = 0.075, tier = 2 },
    [GetHashKey('WEAPON_COMPACTRIFLE')] = { recoil = 0.3, shake = 0.03, tier = 2 },
    [GetHashKey('WEAPON_COMBATPDW')] = { recoil = 0.2, shake = 0.05, tier = 2 },
    [GetHashKey('WEAPON_AUTOSHOTGUN')] = { recoil = 0.2, shake = 0.04, tier = 2 },

    -- Tier 3: High recoil
    [GetHashKey('WEAPON_PISTOL50')] = { recoil = 0.6, shake = 0.05, tier = 3 },
    [GetHashKey('WEAPON_PUMPSHOTGUN')] = { recoil = 0.4, shake = 0.07, tier = 3 },
    [GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = { recoil = 0.4, shake = 0.085, tier = 3 },
    [GetHashKey('WEAPON_SAWNOFFSHOTGUN')] = { recoil = 0.7, shake = 0.06, tier = 3 },
    [GetHashKey('WEAPON_ASSAULTSHOTGUN')] = { recoil = 0.4, shake = 0.12, tier = 3 },
    [GetHashKey('WEAPON_BULLPUPSHOTGUN')] = { recoil = 0.2, shake = 0.08, tier = 3 },
    [GetHashKey('WEAPON_HEAVYSHOTGUN')] = { recoil = 0.2, shake = 0.13, tier = 3 },
    [GetHashKey('WEAPON_SNIPERRIFLE')] = { recoil = 0.5, shake = 0.2, tier = 3 },
    [GetHashKey('WEAPON_HEAVYSNIPER')] = { recoil = 0.7, shake = 0.3, tier = 3 },
    [GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = { recoil = 0.7, shake = 0.35, tier = 3 },
    [GetHashKey('WEAPON_REMOTESNIPER')] = { recoil = 1.2, shake = 0.1, tier = 3 },
    [GetHashKey('WEAPON_GRENADELAUNCHER')] = { recoil = 1.0, shake = 0.08, tier = 3 },
    [GetHashKey('WEAPON_GRENADELAUNCHER_SMOKE')] = { recoil = 1.0, shake = 0.04, tier = 3 },
    [GetHashKey('WEAPON_RPG')] = { recoil = 0.0, shake = 0.9, tier = 3 },
    [GetHashKey('WEAPON_STINGER')] = { recoil = 0.0, shake = 0.3, tier = 3 },
    [GetHashKey('WEAPON_MINIGUN')] = { recoil = 0.01, shake = 0.25, tier = 3 },
    [GetHashKey('WEAPON_DOUBLEACTION')] = { recoil = 0.4, shake = 0.025, tier = 3 },
    [GetHashKey('WEAPON_MUSKET')] = { recoil = 0.7, shake = 0.09, tier = 3 },
    [GetHashKey('WEAPON_MARKSMANPISTOL')] = { recoil = 0.9, shake = 0.04, tier = 3 },
    [GetHashKey('WEAPON_RAILGUN')] = { recoil = 2.4, shake = 0.08, tier = 3 },
    [GetHashKey('WEAPON_REVOLVER')] = { recoil = 0.6, shake = 0.05, tier = 3 },
    [GetHashKey('WEAPON_REVOLVER_MK2')] = { recoil = 0.65, shake = 0.055, tier = 3 },
    [GetHashKey('WEAPON_DBSHOTGUN')] = { recoil = 0.7, shake = 0.04, tier = 3 },
    [GetHashKey('WEAPON_COMPACTLAUNCHER')] = { recoil = 0.5, shake = 0.05, tier = 3 },
    [GetHashKey('WEAPON_HEAVYPISTOL')] = { recoil = 0.4, shake = 0.04, tier = 3 },
    [GetHashKey('WEAPON_SPECIALCARBINE')] = { recoil = 0.1, shake = 0.06, tier = 3 },
    [GetHashKey('WEAPON_HOMINGLAUNCHER')] = { recoil = 0, shake = 0.04, tier = 3 },
    [GetHashKey('WEAPON_FLAREGUN')] = { recoil = 0.9, shake = 0.04, tier = 3 },
}

local function getRandomFactor(tier)
    if tier == 1 then
        return math.random() * 0.01
    elseif tier == 2 then
        return math.random() * 0.02
    else
        return math.random() * 0.03
    end
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        if weapon and weapon ~= `WEAPON_UNARMED` then
            Wait(0)
        else
            Wait(1500)
        end

        if weapon and weapon ~= `WEAPON_UNARMED` then
            local inVehicle = IsPedInAnyVehicle(ped, false)
            for hash, data in pairs(weapons) do
                if weapon == hash then
                    local bullets = 0;
                    if IsPedShooting(ped) then
                        bullets = bullets + 1
                        local randomShake = data.shake + getRandomFactor(data.tier)
                        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', randomShake)
                        if (not IsPedDoingDriveby(PlayerPedId())) then
                            local _, wep = GetCurrentPedWeapon(ped)
                            if wep and weapons[wep] and weapons[wep].recoil and weapons[wep].recoil ~= 0 then
                                local totalRecoil = 0
                                local initialAim = GetGameplayCamRelativePitch()      -- Store initial aim position
                                local initialCamYaw = GetGameplayCamRelativeHeading() -- Store initial camera yaw
                                repeat
                                    Wait(0)
                                    local pitch = initialAim +
                                        (math.random() * 0.02 - 0.01) -- Randomly adjust aim position
                                    local camYaw = initialCamYaw +
                                        (math.random() * 0.02 - 0.01) -- Randomly adjust camera yaw
                                    local randomRecoil = weapons[wep].recoil + getRandomFactor(weapons[wep].tier)
                                    if inVehicle then
                                        randomRecoil = randomRecoil * 1.5 -- Increase recoil by 50% in vehicle
                                    end
                                    if GetFollowPedCamViewMode() ~= 4 then
                                        SetGameplayCamRelativePitch(pitch + 0.1 + randomRecoil, 0.2)
                                        SetGameplayCamRelativeHeading(camYaw)
                                    else
                                        SetGameplayCamRelativePitch(pitch + 0.1 + randomRecoil, 1.0)
                                        SetGameplayCamRelativeHeading(camYaw)
                                    end
                                    totalRecoil = totalRecoil + 0.1 + randomRecoil
                                until totalRecoil >= weapons[wep].recoil
                            end
                        end
                    end

                    if bullets > 0 then
                        TriggerEvent("coca_ui_player:AddStress", 0.25) -- Increase stress if ammo has changed
                    end
                end
            end
        end
    end
end)

-- ROTATE HEAD TO ACTIVE SPEAK PLAYER

CreateThread(function()
    while true do
        Wait(500)
        local onlinePlayers = GetActivePlayers()
        local playerPed = PlayerPedId()
        for i = 1, #onlinePlayers do
            if onlinePlayers[i] ~= PlayerId() and NetworkIsPlayerActive(onlinePlayers[i]) then
                if MumbleIsPlayerTalking(onlinePlayers[i]) then
                    local targetPed = GetPlayerPed(onlinePlayers[i])
                    if #(GetEntityCoords(targetPed) - GetEntityCoords(playerPed)) < 20 then
                        TaskLookAtEntity(playerPed, targetPed, 3000, 2048, 3)
                    end
                end
            end
        end
    end
end)


-- -- ANTI STRAFE

local pressAmount = 0
local keys = { 30, 31 }

local function breakStrafe(key, time)
    CreateThread(function()
        local finishTime = GetGameTimer() + time
        while finishTime > GetGameTimer() do
            SetControlNormal(0, key, 1.0)
            Wait(0)
        end
    end)
end

CreateThread(function()
    while true do
        Wait(1000)
        if pressAmount > 4 then
            local key = IsControlJustPressed(0, 30) and 30 or 31
            breakStrafe(key, 250)
        end
        pressAmount = 0
    end
end)

CreateThread(function()
    while true do
        local time = 1000
        local playerPed = PlayerPedId()
        if IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(playerPed) then
            time = 0
            for i = 1, #keys do
                if IsControlJustPressed(0, keys[i]) then
                    pressAmount = pressAmount + 1
                end
            end
        end
        Wait(time)
    end
end)

-- Hide default health and armour

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    local pedId = PlayerId()
    while true do
        Wait(2000)

        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

CreateThread(function()
    while true do
        Wait(1)
        local id = PlayerId()
        DisablePlayerVehicleRewards(id)

        if GetEntityMaxHealth(GetPlayerPed(-1)) ~= 200 then  -- set female peds to same health as male.
            SetEntityMaxHealth(GetPlayerPed(-1), 200)
            SetEntityHealth(GetPlayerPed(-1), 200)
        end

        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)

        SetPedDensityMultiplierThisFrame(Config.PedFrequency)
        SetScenarioPedDensityMultiplierThisFrame(Config.PedFrequency, Config.PedFrequency)
        -------------------------------
        SetRandomVehicleDensityMultiplierThisFrame(Config.TrafficFrequency)
        SetParkedVehicleDensityMultiplierThisFrame(Config.TrafficFrequency)
        SetVehicleDensityMultiplierThisFrame(Config.TrafficFrequency)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(20 * 1000)
        PopulateNow()
    end
end)

-- set player can attact 

AddEventHandler('onClientMapStart', function()
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)
