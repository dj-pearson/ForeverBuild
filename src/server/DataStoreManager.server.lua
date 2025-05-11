local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreManager = {}
DataStoreManager.__index = DataStoreManager

function DataStoreManager.new()
    local self = setmetatable({}, DataStoreManager)
    self.dataStores = {}
    self.cache = {}
    return self
end

function DataStoreManager:Initialize()
    -- Initialize core data stores
    self.dataStores.PlayerData = DataStoreService:GetDataStore("PlayerData")
    self.dataStores.GameData = DataStoreService:GetDataStore("GameData")
    self.dataStores.Achievements = DataStoreService:GetDataStore("Achievements")
    
    -- Set up error handling
    DataStoreService:OnUpdate("PlayerData", function(key, value)
        self:HandleDataUpdate("PlayerData", key, value)
    end)
end

function DataStoreManager:HandleDataUpdate(storeName, key, value)
    if self.cache[storeName] and self.cache[storeName][key] then
        self.cache[storeName][key] = value
    end
end

function DataStoreManager:GetData(storeName, key)
    if not self.dataStores[storeName] then
        error("Invalid data store: " .. storeName)
    end
    
    -- Check cache first
    if self.cache[storeName] and self.cache[storeName][key] then
        return self.cache[storeName][key]
    end
    
    -- Get from DataStore
    local success, result = pcall(function()
        return self.dataStores[storeName]:GetAsync(key)
    end)
    
    if success then
        -- Cache the result
        if not self.cache[storeName] then
            self.cache[storeName] = {}
        end
        self.cache[storeName][key] = result
        return result
    else
        warn("Failed to get data from " .. storeName .. " for key " .. key .. ": " .. tostring(result))
        return nil
    end
end

function DataStoreManager:SetData(storeName, key, value)
    if not self.dataStores[storeName] then
        error("Invalid data store: " .. storeName)
    end
    
    -- Update cache
    if not self.cache[storeName] then
        self.cache[storeName] = {}
    end
    self.cache[storeName][key] = value
    
    -- Save to DataStore
    local success, result = pcall(function()
        self.dataStores[storeName]:SetAsync(key, value)
    end)
    
    if not success then
        warn("Failed to set data in " .. storeName .. " for key " .. key .. ": " .. tostring(result))
        return false
    end
    
    return true
end

return DataStoreManager
