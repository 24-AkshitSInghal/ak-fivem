RegisterCommand("vehicle", function(source, args)
    
    local vehicleName = args[1] or 'elegy'

    RequestModel(vehicleName)

    while not HasModelLoaded(vehicleName) do
        Wait(10)
    end

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    if IsPedInAnyVehicle(playerPed, true) then
        TriggerEvent("chat:addMessage", { args = { "You are already in a vehicle" } })
        return
    end

    local vehicle = CreateVehicle(vehicleName, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true)


    SetPedIntoVehicle(playerPed, vehicle, -1)


    SetModelAsNoLongerNeeded(vehicleName)
end, false)
