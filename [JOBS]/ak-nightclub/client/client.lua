Citizen.CreateThread(function()
      local blipInfo = Config.location
      local blip = AddBlipForCoord(vector3(blipInfo.x, blipInfo.y, blipInfo.z))

      SetBlipSprite(blip, blipInfo.blipSprite)
      SetBlipColour(blip, blipInfo.blipColour)
      SetBlipScale(blip, 0.7)
      SetBlipAsShortRange(blip, true)

      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(blipInfo.type)

      EndTextCommandSetBlipName(blip)
end)


local pedModels = {
      "s_f_y_stripper_04", --white
      "csb_stripper_09",   --black
      "csb_stripper_08",   -- white
}

-- Function to get a random ped model from the array
function GetRandomPedModel()
      local randomIndex = math.random(#pedModels)
      print(pedModels[randomIndex])
      return pedModels[randomIndex]
end

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations1) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)
            local npc2 = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)
            local ad = "mini@strip_club@lap_dance_2g@ld_2g_p2"

            RequestAnimDict(ad)
            while not HasAnimDictLoaded(ad) do
                  Citizen.Wait(1000)
            end

            local netScene6 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene6, ad, "ld_2g_p2_s1", 1.0, -4.0, 261, 0, 0)
            TaskSynchronizedScene(npc2, netScene6, ad, "ld_2g_p2_s2", 1.0, -4.0, 261, 0, 0)
            FreezeEntityPosition(npc, true)
            FreezeEntityPosition(npc2, true)
            SetEntityHeading(npc, item.heading)
            SetEntityHeading(npc2, item.heading)
            SetEntityInvincible(npc, true)
            SetEntityInvincible(npc2, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            SetBlockingOfNonTemporaryEvents(npc2, true)
            SetSynchronizedSceneLooped(netScene6, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations2) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@lap_dance@ld_girl_a_song_a_p1")
            while not HasAnimDictLoaded("mini@strip_club@lap_dance@ld_girl_a_song_a_p1") do
                  Citizen.Wait(100)
            end
            Wait(6000)
            local netScene2 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene2, "mini@strip_club@lap_dance@ld_girl_a_song_a_p1",
                  "ld_girl_a_song_a_p1_f", 1.0, -4.0, 261, 0, 0)
            SetSynchronizedSceneLooped(netScene2, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations3) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@private_dance@part1")
            while not HasAnimDictLoaded("mini@strip_club@private_dance@part1") do
                  Citizen.Wait(100)
            end

            local netScene4 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene4, "mini@strip_club@private_dance@part1", "priv_dance_p1", 1.0, -4.0, 261,
                  0, 0)
            SetSynchronizedSceneLooped(netScene4, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations4) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@private_dance@part2")
            while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
                  Citizen.Wait(100)
            end

            local netScene2 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene2, "mini@strip_club@private_dance@part2", "priv_dance_p2", 1.0, -4.0, 261,
                  0, 0)
            SetSynchronizedSceneLooped(netScene2, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations5) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@lap_dance@ld_girl_a_song_a_p1")
            while not HasAnimDictLoaded("mini@strip_club@lap_dance@ld_girl_a_song_a_p1") do
                  Citizen.Wait(100)
            end

            local netScene2 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene2, "mini@strip_club@lap_dance@ld_girl_a_song_a_p1",
                  "ld_girl_a_song_a_p1_f", 1.0, -4.0, 261, 0, 0)
            SetSynchronizedSceneLooped(netScene2, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
            print("waiting")
      end

      for _, item in pairs(Config.Locations6) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@pole_dance@pole_dance3")
            while not HasAnimDictLoaded("mini@strip_club@pole_dance@pole_dance3") do
                  Citizen.Wait(100)
            end

            local netScene3 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene3, "mini@strip_club@pole_dance@pole_dance3", "pd_dance_03", 1.0, -4.0, 261,
                  0, 0)
            SetSynchronizedSceneLooped(netScene3, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

Citizen.CreateThread(function()
      local model = GetRandomPedModel()
      RequestModel(GetHashKey(model))

      while not HasModelLoaded(GetHashKey(model)) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations7) do
            local npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)
            local npc2 = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)
            local ad = "mini@strip_club@lap_dance_2g@ld_2g_p1"

            RequestAnimDict(ad)
            while not HasAnimDictLoaded(ad) do
                  Citizen.Wait(1000)
            end

            local netScene = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene, ad, "ld_2g_p1_s1", 1.0, -4.0, 261, 0, 0)
            TaskSynchronizedScene(npc2, netScene, ad, "ld_2g_p1_s2", 1.0, -4.0, 261, 0, 0)
            FreezeEntityPosition(npc, true)
            FreezeEntityPosition(npc2, true)
            SetEntityHeading(npc, item.heading)
            SetEntityHeading(npc2, item.heading)
            SetEntityInvincible(npc, true)
            SetEntityInvincible(npc2, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            SetBlockingOfNonTemporaryEvents(npc2, true)
            SetSynchronizedSceneLooped(netScene, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)

-- Audition Dancer in room
local AuditionpedModels = {
      "csb_stripper_01",
      "S_F_Y_Stripper_01",
      "S_F_Y_Stripper_02",
      "S_F_Y_StripperLite",
      "s_f_y_stripperheavy",
      "csb_stripper_05",
      "s_f_y_stripper_07"
}

-- Audtion SeX Girl
local function PlayHookerSpeech(hooker, speechName, speechParam)
      print(hooker)

      PlayPedAmbientSpeechNative(hooker, speechName, speechParam)
end

local function drawNativeNotification(text)
      SetTextComponentFormat("STRING")
      AddTextComponentString(text)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
      local selectedModel = "s_f_y_stripper_10"
      local modelHash = GetHashKey(selectedModel)
      RequestModel(modelHash)
      local npc = nil

      while not HasModelLoaded(modelHash) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations8) do
            npc = CreatePed(1, modelHash, item.x, item.y, item.z, item.heading, false, true)
            SetPedComponentVariation(npc, 3, 0, 2, 1, 2) -- Torso
            SetPedComponentVariation(npc, 10, 0)         -- Decals ??
            SetPedComponentVariation(npc, 11, 0)         -- Auxiliary parts for torso
            SetPedComponentVariation(npc, 9, 1)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@private_dance@part2")
            while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
                  Citizen.Wait(100)
            end

            local netScene2 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene2, "mini@strip_club@private_dance@part2", "priv_dance_p2", 1.0, -4.0, 261,
                  0, 0)
            SetSynchronizedSceneLooped(netScene2, 1)
            SetModelAsNoLongerNeeded(modelHash)
      end


      local cacheNpcLocation = vector3(Config.Locations8[1].x, Config.Locations8[1].y, Config.Locations8[1].z)

      RegisterNetEvent("syncNPCAnimation")
      AddEventHandler("syncNPCAnimation", function(offset, isStarted)
            print(isStarted)
            print(npc)
            if isStarted then
                  ClearPedTasksImmediately(npc)
                  SetEntityHeading(npc, 30.99)
                  SetEntityHeading(playerPed, 30.99)
                  RequestAnimDict("zmdev@erotica_standingf")
                  while not HasAnimDictLoaded("zmdev@erotica_standingf") do
                        Citizen.Wait(100)
                  end
                  TaskPlayAnim(npc, "zmdev@erotica_standingf", "standingf", 8.0, -8.0, -1, 1, 0,
                        false, false, false)
                  SetEntityCoords(npc, offset.x, offset.y, offset.z, false, false, false, true)
            else
                  isStarted = false
                  FreezeEntityPosition(npc, true)
                  SetEntityCoords(npc, cacheNpcLocation)
                  SetEntityHeading(npc, 135.3)
                  SetEntityInvincible(npc, true)
                  SetBlockingOfNonTemporaryEvents(npc, true)
                  RequestAnimDict("mini@strip_club@private_dance@part2")
                  while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
                        Citizen.Wait(100)
                  end

                  local netScene2 = CreateSynchronizedScene(cacheNpcLocation.x,
                        cacheNpcLocation.y, cacheNpcLocation.z, vec3(0.0, 0.0, 0.0), 2)
                  TaskSynchronizedScene(npc, netScene2, "mini@strip_club@private_dance@part2",
                        "priv_dance_p2", 1.0, -4.0, 261, 0, 0)
                  SetSynchronizedSceneLooped(netScene2, 1)
                  SetModelAsNoLongerNeeded(modelHash)
            end
      end)

      local isStarted = false

      
      while true do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - cacheNpcLocation)

            if distance < 2.0 then
                  if isStarted then
                        DrawText3D(cacheNpcLocation.x, cacheNpcLocation.y, cacheNpcLocation.z, "~q~[E]~s~ to stop")
                  else
                        DrawText3D(cacheNpcLocation.x, cacheNpcLocation.y, cacheNpcLocation.z,
                              "~q~[E]~s~ to have Fun")
                  end

                  if IsControlJustReleased(0, 38) then       -- E key
                        local doPlayerHaveItem = exports['coca_inventory']:HasItemInInventory("vanillacard")
                        if (doPlayerHaveItem) then
                              if isStarted then
                                    PlayHookerSpeech(npc, "HOOKER_LEAVES_ANGRY",
                                          "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
                                    isStarted = false
                                    FreezeEntityPosition(npc, true)
                                    SetEntityCoords(npc, cacheNpcLocation)
                                    SetEntityHeading(npc, 135.3)
                                    SetEntityInvincible(npc, true)
                                    SetBlockingOfNonTemporaryEvents(npc, true)
                                    RequestAnimDict("mini@strip_club@private_dance@part2")
                                    while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
                                          Citizen.Wait(100)
                                    end

                                    local netScene2 = CreateSynchronizedScene(cacheNpcLocation.x,
                                          cacheNpcLocation.y, cacheNpcLocation.z, vec3(0.0, 0.0, 0.0), 2)
                                    TaskSynchronizedScene(npc, netScene2, "mini@strip_club@private_dance@part2",
                                          "priv_dance_p2", 1.0, -4.0, 261, 0, 0)
                                    SetSynchronizedSceneLooped(netScene2, 1)
                                    SetModelAsNoLongerNeeded(modelHash)
                                    ClearPedTasksImmediately(playerPed)

                                    -- Sync the stop animation with all players
                                    TriggerServerEvent('syncNPCAnimationServer', npc, isStarted)
                              else
                                    PlayHookerSpeech(npc, "HOOKER_SECLUDED", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
                                    isStarted = true
                                    ClearPedTasksImmediately(npc)
                                    SetEntityHeading(npc, 30.99)
                                    SetEntityHeading(playerPed, 30.99)
                                    RequestAnimDict("zmdev@erotica_standingf")
                                    while not HasAnimDictLoaded("zmdev@erotica_standingf") do
                                          Citizen.Wait(100)
                                    end
                                    TaskPlayAnim(npc, "zmdev@erotica_standingf", "standingf", 8.0, -8.0, -1, 1, 0,
                                          false, false, false)

                                    RequestAnimDict("zmdev@erotica_standingm")
                                    while not HasAnimDictLoaded("zmdev@erotica_standingm") do
                                          Citizen.Wait(100)
                                    end
                                    TaskPlayAnim(playerPed, "zmdev@erotica_standingm", "standingm", 8.0, -8.0, -1,
                                          1, 0, false, false, false)
                                    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.23, 0.0, -1.0)
                                    SetEntityCoords(npc, offset.x, offset.y, offset.z, false, false, false, true)

                                    -- Sync the start animation with all players
                                    TriggerServerEvent('syncNPCAnimationServer', offset, isStarted)
                              end
                        else
                              drawNativeNotification("Stay away from me. You ~q~Pervert~w~!")
                        end
                  end
            end
      end
end)


