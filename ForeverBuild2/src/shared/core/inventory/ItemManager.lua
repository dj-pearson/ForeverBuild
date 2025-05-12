local ItemManager = {}
ItemManager.__index = ItemManager

function ItemManager.new()
    local self = setmetatable({}, ItemManager)
    self.items = {}
    return self
end

function ItemManager:Initialize()
    print("Initializing ItemManager...")
    -- Load item definitions
end

function ItemManager:GetItemData(itemId)
    -- Return item data from the catalogue
    return self.items[itemId] or {
        id = itemId,
        name = "Unknown Item",
        description = "Item not found in catalogue",
        price = 0
    }
end

function ItemManager:RegisterItem(itemData)
    if not itemData or not itemData.id then
        warn("ItemManager: Attempted to register item without ID")
        return false
    end
    
    self.items[itemData.id] = itemData
    return true
end

function ItemManager:IsAdmin(player)
    -- Check if player is admin (placeholder implementation)
    local adminIds = {1, 123456, 789012} -- example admin IDs
    local userId = typeof(player) == "number" and player or player.UserId
    
    return table.find(adminIds, userId) ~= nil
end

return ItemManager
