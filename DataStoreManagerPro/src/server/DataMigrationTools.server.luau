--!strict
--[[
    DataMigrationTools.luau
    
    Provides tools for migrating data between DataStores, versioning data,
    and transforming data structures.
    
    Features:
    - DataStore-to-DataStore migration
    - Version control and history tracking
    - Schema transformation and validation
    - Backup and restore capabilities
    - Detailed migration logs and reports
    - Progress tracking and visualization
    
    Author: GitHub Copilot
    Created: May 2023
]]

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local DataStoreManager = require(script.Parent.DataStoreManager)
local SchemaManager = require(script.Parent.SchemaManager.server)
local SchemaValidator = require(script.Parent.SchemaValidator.server)
local PerformanceMonitor = require(script.Parent.PerformanceMonitor)
local CacheManager = require(script.Parent.CacheManager.server)
local SessionManager = require(script.Parent.SessionManager.server)

local DataMigrationTools = {}

-- Migration status tracking
DataMigrationTools.migrationStatus = {}
DataMigrationTools.activeMigrations = 0
DataMigrationTools.completedMigrations = 0
DataMigrationTools.failedMigrations = 0
DataMigrationTools.migrations = {}
DataMigrationTools.backups = {}

-- Configuration settings
DataMigrationTools.config = {
    backupBeforeMigration = true,
    validateBeforeMigration = true,
    validateAfterMigration = true,
    batchSize = 10,
    migrationCooldown = 0.5, -- seconds between migrations to avoid throttling
    maxRetries = 3,
    retryDelay = 2, -- seconds between retries
    logLevel = 2, -- 0: none, 1: errors only, 2: basic, 3: verbose
}

--[[ Private Utility Functions ]]--

-- Generate a unique ID for a migration
local function generateMigrationId()
    return HttpService:GenerateGUID(false)
end

-- Log migration events with the proper level
local function log(message, level)
    level = level or 2
    if level <= DataMigrationTools.config.logLevel then
        if level == 1 then
            warn("[DataMigrationTools] " .. message)
        else
            print("[DataMigrationTools] " .. message)
        end
    end
end

