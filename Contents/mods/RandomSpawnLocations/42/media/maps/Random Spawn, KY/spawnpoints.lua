local TOWN_KEY_MAP = {
    ["Brandenburg"] = "Brandenburg",
    ["Dixie"] = "Dixie",
    ["Doe Valley Forest"] = "DoeValleyForest",
    ["Echo Creek"] = "EchoCreek",
    ["Ekron"] = "Ekron",
    ["Fallas Lake"] = "FallasLake",
    ["Hog Wallow"] = "HogWallow",
    ["Irvington"] = "Irvington",
    ["Louisville"] = "Louisville",
    ["March Ridge"] = "MarchRidge",
    ["Muldraugh"] = "Muldraugh",
    ["Riverside"] = "Riverside",
    ["Rosewood"] = "Rosewood",
    ["Valley Station"] = "ValleyStation",
    ["West Point"] = "WestPoint",
}

local MODDED_TOWN_KEY_MAP = {
    ["Anruisi Town"] = "AnruisiTown",
    ["Maplewood"] = "Maplewood",
    ["Raven Creek"] = "RavenCreek",
}

local VANILLA_TOWN_KEYS = {
    "Brandenburg","Dixie","DoeValleyForest","EchoCreek","Ekron",
    "FallasLake","HogWallow","Irvington","Louisville","MarchRidge",
    "Muldraugh","Riverside","Rosewood","ValleyStation","WestPoint",
}

local function merge(dest, src)
    if not src then return end
    local n = #dest
    for i = 1, #src do
        n = n + 1
        dest[n] = src[i]
    end
end

local function allVanillaTownsOff(sv)
    for i = 1, #VANILLA_TOWN_KEYS do
        if sv[VANILLA_TOWN_KEYS[i]] ~= false then return false end
    end
    return true
end

local function allTypesOff(sv)
    return sv.BalancedResidential ~= true
       and sv.BalancedNonResidential ~= true
       and sv.Residential ~= true
       and sv.NonResidential ~= true
       and sv.HardcoreSpawns ~= true
       and sv.IsolatedAreas ~= true
       and sv.Wilderness ~= true
       and sv.BalancedWilderness ~= true
end

local function townAllowed(pt, sv, townsAllOff)
    local town = pt.town
    if town == "Isolated Areas" or town == "Wilderness" then return true end
    local moddedKey = MODDED_TOWN_KEY_MAP[town]
    if moddedKey then return sv[moddedKey] == true end
    if townsAllOff then return true end
    local key = TOWN_KEY_MAP[town]
    if key == nil then return true end
    return sv[key] ~= false
end

local function getVanillaBalanced(points)
    local result = {}
    local n = 0
    for i = 1, #points do
        local pt = points[i]
        if pt.balance == true and pt.type == "Residential" and not MODDED_TOWN_KEY_MAP[pt.town] then
            n = n + 1
            result[n] = pt
        end
    end
    return result
end

