RegisterServerEvent('coca_mission_pet:removePet', function(petId)
    local ped = NetworkGetEntityFromNetworkId(petId)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end)