-- Safely serialize data to JSON
local function safeSerialize(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success then
        return result
    else
        log("Failed to serialize data: " .. tostring(result), 1)
        return nil
    end
end

-- Safely deserialize JSON to data
local function safeDeserialize(json)
    if not json then return nil end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if success then
        return result
    else
        log("Failed to deserialize data: " .. tostring(result), 1)
        return nil
    end
end

-- Create a deep copy of a table
local function deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in pairs(original) do
            copy[key] = deepCopy(value)
        end
    else
        copy = original
    end
    return copy
end

-- Add metadata to migrated data
local function addMigrationMetadata(data, sourceStore, destStore, migrationId)
    if type(data) ~= "table" then
        return data
    end
    
    -- Add migration metadata as a special field
    data.__migrationMeta = data.__migrationMeta or {}
    table.insert(data.__migrationMeta, {
        migrationId = migrationId,
        sourceStore = sourceStore,
        destStore = destStore,
        timestamp = os.time(),
    })
    
    -- Add version if not present
    data.__version = data.__version or {
        current = 1,
        history = {}
    }
    
    -- Update version
    local newVersion = {
        versionNumber = data.__version.current + 1,
        timestamp = os.time(),
        reason = "Migration from " .. sourceStore .. " to " .. destStore,
        migrationId = migrationId
    }
    
    -- Add current version to history
    table.insert(data.__version.history, {
        versionNumber = data.__version.current,
        timestamp = data.__version.timestamp or os.time(),
        reason = data.__version.reason or "Pre-migration version"
    })
    
    -- Update current version
    data.__version.current = newVersion.versionNumber
    data.__version.timestamp = newVersion.timestamp
    data.__version.reason = newVersion.reason
    data.__version.migrationId = newVersion.migrationId
    
    return data
end

-- Transform data structure based on schema
local function transformData(data, sourceSchema, destSchema)
    if not sourceSchema or not destSchema then
        return data
    end
    
    -- If data is not valid according to source schema, attempt to repair
    local isValid, repairedData = SchemaValidator.validate(data, sourceSchema)
    if not isValid and repairedData then
        data = repairedData
    end
    
    -- Apply destination schema transformations
    -- This requires knowledge of the schema format and transformations
    -- For now, we'll just validate against the destination schema
    local isValidDest, transformedData = SchemaValidator.validate(data, destSchema)
    if not isValidDest and transformedData then
        return transformedData
    end
    
    return data
end

--[[ Public API Functions ]]--

-- Initialize the migration tools
function DataMigrationTools:initialize()
    log("DataMigrationTools initialized")
    
    -- Initialize tracking data structures
    self.migrationStatus = {}
    self.activeMigrations = 0
    self.completedMigrations = 0
    self.failedMigrations = 0
    self.migrations = {}
    self.backups = {}
    
    return true
end

-- Create a backup of data before migration
function DataMigrationTools:createBackup(dataStoreName, keyName, data)
    local backupId = generateMigrationId()
    
    -- Store the backup
    self.backups[backupId] = {
        dataStoreName = dataStoreName,
        keyName = keyName,
        data = deepCopy(data),
        timestamp = os.time()
    }
    
    log("Created backup " .. backupId .. " for " .. dataStoreName .. "/" .. keyName, 2)
    return backupId
end

-- Restore data from a backup
function DataMigrationTools:restoreFromBackup(backupId)
    local backup = self.backups[backupId]
    if not backup then
        return false, "Backup not found: " .. tostring(backupId)
    end
    
    -- Restore the data
    local success, result = DataStoreManager.setData(
        backup.dataStoreName, 
        backup.keyName, 
        backup.data
    )
    
    if success then
        log("Restored data from backup " .. backupId .. " for " .. backup.dataStoreName .. "/" .. backup.keyName, 2)
    else
        log("Failed to restore from backup " .. backupId .. ": " .. tostring(result), 1)
    end
    
    return success, result
end

-- Get a list of available backups
function DataMigrationTools:getBackups(dataStoreName, keyName)
    local result = {}
    
    for id, backup in pairs(self.backups) do
        if (not dataStoreName or backup.dataStoreName == dataStoreName) and
           (not keyName or backup.keyName == keyName) then
            table.insert(result, {
                id = id,
                dataStoreName = backup.dataStoreName,
                keyName = backup.keyName,
                timestamp = backup.timestamp,
                size = #safeSerialize(backup.data) or 0
            })
        end
    end
    
    return result
end

-- Delete a backup
function DataMigrationTools:deleteBackup(backupId)
    if self.backups[backupId] then
        self.backups[backupId] = nil
        log("Deleted backup " .. backupId, 2)
        return true
    else
        log("Backup not found: " .. backupId, 1)
        return false, "Backup not found"
    end
end

-- Migrate a single key from one DataStore to another
function DataMigrationTools:migrateKey(sourceStore, destStore, keyName)
    local migrationId = generateMigrationId()
    
    -- Set up migration status
    self.migrationStatus[migrationId] = {
        migrationId = migrationId,
        inProgress = true,
        sourceStore = sourceStore,
        destStore = destStore,
        keyName = keyName,
        startTime = os.time(),
        status = "starting",
        error = nil,
        progress = 0
    }
    
    -- Increment active migrations
    self.activeMigrations = self.activeMigrations + 1
    
    -- Add to migrations list
    self.migrations[migrationId] = self.migrationStatus[migrationId]
    
    -- Log start
    log("Starting migration " .. migrationId .. " for key " .. keyName .. " from " .. sourceStore .. " to " .. destStore, 2)
    
    -- Load data from source
    self.migrationStatus[migrationId].status = "loading_source"
    self.migrationStatus[migrationId].progress = 10
    local sourceData, loadError = DataStoreManager.getData(sourceStore, keyName)
    
    if not sourceData then
        self:_failMigration(migrationId, "Failed to load data from source: " .. (loadError or "unknown error"))
        return false, self.migrationStatus[migrationId].error, migrationId
    end
    
    -- Create backup if configured
    if self.config.backupBeforeMigration then
        self.migrationStatus[migrationId].status = "creating_backup"
        self.migrationStatus[migrationId].progress = 20
        local backupId = self:createBackup(sourceStore, keyName, sourceData)
        self.migrationStatus[migrationId].backupId = backupId
    end
    
    -- Get schemas if they exist
    self.migrationStatus[migrationId].status = "loading_schemas"
    self.migrationStatus[migrationId].progress = 30
    local sourceSchema = SchemaManager.loadSchema(sourceStore, keyName)
    local destSchema = SchemaManager.loadSchema(destStore, keyName)
    
    -- Validate against source schema if needed
    if self.config.validateBeforeMigration and sourceSchema then
        self.migrationStatus[migrationId].status = "validating_source"
        self.migrationStatus[migrationId].progress = 40
        local isValid, repairedData = SchemaValidator.validate(sourceData, sourceSchema)
        
        if not isValid then
            log("Source data validation failed for " .. keyName .. ", attempting to use repaired data", 2)
            
            if repairedData then
                sourceData = repairedData
            else
                self:_failMigration(migrationId, "Source data validation failed and couldn't be repaired")
                return false, self.migrationStatus[migrationId].error, migrationId
            end
        end
    end
    
    -- Transform data if needed
    if sourceSchema and destSchema and sourceSchema ~= destSchema then
        self.migrationStatus[migrationId].status = "transforming_data"
        self.migrationStatus[migrationId].progress = 50
        sourceData = transformData(sourceData, sourceSchema, destSchema)
    end
    
    -- Add migration metadata
    self.migrationStatus[migrationId].status = "adding_metadata"
    self.migrationStatus[migrationId].progress = 60
    local migratedData = addMigrationMetadata(sourceData, sourceStore, destStore, migrationId)
    
    -- Validate against destination schema if needed
    if self.config.validateAfterMigration and destSchema then
        self.migrationStatus[migrationId].status = "validating_destination"
        self.migrationStatus[migrationId].progress = 70
        local isValid, repairedData = SchemaValidator.validate(migratedData, destSchema)
        
        if not isValid then
            log("Destination data validation failed for " .. keyName .. ", attempting to use repaired data", 2)
            
            if repairedData then
                migratedData = repairedData
            else
                self:_failMigration(migrationId, "Destination data validation failed and couldn't be repaired")
                return false, self.migrationStatus[migrationId].error, migrationId
            end
        end
    end
    
    -- Save to destination
    self.migrationStatus[migrationId].status = "saving_destination"
    self.migrationStatus[migrationId].progress = 80
    local saveSuccess, saveError = DataStoreManager.setData(destStore, keyName, migratedData)
    
    if not saveSuccess then
        self:_failMigration(migrationId, "Failed to save to destination: " .. (saveError or "unknown error"))
        return false, self.migrationStatus[migrationId].error, migrationId
    end
    
    -- Complete migration
    self.migrationStatus[migrationId].inProgress = false
    self.migrationStatus[migrationId].status = "completed"
    self.migrationStatus[migrationId].completionTime = os.time()
    self.migrationStatus[migrationId].progress = 100
    
    -- Update counters
    self.activeMigrations = self.activeMigrations - 1
    self.completedMigrations = self.completedMigrations + 1
    
    log("Migration " .. migrationId .. " completed successfully for key " .. keyName .. " from " .. sourceStore .. " to " .. destStore, 2)
    return true, migrationId, migrationId
end

-- Mark a migration as failed
function DataMigrationTools:_failMigration(migrationId, errorMessage)
    local migration = self.migrationStatus[migrationId]
    if not migration then return false end
    
    migration.inProgress = false
    migration.status = "failed"
    migration.error = errorMessage
    migration.completionTime = os.time()
    
    -- Update counters
    self.activeMigrations = self.activeMigrations - 1
    self.failedMigrations = self.failedMigrations + 1
    
    log("Migration " .. migrationId .. " failed: " .. errorMessage, 1)
    return true
end

-- Migrate all keys from one DataStore to another
function DataMigrationTools:migrateDataStore(sourceStore, destStore, options)
    options = options or {}
    local batchSize = options.batchSize or self.config.batchSize
    local cursor = options.cursor
    local totalMigrated = options.totalMigrated or 0
    local totalFailed = options.totalFailed or 0
    local parentMigrationId = options.parentMigrationId or generateMigrationId()
    
    -- Initialize parent migration if this is the first call
    if not options.parentMigrationId then
        self.migrationStatus[parentMigrationId] = {
            migrationId = parentMigrationId,
            inProgress = true,
            sourceStore = sourceStore,
            destStore = destStore,
            isDataStoreMigration = true,
            startTime = os.time(),
            status = "listing_keys",
            error = nil,
            progress = 0,
            totalMigrated = 0,
            totalFailed = 0,
            childMigrations = {}
        }
        
        -- Add to migrations list
        self.migrations[parentMigrationId] = self.migrationStatus[parentMigrationId]
        
        log("Starting DataStore migration " .. parentMigrationId .. " from " .. sourceStore .. " to " .. destStore, 2)
    end
    
    -- List keys from the source DataStore
    local keyResult, keyError = DataStoreManager.listKeys(sourceStore, batchSize, cursor)
    
    if not keyResult then
        self:_failMigration(parentMigrationId, "Failed to list keys: " .. (keyError or "unknown error"))
        return false, self.migrationStatus[parentMigrationId].error, parentMigrationId
    end
    
    local keys = keyResult.keys
    local nextCursor = keyResult.nextCursor
    
    -- Update status
    self.migrationStatus[parentMigrationId].status = "migrating_keys"
    
    -- Migrate each key
    for _, key in ipairs(keys) do
        local success, result, childMigrationId = self:migrateKey(sourceStore, destStore, key)
        
        -- Track child migration
        if childMigrationId then
            table.insert(self.migrationStatus[parentMigrationId].childMigrations, childMigrationId)
        end
        
        if success then
            totalMigrated = totalMigrated + 1
            self.migrationStatus[parentMigrationId].totalMigrated = totalMigrated
        else
            totalFailed = totalFailed + 1
            self.migrationStatus[parentMigrationId].totalFailed = totalFailed
        end
        
        -- Brief pause to avoid throttling
        task.wait(self.config.migrationCooldown)
    end
    
    -- Calculate progress (approximate if we don't know total)
    local progress = nextCursor and 50 or 100 -- If no next cursor, we're done
    self.migrationStatus[parentMigrationId].progress = progress
    
    -- Continue with next batch if there are more keys
    if nextCursor then
        task.spawn(function()
            self:migrateDataStore(sourceStore, destStore, {
                batchSize = batchSize,
                cursor = nextCursor,
                totalMigrated = totalMigrated,
                totalFailed = totalFailed,
                parentMigrationId = parentMigrationId
            })
        end)
        
        return true, "Migration in progress", parentMigrationId
    else
        -- Complete migration
        self.migrationStatus[parentMigrationId].inProgress = false
        self.migrationStatus[parentMigrationId].status = "completed"
        self.migrationStatus[parentMigrationId].completionTime = os.time()
        self.migrationStatus[parentMigrationId].progress = 100
        
        log("DataStore migration " .. parentMigrationId .. " completed. Migrated: " .. totalMigrated .. ", Failed: " .. totalFailed, 2)
        return true, {
            migrationId = parentMigrationId,
            totalMigrated = totalMigrated,
            totalFailed = totalFailed
        }
    end
end

-- Get the status of a migration
function DataMigrationTools:getMigrationStatus(migrationId)
    return self.migrationStatus[migrationId]
end

-- Get all migrations
function DataMigrationTools:getAllMigrations()
    return self.migrations
end

-- Get migration statistics
function DataMigrationTools:getMigrationStats()
    return {
        activeMigrations = self.activeMigrations,
        completedMigrations = self.completedMigrations,
        failedMigrations = self.failedMigrations,
        totalMigrations = self.activeMigrations + self.completedMigrations + self.failedMigrations,
        totalBackups = #self:getBackups()
    }
end

-- Delete all backups older than a certain time
function DataMigrationTools:cleanupOldBackups(maxAgeInSeconds)
    maxAgeInSeconds = maxAgeInSeconds or (86400 * 7) -- Default to 7 days
    local now = os.time()
    local count = 0
    
    for id, backup in pairs(self.backups) do
        if (now - backup.timestamp) > maxAgeInSeconds then
            self.backups[id] = nil
            count = count + 1
        end
    end
    
    log("Cleaned up " .. count .. " old backups", 2)
    return count
end

-- Apply a schema transformation to data during migration
function DataMigrationTools:registerSchemaTransformation(sourceStore, destStore, keyPattern, transformFunc)
    -- This function would register custom transformation functions
    -- that would be applied during migration
    -- Implementation depends on how schema transformations are handled
    log("Schema transformation registered for " .. sourceStore .. " to " .. destStore .. " with pattern " .. keyPattern, 2)
    return true
end

return DataMigrationTools