Citizen.CreateThread(function()
      local selectedModel = AuditionpedModels[math.random(#AuditionpedModels)]
      local modelHash = GetHashKey(selectedModel)
      RequestModel(modelHash)

      while not HasModelLoaded(modelHash) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations8_1) do
            local npc = CreatePed(1, modelHash, item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@private_dance@part1")
            while not HasAnimDictLoaded("mini@strip_club@private_dance@part1") do
                  Citizen.Wait(100)
            end

            local netScene4 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene4, "mini@strip_club@private_dance@part1", "priv_dance_p1", 1.0, -4.0,
                  261, 0, 0)
            SetSynchronizedSceneLooped(netScene4, 1)
            SetModelAsNoLongerNeeded(modelHash)
      end
end)

Citizen.CreateThread(function()
      local selectedModel = AuditionpedModels[math.random(#AuditionpedModels)]
      local modelHash = GetHashKey(selectedModel)
      RequestModel(modelHash)

      while not HasModelLoaded(modelHash) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations8_2) do
            local npc = CreatePed(1, modelHash, item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            RequestAnimDict("mini@strip_club@lap_dance@ld_girl_a_song_a_p1")
            while not HasAnimDictLoaded("mini@strip_club@lap_dance@ld_girl_a_song_a_p1") do
                  Citizen.Wait(100)
            end
            local netScene2 = CreateSynchronizedScene(item.x, item.y, item.z, vec3(0.0, 0.0, 0.0), 2)
            TaskSynchronizedScene(npc, netScene2, "mini@strip_club@lap_dance@ld_girl_a_song_a_p1",
                  "ld_girl_a_song_a_p1_f", 1.0, -4.0, 261, 0, 0)
            SetSynchronizedSceneLooped(netScene2, 1)
            SetModelAsNoLongerNeeded(GetHashKey(model))
      end
end)


-- moving stripper
Citizen.CreateThread(function()
      RequestModel(GetHashKey("s_f_y_stripper_06"))

      while not HasModelLoaded(GetHashKey("s_f_y_stripper_06")) do
            Wait(10)
      end

      local locations = Config.Locations9
      local locationsMid = Config.Locations9_mid
      local locationsLeft = Config.Locations9_left
      local locationsRight = Config.Locations9_right

      local pedHash = GetHashKey("s_f_y_stripper_06")
      local npc = CreatePed(1, pedHash, locations[1].x, locations[1].y, locations[1].z, locations[1].heading, false, true)
      SetPedComponentVariation(npc, 3, 0, 2, 1, 2) -- Torso
      SetPedComponentVariation(SpawnObject, 6, 0)  -- Underwear
      SetPedComponentVariation(SpawnObject, 10, 0) -- Decals ??
      SetPedComponentVariation(SpawnObject, 11, 0) -- Auxiliary parts for torso
      SetPedComponentVariation(SpawnObject, 9, 1)

      SetEntityInvincible(npc, true)
      SetBlockingOfNonTemporaryEvents(npc, true)
      FreezeEntityPosition(npc, false)

      local function MoveToLocation(npc, loc)
            TaskGoToCoordAnyMeans(npc, loc.x, loc.y, loc.z, 1.0, 0, 0, 786603, 0xbf800000)
            while true do
                  Citizen.Wait(0)
                  if IsEntityAtCoord(npc, loc.x, loc.y, loc.z, 1.0, 1.0, 1.0, false, true, 0) then
                        break
                  end
            end
      end

      local function WaitAtLocation(duration)
            Citizen.Wait(duration)
      end

      local function PlayAnimation(npc, dict, anim, duration)
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                  Citizen.Wait(100)
            end
            TaskPlayAnim(npc, dict, anim, 8.0, 8.0, -1, 1, 0, false, false, false)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            FreezeEntityPosition(npc, false)

            Citizen.Wait(duration)
            ClearPedTasks(npc)
      end

      function PlayScenarioForDuration(npc, scenario, duration)
            TaskStartScenarioInPlace(npc, scenario, 0, true)
            Citizen.Wait(duration)
            ClearPedTasksImmediately(npc)
      end

      Citizen.CreateThread(function()
            while true do
                  for _, loc in ipairs(locations) do
                        MoveToLocation(npc, loc)
                        SetEntityHeading(npc, loc.heading)
                        SetBlockingOfNonTemporaryEvents(npc, true)

                        -- Attach the cigarette to the NPC
                        PlayScenarioForDuration(npc, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", 120000)
                        WaitAtLocation(2500)
                  end

                  for _, loc in ipairs(locationsMid) do
                        MoveToLocation(npc, loc)
                        SetEntityHeading(npc, loc.heading)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        PlayAnimation(npc, "mini@strip_club@private_dance@part3", "priv_dance_p3", 60000)
                        WaitAtLocation(1000)
                  end

                  for _, loc in ipairs(locationsRight) do
                        MoveToLocation(npc, loc)
                        SetEntityHeading(npc, loc.heading)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        PlayAnimation(npc, "mini@strip_club@private_dance@part2", "priv_dance_p2", 30000)
                        WaitAtLocation(1000)
                  end

                  for _, loc in ipairs(locationsMid) do
                        MoveToLocation(npc, loc)
                        SetEntityHeading(npc, loc.heading)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        PlayAnimation(npc, "mini@strip_club@private_dance@part3", "priv_dance_p3", 60000)
                        WaitAtLocation(1000)
                  end

                  for _, loc in ipairs(locationsLeft) do
                        MoveToLocation(npc, loc)
                        SetEntityHeading(npc, loc.heading)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        PlayAnimation(npc, "mini@strip_club@private_dance@part2", "priv_dance_p2", 30000)
                        WaitAtLocation(1000)
                  end

                  for _, loc in ipairs(locationsMid) do
                        MoveToLocation(npc, loc)
                        SetEntityHeading(npc, loc.heading)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        PlayAnimation(npc, "mini@strip_club@private_dance@part3", "priv_dance_p3", 60000)
                        WaitAtLocation(1000)
                  end
            end
      end)
end)

-- bartender
Citizen.CreateThread(function()
      RequestModel(GetHashKey("a_f_y_topless_01"))

      while not HasModelLoaded(GetHashKey("a_f_y_topless_01")) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations10) do
            local npc = CreatePed(1, GetHashKey("a_f_y_topless_01"), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)

            -- Play the bartender animation
            TaskStartScenarioInPlace(npc, "WORLD_HUMAN_PROSTITUTE_LOW_CLASS", 0, true)

            -- Release model memory
            SetModelAsNoLongerNeeded(GetHashKey("a_f_y_topless_01"))
      end
end)

-- LapDance Hostess
Citizen.CreateThread(function()
      RequestModel(GetHashKey("s_f_y_bartender_01"))

      while not HasModelLoaded(GetHashKey("s_f_y_bartender_01")) do
            Wait(10)
      end

      for _, item in pairs(Config.Locations12) do
            local npc = CreatePed(1, GetHashKey("s_f_y_bartender_01"), item.x, item.y, item.z, item.heading, false, true)

            FreezeEntityPosition(npc, true)
            SetEntityHeading(npc, item.heading)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)

            -- Play the bartender animation
            TaskStartScenarioInPlace(npc, "WORLD_HUMAN_PROSTITUTE_HiGH_CLASS", 0, true)

            -- Release model memory
            SetModelAsNoLongerNeeded(GetHashKey("s_f_y_bartender_01"))
      end
end)

local function drawNativeNotification(text)
      SetTextComponentFormat("STRING")
      AddTextComponentString(text)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function DrawText3D(x, y, z, text)
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

function LoadModel(model)
      model = GetHashKey(model)

      if not HasModelLoaded(model) and IsModelInCdimage(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                  Wait(20)
            end
      end
end

function LoadDict(Dict, Bool)
      RequestAnimDict(Dict)
      while not HasAnimDictLoaded(Dict) do
            Wait(20)
            RequestAnimDict(Dict)
      end

      if Bool then
            return Dict
      end
end

function DrawText2D(text)
      AddTextEntry(GetCurrentResourceName(), text)
      BeginTextCommandDisplayHelp(GetCurrentResourceName())
      EndTextCommandDisplayHelp(0, 0, true, -1)
end

function LeanStart(playerHeading)
      local playerped = PlayerPedId()
      local playerCoords = GetEntityCoords(playerped)

      LoadModel("prop_anim_cash_note_b")
      LoadModel("prop_cash_pile_01")

      local is_female = function()
            return (GetEntityModel(playerped) == "mp_f_freemode_01" and "_female" or "")
      end

      SetEntityCoordsNoOffset(playerped, playerCoords)
      FreezeEntityPosition(playerped, true)
      SetEntityHeading(playerped, playerHeading)
      Wait(50)

      TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@enter", true), "enter" .. is_female(), 8.0, -8.0, -1,
            0, 0, false, false, false)
      Wait(2750)
      PreviousCamViewMode = GetFollowPedCamViewMode(playerped)
      SetFollowPedCamViewMode(4)
      SetGameplayCamRelativeHeading(0.0)
      TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@base", true), "base" .. is_female(), 8.0, -8.0, -1, 1,
            0, false, false, false)
      local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
      while true do
            Wait(0)

            DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z, "Press ~q~[Backspace]~w~ to exit")
            DrawText2D("Press ~q~[Space]~w~ to tip Bill to sexy lady ~n~ Press ~q~[E]~w~ to tip stack to sexy lady")
            if IsControlJustReleased(0, 22) then
                  if exports.coca_banking:RemoveCash(characterId, 200) then
                        local pos = GetPedBoneCoords(playerped, 28422, 0.0, 0.0, 0.0)
                        local cash = CreateObject("prop_anim_cash_pile_02", pos, true, false, false)
                        SetEntityAlpha(cash, 0, false)
                        AttachEntityToEntity(cash, playerped, GetPedBoneIndex(playerped, 28422), 0.0, 0.0, 0.0, 0.0,
                              0.0, 0.0, false, false, false, false, 2, true)
                        TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@toss", true),
                              "toss" .. is_female(),
                              8.0, -8.0, -1, 2, 0, false, false, false)
                        Citizen.Wait(150)
                        SetEntityAlpha(cash, 255, false)
                        while true do
                              if GetEntityAnimCurrentTime(playerped, "mini@strip_club@leaning@toss", "toss" .. is_female()) >= 0.74 then
                                    local alphaLevel = 255
                                    repeat
                                          SetEntityAlpha(cash, alphaLevel, false)
                                          alphaLevel = alphaLevel - 51
                                          Citizen.Wait(40)
                                    until (alphaLevel == 0)
                                    DeleteEntity(cash)
                                    break
                              end
                              Citizen.Wait(50)
                        end
                        TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@base", true),
                              "base" .. is_female(),
                              8.0, -8.0, -1, 1, 0, false, false, false)
                  else
                        drawNativeNotification("You don't have cash")
                  end
            elseif IsControlJustReleased(0, 38) then
                  if exports.coca_banking:RemoveCash(characterId, 20) then
                        local pos = GetPedBoneCoords(playerped, 28422, 0.0, 0.0, 0.0)
                        local cash = CreateObject("prop_anim_cash_note_b", pos, true, false, false)
                        SetEntityAlpha(cash, 0, false)
                        AttachEntityToEntity(cash, playerped, GetPedBoneIndex(playerped, 28422), 0.0, 0.0, 0.0, 0.0,
                              0.0, 0.0, false, false, false, false, 2, true)
                        TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@toss", true),
                              "toss" .. is_female(),
                              8.0, -8.0, -1, 2, 0, false, false, false)
                        Citizen.Wait(150)
                        SetEntityAlpha(cash, 255, false)
                        while true do
                              if GetEntityAnimCurrentTime(playerped, "mini@strip_club@leaning@toss", "toss" .. is_female()) >= 0.74 then
                                    local alphaLevel = 255
                                    repeat
                                          SetEntityAlpha(cash, alphaLevel, false)
                                          alphaLevel = alphaLevel - 51
                                          Citizen.Wait(40)
                                    until (alphaLevel == 0)
                                    DeleteEntity(cash)
                                    break
                              end
                              Citizen.Wait(50)
                        end
                        TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@base", true),
                              "base" .. is_female(),
                              8.0, -8.0, -1, 1, 0, false, false, false)
                  else
                        drawNativeNotification("You don't have cash")
                  end
            elseif IsControlJustReleased(0, 177) then
                  break
            end
      end

      SetFollowPedCamViewMode(PreviousCamViewMode)
      Wait(100)
      TaskPlayAnim(playerped, LoadDict("mini@strip_club@leaning@exit", true), "exit" .. is_female(), 8.0, -8.0, -1, 0,
            0, false, false, false)
      FreezeEntityPosition(playerped, false)
