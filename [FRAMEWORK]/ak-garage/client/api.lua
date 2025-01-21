-- You can implement your custom API here

-- Get vehicle extra data, you can use this to store extra data (such as fuel) for the vehicle to database
-- Args: (number) vehicle
-- Return: table
function GetVehicleExtraData(vehicle)
    -- For Standalone
    return {
        damage = GetVehicleDamageData(vehicle),
        fuel = GetVehicleFuelLevel(vehicle)
    }
end

-- Set vehicle extra data
-- Args: (number) vehicle, (table) data
function SetVehicleExtraData(vehicle, data)
    -- For Standalone
    if data and data.damage then
        SetVehicleDamageData(vehicle, data.damage)
    end
    if data and data.fuel then
        SetVehicleFuelLevel(vehicle, data.fuel)
    end
end

-- Send notification to player
-- Args: (string) message
function SendNotification(message)
    -- For Standalone
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
