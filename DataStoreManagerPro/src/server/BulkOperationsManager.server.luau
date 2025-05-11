--luau
-- DataStore Plugin/BulkOperationsManager.luau

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local DataStoreManager = require(script.Parent.DataStoreManager)
local CacheManager = require(script.Parent.CacheManager.server)
local SessionManager = require(script.Parent.SessionManager.server)
local PerformanceMonitor = require(script.Parent.PerformanceMonitor)
local SchemaManager = require(script.Parent.SchemaManager.server)
local SchemaValidator = require(script.Parent.SchemaValidator.server)

local BulkOperationsManager = {}
BulkOperationsManager.sessionId = HttpService:GenerateGUID()

-- Status tracking for bulk operations
local activeOperations = {}

-- Constants
local MAX_BATCH_SIZE = 100 -- Maximum keys to process in a single batch
local DEFAULT_CONCURRENCY = 5 -- Default number of concurrent operations
local REQUEST_INTERVAL = 0.5 -- Time in seconds between requests to avoid throttling

--[[
    Bulk operation status object:
    {
        id = string,            -- Operation ID
        type = string,          -- Operation type (read, write, update, delete)
        dataStoreName = string, -- DataStore name
        keys = {string},        -- Array of keys to process
        started = number,       -- Start time
        completed = number,     -- Completion time (nil if not complete)
        processed = number,     -- Number of keys processed
        successful = number,    -- Number of successful operations
        failed = number,        -- Number of failed operations
        results = {},           -- Results by key
        errors = {},            -- Errors by key
        inProgress = boolean,   -- Whether operation is currently running
        progress = number,      -- Progress percentage (0-100)
        cancelled = boolean     -- Whether operation was cancelled
    }
--]]

-- Generate a unique operation ID
local function generateOperationId()
    return "bulk_" .. HttpService:GenerateGUID()
end

-- Create a new bulk operation status object
local function createOperationStatus(operationType, dataStoreName, keys)
    local id = generateOperationId()
    
    local status = {
        id = id,
        type = operationType,
        dataStoreName = dataStoreName,
        keys = keys,
        started = os.time(),
        completed = nil,
        processed = 0,
        successful = 0,
        failed = 0,
        results = {},
        errors = {},
        inProgress = true,
        progress = 0,
        cancelled = false
    }
    
    activeOperations[id] = status
    return status
end

