local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(script.Parent.Constants)
local ItemManager = require(script.Parent.ItemManager)
local InventoryManager = require(script.Parent.InventoryManager)
local PlacementManager = require(script.Parent.PlacementManager)

local GameManager = {}
GameManager.__index = GameManager

-- Initialize a new GameManager
function GameManager.new()
    local self = setmetatable({}, GameManager)
    self.itemManager = ItemManager.new()
    self.inventoryManager = InventoryManager.new()
    self.placementManager = PlacementManager.new()
    return self
end

-- Initialize the game
function GameManager:Initialize()
    print("Initializing game systems...")
    
    -- Set up player handling
    self:SetupPlayerHandling()
    
    print("Game systems initialized successfully")
end

-- Set up player handling
function GameManager:SetupPlayerHandling()
    -- Handle player joining
    game.Players.PlayerAdded:Connect(function(player)
        self:OnPlayerJoined(player)
    end)
    
    -- Handle player leaving
    game.Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerLeaving(player)
    end)
end

-- Handle player joining
function GameManager:OnPlayerJoined(player)
    print("Player joined:", player.Name)
    
    -- Initialize player inventory
    self.inventoryManager:InitializePlayer(player)
    
    -- Set up player attributes
    self:SetupPlayerAttributes(player)
end

-- Handle player leaving
function GameManager:OnPlayerLeaving(player)
    print("Player leaving:", player.Name)
    
    -- Clean up player data
    self.inventoryManager:CleanupPlayer(player)
end

-- Set up player attributes
function GameManager:SetupPlayerAttributes(player)
    -- Set admin status
    player:SetAttribute("IsAdmin", self.itemManager:IsAdmin(player))
end

-- Buy an item
function GameManager:BuyItem(player, itemId)
    -- Check if player is admin
    if self.itemManager:IsAdmin(player) then
        return self.inventoryManager:AddItem(player, itemId)
    end
    
    -- Check if item is free
    if self.itemManager:IsItemFree(itemId, player) then
        return self.inventoryManager:AddItem(player, itemId)
    end
    
    -- Get price
    local price = self.itemManager:GetActionPrice(itemId, Constants.ITEM_ACTIONS.BUY, player)
    
    -- TODO: Implement currency check and deduction
    
    -- Add item to inventory
    return self.inventoryManager:AddItem(player, itemId)
end

-- Place an item
function GameManager:PlaceItem(player, itemId, position, rotation)
    return self.placementManager:PlaceItem(player, itemId, position, rotation)
end

-- Move an item
function GameManager:MoveItem(player, placedItem, newPosition)
    return self.placementManager:MoveItem(player, placedItem, newPosition)
end

-- Rotate an item
function GameManager:RotateItem(player, placedItem, newRotation)
    return self.placementManager:RotateItem(player, placedItem, newRotation)
end

-- Change item color
function GameManager:ChangeItemColor(player, placedItem, newColor)
    return self.placementManager:ChangeItemColor(player, placedItem, newColor)
end

-- Remove an item
function GameManager:RemoveItem(player, placedItem)
    return self.placementManager:RemoveItem(player, placedItem)
end

-- Get player inventory
function GameManager:GetPlayerInventory(player)
    return self.inventoryManager:GetInventory(player)
end

-- Check if player has item
function GameManager:HasItem(player, itemId, quantity)
    return self.inventoryManager:HasItem(player, itemId, quantity)
end

-- Check if player is admin
function GameManager:IsAdmin(player)
    return self.itemManager:IsAdmin(player)
end

-- Get item data
function GameManager:GetItemData(itemId)
    return self.itemManager:GetItemData(itemId)
end

-- Get item model
function GameManager:GetItemModel(itemId)
    return self.itemManager:GetItemModel(itemId)
end

return GameManager 