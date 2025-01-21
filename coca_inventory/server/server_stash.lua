local Stashes = {}
local StashLocks = {}

DBQuery = function(query, cb)
    local data = exports.oxmysql:fetchSync(query)
    if cb then
        cb(data)
    end
    return data
end

local function LoadStash(StashName, cb)
    Stashes[StashName] = {}
    DBQuery("SELECT inventory FROM `stashes` WHERE `stashname` = '" .. StashName .. "'",
        function(result)
            if result and result[1] then
                inventory = json.decode(result[1].inventory)
                Stashes[StashName] = inventory
            else
                for i = 1, 80 do
                    Stashes[StashName][i] = { name = '', count = 0 }
                end

                local inventory = json.encode(Stashes[StashName])
                DBQuery("INSERT INTO `stashes` (`stashname`, `inventory`) VALUES ('" ..
                    StashName ..
                    "', '" .. inventory .. "') ON DUPLICATE KEY UPDATE `inventory` = '" .. inventory .. "'")
            end

            if cb then
                cb(Stashes[StashName])
            end
        end)
end

local function SaveStash(StashName, newStashInventory)
    Stashes[StashName] = newStashInventory
    local inventory = json.encode(Stashes[StashName])
    DBQuery("INSERT INTO `stashes` (`stashname`, `inventory`) VALUES ('" ..
        StashName ..
        "', '" .. inventory .. "') ON DUPLICATE KEY UPDATE `inventory` = '" .. inventory .. "'")
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(Config.Stashes) do
            LoadStash(v.stashname)
        end
    end
end)

RegisterServerEvent('coca_inventory:Server:RequestStashData', function(reqestedStashName)
    local src = source
    if StashLocks[reqestedStashName] == nil then
        StashLocks[reqestedStashName] = src
        LoadStash(reqestedStashName, function(data)
            TriggerClientEvent('coca_inventory:Server:ReceiveStash', src, Stashes[reqestedStashName])
        end)
    else
        TriggerClientEvent('coca_inventory:Server:StashLocked', src)
    end
end)


RegisterServerEvent('coca_inventory:Server:ReleaseStash', function(StashName)
    local src = source
    if StashLocks[StashName] == src then
        StashLocks[StashName] = nil
    end
end)

RegisterServerEvent('coca_inventory:Server:SaveStash', function(StashName, newStashInventory)
    SaveStash(StashName, newStashInventory)
end)
