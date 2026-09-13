local RES = GetCurrentResourceName()

local function dbg(...) if Config.Debug then print('[mach1ne_kidnapping]', ...) end end
local function notify(desc, typ) st.notify({ title = 'Kidnapping', description = desc, type = typ or 'inform', duration = 6000 }) end

local State = {
    objects = {},
    scenes = {},
    bossPed = nil,
    victimPed = nil,
    sceneFinish = false,
    checkVideo = false,
    kidnapped = false,
    attached = false,
    chair = nil,
    tripod = nil,
    camera = nil,
    blindfoldObject = nil,
    queryActive = false,
}
local finishBlip = nil
local kidnappingBlip = nil
local queryBlip = nil

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

local function loadModel(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    return model
end

local function addBlip(coords, sprite, colour, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function removeBlip(blip)
    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
end

local function cleanupEntities()
    for _, obj in pairs(State.objects) do DeleteObject(obj) end
    State.objects = {}
    if State.chair then DeleteObject(State.chair); State.chair = nil end
    if State.tripod then DeleteObject(State.tripod); State.tripod = nil end
    if State.camera then DeleteObject(State.camera); State.camera = nil end
    if State.blindfoldObject then DeleteObject(State.blindfoldObject); State.blindfoldObject = nil end
    if State.victimPed and DoesEntityExist(State.victimPed) then DeletePed(State.victimPed); State.victimPed = nil end
end

CreateThread(function()
    local boss = Config.Boss
    loadModel(boss.model)
    State.bossPed = CreatePed(4, GetHashKey(boss.model), boss.pos.x, boss.pos.y, boss.pos.z - 0.95, boss.heading, false, true)
    FreezeEntityPosition(State.bossPed, true)
    SetEntityInvincible(State.bossPed, true)
    SetBlockingOfNonTemporaryEvents(State.bossPed, true)
    TaskStartScenarioInPlace(State.bossPed, 'WORLD_HUMAN_SMOKING', 0, true)

    st.create3DTextUIOnCoords('kidnapping_boss', {
        {
            id = 'boss_get_job',
            text = Strings['get_job'],
            coords = boss.pos,
            displayDist = Config.DisplayDist,
            interactDist = Config.InteractDist,
            key = 'E',
            keyNum = 38,
            theme = 'green',
            canInteract = function() return not State.kidnapped end,
            onSelect = function() KidnappingStart() end,
        },
        {
            id = 'boss_finish_job',
            text = Strings['finish_job'],
            coords = boss.pos,
            displayDist = Config.DisplayDist,
            interactDist = Config.InteractDist,
            key = 'E',
            keyNum = 38,
            theme = 'green',
            canInteract = function() return State.kidnapped end,
            onSelect = function() KidnappingFinish() end,
        },
    })
end)

RegisterNetEvent('mach1ne_kidnapping:client:policeAlert', function(targetCoords)
    notify(Strings['police_alert'], 'warning')
    local alpha = 250
    local blip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, 50.0)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, alpha)
    SetBlipAsShortRange(blip, true)
    CreateThread(function()
        while alpha > 0 do
            Wait(125)
            alpha = alpha - 1
            SetBlipAlpha(blip, alpha)
            if alpha == 0 then RemoveBlip(blip); return end
        end
    end)
end)

CreateThread(function()
    st.create3DTextUIOnCoords('kidnapping_query', {
        {
            id = 'camera',
            text = Strings['get_videorecord'],
            coords = Config.QueryRoom.cameraPos,
            displayDist = Config.DisplayDist,
            interactDist = Config.InteractDist,
            key = 'E',
            keyNum = 38,
            theme = 'green',
            canInteract = function() return State.sceneFinish end,
            onSelect = function()
                State.sceneFinish = false
                State.checkVideo = true
                notify(Strings['go_laptop'], 'inform')
            end,
        },
        {
            id = 'laptop',
            text = Strings['check_videorecord'],
            coords = Config.QueryRoom.laptopScenePos,
            displayDist = Config.DisplayDist,
            interactDist = Config.InteractDist,
            key = 'E',
            keyNum = 38,
            theme = 'green',
            canInteract = function() return State.checkVideo end,
            onSelect = function()
                State.checkVideo = false
                LaptopAnimation()
            end,
        },
    })
end)

