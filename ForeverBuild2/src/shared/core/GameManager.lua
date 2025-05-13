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
    
    -- Player data cache
    local playerData = {}
    
    -- DataStores
    local PlayerCurrencyStore = DataStoreService:GetDataStore("PlayerCurrency")
    local PlayerInventoryStore = DataStoreService:GetDataStore("PlayerInventory")
    local PlacedItemsStore = DataStoreService:GetDataStore("PlacedItems")
    
    -- Helper: skip DataStore in Studio
    local function canUseDataStore()
        return not RunService:IsStudio()
    end
    
    -- Initialize player data
    local function initializePlayerData(player)
        playerData[player.UserId] = {
            currency = Constants.GAME.STARTING_CURRENCY,
            inventory = {},
            placedItems = {}
        }
        if canUseDataStore() then
            local success, result = pcall(function()
                local currency = PlayerCurrencyStore:GetAsync(player.UserId)
                local inventory = PlayerInventoryStore:GetAsync(player.UserId)
                local placedItems = PlacedItemsStore:GetAsync(player.UserId)
                if currency then playerData[player.UserId].currency = currency end
                if inventory then playerData[player.UserId].inventory = inventory end
                if placedItems then playerData[player.UserId].placedItems = placedItems end
            end)
            if not success then warn("Failed to load data for", player.Name, ":", result) end
        end
    end
    
    -- Save player data
    local function savePlayerData(player)
        local userId = player.UserId
        if not playerData[userId] then return end
        if canUseDataStore() then
            local success, result = pcall(function()
                PlayerCurrencyStore:SetAsync(userId, playerData[userId].currency)
                PlayerInventoryStore:SetAsync(userId, playerData[userId].inventory)
                PlacedItemsStore:SetAsync(userId, playerData[userId].placedItems)
            end)
            if not success then warn("Failed to save data for", player.Name, ":", result) end
        end
    end
    
    -- Update client UI
    local function updateClientUI(player)
        if ReplicatedStorage.Remotes.UpdateBalance then
            ReplicatedStorage.Remotes.UpdateBalance:FireClient(player, playerData[player.UserId].currency)
        end
        -- You can add more remotes for inventory if needed
    end
    
    -- Player join/leave
    Players.PlayerAdded:Connect(function(player)
        initializePlayerData(player)
        updateClientUI(player)
    end)
    Players.PlayerRemoving:Connect(function(player)
        savePlayerData(player)
        playerData[player.UserId] = nil
    end)
    
    -- Purchase logic
    function GameManager.HandleBuyItem(player, itemId)
        local userId = player.UserId
        local pdata = playerData[userId]
        local itemData = Constants.ITEMS[itemId]
        if not pdata or not itemData then
            return { success = false, message = "Invalid item or player." }
        end
        if pdata.currency < itemData.price then
            return { success = false, message = "Not enough currency." }
        end
        pdata.currency = pdata.currency - itemData.price
        pdata.inventory[itemId] = (pdata.inventory[itemId] or 0) + 1
        savePlayerData(player)
        updateClientUI(player)
        return { success = true, message = "Purchase successful!" }
    end
    
    -- Placement logic
    function GameManager.HandlePlaceItem(player, itemId, position, rotation)
        local userId = player.UserId
        local pdata = playerData[userId]
        if not pdata or not pdata.inventory[itemId] or pdata.inventory[itemId] <= 0 then
            return { success = false, message = "You do not have this item in your inventory." }
        end
        -- Placement validation (stub: always true)
        local validPlacement = true -- TODO: add collision/grid checks
        if not validPlacement then
            return { success = false, message = "Invalid placement location." }
        end
        pdata.inventory[itemId] = pdata.inventory[itemId] - 1
        -- Add to placedItems (stub: just increment count)
        local placedId = tostring(os.time()) .. tostring(math.random(1000,9999))
        pdata.placedItems[placedId] = { id = itemId, position = position, rotation = rotation }
        savePlayerData(player)
        updateClientUI(player)
        return { success = true, message = "Item placed successfully!" }
    end
    
    -- Remove item logic
    function GameManager.HandleRemoveItem(player, itemId)
        local userId = player.UserId
        local pdata = playerData[userId]
        if not pdata or not pdata.placedItems[itemId] then
            return { success = false, message = "You cannot remove this item." }
        end
        pdata.placedItems[itemId] = nil
        savePlayerData(player)
        updateClientUI(player)
        return { success = true, message = "Item removed successfully!" }
    end
    -- Move/Rotate logic (stubs)
    function GameManager.HandleMoveItem(player, itemId, newPosition)
        local userId = player.UserId
        local pdata = playerData[userId]
        if not pdata or not pdata.placedItems[itemId] then
            return { success = false, message = "You cannot move this item." }
        end
        pdata.placedItems[itemId].position = newPosition
        savePlayerData(player)
        updateClientUI(player)
        return { success = true, message = "Item moved successfully!" }
    end
    function GameManager.HandleRotateItem(player, itemId, newRotation)
        local userId = player.UserId
        local pdata = playerData[userId]
        if not pdata or not pdata.placedItems[itemId] then
            return { success = false, message = "You cannot rotate this item." }
        end
        pdata.placedItems[itemId].rotation = newRotation
        savePlayerData(player)
        updateClientUI(player)
        return { success = true, message = "Item rotated successfully!" }
    end
    function GameManager.HandleChangeColor(player, itemId, newColor)
        warn("HandleChangeColor not implemented!")
    end
    function GameManager.GetPlayerInventory(player)
        local userId = player.UserId
        local pdata = playerData[userId]
        if not pdata then
            return { success = false, message = "Player data not found." }
        end
        return { success = true, inventory = pdata.inventory, currency = pdata.currency }
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
    -- Client will only use Remotes/Functions and Constants
    GameManager.Remotes = ReplicatedStorage:WaitForChild("Remotes")
    GameManager.Constants = Constants
end

return GameManager