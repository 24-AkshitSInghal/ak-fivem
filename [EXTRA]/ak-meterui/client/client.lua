
-- seat belt logic
local seatbeltOn = false
local prevSpeed = 0.0
local prevVelocity = vector3(0.0, 0.0, 0.0)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, false)
        local sleep = 1500

        if IsPedInAnyVehicle(player, false) then
            sleep = 10
            local currSpeed = GetEntitySpeed(vehicle)
            local position = GetEntityCoords(player)

            if seatbeltOn then

                local seatbeltEjectSpeed = 100.0 -- 45 MPH
                local seatbeltEjectAccel = 40.0 -- 100 G's
                local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()

                if vehIsMovingFwd and prevSpeed > (seatbeltEjectSpeed / 2.237) and vehAcc > (seatbeltEjectAccel * 9.81) then
                    SetEntityCoords(player, position.x, position.y, position.z - 0.47, true, true, true)
                    SetEntityVelocity(player, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                    Citizen.Wait(1)
                    SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
                else
                    prevVelocity = GetEntityVelocity(vehicle)
                end
               
                DisableControlAction(0, 75, true)  
                DisableControlAction(27, 75, true)
            else
                -- Seatbelt off: handle ejection
                local seatbeltEjectSpeed = 60.0 -- 45 MPH
                local seatbeltEjectAccel = 30.0 -- 100 G's
                local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
    
                if vehIsMovingFwd and prevSpeed > (seatbeltEjectSpeed / 2.237) and vehAcc > (seatbeltEjectAccel * 9.81) then
                    SetEntityCoords(player, position.x, position.y, position.z - 0.47, true, true, true)
                    SetEntityVelocity(player, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                    Citizen.Wait(1)
                    SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
                else
                    prevVelocity = GetEntityVelocity(vehicle)
                end

                
            end

            prevSpeed = currSpeed
        else
            seatbeltOn = false
        end
        Citizen.Wait(sleep)
    end
end)

-- Fuel consumption logic
local digitAbovefuelDisappear = 80
local reductionFactor = 0.8

local fuelConsumptionRates = {
    ['Compacts'] = 0.1 * reductionFactor,
    ['Sedans'] = 0.1 * reductionFactor,
    ['SUVs'] = 0.15 * reductionFactor,
    ['Coupes'] = 0.1 * reductionFactor,
    ['Muscle'] = 0.12 * reductionFactor,
    ['Sports Classics'] = 0.15 * reductionFactor,
    ['Sports'] = 0.2 * reductionFactor,
    ['Super'] = 0.25 * reductionFactor,
    ['Motorcycles'] = 0.05 * reductionFactor,
    ['Off-road'] = 0.15 * reductionFactor,
    ['Industrial'] = 0.25 * reductionFactor,
    ['Utility'] = 0.1 * reductionFactor,
    ['Vans'] = 0.2 * reductionFactor,
    ['Cycles'] = 0.0 * reductionFactor,
    ['Boats'] = 0.1 * reductionFactor,
    ['Helicopters'] = 0.3 * reductionFactor,
    ['Planes'] = 0.3 * reductionFactor,
    ['Service'] = 0.1 * reductionFactor,
    ['Emergency'] = 0.1 * reductionFactor,
    ['Military'] = 0.2 * reductionFactor,
    ['Commercial'] = 0.3 * reductionFactor,
    ['Trains'] = 0.1 * reductionFactor
}

local electricVehicles = {
    ["airtug"] = true,
    ["buffaloevx"] = true,
    ["caddy"] = true,
    ["caddy2"] = true,
    ["caddy3"] = true,
    ["cyclone"] = true,
    ["cyclone2"] = true,
    ["dilettan"] = true,
    ["dilettan2"] = true,
    ["iwagen"] = true,
    ["imorgon"] = true,
    ["khamelion"] = true,
    ["lacoureuse"] = true,
    ["neon"] = true,
    ["omnisegt"] = true,
    ["powersurge"] = true,
    ["raiden"] = true,
    ["rocketvoltic"] = true,
    ["surge"] = true,
    ["tezeract"] = true,
    ["virtue"] = true,
    ["voltic"] = true
}

local function getVehicleCategory(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    local vehicleClasses = {
        [0] = 'Compacts',
        [1] = 'Sedans',
        [2] = 'SUVs',
        [3] = 'Coupes',
        [4] = 'Muscle',
        [5] = 'Sports Classics',
        [6] = 'Sports',
        [7] = 'Super',
        [8] = 'Motorcycles',
        [9] = 'Off-road',
        [10] = 'Industrial',
        [11] = 'Utility',
        [12] = 'Vans',
        [13] = 'Cycles',
        [14] = 'Boats',
        [15] = 'Helicopters',
        [16] = 'Planes',
        [17] = 'Service',
        [18] = 'Emergency',
        [19] = 'Military',
        [20] = 'Commercial',
        [21] = 'Trains'
    }
    return vehicleClasses[vehicleClass] or 'Unknown'
end

local function getFuelConsumptionRate(vehicle)
    local category = getVehicleCategory(vehicle)
    return fuelConsumptionRates[category] or 0.1
end

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player)
        local model = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(model):lower()
        local vehicleClass = GetVehicleClass(vehicle)

        if not IsPauseMenuActive() and IsPedInAnyVehicle(player) then
            if vehicleClass == 13 or IsThisModelABicycle(vehicle) or electricVehicles[vehicleName] then
                SetVehicleFuelLevel(vehicle, 100.0)
                sleep = 1500
                SendNUIMessage({
                    toggle = true,
                    vel = math.floor(GetEntitySpeed(vehicle) * 3.6),
                    fuel = 100,
                    type = 'km/h',
                    config = digitAbovefuelDisappear,
                    seatbeltOn = seatbeltOn
                })
            else
                sleep = 200
                local vel = math.floor(GetEntitySpeed(vehicle) * 3.6)
                local fuelLevel = GetVehicleFuelLevel(vehicle)

                if fuelLevel > 0 then
                    local fuelConsumptionRate = getFuelConsumptionRate(vehicle)
                    local newFuelLevel = fuelLevel - (fuelConsumptionRate * vel / 1000)
                    SetVehicleFuelLevel(vehicle, newFuelLevel)
                end

                local fuel = math.floor(GetVehicleFuelLevel(vehicle))

                SendNUIMessage({
                    toggle = true,
                    vel = vel,
                    fuel = fuel,
                    type = 'km/h',
                    config = digitAbovefuelDisappear,
                    seatbeltOn = seatbeltOn
                })
            end
        else
            sleep = 1500
            SendNUIMessage({
                toggle = false
            })
        end
        Citizen.Wait(sleep)
    end
end)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')
RegisterCommand('toggleseatbelt', function(source, args, rawCommand)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local class = GetVehicleClass(GetVehiclePedIsIn(ped))
        if class ~= 8 and class ~= 13 and class ~= 14 then
            toggleSeatbelt()
        end
    end
end, false)

function toggleSeatbelt()
    if seatbeltOn then
        SetFlyThroughWindscreenParams(27, 31, 17.0, 2000)
        SendNUIMessage({ show = false }) -- Correct show value to false when seatbelt is off
    else
        SetFlyThroughWindscreenParams(1000000.0, 1000000.0, 17.0, 500.0)
        SendNUIMessage({ show = true }) -- Correct show value to true when seatbelt is on
    end
    seatbeltOn = not seatbeltOn
end




