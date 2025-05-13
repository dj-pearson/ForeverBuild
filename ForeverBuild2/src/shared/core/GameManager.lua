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
    
    -- Create Remotes folder if it doesn't exist
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not Remotes then
        Remotes = Instance.new("Folder")
        Remotes.Name = "Remotes"
        Remotes.Parent = ReplicatedStorage
    end
    
    -- Create Remote events/functions if they don't exist
    local function getOrCreateRemote(name, isFunction)
        local remote = Remotes:FindFirstChild(name)
        if not remote then
            remote = isFunction and Instance.new("RemoteFunction") or Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = Remotes
        end
        return remote
    end
    
    local PurchaseItem = getOrCreateRemote("PurchaseItem", true)
    local RequestInventory = getOrCreateRemote("RequestInventory", true)
    local PlaceItem = getOrCreateRemote("PlaceItem", false)
    local PlacedItemAction = getOrCreateRemote("PlacedItemAction", false)
    
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
    
    -- Handle purchase requests
    PurchaseItem.OnServerInvoke = function(player, itemName, quantity)
        local userId = player.UserId
        local data = playerData[userId]
        if not data then return { success = false, message = "Player data not found" } end
        
        local itemData = Constants.ITEMS[itemName]
        if not itemData then return { success = false, message = "Invalid item" } end
        
        local totalCost = itemData.price * quantity
        if data.currency < totalCost then
            return { success = false, message = "Not enough currency" }
        end
        
        -- Process purchase
        data.currency = data.currency - totalCost
        data.inventory[itemName] = (data.inventory[itemName] or 0) + quantity
        
        -- Save immediately
        savePlayerData(player)
        
        return {
            success = true,
            newCurrency = data.currency,
            newInventory = data.inventory
        }
    end
    
    -- Handle inventory requests
    RequestInventory.OnServerInvoke = function(player)
        local userId = player.UserId
        local data = playerData[userId]
        if not data then return { success = false, message = "Player data not found" } end
        
        return {
            success = true,
            currency = data.currency,
            inventory = data.inventory
        }
    end
    
    -- Handle item placement
    PlaceItem.OnServerEvent:Connect(function(player, itemName, position, rotation)
        local userId = player.UserId
        local data = playerData[userId]
        if not data then return end
        
        if not data.inventory[itemName] or data.inventory[itemName] <= 0 then
            return
        end
        
        -- TODO: Implement actual placement logic
        -- For now, just remove from inventory
        data.inventory[itemName] = data.inventory[itemName] - 1
        savePlayerData(player)
    end)
    
    -- Handle placed item actions
    PlacedItemAction.OnServerEvent:Connect(function(player, itemId, action)
        local userId = player.UserId
        local data = playerData[userId]
        if not data then return end
        
        local item = data.placedItems[itemId]
        if not item then return end
        
        local actionData = Constants.ITEM_ACTIONS[action]
        if not actionData then return end
        
        if data.currency < actionData.cost then return end
        
        -- Process action
        data.currency = data.currency - actionData.cost
        -- TODO: Implement actual action logic
        
        savePlayerData(player)
    end)
    
    -- Initialize game systems
    print("Initializing game systems...")
    -- Remove non-existent module requirements
    print("Game systems initialized successfully")
end

-- Client-only functionality
if not IS_SERVER then
    -- Client will only use RemoteEvents/Functions and Constants
    GameManager.Remotes = ReplicatedStorage:WaitForChild("Remotes")
    GameManager.Constants = Constants
end

return GameManager