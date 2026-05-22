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

    keepItem.name = "Random Spawn, KY"

    self.listbox:clear()
    self.listbox:addItem(keepItem.name, keepItem)
end