function KidnappingStart()
    local canStart = lib.callback.await('mach1ne_kidnapping:server:checkTime', false)
    if not canStart then return end

    State.queryActive = true
    notify(Strings['info_1'], 'inform')
    Wait(1500)
    notify(Strings['info_2'], 'inform')
    Wait(1500)
    notify(Strings['info_3'], 'warning')

    local spawn = Config.VictimSpawns[math.random(1, #Config.VictimSpawns)]
    kidnappingBlip = addBlip(spawn.pos, 456, 0, Strings['kidnap_blip'])

    CreateThread(function()
        while State.queryActive do
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - spawn.pos)
            if dist <= 100.0 then break end
            Wait(500)
        end
        if not State.queryActive then return end

        loadModel(Config.VictimModel)
        State.victimPed = CreatePed(GetPedType(GetHashKey(Config.VictimModel)), GetHashKey(Config.VictimModel), spawn.pos.x, spawn.pos.y, spawn.pos.z, spawn.heading, 1, 0)
        DecorSetBool(State.victimPed, 'ScriptedPed', true)
        SetPedMaxHealth(State.victimPed, 200)
        SetEntityHealth(State.victimPed, 200)
        SetPedDiesWhenInjured(State.victimPed, true)
        SetBlockingOfNonTemporaryEvents(State.victimPed, true)
        SetEntityInvincible(State.victimPed, true)
        local netid = NetworkGetNetworkIdFromEntity(State.victimPed)
        Wait(1000)
        SetNetworkIdCanMigrate(netid, false)

        CreateThread(function()
            local currentUI = nil
            local function showUI(id, text, cb)
                if currentUI == id then return end
                st.hideTextUI()
                if id then
                    st.showTextUI({ keyText = 'E', displayText = text, position = 'bottom-center' }, cb or function() end)
                end
                currentUI = id
            end

            local enteredVehicle = false

            while State.queryActive do
                local ped = PlayerPedId()
                local pedCo = GetEntityCoords(ped)
                local distToQuery = #(pedCo - Config.QueryRoom.scenePos)
                local distToVictim = #(pedCo - GetEntityCoords(State.victimPed))

                if distToVictim >= 150.0 then
                    notify(Strings['mission_failed2'], 'error')
                    showUI(nil)
                    missionFail()
                    return
                end

                if IsEntityDead(State.victimPed) then
                    notify(Strings['mission_failed'], 'error')
                    showUI(nil)
                    missionFail()
                    return
                end

                local playerId = PlayerId()
                local aimingAtVictim = IsPlayerFreeAimingAtEntity(playerId, State.victimPed)
                if aimingAtVictim then
                    if not IsEntityPlayingAnim(State.victimPed, 'missminuteman_1ig_2', 'handsup_enter', 1) then
                        loadAnimDict('missminuteman_1ig_2')
                        TaskPlayAnim(State.victimPed, 'missminuteman_1ig_2', 'handsup_enter', 8.0, 8.0, -1, 50, 0, 0, 0, 0)
                        TaskTurnPedToFaceEntity(State.victimPed, ped, 1000)
                    end
                end

                local handsUp = IsEntityPlayingAnim(State.victimPed, 'missminuteman_1ig_2', 'handsup_enter', 1)
                if handsUp then
                    if not enteredVehicle then
                        local _, aimedEntity = GetEntityPlayerIsFreeAimingAt(playerId)
                        if GetEntityType(aimedEntity) == 2 then
                            enteredVehicle = true
                            notify(Strings['go_query'], 'inform')
                            TaskEnterVehicle(State.victimPed, aimedEntity, -1, 1, 2.0001, 1)
                            removeBlip(kidnappingBlip); kidnappingBlip = nil
                            if not queryBlip then
                                queryBlip = addBlip(Config.QueryRoom.scenePos, Config.QueryRoom.blip.sprite, Config.QueryRoom.blip.color, Strings['query_blip'])
                            end
                        end
                    end

                    if not State.attached then
                        showUI('blindfold', Strings['blindfold'], function()
                            Blindfold()
                            currentUI = nil
                        end)
                    else
                        showUI(nil)
                    end
                end

                if IsPedInAnyVehicle(State.victimPed, false) and not IsPedInAnyVehicle(ped, false) then
                    local vehicle = GetVehiclePedIsIn(State.victimPed, false)
                    showUI('leave_vehicle', Strings['leave_vehicle'], function()
                        TaskLeaveVehicle(State.victimPed, vehicle, 256)
                        currentUI = nil
                    end)
                elseif not handsUp and currentUI == 'blindfold' then
                    showUI(nil)
                end

                if distToQuery <= 60.0 and not IsPedInAnyVehicle(State.victimPed, false) then
                    showUI('start_query', Strings['start_query'], function()
                        st.hideTextUI()
                        currentUI = nil
                        CloseEyes()
                        removeBlip(queryBlip); queryBlip = nil
                    end)
                end

                Wait(0)
            end
            showUI(nil)
        end)
    end)
end

function missionFail()
    State.queryActive = false
    State.kidnapped = false
    State.attached = false
    removeBlip(kidnappingBlip); kidnappingBlip = nil
    removeBlip(queryBlip); queryBlip = nil
    cleanupEntities()
    st.hideTextUI()
end

function Blindfold()
    if State.attached then return end
    local ped = PlayerPedId()
    local pedCo = GetEntityCoords(ped)
    local npcCo = GetEntityCoords(State.victimPed)
    if #(pedCo - npcCo) > 2.0 then
        notify(Strings['cant_blindfold'], 'error')
        return
    end
    State.attached = true
    st.hideTextUI()
    loadAnimDict('random@shop_robbery')
    TaskPlayAnim(ped, 'random@shop_robbery', 'robbery_action_b', 8.0, -8, -1, 16, 0, 0, 0, 0)
    loadModel('prop_money_bag_01')
    State.blindfoldObject = CreateObject(GetHashKey('prop_money_bag_01'), 0, 0, 0, true, true, true)
    AttachEntityToEntity(State.blindfoldObject, State.victimPed, GetPedBoneIndex(State.victimPed, 12844), 0.2, 0.04, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
    Wait(2000)
    ClearPedTasks(ped)
end

function Knockout()
    local ped = PlayerPedId()
    local pedCo = GetEntityCoords(ped)
    local animDict = 'misschinese1leadinoutchinese_1_int'
    loadAnimDict(animDict)
    local scene = NetworkCreateSynchronisedScene(pedCo.xy, pedCo.z - 1.0, vector3(0.0, 0.0, 0.0), 2, false, false, 1065353216, 0, 1065353216)
    NetworkAddPedToSynchronisedScene(ped, scene, animDict, 'husb_leadin_action', 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddPedToSynchronisedScene(State.victimPed, scene, animDict, 'russ_leadin_action', 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkStartSynchronisedScene(scene)
    Wait(6000)
    SetPedToRagdoll(State.victimPed, 30000, 30000, 0, false, false, false)
end

function CloseEyes()
    local busy = lib.callback.await('mach1ne_kidnapping:server:checkQueryRoom', false)
    if busy then
        notify(Strings['query_room_busy'], 'warning')
        return
    end
    State.queryActive = false
    DoScreenFadeOut(5000)
    while not IsScreenFadedOut() do Wait(50) end
    loadModel('ch_prop_tunnel_tripod_lampa')
    loadModel('prop_ing_camera_01')
    State.tripod = CreateObject(GetHashKey('ch_prop_tunnel_tripod_lampa'), Config.QueryRoom.tripodPos, 1, 1, 0)
    State.camera = CreateObject(GetHashKey('prop_ing_camera_01'), Config.QueryRoom.cameraPos, 1, 1, 0)
    FreezeEntityPosition(State.tripod, true)
    FreezeEntityPosition(State.camera, true)
    SetEntityRotation(State.camera, 0, 0, Config.QueryRoom.cameraHeading, 2, true)
    DoScreenFadeIn(5000)
    FirstAnimation()
end

function FirstAnimation()
    TriggerServerEvent('mach1ne_kidnapping:server:syncQueryRoom')
    DeleteObject(State.blindfoldObject)
    local ped = PlayerPedId()
    local scenes = { false, false, false, false }
    local animDict = 'missfbi3_wrench'
    loadAnimDict(animDict)

    for k, v in pairs(Config.Objects_1) do
        loadModel(v)
        State.objects[k] = CreateObject(GetHashKey(v), GetEntityCoords(ped), 1, 1, 0)
    end
    loadModel('prop_torture_ch_01')
    State.chair = CreateObject(GetHashKey('prop_torture_ch_01'), GetEntityCoords(ped), 1, 1, 0)

    for i = 1, #Config.Anims_1 do
        State.scenes[i] = NetworkCreateSynchronisedScene(Config.QueryRoom.scenePos.x, Config.QueryRoom.scenePos.y, Config.QueryRoom.scenePos.z - 0.60, Config.QueryRoom.sceneRot, 2, false, true, 1065353216, 0, 1065353216)
        NetworkAddPedToSynchronisedScene(ped, State.scenes[i], animDict, Config.Anims_1[i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddPedToSynchronisedScene(State.victimPed, State.scenes[i], animDict, Config.Anims_1[i][2], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(State.chair, State.scenes[i], animDict, Config.Anims_1[i][3], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(State.objects[1], State.scenes[i], animDict, Config.Anims_1[i][4], 1.0, -1.0, 1148846080)
    end

    NetworkStartSynchronisedScene(State.scenes[1])
    waitForInput(Strings['attack_left'], function() scenes[1] = true end)
    NetworkStartSynchronisedScene(State.scenes[2])
    Wait(5000)
    waitForInput(Strings['attack_mid'], function() scenes[2] = true end)
    NetworkStartSynchronisedScene(State.scenes[3])
    Wait(5000)
    waitForInput(Strings['attack_right'], function() scenes[3] = true end)
    NetworkStartSynchronisedScene(State.scenes[4])
    Wait(5000)
    waitForInput(Strings['switch_jerrycan'], function() scenes[4] = true end)
    DeleteObject(State.objects[1])
    TriggerServerEvent('mach1ne_kidnapping:server:policeAlert', GetEntityCoords(PlayerPedId()))
    SecondAnimation()
end

function SecondAnimation()
    local ped = PlayerPedId()
    local scenes = { false, false, false, false }
    local animDict = 'missfbi3_waterboard'
    loadAnimDict(animDict)

    for k, v in pairs(Config.Objects_2) do
        loadModel(v)
        State.objects[k] = CreateObject(GetHashKey(v), GetEntityCoords(ped), 1, 1, 0)
    end

    for i = 1, #Config.Anims_2 do
        if i == 3 then
            State.scenes[i] = NetworkCreateSynchronisedScene(Config.QueryRoom.scenePos.x, Config.QueryRoom.scenePos.y, Config.QueryRoom.scenePos.z - 0.60, Config.QueryRoom.sceneRot, 2, false, true, 1065353216, 0, 1065353216)
        else
            State.scenes[i] = NetworkCreateSynchronisedScene(Config.QueryRoom.scenePos.x, Config.QueryRoom.scenePos.y, Config.QueryRoom.scenePos.z - 0.60, Config.QueryRoom.sceneRot, 2, true, false, 1065353216, 0, 1065353216)
        end
        NetworkAddPedToSynchronisedScene(ped, State.scenes[i], animDict, Config.Anims_2[i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddPedToSynchronisedScene(State.victimPed, State.scenes[i], animDict, Config.Anims_2[i][2], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(State.chair, State.scenes[i], animDict, Config.Anims_2[i][3], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(State.objects[1], State.scenes[i], animDict, Config.Anims_2[i][4], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(State.objects[2], State.scenes[i], animDict, Config.Anims_2[i][5], 1.0, -1.0, 1148846080)
    end

    NetworkStartSynchronisedScene(State.scenes[1])
    waitForInput(Strings['drop_chair'], function() scenes[1] = true end)
    NetworkStartSynchronisedScene(State.scenes[2])
    Wait(15000)
    waitForInput(Strings['pour_gasoline'], function() scenes[2] = true end)
    NetworkStartSynchronisedScene(State.scenes[3])
    Wait(7500)
    waitForInput(Strings['up_chair'], function() scenes[3] = true end)
    NetworkStartSynchronisedScene(State.scenes[4])
    Wait(5000)
    waitForInput(Strings['switch_pliers'], function() scenes[4] = true end)
    DeleteObject(State.objects[1])
    DeleteObject(State.objects[2])
    ThirdAnimation()
end

function ThirdAnimation()
    local ped = PlayerPedId()
    local scenes = { false, false }
    local animDict = 'missfbi3_toothpull'
    loadAnimDict(animDict)

    for k, v in pairs(Config.Objects_3) do
        loadModel(v)
        State.objects[k] = CreateObject(GetHashKey(v), GetEntityCoords(ped), 1, 1, 0)
    end

    for i = 1, #Config.Anims_3 do
        if i == 3 then
            State.scenes[i] = NetworkCreateSynchronisedScene(Config.QueryRoom.scenePos.x + 0.25, Config.QueryRoom.scenePos.y, Config.QueryRoom.scenePos.z - 0.60, Config.QueryRoom.sceneRot, 2, false, true, 1065353216, 0, 1065353216)
        else
            State.scenes[i] = NetworkCreateSynchronisedScene(Config.QueryRoom.scenePos.x + 0.25, Config.QueryRoom.scenePos.y, Config.QueryRoom.scenePos.z - 0.60, Config.QueryRoom.sceneRot, 2, true, false, 1065353216, 0, 1065353216)
        end
        NetworkAddPedToSynchronisedScene(ped, State.scenes[i], animDict, Config.Anims_3[i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddPedToSynchronisedScene(State.victimPed, State.scenes[i], animDict, Config.Anims_3[i][2], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(State.objects[1], State.scenes[i], animDict, Config.Anims_3[i][3], 1.0, -1.0, 1148846080)
    end

    NetworkStartSynchronisedScene(State.scenes[1])
    Wait(2000)
    NetworkStartSynchronisedScene(State.scenes[2])
    Wait(5000)
    waitForInput(Strings['tooth_pull'], function() scenes[1] = true end)
    NetworkStartSynchronisedScene(State.scenes[3])
    Wait(7500)
    waitForInput(Strings['tooth_rip'], function() scenes[2] = true end)
    NetworkStartSynchronisedScene(State.scenes[4])
    Wait(10000)
    DeleteObject(State.objects[1])
    ClearPedTasks(ped)
    ClearPedTasks(State.victimPed)

    local entityCo = GetEntityCoords(State.victimPed)
    SetEntityCoords(State.victimPed, entityCo.x + 0.5, entityCo.y, entityCo.z - 0.95, 1, 1, 1, 0)
    Wait(250)
    Knockout()
    State.sceneFinish = true
end

function LaptopAnimation()
    local ped = PlayerPedId()
    local animDict = 'switch@franklin@on_laptop'
    local laptopObject = 'p_laptop_02_s'
    local laptopAnims = {
        { '001927_01_fras_v2_4_on_laptop_idle', '001927_01_fras_v2_4_on_laptop_idle_laptop' },
        { '001927_01_fras_v2_4_on_laptop_exit', '001927_01_fras_v2_4_on_laptop_exit_laptop' },
    }
    loadModel(laptopObject)
    loadAnimDict(animDict)
    local sceneObject = CreateObject(GetHashKey(laptopObject), GetEntityCoords(ped), 1, 1, 0)
    local laptopScenes = {}

    for i = 1, 2 do
        laptopScenes[i] = NetworkCreateSynchronisedScene(Config.QueryRoom.laptopScenePos.x, Config.QueryRoom.laptopScenePos.y, Config.QueryRoom.laptopScenePos.z - 0.05, Config.QueryRoom.laptopSceneRot, 2, true, false, 1065353216, 0, 1065353216)
        NetworkAddPedToSynchronisedScene(ped, laptopScenes[i], animDict, laptopAnims[i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(sceneObject, laptopScenes[i], animDict, laptopAnims[i][2], 1.0, -1.0, 1148846080)
    end

    NetworkStartSynchronisedScene(laptopScenes[1])
    Wait(5000)
    NetworkStartSynchronisedScene(laptopScenes[2])
    Wait(5000)
    DeleteObject(sceneObject)
    ClearPedTasks(ped)

    TriggerServerEvent('mach1ne_kidnapping:server:giveVideoRecord')
    finishBlip = addBlip(Config.Boss.pos, 500, 0, Strings['boss_blip'])
    State.kidnapped = true
    TriggerServerEvent('mach1ne_kidnapping:server:syncQueryRoom')

    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(State.victimPed))
            if dist >= 10.0 then
                cleanupEntities()
                break
            end
            Wait(500)
        end
    end)
end

function KidnappingFinish()
    TriggerServerEvent('mach1ne_kidnapping:server:finish')
    State.kidnapped = false
    State.attached = false
    removeBlip(finishBlip); finishBlip = nil
end

function waitForInput(text, onConfirm)
    local confirmed = false
    st.showTextUI({ keyText = 'E', displayText = text, position = 'bottom-center' }, function()
        confirmed = true
    end)
    local timeout = GetGameTimer() + 30000
    while not confirmed and GetGameTimer() < timeout do
        Wait(50)
    end
    st.hideTextUI()
    if confirmed then onConfirm() end
end

AddEventHandler('onResourceStop', function(res)
    if res ~= RES then return end
    st.hideTextUI()
    cleanupEntities()
    removeBlip(finishBlip)
    removeBlip(kidnappingBlip)
    removeBlip(queryBlip)
end)
