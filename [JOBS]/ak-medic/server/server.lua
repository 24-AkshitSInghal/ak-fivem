local lastSpawnTime = 0
local spawnCooldown = 10 * 60 * 1000 -- 10 minutes in milliseconds
local activeEmsIds = {}

RegisterServerEvent('ak-medic:requestHeli', function(coords, heading)
    local currentTime = os.time() * 1000

    if currentTime - lastSpawnTime >= spawnCooldown then
        lastSpawnTime = currentTime
        TriggerClientEvent('ak-medic:spawnHeli', source, "polmav", coords, heading)
    else
        TriggerClientEvent('ak-medic:heliCooldownStatus', source)
    end
end)

local lastSpawnTimeAmbulance = 0
local spawnCooldownAmbulance = 5 * 60 * 1000 -- 10 minutes in milliseconds

RegisterServerEvent('ak-medic:requestAmbulance', function(coords, heading)
    local currentTime = os.time() * 1000

    if currentTime - lastSpawnTimeAmbulance >= spawnCooldownAmbulance then
        lastSpawnTimeAmbulance = currentTime
        TriggerClientEvent('ak-medic:spawnAmbulance', source, "ambulance", coords, heading)
    else
        TriggerClientEvent('ak-medic:AmbulanceCooldownStatus', source)
    end
end)

RegisterServerEvent("healPlayer")
AddEventHandler("healPlayer", function(targetPlayerId)
    TriggerClientEvent("healPlayer", targetPlayerId)
end)

RegisterNetEvent('addPlayerToActiveEms', function(serverId)
    table.insert(activeEmsIds, serverId)
    print("Server ID " .. serverId .. " is added in Ems")
end)

RegisterServerEvent("sendNotificationToALlEMS", function(playerCoords, msg)
    for _, emsId in ipairs(activeEmsIds) do
        TriggerClientEvent("notifyEMS", emsId, playerCoords, msg)
    end
end)

RegisterNetEvent('removePlayerFromActiveEMS', function(serverId)
    for i, id in ipairs(activeEmsIds) do
        if id == serverId then
            table.remove(activeEmsIds, i)
            print("Server ID " .. serverId .. " is removed from active EMS")
            break
        end
    end
end)

function SendActiveEMSLocations()
    local EMSLocations = {}

    for _, EmsID in ipairs(activeEmsIds) do
        local Coords = GetEntityCoords(GetPlayerPed(EmsID))
        table.insert(EMSLocations, { id = EmsID, coords = Coords })
    end

    for _, targetId in ipairs(activeEmsIds) do
        TriggerClientEvent("updateEMSLocations", targetId, EMSLocations)
    end
end

-- Periodically send the locations of active police officers
CreateThread(function()
    while true do
        if #activeEmsIds > 0 then
            SendActiveEMSLocations()
        end
        Wait(5000) -- Update every 5 seconds
    end
end)

RegisterServerEvent("ak-medic:playerDied")
AddEventHandler("ak-medic:playerDied", function(data)
    local killerSrc = data.killerSrc
    local killerName = data.killerName
    local weaponName = data.weaponName
    print(killerSrc)
    if killerSrc then
        print("in killerSrc")
        exports['ak-logs']:CreateLog({
            category = "player_deaths",
            title = "Player Death Logs",
            action = "New",
            color = "red",
            players = {
                { id = source,  role = "Player" },
                { id = killerSrc, role = "Murderer" },
            },
            info = {
                { name = "Weapon", value = weaponName },
            },
            takeScreenshot = true
        })
    else
        exports['ak-logs']:CreateLog({
            category = "player_deaths",
            title = "Player Death Logs",
            action = "New",
            color = "red",
            players = {
                { id = source, role = "Player" },
            },
            info = {
                { name = "Ped Killer Name", value = killerName },
                { name = "Weapon",          value = weaponName },
            },
            takeScreenshot = true
        })
    end
end)
