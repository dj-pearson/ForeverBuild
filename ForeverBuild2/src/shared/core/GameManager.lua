local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Constants)

-- Determine if we're on the server
local IS_SERVER = RunService:IsServer()

local GameManager = {}

-- Server-only functionality
if IS_SERVER then
    local DataStoreService = game:GetService("DataStoreService")
    local Players = game:GetService("Players")
    
    -- DataStores
    local PlayerCurrencyStore = DataStoreService:GetDataStore("PlayerCurrency")
    local PlayerInventoryStore = DataStoreService:GetDataStore("PlayerInventory")
    local PlacedItemsStore = DataStoreService:GetDataStore("PlacedItems")
    
    -- Player data cache
    local playerData = {}
    
    -- Initialize player data
    local function initializePlayerData(player)
        print("Initializing data for player:", player.Name)
        playerData[player.UserId] = {
            currency = Constants.GAME.STARTING_CURRENCY,
            inventory = {},
            placedItems = {}
        }
        
        -- Try to load saved data
        local success, result = pcall(function()
            -- Only try to load in production
            if game:GetService("RunService"):IsStudio() then
                return
            end
            
            local currency = PlayerCurrencyStore:GetAsync(player.UserId)
            local inventory = PlayerInventoryStore:GetAsync(player.UserId)
            local placedItems = PlacedItemsStore:GetAsync(player.UserId)
            
            if currency then playerData[player.UserId].currency = currency end
            if inventory then playerData[player.UserId].inventory = inventory end
            if placedItems then playerData[player.UserId].placedItems = placedItems end
        end)
        
        if not success then
            warn("Failed to load data for", player.Name, ":", result)
        end
    end
    
    -- Save player data
    local function savePlayerData(player)
        local userId = player.UserId
        if not playerData[userId] then return end
        
        -- Only try to save in production
        if game:GetService("RunService"):IsStudio() then
            return
        end
        
        local success, result = pcall(function()
            PlayerCurrencyStore:SetAsync(userId, playerData[userId].currency)
            PlayerInventoryStore:SetAsync(userId, playerData[userId].inventory)
            PlacedItemsStore:SetAsync(userId, playerData[userId].placedItems)
        end)
        
        if not success then
            warn("Failed to save data for", player.Name, ":", result)
        end
    end
    
    -- Handle player joining
    Players.PlayerAdded:Connect(function(player)
        print("Player joined:", player.Name)
        initializePlayerData(player)
    end)
    
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(player)
        savePlayerData(player)
        playerData[player.UserId] = nil
    end)
    
    -- Expose functions for server event handlers
    function GameManager.HandleBuyItem(player, itemId)
        warn("HandleBuyItem not implemented!")
    end
    function GameManager.HandlePlaceItem(player, itemId, position, rotation)
        warn("HandlePlaceItem not implemented!")
    end
    function GameManager.HandleMoveItem(player, itemId, newPosition)
        warn("HandleMoveItem not implemented!")
    end
    function GameManager.HandleRotateItem(player, itemId, newRotation)
        warn("HandleRotateItem not implemented!")
    end
    function GameManager.HandleChangeColor(player, itemId, newColor)
        warn("HandleChangeColor not implemented!")
    end
    function GameManager.HandleRemoveItem(player, itemId)
        warn("HandleRemoveItem not implemented!")
    end
    function GameManager.GetPlayerInventory(player)
        warn("GetPlayerInventory not implemented!")
        return { success = false, message = "Not implemented" }
    end
    function GameManager.GetItemData(itemId)
        warn("GetItemData not implemented!")
        return nil
    end
    function GameManager.GetItemPlacement(itemId)
        warn("GetItemPlacement not implemented!")
        return nil
    end
    function GameManager.AddToInventory(player, itemId)
        warn("AddToInventory not implemented!")
    end
    function GameManager.ApplyItemEffect(player, itemId, placement)
        warn("ApplyItemEffect not implemented!")
    end
    
    -- Existing purchase, inventory, placement, and action logic can be refactored into these functions as needed
    
    print("Initializing game systems...")
    print("Game systems initialized successfully")
end

-- Client-only functionality
if not IS_SERVER then
    -- Client will only use RemoteEvents/Functions and Constants
    GameManager.Remotes = ReplicatedStorage:WaitForChild("Remotes")
    GameManager.Constants = Constants
end

return GameManager