end

CreateThread(function()
      while true do
            local sleep = 1500
            local playerped = PlayerPedId()
            local playerCoords = GetEntityCoords(playerped)

            for _, location in ipairs(Config.LeanLoc) do
                  local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, location.x, location.y,
                        location.z)

                  if distance < 2 then
                        sleep = 5
                        DrawText3D(location.x, location.y, location.z, "Press ~q~[E]~w~ to lean")
                        if IsControlJustReleased(0, 38) then
                              LeanStart(location.h)
                        end
                  end
            end

            Wait(sleep) -- Yield execution to prevent crashing
      end
end)




RegisterCommand("testped", function(source, args, rawCommand)
      local pedModel = args[1] -- First argument: ped model
      local animDict = args[2] -- Second argument: animation dictionary
      local animName = args[3] -- Third argument: animation name

      if pedModel and animDict and animName then
            -- Load the ped model
            RequestModel(GetHashKey(pedModel))
            while not HasModelLoaded(GetHashKey(pedModel)) do
                  Citizen.Wait(10)
            end

            -- Get the player's position
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            -- Create the ped
            local ped = CreatePed(4, GetHashKey(pedModel), playerCoords.x, playerCoords.y, playerCoords.z,
                  GetEntityHeading(playerPed), true, false)

            -- Freeze the ped in place
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)

            -- Load the animation dictionary
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                  Citizen.Wait(10)
            end

            -- Play the animation
            TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)

            -- Release the model
            SetModelAsNoLongerNeeded(GetHashKey(pedModel))
      else
            -- Notify the user if arguments are missing
            TriggerEvent('chat:addMessage', {
                  color = { 255, 0, 0 },
                  multiline = true,
                  args = { "Error", "Usage: /testped <pedModel> <animDict> <animName>" }
            })
      end
end, false)

-- Function to display native notifications
function drawNativeNotification(text)
      SetTextComponentFormat("STRING")
      AddTextComponentString(text)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
