local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Constants = require(script.Parent.Constants)
local ItemManager = require(script.Parent.ItemManager)

local InventoryManager = {}
InventoryManager.__index = InventoryManager

-- Initialize a new InventoryManager
function InventoryManager.new()
    local self = setmetatable({}, InventoryManager)
    self.playerInventories = {}
    self.inventoryStore = DataStoreService:GetDataStore("PlayerInventories")
    return self
end

-- Initialize player inventory
function InventoryManager:InitializePlayer(player)
    local inventory = {
        items = {},
        size = 0,
        maxSize = Constants.INVENTORY.MAX_SLOTS
    }
    
    self.playerInventories[player.UserId] = inventory
    
    -- Load saved inventory
    self:LoadInventory(player)
end

-- Load player inventory from DataStore
function InventoryManager:LoadInventory(player)
    local success, result = pcall(function()
        return self.inventoryStore:GetAsync(player.UserId)
    end)
    
    if success and result then
        self.playerInventories[player.UserId] = result
    end
end

-- Save player inventory to DataStore
function InventoryManager:SaveInventory(player)
    local inventory = self.playerInventories[player.UserId]
    if not inventory then return end
    
    pcall(function()
        self.inventoryStore:SetAsync(player.UserId, inventory)
    end)
end

-- Add item to player inventory
function InventoryManager:AddItem(player, itemId, quantity)
    quantity = quantity or 1
    local inventory = self.playerInventories[player.UserId]
    if not inventory then return false, "Inventory not found" end
    
    -- Check if inventory is full
    if inventory.size + quantity > inventory.maxSize then
        return false, "Inventory is full"
    end
    
    -- Check if item exists
    local itemData = ItemManager:GetItemData(itemId)
    if not itemData then
        return false, "Item not found"
    end
    
    -- Add item to inventory
    local existingItem = self:FindItem(player, itemId)
    if existingItem then
        existingItem.quantity = existingItem.quantity + quantity
    else
        table.insert(inventory.items, {
            id = itemId,
            quantity = quantity,
            properties = {
                rotation = 0,
                colorChanges = 0,
                color = itemData.properties.originalColor
            }
        })
    end
    
    inventory.size = inventory.size + quantity
    
    -- Save inventory
    self:SaveInventory(player)
    
    return true, "Item added successfully"
end

-- Remove item from player inventory
function InventoryManager:RemoveItem(player, itemId, quantity)
    quantity = quantity or 1
    local inventory = self.playerInventories[player.UserId]
    if not inventory then return false, "Inventory not found" end
    
    local itemIndex = self:FindItemIndex(player, itemId)
    if not itemIndex then
        return false, "Item not found in inventory"
    end
    
    local item = inventory.items[itemIndex]
    if item.quantity < quantity then
        return false, "Not enough items"
    end
    
    item.quantity = item.quantity - quantity
    if item.quantity <= 0 then
        table.remove(inventory.items, itemIndex)
    end
    
    inventory.size = inventory.size - quantity
    
    -- Save inventory
    self:SaveInventory(player)
    
    return true, "Item removed successfully"
end

-- Find item in inventory
function InventoryManager:FindItem(player, itemId)
    local inventory = self.playerInventories[player.UserId]
    if not inventory then return nil end
    
    for _, item in ipairs(inventory.items) do
        if item.id == itemId then
            return item
        end
    end
    
    return nil
end

-- Find item index in inventory
function InventoryManager:FindItemIndex(player, itemId)
    local inventory = self.playerInventories[player.UserId]
    if not inventory then return nil end
    
    for i, item in ipairs(inventory.items) do
        if item.id == itemId then
            return i
        end
    end
    
    return nil
end

-- Get player inventory
function InventoryManager:GetInventory(player)
    return self.playerInventories[player.UserId]
end

-- Check if player has item
function InventoryManager:HasItem(player, itemId, quantity)
    quantity = quantity or 1
    local item = self:FindItem(player, itemId)
    return item and item.quantity >= quantity
end

-- Update item properties
function InventoryManager:UpdateItemProperties(player, itemId, properties)
    local item = self:FindItem(player, itemId)
    if not item then return false, "Item not found" end
    
    -- Update properties
    for key, value in pairs(properties) do
        item.properties[key] = value
    end
    
    -- Save inventory
    self:SaveInventory(player)
    
    return true, "Item properties updated"
end

-- Clean up player data
function InventoryManager:CleanupPlayer(player)
    self.playerInventories[player.UserId] = nil
end

return InventoryManager 