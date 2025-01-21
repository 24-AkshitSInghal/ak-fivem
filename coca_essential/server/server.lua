RegisterServerEvent("coca_essenitial:sharetext", function(text)
    local src = source
    TriggerClientEvent("coca_essenitial:triggerText", -1, text, src)
end)
