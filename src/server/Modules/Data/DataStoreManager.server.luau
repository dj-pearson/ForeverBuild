local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

local DATASTORE_NAME = Constants.DataStoreNames.PlayerData
local WORLD_DATASTORE_NAME = Constants.DataStoreNames.WorldObjects
local BACKUP_DATASTORE_NAME = Constants.DataStoreNames.PlayerDataBackup
local DataStoreManager = {}
DataStoreManager.__index = DataStoreManager

-- Constants
local MAX_RETRIES = Constants.RetrySettings.MaxRetries
local RETRY_DELAY = Constants.RetrySettings.RetryDelay
local BACKUP_INTERVAL = Constants.RetrySettings.BackupInterval
local DATA_VERSION = Constants.DataVersions.PlayerData

-- Cache
local playerCache = {}
local worldObjectsCache = {}
local lastBackupTime = {}

-- Data validation schemas
local PlayerDataSchema = {
    coins = "number",
    inventory = "table",
    tutorialComplete = "boolean",
    lastLogin = "number",
    version = "number"
}

local WorldObjectsSchema = {
    objects = "table",
    lastUpdate = "number",
    version = "number"
}

-- Utility: Deep copy
local function deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = deepCopy(v)
    end
    return copy
end

-- Utility: Validate data against schema
local function validateData(data, schema)
    for field, expectedType in pairs(schema) do
        if type(data[field]) ~= expectedType then
            return false, string.format("Invalid type for field %s: expected %s, got %s", 
                field, expectedType, type(data[field]))
        end
    end
    return true
end

-- Utility: Create default data
local function createDefaultPlayerData()
    return {
        coins = 0,
        inventory = {},
        tutorialComplete = false,
        lastLogin = os.time(),
        version = DATA_VERSION
    }
end

local function createDefaultWorldData()
    return {
        objects = {},
        lastUpdate = os.time(),
        version = DATA_VERSION
    }
end

-- Utility: Migrate data if needed
local function migrateData(data, currentVersion)
    if data.version == currentVersion then
        return data
    end
    
    Logger:info("Migrating data", { fromVersion = data.version, toVersion = currentVersion })
    
    -- Add migration logic here as needed
    data.version = currentVersion
    return data
end

-- Enhanced retry logic with exponential backoff
local function retryOperation(operation, maxRetries)
    maxRetries = maxRetries or MAX_RETRIES
    local retries = 0
    local success, result
    local delay = RETRY_DELAY

    repeat
        success, result = pcall(operation)
        if not success then
            retries = retries + 1
            if retries < maxRetries then
                task.wait(delay)
                delay = delay * 2 -- Exponential backoff
            end
        end
    until success or retries >= maxRetries

    return success, result
end

-- Backup data
local function backupPlayerData(player)
    local dataStore = DataStoreService:GetDataStore(BACKUP_DATASTORE_NAME)
    local key = tostring(player.UserId)
    local data = playerCache[player.UserId]
    
    if not data then return end
    
    local success, err = retryOperation(function()
        dataStore:SetAsync(key, {
            data = data,
            timestamp = os.time()
        })
    end)
    
    if success then
        lastBackupTime[player.UserId] = os.time()
        Logger:info("Player data backed up", { playerId = player.UserId })
    else
        Logger:error("Failed to backup player data", { 
            playerId = player.UserId,
            error = err
        })
    end
end

-- Load player data with enhanced error handling
function DataStoreManager.LoadPlayerData(player)
    local dataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
    local backupStore = DataStoreService:GetDataStore(BACKUP_DATASTORE_NAME)
    local key = tostring(player.UserId)
    local data
    
    -- Try loading from main datastore
    local success, result = retryOperation(function()
        return dataStore:GetAsync(key)
    end)
    
    if success and result then
        data = result
    else
        -- Try loading from backup
        Logger:warn("Failed to load from main datastore, trying backup", { 
            playerId = player.UserId,
            error = result
        })
        
        success, result = retryOperation(function()
            return backupStore:GetAsync(key)
        end)
        
        if success and result and result.data then
            data = result.data
            Logger:info("Loaded data from backup", { playerId = player.UserId })
        else
            Logger:error("Failed to load player data from both stores", { 
                playerId = player.UserId,
                error = result
            })
            data = createDefaultPlayerData()
        end
    end
    
    -- Validate and migrate data
    local isValid, errorMsg = validateData(data, PlayerDataSchema)
    if not isValid then
        Logger:error("Invalid player data", { 
            playerId = player.UserId,
            error = errorMsg
        })
        data = createDefaultPlayerData()
    else
        data = migrateData(data, DATA_VERSION)
    end
    
    playerCache[player.UserId] = data
    return deepCopy(data)
end

-- Save player data with enhanced error handling
function DataStoreManager.SavePlayerData(player)
    local dataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
    local key = tostring(player.UserId)
    local data = playerCache[player.UserId]
    
    if not data then
        Logger:warn("No data to save for player", { playerId = player.UserId })
        return
    end
    
    local success, err = retryOperation(function()
        dataStore:SetAsync(key, data)
    end)
    
    if success then
        Logger:info("Player data saved", { playerId = player.UserId })
        -- Backup after successful save
        backupPlayerData(player)
    else
        Logger:error("Failed to save player data", { 
            playerId = player.UserId,
            error = err
        })
    end
end

-- Initialize
function DataStoreManager.Initialize()
    -- Set up player handling
    Players.PlayerAdded:Connect(function(player)
        local data = DataStoreManager.LoadPlayerData(player)
        playerCache[player.UserId] = data
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        DataStoreManager.SavePlayerData(player)
        playerCache[player.UserId] = nil
        lastBackupTime[player.UserId] = nil
    end)
    
    -- Set up periodic backups
    task.spawn(function()
        while true do
            task.wait(BACKUP_INTERVAL)
            for _, player in ipairs(Players:GetPlayers()) do
                if not lastBackupTime[player.UserId] or 
                   os.time() - lastBackupTime[player.UserId] >= BACKUP_INTERVAL then
                    backupPlayerData(player)
                end
            end
        end
    end)
    
    Logger:info("DataStoreManager initialized successfully")
    return true
end

return DataStoreManager 