local original_getSpawnRegions = SpawnRegionMgr.getSpawnRegions

function SpawnRegionMgr.getSpawnRegions()
    local regions = original_getSpawnRegions()

    if regions then
        for _, region in ipairs(regions) do
            if region.name == "Random Spawn, KY" then
                return regions
            end
        end
    end

    local rslRegion = { name = "Random Spawn, KY", file = "media/maps/Random Spawn, KY/spawnpoints.lua" }
    rslRegion.points = SpawnRegionMgr.loadSpawnPointsFile(rslRegion.file, false)

    if rslRegion.points then
        regions = regions or {}
        table.insert(regions, rslRegion)
    end

    return regions
end

local original_fillList = MapSpawnSelect.fillList

function MapSpawnSelect:fillList()
    original_fillList(self)

    local keepItem = nil
    for _, entry in ipairs(self.listbox.items) do
        local item = entry.item
        if item.region and item.region.name == "Random Spawn, KY" then
            keepItem = item
            break
        end
    end

    if not keepItem then
        return
    end

    keepItem.name = getText("IGUI_RSL_SpawnRegionName")

    self.listbox:clear()
    self.listbox:addItem(keepItem.name, keepItem)
end
