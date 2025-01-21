RegisterCommand("startrolling", function(source, args, raw)

    local _source = source
    -- local job = xPlayer.job.name

    -- if job == 'weazelnews' then
        local src = source
    TriggerClientEvent("coca_job_news:GetCam", src)
    -- end
end)

RegisterCommand("startrecording", function(source, args, raw)
    
    local _source = source

        local src = source
    TriggerClientEvent("coca_job_news:GetMic", src)
 
    
end)
