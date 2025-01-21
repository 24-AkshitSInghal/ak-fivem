local fraction = nil

while not fraction do
    Wait(1000)
    fraction = exports['coca_spawnmanager']:GetCharacterFraction()
end

if fraction ~= "admin" then
    SendNUIMessage({
        type = 'toggle',
        state = false,
    })
    return
end

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- player coords

local showCoords = true;

CreateThread(function()
    while true do
        Wait(1000)
        local playerId = PlayerPedId()
        local playercoods = GetEntityCoords(playerId)
        local playerHeading = GetEntityHeading(playerId)
        if showCoords then
            SendNUIMessage({
                type = 'coords',
                x = playercoods.x,
                y = playercoods.y,
                z = playercoods.z,
                heading = playerHeading
            })
        end
    end
end)

TriggerEvent('chat:addSuggestion', '/coords', '(admin) Toggle Show Coords')
RegisterCommand('coords', function(source, args)
    if showCoords then
        showCoords = false;
        SendNUIMessage({
            type = 'toggle',
            state = false,
        })
    else
        showCoords = true;
        SendNUIMessage({
            type = 'toggle',
            state = true,
        })
    end
end)

-- SET HEALTH
TriggerEvent('chat:addSuggestion', '/health', '(admin) usage: /health [health 100 - 200]')
RegisterCommand('health', function(source, args)
    if (args[1] == nil) then return end
    SetEntityHealth(PlayerPedId(), tonumber(args[1]))
end)

-- SET ARMOUR
TriggerEvent('chat:addSuggestion', '/armor', '(admin) usage: /armor [health 0 - 100]')
RegisterCommand('armor', function(source, args, rawCommand)
    local player = PlayerPedId()
    local armorLevel = tonumber(args[1])

    if armorLevel and armorLevel >= 0 and armorLevel <= 100 then
        SetPedArmour(player, armorLevel)
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "System", "Armor set to " .. armorLevel .. "%" }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "System", "Invalid armor level. Please enter a value between 0 and 100." }
        })
    end
end, false)

-- Enable GOD MOD

local godModeEnabled = false
TriggerEvent('chat:addSuggestion', '/god', '(admin) God Mode')
RegisterCommand('god', function(source, args)
    godModeEnabled = not godModeEnabled -- Toggle god mode status

    if godModeEnabled then
        SetEntityInvincible(PlayerPedId(), true) -- Enable god mode for the player
        drawNativeNotification("God mode enabled.")
    else
        SetEntityInvincible(PlayerPedId(), false) -- Disable god mode for the player
        drawNativeNotification("God mode disabled.")
    end
end)

-- delete entity with [E]

local deleteActive = false;
TriggerEvent('chat:addSuggestion', '/delete', '(admin) Toggle Delete Entity With [E]')
RegisterCommand("delete", function()
    if deleteActive then
        deleteActive = false;
    else
        deleteActive = true;
    end
end)


Citizen.CreateThread(function()
    while true do
        Wait(1)

        local found, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if found and IsControlPressed(2, 38) and deleteActive then
            NetworkRegisterEntityAsNetworked(entity)
            local entID = NetworkGetNetworkIdFromEntity(entity)
            TriggerServerEvent("ak-admin:DeleteEntity", entID)
        end
    end
end)

-- change fraction of admin
TriggerEvent('chat:addSuggestion', '/fraction', '(admin) usage: /fraction [Fraction Name] [Player Character ID]')
RegisterCommand('fraction', function(source, args, raw)
    local fraction = args[1]
    local characterId = args[2]
    local userfraction = exports['coca_spawnmanager']:GetCharacterFraction()

    if userfraction ~= 'admin' then
        return
    end

    if fraction == "" and characterId == "" then
        drawNativeNotification("Please enter both feild.")
        return
    end

    TriggerServerEvent('coca_spawnmanager:changeFraction', fraction, characterId)
end)

------- Teleport -------

RegisterCommand("goto", function(source, args)
    if not args or #args == 0 then
        TriggerEvent("chat:addMessage", { args = { "Usage: /goto [player_id]" } })
        return
    end
    local targertId = args[1]


    TriggerServerEvent('coca_teleport:goto', targertId);
end)


RegisterCommand("summon", function(source, args)
    if not args or #args == 0 then
        TriggerEvent("chat:addMessage", { args = { "Usage: /summon [player_id]" } })
        return
    end

    local targertId = args[1]

    TriggerServerEvent('coca_teleport:summon', targertId);
end)

TriggerEvent('chat:addSuggestion', '/tpm', '(admin) usage: Teleport to WayPoint')
RegisterCommand('tpm', function(source, args, rawCommand)
    local blip = GetFirstBlipInfoId(8)
    if blip == 0 then
        return
    end
    local coords = GetBlipInfoIdCoord(blip)
    StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, true, true, true)
end, false)