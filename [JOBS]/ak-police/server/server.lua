local activePoliceIds = {}

RegisterNetEvent('removePlayerFromActivePolice', function(serverId)
    for i, id in ipairs(activePoliceIds) do
        if id == serverId then
            table.remove(activePoliceIds, i)
            break
        end
    end
end)

RegisterNetEvent('addPlayerToActivePolice', function(serverId)
    table.insert(activePoliceIds, serverId)
end)

RegisterServerEvent("sendNotificationToAllPolice", function(playerCoords, msg)
    for _, policeId in ipairs(activePoliceIds) do
        TriggerClientEvent("notifyPolice", policeId, playerCoords, msg)
    end
end)

function SendActivePoliceLocations()
    local policeLocations = {}

    for _, policeId in ipairs(activePoliceIds) do
        local policeCoords = GetEntityCoords(GetPlayerPed(policeId))
        table.insert(policeLocations, { id = policeId, coords = policeCoords })
    end

    for _, targetPoliceId in ipairs(activePoliceIds) do
        TriggerClientEvent("updatePoliceLocations", targetPoliceId, policeLocations)
    end
end

-- Periodically send the locations of active police officers
CreateThread(function()
    while true do
        if #activePoliceIds > 0 then
            SendActivePoliceLocations()
        end
        Wait(5000) -- Update every 5 seconds
    end
end)

local lastSpawnTime = 0
local spawnCooldown = 10 * 60 * 1000 -- 10 minutes in milliseconds

RegisterServerEvent('ak-police:requestHeli', function(coords, heading)
    local currentTime = os.time() * 1000

    if currentTime - lastSpawnTime >= spawnCooldown then
        lastSpawnTime = currentTime
        TriggerClientEvent('ak-police:spawnHeli', source, "polmav", coords, heading)
    else
        TriggerClientEvent('ak-police:heliCooldownStatus', source)
    end
end)

