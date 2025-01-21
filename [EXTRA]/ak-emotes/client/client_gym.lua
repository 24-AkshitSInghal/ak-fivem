local workoutAreas = {
    [1] = { ["x"] = -1196.979, ["y"] = -1572.897, ["z"] = 4.613, ["h"] = 211.115, ["workType"] = "Weights", ["emote"] = "weights" },
    [2] = { ["x"] = -1199.060, ["y"] = -1574.493, ["z"] = 4.610, ["h"] = 213.649, ["workType"] = "Weights", ["emote"] = "weights" },
    [3] = { ["x"] = -1200.587, ["y"] = -1577.505, ["z"] = 4.608, ["h"] = 312.377, ["workType"] = "Pushups", ["emote"] = "pushUps" },
    [4] = { ["x"] = -1196.013, ["y"] = -1567.369, ["z"] = 4.617, ["h"] = 308.908, ["workType"] = "Situps", ["emote"] = "situps" },
    [5] = { ["x"] = -1215.022, ["y"] = -1541.686, ["z"] = 4.728, ["h"] = 119.798, ["workType"] = "Yoga", ["emote"] = "yoga" },
    [6] = { ["x"] = -1217.592, ["y"] = -1543.162, ["z"] = 4.721, ["h"] = 119.818, ["workType"] = "Yoga", ["emote"] = "yoga" },
    [7] = { ["x"] = -1220.845, ["y"] = -1545.028, ["z"] = 4.692, ["h"] = 119.826, ["workType"] = "Yoga", ["emote"] = "yoga" },
    [8] = { ["x"] = -1224.699, ["y"] = -1547.247, ["z"] = 4.625, ["h"] = 119.868, ["workType"] = "Yoga", ["emote"] = "yoga" },
    [9] = { ["x"] = -1228.495, ["y"] = -1549.429, ["z"] = 4.556, ["h"] = 119.877, ["workType"] = "Yoga", ["emote"] = "yoga" },
    [10] = { ["x"] = -1253.41, ["y"] = -1601.65, ["z"] = 3.55, ["h"] = 213.34, ["workType"] = "Chinups", ["emote"] = "chinups" },
    [11] = { ["x"] = -1252.43, ["y"] = -1603.14, ["z"] = 3.53, ["h"] = 213.78, ["workType"] = "Chinups", ["emote"] = "chinups" },
    [12] = { ["x"] = -1251.26, ["y"] = -1604.81, ["z"] = 3.54, ["h"] = 217.94, ["workType"] = "Chinups", ["emote"] = "chinups" },
}

local inprocess = false
local workoutType = 0

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local plyCoords = GetEntityCoords(playerPed)
        local nearWorkoutArea = false

        for i = 1, #workoutAreas do
            local dist = #(plyCoords - vector3(workoutAreas[i].x, workoutAreas[i].y, workoutAreas[i].z))
            if dist < 2.0 and not inprocess then
                nearWorkoutArea = true
                DrawText3D(workoutAreas[i].x, workoutAreas[i].y, workoutAreas[i].z,
                    "[E] to do " .. workoutAreas[i].workType)
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('event:control:gym', i)
                end
            end
        end

        if nearWorkoutArea then
            Citizen.Wait(1)
        else
            Citizen.Wait(1500)
        end
    end
end)


RegisterNetEvent('event:control:gym', function(useID)
    if not inprocess then
        inprocess = true
        workoutType = useID
        TriggerEvent('doworkout')
    end
end)


RegisterNetEvent('doworkout', function()
    local playerPed = PlayerPedId()
    local workoutArea = workoutAreas[workoutType]
    local animDict = "amb@world_human_push_ups@male@base" 
    local animName = "base"                               

    if workoutArea.workType == "Weights" then
        animDict = "amb@world_human_muscle_free_weights@male@barbell@base"
        animName = "base"
    elseif workoutArea.workType == "Pushups" then
        animDict = "amb@world_human_push_ups@male@base"
        animName = "base"
    elseif workoutArea.workType == "Situps" then
        animDict = "amb@world_human_sit_ups@male@base"
        animName = "base"
    elseif workoutArea.workType == "Yoga" then
        animDict = "amb@world_human_yoga@male@base"
        animName = "base_a"
    elseif workoutArea.workType == "Chinups" then
        animDict = "amb@prop_human_muscle_chin_ups@male@base"
        animName = "base"
    end

    -- Request the animation dictionary
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    -- Set player position and heading
    SetEntityCoords(playerPed, workoutArea.x, workoutArea.y, workoutArea.z)
    SetEntityHeading(playerPed, workoutArea.h)

    -- Play the animation
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

    Citizen.Wait(30000)

    -- Stop the animation
    ClearPedTasks(playerPed)
    inprocess = false
end)