function SpawnPoints()
    if SandboxVars and getSandboxOptions then
        getSandboxOptions():toLua()
    end

    local sv = (SandboxVars and SandboxVars.RSL) or {}
    local typesOff = allTypesOff(sv)
    local points = {}

    if sv.BalancedResidential == true or sv.Residential == true or typesOff then
        if RSL_SpawnPoints_Balanced_Residential then
            merge(points, RSL_SpawnPoints_Balanced_Residential())
        elseif RSL_SpawnPoints_Balanced then
            local src = RSL_SpawnPoints_Balanced()
            for i = 1, #src do
                if src[i].type == "Residential" then
                    points[#points+1] = src[i]
                end
            end
        end
    end

    if sv.BalancedNonResidential == true or sv.NonResidential == true then
        if RSL_SpawnPoints_Balanced_NonResidential then
            merge(points, RSL_SpawnPoints_Balanced_NonResidential())
        elseif RSL_SpawnPoints_Balanced then
            local src = RSL_SpawnPoints_Balanced()
            for i = 1, #src do
                if src[i].type == "NonResidential" then
                    points[#points+1] = src[i]
                end
            end
        end
    end

    if sv.Residential == true or typesOff then
        if RSL_SpawnPoints_Residential_A then merge(points, RSL_SpawnPoints_Residential_A()) end
        if RSL_SpawnPoints_Residential_B then merge(points, RSL_SpawnPoints_Residential_B()) end
    end

    if sv.NonResidential == true or typesOff then
        if RSL_SpawnPoints_NonRes_Louisville_A then merge(points, RSL_SpawnPoints_NonRes_Louisville_A()) end
        if RSL_SpawnPoints_NonRes_Louisville_B then merge(points, RSL_SpawnPoints_NonRes_Louisville_B()) end
        if RSL_SpawnPoints_NonRes_Other_A then merge(points, RSL_SpawnPoints_NonRes_Other_A()) end
        if RSL_SpawnPoints_NonRes_Other_B then merge(points, RSL_SpawnPoints_NonRes_Other_B()) end
    end

    if sv.HardcoreSpawns == true or typesOff then
        if RSL_SpawnPoints_Hardcore then merge(points, RSL_SpawnPoints_Hardcore()) end
    end

    if sv.IsolatedAreas == true then
        if RSL_SpawnPoints_Isolated then merge(points, RSL_SpawnPoints_Isolated()) end
    end

    if sv.Wilderness == true or sv.BalancedWilderness == true then
        if RSL_SpawnPoints_Wilderness then merge(points, RSL_SpawnPoints_Wilderness()) end
    end

    if sv.AnruisiTown == true then
        if RSL_SpawnPoints_Modded_AnruisiTown then merge(points, RSL_SpawnPoints_Modded_AnruisiTown()) end
    end
    if sv.Maplewood == true then
        if RSL_SpawnPoints_Modded_Maplewood then merge(points, RSL_SpawnPoints_Modded_Maplewood()) end
    end
    if sv.RavenCreek == true then
        if RSL_SpawnPoints_Modded_RavenCreek then merge(points, RSL_SpawnPoints_Modded_RavenCreek()) end
    end

    local townsAllOff = allVanillaTownsOff(sv)
    local filtered = {}
    local n = 0

    for i = 1, #points do
        local pt = points[i]
        local typeOn = false

        if typesOff then
            typeOn = pt.town ~= "Isolated Areas" and pt.town ~= "Wilderness"
        else
            local town = pt.town
            if town == "Isolated Areas" then
                typeOn = sv.IsolatedAreas == true
            elseif town == "Wilderness" then
                typeOn = sv.Wilderness == true or (pt.balance == true and sv.BalancedWilderness == true)
            elseif MODDED_TOWN_KEY_MAP[town] then
                typeOn = sv[MODDED_TOWN_KEY_MAP[town]] == true
            elseif pt.hardcore == true then
                typeOn = sv.HardcoreSpawns == true
            elseif pt.type == "Residential" then
                typeOn = sv.Residential == true or (pt.balance == true and sv.BalancedResidential == true)
            elseif pt.type == "NonResidential" then
                typeOn = sv.NonResidential == true or (pt.balance == true and sv.BalancedNonResidential == true)
            end
        end

        if typeOn and townAllowed(pt, sv, townsAllOff) then
            n = n + 1
            filtered[n] = pt
        end
    end

    if n == 0 then
        filtered = getVanillaBalanced(points)
    end

    if #filtered == 0 then return nil end

    return buildReturn(filtered)
end

function buildReturn(pts)
    local minimal = {}
    local n = 0
    for i = 1, #pts do
        local pt = pts[i]
        local p = { worldX=pt.worldX, worldY=pt.worldY, posX=pt.posX, posY=pt.posY }
        if pt.posZ and pt.posZ ~= 0 then p.posZ = pt.posZ end
        n = n + 1
        minimal[n] = p
    end
    return { unemployed = minimal }
end
