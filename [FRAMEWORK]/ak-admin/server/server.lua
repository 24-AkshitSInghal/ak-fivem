RegisterNetEvent("ak-admin:DeleteEntity", function(entID)
    local ent = NetworkGetEntityFromNetworkId(entID)

    if DoesEntityExist(ent) then
        DeleteEntity(ent)

        Citizen.Wait(1000)

        ent = NetworkGetEntityFromNetworkId(entID)

        if DoesEntityExist(ent) then
            local owner = NetworkGetEntityOwner(ent)
            TriggerClientEvent("ak-admin:DeleteFromClient", owner, entID)

            Citizen.Wait(1000)

            ent = NetworkGetEntityFromNetworkId(entID)

            if DoesEntityExist(ent) then
                print("The entity could not be deleted.")
            end
        end
    end
end)

------- Teleport -------

RegisterNetEvent('ak-admin:goto', function(targertId)
    local playerId = source;
    local targetPed = GetPlayerPed(targertId)

    if targetPed <= 0 then
        TriggerClientEvent("chat:addMessage", playerId, { args = { 'Sorry ' .. targertId .. ' doesn\'t seem to exist' } })
        return
    end
    print(playerId)

    local targetCoords = GetEntityCoords(targetPed);
    local playerPed = GetPlayerPed(playerId)

    SetEntityCoords(playerPed, targetCoords)
end)

RegisterNetEvent('ak-admin:summon', function(targertId)
    local playerId = source;
    local targetPed = GetPlayerPed(targertId)

    if targetPed <= 0 then
        TriggerClientEvent("chat:addMessage", playerId, { args = { 'Sorry ' .. targertId .. ' doesn\'t seem to exist' } })
        return
    end
    local playerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed);

    SetEntityCoords(targetPed, playerCoords)
end)
