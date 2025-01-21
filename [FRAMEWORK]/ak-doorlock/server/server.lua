Doors = Config.Doors

RegisterCommand('door', function(source, args, rawCommand)
    local doorName = args[1]
    local lockState = tonumber(args[2])
    local doors = Doors

    if not doorName or not doors[doorName] then return end

    if not lockState or (lockState ~= 0 and lockState ~= 1) then return end

    doors[doorName].Locked = lockState

    Doors = doors

    TriggerClientEvent('coca_props_door:update', -1, doorName, lockState)
end)

RegisterServerEvent("coca_props_door:doorStateChange", function(doorName, lockedState)
    ExecuteCommand("door " .. doorName .. " " .. lockedState)
end)

RegisterServerEvent("coca_props_door:Server:InitializeDoorStates", function()
    TriggerClientEvent("coca_props_door:setDoors", source, Doors)
end)

RegisterServerEvent("coca_props_door:Server:RequestDoorStates", function()
    local _source = source
    TriggerClientEvent("coca_props_door:setDoors", _source, Doors)
end)

