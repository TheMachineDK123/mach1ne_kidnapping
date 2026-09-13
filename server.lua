local RES = GetCurrentResourceName()

local function dbg(...) if Config.Debug then print('[mach1ne_kidnapping]', ...) end end
local function now() return os.time() end

local lastNapping = 0
local queryRoom = false

local function isPolice(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local job = xPlayer.getJob().name
    for _, j in ipairs(Config.PoliceJobs) do if j == job then return true end end
    return false
end

local function notifyPlayer(src, desc, typ)
    TriggerClientEvent('st_libs:notify', src, {
        title = 'Kidnapping',
        description = desc,
        type = typ or 'inform',
        duration = 6000,
    })
end

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS mach1ne_kidnapping_cooldown (
            id INT NOT NULL DEFAULT 1 PRIMARY KEY,
            last_napping BIGINT NOT NULL DEFAULT 0
        ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
    ]])
    MySQL.prepare('INSERT IGNORE INTO mach1ne_kidnapping_cooldown (id, last_napping) VALUES (1, 0)')
    local row = MySQL.single.await('SELECT last_napping FROM mach1ne_kidnapping_cooldown WHERE id = 1')
    if row then lastNapping = tonumber(row.last_napping) or 0 end
    dbg(('Cooldown indlæst: %d'):format(lastNapping))
end)

local function saveCooldown()
    MySQL.prepare('UPDATE mach1ne_kidnapping_cooldown SET last_napping = ? WHERE id = 1', { lastNapping })
end

lib.callback.register('mach1ne_kidnapping:server:checkQueryRoom', function(src)
    return queryRoom
end)

lib.callback.register('mach1ne_kidnapping:server:checkTime', function(src)
    if (now() - lastNapping) < Config.Cooldown and lastNapping ~= 0 then
        local seconds = Config.Cooldown - (now() - lastNapping)
        local minutes = math.floor(seconds / 60)
        notifyPlayer(src, Strings['wait_nextnapping'] .. ' ' .. minutes .. ' ' .. Strings['minute'], 'warning')
        return false
    end
    lastNapping = now()
    saveCooldown()
    return true
end)

RegisterNetEvent('mach1ne_kidnapping:server:syncQueryRoom', function()
    queryRoom = not queryRoom
end)

RegisterNetEvent('mach1ne_kidnapping:server:policeAlert', function(coords)
    local src = source
    for _, pid in ipairs(GetPlayers()) do
        if isPolice(tonumber(pid)) then
            TriggerClientEvent('mach1ne_kidnapping:client:policeAlert', tonumber(pid), coords)
        end
    end
end)

RegisterNetEvent('mach1ne_kidnapping:server:giveVideoRecord', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local added = exports.ox_inventory:AddItem(src, Config.VideoItem, 1)
    if added then
        dbg(('%s (%s) fik videooptagelse'):format(xPlayer.getName(), src))
    else
        notifyPlayer(src, 'Din inventar er fuld - kunne ikke modtage videooptagelse.', 'error')
    end
end)

RegisterNetEvent('mach1ne_kidnapping:server:finish', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local count = exports.ox_inventory:Search(src, 'count', Config.VideoItem)
    if count and count > 0 then
        exports.ox_inventory:RemoveItem(src, Config.VideoItem, count)
        local totalPayout = 0
        for _ = 1, count do
            totalPayout = totalPayout + math.random(Config.RewardCashMin, Config.RewardCashMax)
        end
        exports.ox_inventory:AddItem(src, 'money', totalPayout)
        notifyPlayer(src, Strings['reward_cash']:format(totalPayout), 'success')
        dbg(('%s (%s) solgte %d videooptagelse(r) for %d kr.'):format(xPlayer.getName(), src, count, totalPayout))
    else
        notifyPlayer(src, 'Du har ingen videooptagelser at sælge.', 'error')
    end

    if #Config.RandomRewardItems > 0 then
        local reward = Config.RandomRewardItems[math.random(1, #Config.RandomRewardItems)]
        local added = exports.ox_inventory:AddItem(src, reward, 1)
        if added then
            notifyPlayer(src, Strings['reward_item']:format(reward), 'success')
        end
    end
end)
