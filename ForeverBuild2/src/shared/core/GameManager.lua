local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local Constants = require(script.Parent.Constants)
-- Use script.Parent path and FindFirstChild for more reliability
local InventoryManager = script.Parent:FindFirstChild("inventory") and require(script.Parent.inventory.InventoryManager) or nil
local ItemManager = script.Parent:FindFirstChild("inventory") and require(script.Parent.inventory.ItemManager) or nil
local PlacementManager = script.Parent:FindFirstChild("placement") and require(script.Parent.placement.PlacementManager) or nil

local GameManager = {}
GameManager.__index = GameManager

local inventoryStore = DataStoreService:GetDataStore("PlayerInventory")
local placedItemsStore = DataStoreService:GetDataStore("PlacedItems")

-- Initialize a new GameManager
function GameManager.new()
    local self = setmetatable({}, GameManager)
    
    -- Initialize managers only if modules were loaded successfully
    if ItemManager then
        self.itemManager = ItemManager.new()
    else
        warn("ItemManager module not found")
        self.itemManager = { Initialize = function() end }
    end
    
    if InventoryManager then
        self.inventoryManager = InventoryManager.new()
    else
        warn("InventoryManager module not found")
        self.inventoryManager = { Initialize = function() end }
    end
    
    if PlacementManager then
        self.placementManager = PlacementManager.new()
    else
        warn("PlacementManager module not found")
        self.placementManager = { Initialize = function() end }
    end
    
    return self
end

-- Initialize the game
function GameManager:Initialize()
    print("Initializing game systems...")
    
    -- Initialize sub-managers
    if self.itemManager and self.itemManager.Initialize then
        self.itemManager:Initialize()
    end
    
    if self.inventoryManager and self.inventoryManager.Initialize then
        self.inventoryManager:Initialize()
    end
    
    if self.placementManager and self.placementManager.Initialize then
        self.placementManager:Initialize()
    end
    
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
    self:LoadPlayerInventory(player)
    self:LoadPlacedItems(player)
    self.inventoryManager:InitializePlayer(player)
    self:SetupPlayerAttributes(player)
end

-- Handle player leaving
function GameManager:OnPlayerLeaving(player)
    print("Player leaving:", player.Name)
    self:SavePlayerInventory(player)
    self:SavePlacedItems(player)
    self.inventoryManager:CleanupPlayer(player)
end

-- Set up player attributes
function GameManager:SetupPlayerAttributes(player)
    -- Set admin status
    player:SetAttribute("IsAdmin", self.itemManager:IsAdmin(player))
end

-- Buy an item
function GameManager:BuyItem(player, itemId, quantity)
    quantity = quantity or 1
    local price = self.itemManager:GetActionPrice(itemId, Constants.ITEM_ACTIONS.BUY, player)
    local totalPrice = price * quantity
    -- TODO: Deduct Robux from player (stub)
    -- Add to inventory
    for i = 1, quantity do
        self.inventoryManager:AddItem(player, itemId)
    end
    self:SavePlayerInventory(player)
    return true
end

-- Place an item
function GameManager:PlaceItem(player, itemId, position, rotation)
    -- TODO: Remove from inventory, add to placed items, save
    self:SavePlacedItems(player)
    return self.placementManager:PlaceItem(player, itemId, position, rotation)
end

-- Clone placed item
function GameManager:ClonePlacedItem(player, placedItem)
    local fee = Constants.ITEM_PRICING.clone or 0
    -- TODO: Deduct fee, clone item, save
    self:SavePlacedItems(player)
end

-- Move placed item
function GameManager:MovePlacedItem(player, placedItem, newPosition)
    local fee = Constants.ITEM_PRICING.move or 0
    -- TODO: Deduct fee, move item, save
    self:SavePlacedItems(player)
end

-- Destroy placed item
function GameManager:DestroyPlacedItem(player, placedItem)
    local fee = Constants.ITEM_PRICING.destroy or 0
    -- TODO: Deduct fee, destroy item, save
    self:SavePlacedItems(player)
end

-- Rotate placed item
function GameManager:RotatePlacedItem(player, placedItem, newRotation)
    local fee = Constants.ITEM_PRICING.rotate or 0
    -- TODO: Deduct fee, rotate item, save
    self:SavePlacedItems(player)
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

-- Get item placement (stub for now)
function GameManager:GetItemPlacement(itemId)
    -- TODO: Implement actual lookup for placed items
    -- For now, return a dummy placement
    return {
        id = itemId,
        locked = false,
        model = nil,
        position = nil,
        orientation = nil
    }
end

function GameManager:SavePlayerInventory(player)
    local inventory = self.inventoryManager:GetInventory(player)
    local success, err = pcall(function()
        inventoryStore:SetAsync(tostring(player.UserId), inventory)
    end)
    if not success then
        warn("Failed to save inventory for", player.Name, err)
    end
end

function GameManager:LoadPlayerInventory(player)
    local inventory = nil
    local success, err = pcall(function()
        inventory = inventoryStore:GetAsync(tostring(player.UserId))
    end)
    if not success then
        warn("Failed to load inventory for", player.Name, err)
    end
    if inventory then
        self.inventoryManager:SetInventory(player, inventory)
    end
end

function GameManager:SavePlacedItems(player)
    -- TODO: Get placed items for this player
    local placedItems = {} -- Replace with actual placed items
    local success, err = pcall(function()
        placedItemsStore:SetAsync(tostring(player.UserId), placedItems)
    end)
    if not success then
        warn("Failed to save placed items for", player.Name, err)
    end
end

function GameManager:LoadPlacedItems(player)
    local placedItems = nil
    local success, err = pcall(function()
        placedItems = placedItemsStore:GetAsync(tostring(player.UserId))
    end)
    if not success then
        warn("Failed to load placed items for", player.Name, err)
    end
    if placedItems then
        -- TODO: Place items in the world for this player
    end
end

return GameManager