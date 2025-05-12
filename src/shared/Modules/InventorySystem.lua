local InventorySystem = {}
InventorySystem.__index = InventorySystem

-- Constants
local MAX_INVENTORY_SIZE = 50
local ITEM_TYPES = {
    WEAPON = "Weapon",
    ARMOR = "Armor",
    CONSUMABLE = "Consumable",
    MATERIAL = "Material",
    QUEST = "Quest"
}

-- Item templates (this would typically be loaded from a data store)
local ITEM_TEMPLATES = {
    -- Weapons
    ["sword_1"] = {
        id = "sword_1",
        name = "Basic Sword",
        type = ITEM_TYPES.WEAPON,
        rarity = "Common",
        stats = {
            damage = 10,
            speed = 1.0
        },
        description = "A basic sword for beginners"
    },
    -- Armor
    ["armor_1"] = {
        id = "armor_1",
        name = "Leather Armor",
        type = ITEM_TYPES.ARMOR,
        rarity = "Common",
        stats = {
            defense = 5
        },
        description = "Basic leather armor"
    },
    -- Consumables
    ["health_potion"] = {
        id = "health_potion",
        name = "Health Potion",
        type = ITEM_TYPES.CONSUMABLE,
        rarity = "Common",
        stats = {
            healAmount = 25
        },
        description = "Restores 25 health"
    }
}

-- Initialize a new inventory system
function InventorySystem.new()
    local self = setmetatable({}, InventorySystem)
    return self
end

-- Create a new inventory
function InventorySystem:CreateInventory()
    return {
        items = {},
        size = 0,
        maxSize = MAX_INVENTORY_SIZE
    }
end

-- Add an item to inventory
function InventorySystem:AddItem(inventory, itemId, quantity)
    quantity = quantity or 1
    
    -- Check if inventory is full
    if inventory.size + quantity > inventory.maxSize then
        return false, "Inventory is full"
    end
    
    -- Get item template
    local itemTemplate = ITEM_TEMPLATES[itemId]
    if not itemTemplate then
        return false, "Invalid item ID"
    end
    
    -- Check if item already exists in inventory
    local existingItem = self:FindItem(inventory, itemId)
    if existingItem then
        existingItem.quantity = existingItem.quantity + quantity
    else
        -- Create new item instance
        local newItem = {
            id = itemId,
            quantity = quantity,
            template = itemTemplate
        }
        table.insert(inventory.items, newItem)
    end
    
    inventory.size = inventory.size + quantity
    return true, "Item added successfully"
end

-- Remove an item from inventory
function InventorySystem:RemoveItem(inventory, itemId, quantity)
    quantity = quantity or 1
    
    local itemIndex = self:FindItemIndex(inventory, itemId)
    if not itemIndex then
        return false, "Item not found"
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
    return true, "Item removed successfully"
end

-- Find an item in inventory
function InventorySystem:FindItem(inventory, itemId)
    for _, item in ipairs(inventory.items) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

-- Find item index in inventory
function InventorySystem:FindItemIndex(inventory, itemId)
    for i, item in ipairs(inventory.items) do
        if item.id == itemId then
            return i
        end
    end
    return nil
end

-- Get item template
function InventorySystem:GetItemTemplate(itemId)
    return ITEM_TEMPLATES[itemId]
end

-- Check if inventory has space
function InventorySystem:HasSpace(inventory, quantity)
    return inventory.size + quantity <= inventory.maxSize
end

-- Get inventory size
function InventorySystem:GetSize(inventory)
    return inventory.size
end

-- Get inventory max size
function InventorySystem:GetMaxSize(inventory)
    return inventory.maxSize
end

-- Get all items of a specific type
function InventorySystem:GetItemsByType(inventory, itemType)
    local items = {}
    for _, item in ipairs(inventory.items) do
        if item.template.type == itemType then
            table.insert(items, item)
        end
    end
    return items
end

-- Use a consumable item
function InventorySystem:UseConsumable(inventory, itemId, target)
    local item = self:FindItem(inventory, itemId)
    if not item then
        return false, "Item not found"
    end
    
    if item.template.type ~= ITEM_TYPES.CONSUMABLE then
        return false, "Item is not consumable"
    end
    
    -- Apply item effects
    if item.template.stats.healAmount then
        -- This would typically call a health system
        -- HealthSystem:Heal(target, item.template.stats.healAmount)
    end
    
    -- Remove one item
    return self:RemoveItem(inventory, itemId, 1)
end

-- Equip an item
function InventorySystem:EquipItem(inventory, itemId, target)
    local item = self:FindItem(inventory, itemId)
    if not item then
        return false, "Item not found"
    end
    
    if item.template.type ~= ITEM_TYPES.WEAPON and item.template.type ~= ITEM_TYPES.ARMOR then
        return false, "Item cannot be equipped"
    end
    
    -- This would typically call an equipment system
    -- EquipmentSystem:Equip(target, item)
    
    return true, "Item equipped successfully"
end

return InventorySystem 