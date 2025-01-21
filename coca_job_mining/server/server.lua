

RegisterServerEvent('coca_job_mining:removePickaxe', function(pickaxeId)
    local entity = NetworkGetEntityFromNetworkId(pickaxeId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end)
