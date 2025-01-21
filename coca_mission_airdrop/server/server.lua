GlobalState.isMissionStarted = false
GlobalState.isDropOpened = false

RegisterServerEvent("coca_mission_airdrop:started", function()
    GlobalState.isMissionStarted = true
    TriggerClientEvent("coca_mission_airdrop:cl_started", -1, GlobalState.isMissionStarted)
end)

RegisterServerEvent("coca_mission_airdrop:ended", function(dropCoords, entity )
    TriggerClientEvent('coca_mission_airdrop:notifyAllPlayers', -1, dropCoords, entity)
    Wait(600000)   -- wait for to call another drop event in server
    GlobalState.isMissionStarted = false
    GlobalState.isDropOpened = false
    TriggerClientEvent("coca_mission_airdrop:cl_ended", -1, GlobalState.isMissionStarted)
end)


RegisterServerEvent('coca_mission_airdrop:requestState', function()
    local src = source
    TriggerClientEvent('coca_mission_airdrop:cl_requestState', src, GlobalState.isMissionStarted)
end)


RegisterNetEvent('coca_mission_airdrop:openCrate', function(dropEntity)
    
    if GlobalState.isDropOpened then return end

    GlobalState.isDropOpened = true
    local source = source

    -- add pick random weapon array here
    TriggerServerEvent("coca_inventory:Server:AddItem", characterId, 'assaultrifle', 1, "You got a ~y~Assault Rifle~w~")
    Wait(2000)
    local ammonAmmount = Math.random(1,4)
    TriggerServerEvent("coca_inventory:Server:AddItem", characterId, '76239mm', ammonAmmount,"You found "..ammonAmmount .." ~y~762x39mm~o~ box in drop")
    if DoesEntityExist(dropEntity) then
        DeleteObject(dropEntity)
    end

   
    TriggerClientEvent('coca_mission_airdrop:openCrate', -1)

end)