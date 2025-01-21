-- use_functions.lua

function PlayAnimation(ped, animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration, 1, 0, false, false, false)
end

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function StopAnimation(ped)
    ClearPedTasksImmediately(ped)
end

local function IsiteminInventory(itemName)
    return HasItemInInventory(itemName)
end

local function IsWeaponStillinInventory(itemName)
    return HasWeaponinInventory(itemName)
end

function UseConsumable(itemData, itemName, itemIndex)
    local consumables = {
        water = UseWater,
        bread = UseBread,
        bandage = UseBandage,
        sandwich = UseSandwich,
        sportsdrink = useSportsdrink,
        firstaidkit = useFirstaidkit,
        bait = useBait,
    }

    if consumables[itemName] then
        consumables[itemName](itemData, itemName, itemIndex)
    else
        drawNativeNotification("You can't use ~o~" .. itemData.label .. "~s~ like this")
    end
end

-- Common function to play an animation
function PlayAnimation(dict, anim, duration)
    local playerPed = PlayerPedId()
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
    Citizen.Wait(duration)
    ClearPedTasks(playerPed)
end

-- Function to use sports drink
function useSportsdrink(itemData, itemName, itemIndex)
    RemoveItemFromInventorybyIndex(itemIndex, 1)
    PlayAnimation("mp_player_intdrink", "loop_bottle", 7000)
    TriggerEvent("coca_ui_player:IncreaseThistBar", 40)
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    local runSpeedMultiplier = 1.25 -- Adjust this multiplier as needed
    SetRunSprintMultiplierForPlayer(playerId, runSpeedMultiplier)
    Citizen.Wait(30000)
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
end

-- Function to use water
function UseWater(itemData, itemName, itemIndex)
    RemoveItemFromInventorybyIndex(itemIndex, 1)
    PlayAnimation("mp_player_intdrink", "loop_bottle", 7000)
    TriggerEvent("coca_ui_player:IncreaseThistBar", 30)
end

-- Function to use bread
function UseBread(itemData, itemName, itemIndex)
    RemoveItemFromInventorybyIndex(itemIndex, 1)
    PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 12000)
    TriggerEvent("coca_ui_player:IncreaseHungerBar", 20)
    TriggerEvent("coca_ui_player:IncreaseThistBar", -5)
end

-- Function to use a sandwich
function UseSandwich(itemData, itemName, itemIndex)
    RemoveItemFromInventorybyIndex(itemIndex, 1)
    PlayAnimation("mp_player_inteat@burger", "mp_player_int_eat_burger", 15000)
    TriggerEvent("coca_ui_player:IncreaseHungerBar", 30)
    TriggerEvent("coca_ui_player:IncreaseThistBar", -5)
end

-- Function to use a bandage
function UseBandage(itemData, itemName, itemIndex)
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)

    if currentHealth >= 200 then
        drawNativeNotification("Your Health is already ~g~Full~s~")
        return
    end

    RemoveItemFromInventorybyIndex(itemIndex, 1)
    PlayAnimation("amb@world_human_clipboard@male@idle_a", "idle_c", 5000)

    local newHealth = math.min(currentHealth + 20, 200)
    SetEntityHealth(playerPed, newHealth)
end

-- Function to use aFirst aid kit
function useFirstaidkit(itemData, itemName, itemIndex)
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)

    if currentHealth >= 200 then
        drawNativeNotification("Your Health is already ~g~Full~s~")
        return
    end

    RemoveItemFromInventorybyIndex(itemIndex, 1)
    PlayAnimation("amb@world_human_clipboard@male@idle_a", "idle_c", 10000)

    local newHealth = math.min(currentHealth + 50, 200)
    SetEntityHealth(playerPed, newHealth)
end

