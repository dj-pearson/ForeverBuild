local InventoryManager = {}
InventoryManager.__index = InventoryManager

function InventoryManager.new()
    local self = setmetatable({}, InventoryManager)
    self.playerInventories = {}
    return self
end

function InventoryManager:Initialize()
    print("Initializing InventoryManager...")
    -- Set up player handlers
end

function InventoryManager:InitializePlayer(player)
    -- Initialize a new player inventory
    local userId = typeof(player) == "number" and player or player.UserId
    self.playerInventories[userId] = {
        items = {},
        lastUpdated = os.time()
    }
    return true
end

function InventoryManager:CleanupPlayer(player)
    -- Clean up player inventory data
    local userId = typeof(player) == "number" and player or player.UserId
    -- Here you would normally save to datastore first
    self.playerInventories[userId] = nil
    return true
end

function InventoryManager:GetPlayerInventory(player)
    local userId = typeof(player) == "number" and player or player.UserId
    if not self.playerInventories[userId] then
        self.playerInventories[userId] = {
            items = {},
            lastUpdated = os.time()
        }
    end
    
    return self.playerInventories[userId]
end

function InventoryManager:AddItemToInventory(player, itemId, quantity)
    quantity = quantity or 1
    
    local inventory = self:GetPlayerInventory(player)
    if not inventory.items[itemId] then
        inventory.items[itemId] = 0
    end
    
    inventory.items[itemId] = inventory.items[itemId] + quantity
    inventory.lastUpdated = os.time()
    
    return true
end

function InventoryManager:RemoveItemFromInventory(player, itemId, quantity)
    quantity = quantity or 1
    
    local inventory = self:GetPlayerInventory(player)
    if not inventory.items[itemId] or inventory.items[itemId] < quantity then
        return false
    end
    
    inventory.items[itemId] = inventory.items[itemId] - quantity
    if inventory.items[itemId] <= 0 then
        inventory.items[itemId] = nil
    end
    
    inventory.lastUpdated = os.time()
    
    return true
end

return InventoryManager
