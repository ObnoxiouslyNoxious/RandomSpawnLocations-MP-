require "RSL_Env"
require "RSL_Config"

if not RSL_Env.isSP() then return end

local SPAWN_POINTS_FILE = "media/maps/Random Spawn, KY/spawnpoints.lua"

local function onFirstSpawn(playerIndex, player)
    if playerIndex ~= 0 then return end

    local gate = ModData.getOrCreate("RSL_FirstSpawnFix")
    if gate.done then return end

    gate.done = true

    RSL_dprint("RSL FirstSpawnFix: re-resolving spawn points with committed settings")

    local regions = SpawnRegionMgr.loadSpawnPointsFile(SPAWN_POINTS_FILE, false)
    if not regions then
        RSL_dprint("RSL FirstSpawnFix: loadSpawnPointsFile returned nil, skipping")
        return
    end

    local pool = regions.unemployed
    if not pool or #pool == 0 then
        RSL_dprint("RSL FirstSpawnFix: spawn pool empty, skipping")
        return
    end

    local rng = newrandom()
    local pt = pool[rng:random(1, #pool)]

    local absX = pt.worldX * 300 + pt.posX
    local absY = pt.worldY * 300 + pt.posY
    local absZ = pt.posZ or 0

    RSL_dprint("RSL FirstSpawnFix: teleporting to (" .. absX .. ", " .. absY .. ", " .. absZ .. ")")

    player:teleportTo(absX, absY, absZ)
end

Events.OnCreatePlayer.Add(onFirstSpawn)