function UseLockpick(itemData, itemName, itemIndex)
    local playerId = PlayerPedId()
    local pos = GetEntityCoords(playerId)
    local vehicle = GetVehiclePedIsIn(playerId)
    local breakChance = itemData.breakchance

    if vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        if IsVehicleInParkingList(plate) then
            drawNativeNotification("~y~Leeny Parky~w~: hey Shoo these car belong to me don't touch them")
            return
        end

        local seconds = math.random(6, 10)
        local circles = math.random(2, 5)
        local success = exports["ak-lock"]:StartLockPickCircle(circles, seconds, success)


        if success then
            if math.random(1, 100) <= breakChance then
                drawNativeNotification("Lockpick ~r~broke~s~!")
                RemoveItemFromInventorybyIndex(itemIndex, 1)
            else
                drawNativeNotification("Hotwire Sucessfuly")
            end
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerEvent("ak-carlock:addCarPlate", plate)
            SetVehicleDoorsLocked(veh, 7)
            SetVehicleAlarm(veh, true)
            SetVehicleDoorsLocked(veh, 1)
            SetVehicleNeedsToBeHotwired(veh, true)
            SetVehicleDoorsLockedForAllPlayers(veh, false)
            SetVehicleAlarmTimeLeft(veh, 15000)
        else
            if math.random(1, 100) <= breakChance then
                drawNativeNotification("Lockpick ~r~broke~s~!")
                RemoveItemFromInventorybyIndex(itemIndex, 1)
            end
        end
    else
        local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 3.0, 0, 71)
        local vehpos = GetEntityCoords(veh)
        local locked = GetVehicleDoorLockStatus(veh)
        local distance = #(vehpos - pos)
        local plate = GetVehicleNumberPlateText(veh)
        if distance < 3 then
            if locked == 2 then
                if IsVehicleInParkingList(plate) then
                    drawNativeNotification("~y~Leeny Parky~w~: hey Shoo these car belong to me don't touch them")
                    return
                end

                local seconds = math.random(6, 10)
                local circles = math.random(2, 5)
                local success = exports["ak-lock"]:StartLockPickCircle(circles, seconds, success)
                if success then
                    if math.random(1, 100) <= breakChance then
                        drawNativeNotification("Lockpick ~r~broke~s~!")

                        RemoveItemFromInventorybyIndex(itemIndex, 1)
                    else
                        drawNativeNotification("Hotwire Sucessfuly")
                    end
                    local plate = GetVehicleNumberPlateText(vehicle)

                    TriggerEvent("ak-carlock:addCarPlate", plate)
                    SetVehicleDoorsLocked(veh, 7)
                    SetVehicleAlarm(veh, true)
                    PlayAnimation("mp_arresting", "a_uncuff", 5000)
                    SetVehicleDoorsLocked(veh, 1)
                    SetVehicleNeedsToBeHotwired(veh, true)
                    SetVehicleDoorsLockedForAllPlayers(veh, false)
                    FreezeEntityPosition(playerId, true)
                    Citizen.Wait(5500)
                    SetVehicleAlarmTimeLeft(veh, 30000)
                    FreezeEntityPosition(playerId, false)
                else
                    if math.random(1, 100) <= breakChance then
                        drawNativeNotification("Lockpick ~r~broke~s~!")
                        RemoveItemFromInventorybyIndex(itemIndex, 1)
                    end
                end
            end
        end
    end
end

-- Client-side function to check if vehicle plate is in parking_vehicle table
function IsVehicleInParkingList(plate)
    local found = nil

    TriggerServerEvent('ak-carlock:isVehicleInParkingList', plate)
    -- Handle the server response using an event listener
    RegisterNetEvent('ak-carlock:isVehicleInParkingListResult', function(result)
        found = result
    end)

    while found == nil do
        Wait(50)
    end


    return found
end

function UseEnginerepairkit(itemData, itemName, itemIndex)
    local playerId = PlayerPedId()
    local pos = GetEntityCoords(playerId)
    local veh = GetClosestVehicle(pos.x, pos.y, pos.z, 3.0, 0, 71)
    local vehpos = GetEntityCoords(veh)
    local distance = #(vehpos - pos)
    local hoodCoords = GetOffsetFromEntityInWorldCoords(veh, 0, 2.5, 0)

    if distance < 3.5 then
        if IsBackEngine(GetEntityModel(veh)) then
            hoodCoords = GetOffsetFromEntityInWorldCoords(veh, 0, -2.5, 0)
        end


        local playerToVehicleDis = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, hoodCoords, true)
        local distanceThreshold = 1

        if playerToVehicleDis < distanceThreshold and not IsPedInAnyVehicle(playerId, false) then
            if GetVehicleDoorLockStatus(veh) < 2 then
                if GetVehicleEngineHealth(veh) > 900 then
                    drawNativeNotification("Engine health not much low")
                    return
                end
                FreezeEntityPosition(playerId, true)
                RemoveItemFromInventorybyIndex(itemIndex, 1)
                PlayAnimation('mini@repair', 'fixing_a_ped', 15000)
                SetVehicleEngineHealth(veh, 550.0)
                FreezeEntityPosition(playerId, false)
                drawNativeNotification("Car Engine is Fixed")
            end
        end
    end
end

function GiveWeapontoPlayer(weaponHash, itemData, itemName, playerId)
    GiveWeaponToPed(playerId, weaponHash, 0, false, true)
    SetCurrentPedWeapon(playerId, weaponHash, true)
    if (not IsPedInAnyVehicle(playerId)) then
        PlayAnimation("combat@gestures@rifle@beckon", "0", 2000)
        Citizen.Wait(2000)
        StopAnimation(playerId)
    end
    CreateThread(function()
        while true do
            Wait(2000)
            local check = IsWeaponStillinInventory(itemName)
            local isArmed = GetSelectedPedWeapon(playerId)
            local fistHash = -1569615261
            if IsEntityDead(playerId) or not check or isArmed == fistHash then
                RemoveWeaponFromPed(playerId, weaponHash)
                break;
            end
        end
    end)
end

function TakeWeaponfromPlayer(playerId, weaponHash)
    local remainingAmmoCount = GetAmmoInPedWeapon(playerId, weaponHash)
    SetPedAmmo(playerId, weaponHash, remainingAmmoCount)
    RemoveWeaponFromPed(playerId, weaponHash)
    drawNativeNotification("Gun ~r~unequipped~s~!")
