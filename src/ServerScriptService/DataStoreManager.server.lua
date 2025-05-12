local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreManager = {}
DataStoreManager.__index = DataStoreManager

-- Initialize the DataStoreManager
function DataStoreManager.new()
    local self = setmetatable({}, DataStoreManager)
    self.dataStores = {}
    return self
end

-- Get or create a DataStore
function DataStoreManager:getDataStore(name)
    if not self.dataStores[name] then
        self.dataStores[name] = DataStoreService:GetDataStore(name)
    end
    return self.dataStores[name]
end

-- Save data for a player
function DataStoreManager:saveData(player, data)
    local success, err = pcall(function()
        local dataStore = self:getDataStore("PlayerData")
        dataStore:SetAsync(player.UserId, data)
    end)
    
    if not success then
        warn("Failed to save data for player", player.Name, ":", err)
        return false
    end
    
    return true
end

-- Load data for a player
function DataStoreManager:loadData(player)
    local success, data = pcall(function()
        local dataStore = self:getDataStore("PlayerData")
        return dataStore:GetAsync(player.UserId)
    end)
    
    if not success then
        warn("Failed to load data for player", player.Name, ":", data)
        return nil
    end
    
    return data
end

-- Initialize the DataStoreManager
function DataStoreManager:Initialize()
    -- Set up any necessary initialization
    return true
end

return DataStoreManager.new()
