local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.Constants)

local InventoryManager = {}
InventoryManager.__index = InventoryManager

function InventoryManager.new()
    local self = setmetatable({}, InventoryManager)
    self.playerInventories = {}
    return self
end

function InventoryManager:Initialize()
    print("InventoryManager initialized")
end

function InventoryManager:InitializePlayer(player)
    self.playerInventories[player.UserId] = {
        items = {},
        maxSlots = Constants.GAME.MAX_INVENTORY_SLOTS
    }
end

function InventoryManager:CleanupPlayer(player)
    self.playerInventories[player.UserId] = nil
end

function InventoryManager:GetInventory(player)
    return self.playerInventories[player.UserId]
end

function InventoryManager:AddItem(player, itemId, quantity)
    quantity = quantity or 1
    local inventory = self:GetInventory(player)
    if not inventory then return false end
    
    if #inventory.items >= inventory.maxSlots then
        return false
    end
    
    table.insert(inventory.items, {
        id = itemId,
        quantity = quantity
    })
    
    return true
end

function InventoryManager:RemoveItem(player, itemId, quantity)
    quantity = quantity or 1
    local inventory = self:GetInventory(player)
    if not inventory then return false end
    
    for i, item in ipairs(inventory.items) do
        if item.id == itemId then
            if item.quantity > quantity then
                item.quantity = item.quantity - quantity
            else
                table.remove(inventory.items, i)
            end
            return true
        end
    end
    
    return false
end

function InventoryManager:HasItem(player, itemId, quantity)
    quantity = quantity or 1
    local inventory = self:GetInventory(player)
    if not inventory then return false end
    
    for _, item in ipairs(inventory.items) do
        if item.id == itemId and item.quantity >= quantity then
            return true
        end
    end
    
    return false
end

return InventoryManager
