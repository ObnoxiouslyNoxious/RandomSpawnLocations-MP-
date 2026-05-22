local TOWN_KEY_MAP = {
    ["Brandenburg"]       = "Brandenburg",
    ["Dixie"]             = "Dixie",
    ["Doe Valley Forest"] = "DoeValleyForest",
    ["Echo Creek"]        = "EchoCreek",
    ["Ekron"]             = "Ekron",
    ["Fallas Lake"]       = "FallasLake",
    ["Hog Wallow"]        = "HogWallow",
    ["Irvington"]         = "Irvington",
    ["Louisville"]        = "Louisville",
    ["March Ridge"]       = "MarchRidge",
    ["Muldraugh"]         = "Muldraugh",
    ["Riverside"]         = "Riverside",
    ["Rosewood"]          = "Rosewood",
    ["Valley Station"]    = "ValleyStation",
    ["West Point"]        = "WestPoint",
}

local MODDED_TOWNS = {
    AnruisiTown = true,
    Maplewood   = true,
    RavenCreek  = true,
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
    if sv.Brandenburg   ~= false then return false end
    if sv.Dixie         ~= false then return false end
    if sv.DoeValleyForest ~= false then return false end
    if sv.EchoCreek     ~= false then return false end
    if sv.Ekron         ~= false then return false end
    if sv.FallasLake    ~= false then return false end
    if sv.HogWallow     ~= false then return false end
    if sv.Irvington     ~= false then return false end
    if sv.Louisville    ~= false then return false end
    if sv.MarchRidge    ~= false then return false end
    if sv.Muldraugh     ~= false then return false end
    if sv.Riverside     ~= false then return false end
    if sv.Rosewood      ~= false then return false end
    if sv.ValleyStation ~= false then return false end
    if sv.WestPoint     ~= false then return false end
    return true
end

local function townAllowed(pt, sv, townsAllOff)
    local town = pt.town
    if town == "Isolated Areas" then return true end
    if MODDED_TOWNS[town] then return sv[town] == true end
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
        if pt.balance == true and not MODDED_TOWNS[pt.town] then
            n = n + 1
            result[n] = pt
        end
    end
    return result
end

function SpawnPoints()
    local sv = (SandboxVars and SandboxVars.RSL) or {}
    local points = {}

    local allTypesOff = sv.BalancedResidential ~= true
        and sv.Residential ~= true
        and sv.NonResidential ~= true
        and sv.HardcoreSpawns ~= true
        and sv.IsolatedAreas ~= true
        and sv.Wilderness ~= true

    if RSL_SpawnPoints_Balanced then
        merge(points, RSL_SpawnPoints_Balanced())
    end

    if sv.BalancedResidential ~= true then
        if sv.Residential == true or sv.IsolatedAreas == true or allTypesOff then
            if RSL_SpawnPoints_Residential_A then merge(points, RSL_SpawnPoints_Residential_A()) end
            if RSL_SpawnPoints_Residential_B then merge(points, RSL_SpawnPoints_Residential_B()) end
        end
        if sv.NonResidential == true or sv.IsolatedAreas == true or allTypesOff then
            if RSL_SpawnPoints_NonRes_Louisville_A then merge(points, RSL_SpawnPoints_NonRes_Louisville_A()) end
            if RSL_SpawnPoints_NonRes_Louisville_B then merge(points, RSL_SpawnPoints_NonRes_Louisville_B()) end
            if RSL_SpawnPoints_NonRes_Other_A then merge(points, RSL_SpawnPoints_NonRes_Other_A()) end
            if RSL_SpawnPoints_NonRes_Other_B then merge(points, RSL_SpawnPoints_NonRes_Other_B()) end
        end
        if sv.HardcoreSpawns == true or sv.IsolatedAreas == true or allTypesOff then
            if RSL_SpawnPoints_Hardcore then merge(points, RSL_SpawnPoints_Hardcore()) end
        end
        if sv.Wilderness == true or allTypesOff then
            if RSL_SpawnPoints_Wilderness then merge(points, RSL_SpawnPoints_Wilderness()) end
        end
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
        local balOk = false
        local townOk = false

        if sv.BalancedResidential ~= true then
            balOk = true
        else
            balOk = pt.balance == true
        end

        if sv.BalancedResidential ~= true then
            if allTypesOff then
                typeOn = true
            elseif pt.town == "Isolated Areas" then
                typeOn = sv.IsolatedAreas == true
            elseif pt.hardcore == true then
                typeOn = sv.HardcoreSpawns == true
            elseif pt.type == "NonResidential" then
                typeOn = sv.NonResidential == true
            elseif pt.type == "Residential" then
                typeOn = sv.Residential == true
            end
        else
            typeOn = pt.balance == true
        end

        townOk = townAllowed(pt, sv, townsAllOff)

        if typeOn and balOk and townOk then
            n = n + 1
            filtered[n] = pt
        end
    end

    if #filtered == 0 then
        filtered = getVanillaBalanced(points)
    end

    if #filtered == 0 then
        return nil
    end

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