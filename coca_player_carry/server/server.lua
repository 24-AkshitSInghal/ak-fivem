local carrying = {}
--carrying[source] = targetSource, source is carrying targetSource
local carried = {}
--carried[targetSource] = source, targetSource is being carried by source


RegisterServerEvent("coca_playercarry:sync", function(targetSrc)
    local player = source
    local sourcePed = GetPlayerPed(player)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    if #(sourceCoords - targetCoords) <= 1 then
        TriggerClientEvent("coca_playercarry:syncTarget", targetSrc, player)
        carrying[player] = targetSrc
        carried[targetSrc] = player
    end
end)

RegisterServerEvent("coca_playercarry:stop", function(targetSrc)
    local source = source

    if carrying[source] then
        TriggerClientEvent("coca_playercarry:cl_stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("coca_playercarry:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)


RegisterServerEvent("coca_playercarry:getInCar", function(vehNetId, targetSrc)
    TriggerClientEvent("coca_playercarry:getInCar", targetSrc, vehNetId)
end)

AddEventHandler('playerDropped', function(reason)
    local source = source

    if carrying[source] then
        TriggerClientEvent("coca_playercarry:cl_stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("coca_playercarry:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)




RegisterServerEvent("Drag")
AddEventHandler("Drag", function(Target)
    local Source = source
    TriggerClientEvent("Drag", Target, Source)
end)