-- Update operation status
local function updateOperationStatus(status, key, success, result)
    status.processed += 1
    
    if success then
        status.successful += 1
        status.results[key] = result
    else
        status.failed += 1
        status.errors[key] = result
    end
    
    status.progress = math.floor((status.processed / #status.keys) * 100)
    
    -- Check if operation is complete
    if status.processed >= #status.keys then
        status.completed = os.time()
        status.inProgress = false
    end
end

-- Process a batch of keys for reading
local function processBatchRead(status, batch, userId)
    local results = {}
    local errors = {}
    
    for _, key in ipairs(batch) do
        if status.cancelled then
            break
        end
        
        local success, result = DataStoreManager.getData(status.dataStoreName, key, userId)
        updateOperationStatus(status, key, success, success and result or (result or "Unknown error"))
        
        -- Small delay to avoid throttling
        task.wait(REQUEST_INTERVAL)
    end
end

-- Process a batch of keys for writing
local function processBatchWrite(status, batch, dataMap, userId)
    for _, key in ipairs(batch) do
        if status.cancelled then
            break
        end
        
        local data = dataMap[key]
        if data ~= nil then
            local success, result = DataStoreManager.setData(status.dataStoreName, key, data, userId)
            updateOperationStatus(status, key, success, success or (result or "Unknown error"))
        else
            updateOperationStatus(status, key, false, "No data provided for this key")
        end
        
        -- Small delay to avoid throttling
        task.wait(REQUEST_INTERVAL)
    end
end

-- Process a batch of keys for updating
local function processBatchUpdate(status, batch, updateFn, userId)
    for _, key in ipairs(batch) do
        if status.cancelled then
            break
        end
        
        local success, result = DataStoreManager.updateData(status.dataStoreName, key, updateFn, userId)
        updateOperationStatus(status, key, success, success and result or (result or "Unknown error"))
        
        -- Small delay to avoid throttling
        task.wait(REQUEST_INTERVAL)
    end
end

-- Process a batch of keys for deletion
local function processBatchDelete(status, batch, userId)
    for _, key in ipairs(batch) do
        if status.cancelled then
            break
        end
        
        local success, result = DataStoreManager.removeData(status.dataStoreName, key, userId)
        updateOperationStatus(status, key, success, success or (result or "Unknown error"))
        
        -- Small delay to avoid throttling
        task.wait(REQUEST_INTERVAL)
    end
end

-- Split an array into batches
local function splitIntoBatches(array, batchSize)
    local batches = {}
    local currentBatch = {}
    
    for i, item in ipairs(array) do
        table.insert(currentBatch, item)
        
        if #currentBatch >= batchSize or i == #array then
            table.insert(batches, currentBatch)
            currentBatch = {}
        end
    end
    
    if #currentBatch > 0 then
        table.insert(batches, currentBatch)
    end
    
    return batches
end

--[[ Public API Functions ]]--

-- Perform a bulk read operation
function BulkOperationsManager.bulkRead(dataStoreName, keys, options)
    options = options or {}
    local userId = options.userId
    local concurrency = options.concurrency or DEFAULT_CONCURRENCY
    local batchSize = options.batchSize or math.min(MAX_BATCH_SIZE, 100)
    
    -- Create status object
    local status = createOperationStatus("read", dataStoreName, keys)
    
    -- Process keys in batches
    task.spawn(function()
        local batches = splitIntoBatches(keys, batchSize)
        local activeTasks = 0
        local batchIndex = 1
        
        -- Process batches with concurrency control
        while batchIndex <= #batches and not status.cancelled do
            if activeTasks < concurrency then
                activeTasks += 1
                
                local currentBatch = batches[batchIndex]
                batchIndex += 1
                
                task.spawn(function()
                    processBatchRead(status, currentBatch, userId)
                    activeTasks -= 1
                end)
            else
                task.wait(0.1) -- Small delay to check again
            end
        end
        
        -- Wait for all tasks to complete
        while activeTasks > 0 and not status.cancelled do
            task.wait(0.1)
        end
        
        -- Ensure status is updated
        if status.cancelled then
            status.inProgress = false
            status.completed = os.time()
        end
    end)
    
    return status.id
end

-- Perform a bulk write operation
function BulkOperationsManager.bulkWrite(dataStoreName, dataMap, options)
    options = options or {}
    local userId = options.userId
    local concurrency = options.concurrency or DEFAULT_CONCURRENCY
    local batchSize = options.batchSize or math.min(MAX_BATCH_SIZE, 50)
    
    -- Extract keys from dataMap
    local keys = {}
    for key, _ in pairs(dataMap) do
        table.insert(keys, key)
    end
    
    -- Create status object
    local status = createOperationStatus("write", dataStoreName, keys)
    
    -- Process keys in batches
    task.spawn(function()
        local batches = splitIntoBatches(keys, batchSize)
        local activeTasks = 0
        local batchIndex = 1
        
        -- Process batches with concurrency control
        while batchIndex <= #batches and not status.cancelled do
            if activeTasks < concurrency then
                activeTasks += 1
                
                local currentBatch = batches[batchIndex]
                batchIndex += 1
                
                task.spawn(function()
                    processBatchWrite(status, currentBatch, dataMap, userId)
                    activeTasks -= 1
                end)
            else
                task.wait(0.1) -- Small delay to check again
            end
        end
        
        -- Wait for all tasks to complete
        while activeTasks > 0 and not status.cancelled do
            task.wait(0.1)
        end
        
        -- Ensure status is updated
        if status.cancelled then
            status.inProgress = false
            status.completed = os.time()
        end
    end)
    
    return status.id
end

-- Perform a bulk update operation
function BulkOperationsManager.bulkUpdate(dataStoreName, keys, updateFunction, options)
    options = options or {}
    local userId = options.userId
    local concurrency = options.concurrency or DEFAULT_CONCURRENCY
    local batchSize = options.batchSize or math.min(MAX_BATCH_SIZE, 50)
    
    if type(updateFunction) ~= "function" then
        error("BulkOperationsManager.bulkUpdate requires an update function")
    end
    
    -- Create status object
    local status = createOperationStatus("update", dataStoreName, keys)
    
    -- Process keys in batches
    task.spawn(function()
        local batches = splitIntoBatches(keys, batchSize)
        local activeTasks = 0
        local batchIndex = 1
        
        -- Process batches with concurrency control
        while batchIndex <= #batches and not status.cancelled do
            if activeTasks < concurrency then
                activeTasks += 1
                
                local currentBatch = batches[batchIndex]
                batchIndex += 1
                
                task.spawn(function()
                    processBatchUpdate(status, currentBatch, updateFunction, userId)
                    activeTasks -= 1
                end)
            else
                task.wait(0.1) -- Small delay to check again
            end
        end
        
        -- Wait for all tasks to complete
        while activeTasks > 0 and not status.cancelled do
            task.wait(0.1)
        end
        
        -- Ensure status is updated
        if status.cancelled then
            status.inProgress = false
            status.completed = os.time()
        end
    end)
    
    return status.id
end

-- Perform a bulk delete operation
function BulkOperationsManager.bulkDelete(dataStoreName, keys, options)
    options = options or {}
    local userId = options.userId
    local concurrency = options.concurrency or DEFAULT_CONCURRENCY
    local batchSize = options.batchSize or math.min(MAX_BATCH_SIZE, 50)
    
    -- Create status object
    local status = createOperationStatus("delete", dataStoreName, keys)
    
    -- Process keys in batches
    task.spawn(function()
        local batches = splitIntoBatches(keys, batchSize)
        local activeTasks = 0
        local batchIndex = 1
        
        -- Process batches with concurrency control
        while batchIndex <= #batches and not status.cancelled do
            if activeTasks < concurrency then
                activeTasks += 1
                
                local currentBatch = batches[batchIndex]
                batchIndex += 1
                
                task.spawn(function()
                    processBatchDelete(status, currentBatch, userId)
                    activeTasks -= 1
                end)
            else
                task.wait(0.1) -- Small delay to check again
            end
        end
        
        -- Wait for all tasks to complete
        while activeTasks > 0 and not status.cancelled do
            task.wait(0.1)
        end
        
        -- Ensure status is updated
        if status.cancelled then
            status.inProgress = false
            status.completed = os.time()
        end
    end)
    
    return status.id
end

-- Apply a function or a schema transformation to keys matching a prefix
function BulkOperationsManager.bulkTransform(dataStoreName, prefix, transformFunction, options)
    options = options or {}
    local userId = options.userId
    local batchSize = options.batchSize or math.min(MAX_BATCH_SIZE, 50)
    
    -- First, list all keys matching the prefix
    local success, result = DataStoreManager.listKeys(dataStoreName, 100, nil, userId)
    
    if not success or not result or not result.keys then
        return nil, "Failed to list keys: " .. tostring(result)
    end
    
    -- Filter keys by prefix if provided
    local keys = {}
    if prefix and prefix ~= "" then
        for _, keyInfo in ipairs(result.keys) do
            if string.sub(keyInfo.KeyName, 1, #prefix) == prefix then
                table.insert(keys, keyInfo.KeyName)
            end
        end
    else
        for _, keyInfo in ipairs(result.keys) do
            table.insert(keys, keyInfo.KeyName)
        end
    end
    
    -- Start the bulk update operation
    return BulkOperationsManager.bulkUpdate(dataStoreName, keys, transformFunction, options)
end

-- Apply a schema to all keys in a DataStore
function BulkOperationsManager.bulkSchemaValidate(dataStoreName, schemaId, options)
    options = options or {}
    local userId = options.userId
    
    -- Load the schema
    local schema = SchemaManager.getSchema(schemaId)
    if not schema then
        return nil, "Schema not found: " .. tostring(schemaId)
    end
    
    -- Create a validation function
    local function validateAndTransform(data)
        if not data then
            return nil
        end
        
        local isValid, result = SchemaValidator.validate(data, schema)
        if not isValid then
            error("Schema validation failed: " .. tostring(result))
        end
        
        return result
    end
    
    -- Use the bulkTransform function
    return BulkOperationsManager.bulkTransform(dataStoreName, "", validateAndTransform, options)
end

-- Find keys containing specific values
function BulkOperationsManager.findKeysByValue(dataStoreName, matchFunction, options)
    options = options or {}
    local userId = options.userId
    local maxResults = options.maxResults or 100
    local batchSize = options.batchSize or math.min(MAX_BATCH_SIZE, 50)
    
    -- First, list all keys
    local success, result = DataStoreManager.listKeys(dataStoreName, 100, nil, userId)
    
    if not success or not result or not result.keys then
        return nil, "Failed to list keys: " .. tostring(result)
    end
    
    -- Extract just the key names
    local allKeys = {}
    for _, keyInfo in ipairs(result.keys) do
        table.insert(allKeys, keyInfo.KeyName)
    end
    
    -- Create status object
    local status = createOperationStatus("find", dataStoreName, allKeys)
    
    -- Use a special array to store matching keys
    status.matchingKeys = {}
    
    -- Function to process a batch for finding
    local function processBatchFind(status, batch)
        for _, key in ipairs(batch) do
            if status.cancelled or #status.matchingKeys >= maxResults then
                break
            end
            
            local success, data = DataStoreManager.getData(status.dataStoreName, key)
            
            if success and data then
                local isMatch = pcall(function()
                    return matchFunction(data, key)
                end)
                
                if isMatch then
                    table.insert(status.matchingKeys, {key = key, data = data})
                end
            end
            
            updateOperationStatus(status, key, success, success or "Failed to read data")
            
            -- Small delay to avoid throttling
            task.wait(REQUEST_INTERVAL)
        end
    end
    
    -- Process keys in batches
    task.spawn(function()
        local batches = splitIntoBatches(allKeys, batchSize)
        
        for i, batch in ipairs(batches) do
            if status.cancelled or #status.matchingKeys >= maxResults then
                break
            end
            
            processBatchFind(status, batch)
        end
        
        status.completed = os.time()
        status.inProgress = false
    end)
    
    return status.id
end

-- Get the status of a bulk operation
function BulkOperationsManager.getOperationStatus(operationId)
    return activeOperations[operationId]
end

-- Get all active bulk operations
function BulkOperationsManager.getActiveOperations()
    local result = {}
    
    for id, status in pairs(activeOperations) do
        if status.inProgress then
            table.insert(result, status)
        end
    end
    
    return result
end

-- Cancel a bulk operation
function BulkOperationsManager.cancelOperation(operationId)
    local status = activeOperations[operationId]
    
    if status and status.inProgress then
        status.cancelled = true
        return true
    end
    
    return false
end

-- Clear completed operations from memory
function BulkOperationsManager.clearCompletedOperations(maxAgeInMinutes)
    maxAgeInMinutes = maxAgeInMinutes or 60 -- Default to 1 hour
    local now = os.time()
    local maxAgeInSeconds = maxAgeInMinutes * 60
    
    local keysToRemove = {}
    
    for id, status in pairs(activeOperations) do
        if not status.inProgress and status.completed and (now - status.completed) > maxAgeInSeconds then
            table.insert(keysToRemove, id)
        end
    end
    
    for _, id in ipairs(keysToRemove) do
        activeOperations[id] = nil
    end
    
    return #keysToRemove
end

-- Initialize the module
function BulkOperationsManager.initialize()
    print("BulkOperationsManager initialized with session ID:", BulkOperationsManager.sessionId)
    
    -- Start a periodic cleanup task
    task.spawn(function()
        while true do
            task.wait(3600) -- Every hour
            BulkOperationsManager.clearCompletedOperations()
        end
    end)
end

return BulkOperationsManager
