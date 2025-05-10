local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
-- Types module is imported but not used, so removing it

local DataStoreManager = {}

-- Cache for player data and placed objects
local playerData = {}
local placedObjects = {}

-- Initialize DataStores
local playerDataStore = DataStoreService:GetDataStore(Constants.DATASTORE_KEYS.PLAYER_INVENTORY)
local placedObjectsStore = DataStoreService:GetDataStore(Constants.DATASTORE_KEYS.PLACED_OBJECTS)

-- Save player data
function DataStoreManager.savePlayerData(userId, data)
    local success, err = pcall(function()
        playerDataStore:SetAsync(tostring(userId), data)
    end)
    
    if not success then
        warn("Failed to save player data for user", userId, ":", err)
        return false
    end
    
    -- Update the cache
    playerData[userId] = data
    
    return true
end

-- Load player data
function DataStoreManager.loadPlayerData(userId)
    local success, data = pcall(function()
        return playerDataStore:GetAsync(tostring(userId))
    end)
    
    if not success then
        warn("Failed to load player data for user", userId, ":", data)
        return nil
    end
    
    -- Update the cache
    playerData[userId] = data
    
    return data
end

-- Save placed objects
function DataStoreManager.savePlacedObjects(objects)
    local success, err = pcall(function()
        placedObjectsStore:SetAsync("all", objects)
    end)
    
    if not success then
        warn("Failed to save placed objects:", err)
        return false
    end
    
    -- Update the cache
    placedObjects = objects
    
    return true
end

-- Load placed objects
function DataStoreManager.loadPlacedObjects()
    local success, data = pcall(function()
        return placedObjectsStore:GetAsync("all")
    end)
    
    if not success then
        warn("Failed to load placed objects:", data)
        return {}
    end
    
    -- Update the cache
    placedObjects = data or {}
    
    return placedObjects
end

-- Auto-save system
local function startAutoSave()
    while true do
        wait(300) -- Save every 5 minutes
        
        -- Save all player data
        for userId, data in pairs(playerData) do
            DataStoreManager.savePlayerData(userId, data)
        end
        
        -- Save placed objects
        DataStoreManager.savePlacedObjects(placedObjects)
    end
end

-- Initialize
function DataStoreManager.init()
    -- Start auto-save system
    task.spawn(startAutoSave)
    print("DataStore manager initialized")
end

return DataStoreManager 