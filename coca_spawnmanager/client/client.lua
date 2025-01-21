---@diagnostic disable: undefined-field

-- Disable default spawn manager
AddEventHandler('onClientMapStart', function()
    start(true)
    Wait(2000)
    exports.spawnmanager:spawnPlayer()
    exports.spawnmanager:setAutoSpawn(false)
end)

local SelectedCharacterData = nil
local characters = {}
local lastLocation = nil
local characterId = nil

local function startChangeAppearence()
    exports["fivem-appearance"]:startPlayerCustomization(function(appearance)
        local ped = PlayerPedId()
        local clothing = {
            model = exports["fivem-appearance"]:getPedModel(ped),
            tattoos = exports["fivem-appearance"]:getPedTattoos(ped),
            appearance = exports["fivem-appearance"]:getPedAppearance(ped)
        }
        Wait(4000)
        TriggerServerEvent("coca_spawnmanager:updateClothing", SelectedCharacterData.id, clothing)
    end, {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = false
    })
end

local function setCharacterClothes(clothing)
    if GetResourceState("fivem-appearance") ~= "started" then return end
    exports["fivem-appearance"]:setPlayerModel(clothing.model)
    local ped = PlayerPedId()
    Citizen.Wait(500)
    exports["fivem-appearance"]:setPedTattoos(ped, clothing.tattoos)
    exports["fivem-appearance"]:setPedAppearance(ped, clothing.appearance)
end

function SetDisplay(bool, typeName)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = typeName,
        status = bool,
    })
end

function start(switch)
    if switch then
        local ped = PlayerPedId()
        SetEntityVisible(ped, false, 0)
        SwitchOutPlayer(ped, 0, 1)
        FreezeEntityPosition(ped, true)
        Wait(3000)
    end
    TriggerServerEvent("coca_spawnmanager:fetchCharacters")
end

RegisterNetEvent("coca_spawnmanager:receiveCharacters", function(charactersData)
    if (#charactersData > 0) then
        characters = charactersData
    end

    SendNUIMessage({
        type = "refresh",
        characters = characters
    })

    Wait(5000)

    SetDisplay(true, "ui")
end)

RegisterNetEvent("coca_spawnmanager:updatedCharacter", function(characterData)
    SendNUIMessage({
        type = "refresh",
        characters = characterData,
    })
end)

RegisterNUICallback("newCharacter", function(data, cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    TriggerServerEvent("coca_spawnmanager:newCharacter", data)
    cb({ 'ok' })
end)

RegisterNUICallback("deleteCharacter", function(data, cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    TriggerServerEvent("coca_spawnmanager:deleteCharacter", data)
    cb({ 'ok' })
end)

RegisterNUICallback("setMainCharacter", function(data, cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    SelectedCharacterData = data
    SetResourceKvpInt("id_" .. SelectedCharacterData.licensekey, SelectedCharacterData.id)
    characterId = SelectedCharacterData.id

    Config.CurrentCharacterId = SelectedCharacterData.id
    local spawns = Config.SpawnLocations
    TriggerServerEvent('setCharacterPhoneData', data)



    if (SelectedCharacterData.last_position) then
        local lastLocationCoords = json.decode(SelectedCharacterData.last_position)
        table.insert(spawns, 1,
            { label = "Last Location", coords = vec3(lastLocationCoords.x, lastLocationCoords.y, lastLocationCoords.z) })
    end

    SendNUIMessage({
        type = "setspawns",
        spawns = spawns,
    })

    -- Send the SelectedCharacterData.id and player server ID to the server
    TriggerServerEvent('setServerWithCharacterId', GetPlayerServerId(PlayerId()), SelectedCharacterData.id)
    cb('ok')
end)

RegisterNUICallback("teleportMainCharacter", function(data, cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, tonumber(data.coords.x), tonumber(data.coords.y), tonumber(data.coords.z), false, false, false,
        false)
    SwitchInPlayer(ped)
    Wait(500)
    SetDisplay(false, "ui")
    Wait(3000)
    while not HasCollisionLoadedAroundEntity(ped) and IsPlayerSwitchInProgress() do
        Wait(100)
    end
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, 0)

    if (not SelectedCharacterData.clothing) then
        startChangeAppearence()
    else
        setCharacterClothes(json.decode(SelectedCharacterData.clothing))
    end

    cb("ok")
end)

-- Function to save the player's location periodically
Citizen.CreateThread(function()
    Citizen.Wait(90000)
    while true do
        Citizen.Wait(45000)
        if characterId then
            local playerPed = PlayerPedId()
            lastLocation = GetEntityCoords(playerPed)
            savelastLocation()
        end
    end
end)

-- Handle onResourceStop event
function savelastLocation()
    if lastLocation and characterId then
        TriggerServerEvent('coca_spawnmanager:saveLastLoc', characterId, lastLocation)
    end
end

local currentMask = -1
local currentHelmet = -1

-- Command to toggle mining mask
RegisterCommand('mask', function()
    local playerPed = PlayerPedId()
    if currentMask == -1 then
        -- Save current mask if not already saved
        currentMask = GetPedDrawableVariation(playerPed, 1)
        SetPedComponentVariation(playerPed, 1, 0, 0, 0) -- Remove mask
    else
        -- Restore saved mask
        SetPedComponentVariation(playerPed, 1, currentMask, 0, 0)
        currentMask = -1
    end
end, false)

-- Command to toggle mining helmet
RegisterCommand('helmet', function()
    local playerPed = PlayerPedId()
    if currentHelmet == -1 then
        -- Save current helmet if not already saved
        currentHelmet = GetPedPropIndex(playerPed, 0)
        ClearPedProp(playerPed, 0) -- Remove helmet
    else
        -- Restore saved helmet
        SetPedPropIndex(playerPed, 0, currentHelmet, 0, true)
        currentHelmet = -1
    end
end, false)

-- Exported function to get character ID
function GetActiveCharacterId()
    if SelectedCharacterData == nil then return end
    return GetResourceKvpInt("id_" .. SelectedCharacterData.licensekey)
end

function GetCharacterFraction()
    if SelectedCharacterData == nil then return end
    return SelectedCharacterData.fraction
end

function GetCharacterFractionPost()
    if SelectedCharacterData == nil then return end
    return SelectedCharacterData.fraction_post
end

function GetCharacterVitalData()
    if SelectedCharacterData == nil then return end
    return {
        health = SelectedCharacterData.health,
        armour = SelectedCharacterData.armour,
        hunger = SelectedCharacterData.hunger,
        thrist = SelectedCharacterData.thrist,
        stress = SelectedCharacterData.stress
    }
end

-- Mark the function as an export
exports('GetActiveCharacterId', GetActiveCharacterId)
exports('GetCharacterFraction', GetCharacterFraction)
exports('GetCharacterFractionPost', GetCharacterFractionPost)
exports('GetCharacterVitalData', GetCharacterVitalData)