end

local function UseWeapon(itemData, itemName, itemIndex)
    local playerId = PlayerPedId()
    local weaponHash = itemData.weaponHash

    if (IsPedArmed(playerId, 4)) then
        local currentWeaponHash = GetSelectedPedWeapon(playerId)
        TakeWeaponfromPlayer(playerId, currentWeaponHash)
        if (currentWeaponHash == weaponHash) then return end
    end

    GiveWeapontoPlayer(weaponHash, itemData, itemName, playerId)
end

function UseAmmo(itemData, itemName, itemIndex)
    local playerId = PlayerPedId()

    if not IsPedArmed(playerId, 4) then
        drawNativeNotification("Take out Weapone to load ~o~Ammo~s~!")
        return
    end

    local currentWeaponHash = GetSelectedPedWeapon(playerId)
    local weaponAmmoName = Config.WeaponAmmo[currentWeaponHash]

    if weaponAmmoName ~= itemName then
        drawNativeNotification("This ~o~Ammo~s~ is not Compatable!")
        return
    end

    local alreadyAmmoCount = GetAmmoInPedWeapon(playerId, currentWeaponHash)
    local maxAmmoLimit = Config.WeaponAmmo[itemName]
    if alreadyAmmoCount >= maxAmmoLimit then
        drawNativeNotification("~o~Max Ammo~s~ limit reached!")
        return
    end
    SetPedAmmo(playerId, currentWeaponHash, alreadyAmmoCount + itemData.ammocount)

    RemoveItemFromInventorybyIndex(itemIndex, 1)
end

function useMiningHelmet(itemData, itemName, itemIndex)
    local playerPed = PlayerPedId()
    local helmetDrawable = 89 -- Example value for a mining helmet
    local helmetTexture = 4   -- Example value for the mining helmet texture

    -- Play animation
    RequestAnimDict("mp_masks@on_foot")
    while not HasAnimDictLoaded("mp_masks@on_foot") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "mp_masks@on_foot", "put_on_mask", 8.0, -8.0, -1, 56, 0, false, false, false)

    -- Wait for the animation to complete
    Citizen.Wait(1000) -- Adjust the wait time if necessary

    -- Equip the mining helmet
    SetPedPropIndex(playerPed, 0, helmetDrawable, helmetTexture, true)
    ClearPedTasks(playerPed)
end

function useSalvage(itemData, itemName, itemIndex)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    TriggerEvent('coca_inventory:stopInventoryUI', true)
    RemoveItemFromInventorybyIndex(itemIndex, 1)
    Wait(700)

    local items = { "electronics", "scrap", "wire", "rubber", "glass" }


    local chanceToAddItems = math.random()

    if chanceToAddItems > 0.2 then
        local totalItemsToAdd = math.random(1, 3)
        local addedItems = {}
        local msg = "Found: "
        for i = 1, totalItemsToAdd do
            local randomItem = items[math.random(1, #items)]
            table.insert(addedItems, { item = randomItem, count = 1 })
            msg = msg .. "~d~" .. randomItem
            if i < totalItemsToAdd then
                msg = msg .. "~w~, "
            end
        end

        TriggerServerEvent('coca_inventory:Server:AddMutipleItem', characterId, addedItems, msg)
    else
        drawNativeNotification("No usefull item found.")
    end
    TriggerEvent('coca_inventory:stopInventoryUI', false)
end

function UseTool(itemData, itemName, itemIndex)
    if itemName == 'lockpick' then
        UseLockpick(itemData, itemName, itemIndex)
    elseif itemName == 'enginerepairkit' then
        UseEnginerepairkit(itemData, itemName, itemIndex)
    else
        drawNativeNotification("You can't use ~o~" .. itemData.label .. "~s~ like this")
    end
end

function UseWearable(itemData, itemName, itemIndex)
    if itemName == 'mininghelmet' then
        useMiningHelmet(itemData, itemName, itemIndex)
    else
        drawNativeNotification("You can't use ~o~" .. itemData.label .. "~s~ like this")
    end
end

function UseMaterial(itemData, itemName, itemIndex)
    if itemName == 'salvage' then
        useSalvage(itemData, itemName, itemIndex)
    else
        drawNativeNotification("You can't use ~o~" .. itemData.label .. "~s~ like this")
    end
end

-- Map item names to their use functions
local useFunctions = {
    tool = UseTool,
    weapon = UseWeapon,
    ammo = UseAmmo,
    consumable = UseConsumable,
    wearable = UseWearable,
    material = UseMaterial,
}

-- Function to handle item use
function HandleItemUse(itemName, itemIndex)
    local itemData = Config.Items[itemName]
    local itemCategory = itemData.category
    local useFunction = useFunctions[itemCategory]

    if useFunction then
        useFunction(itemData, itemName, itemIndex)
    else
        drawNativeNotification("You can't use ~o~" .. itemData.label .. "~s~ like this")
    end
end
