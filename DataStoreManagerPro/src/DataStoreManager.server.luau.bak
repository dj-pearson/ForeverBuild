--luau
-- DataStore Plugin/DataStoreManager.luau

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- Get module resolver from init script or define a local one
local resolver = script.Parent:FindFirstChild("ModuleResolver")
local resolveModule = resolver and require(resolver).resolveModule or function(name)
    local success, result = pcall(function()
        return require(script.Parent:FindFirstChild(name))
    end)
    
    if success and result then
        return result
    end
    
    warn("Failed to resolve module: " .. name)
    return {
        initialize = function() return true end,
        createUI = function() return Instance.new("Frame") end
    }
end

local CacheManager = resolveModule('CacheManager')
local SchemaManager = resolveModule('SchemaManager')
local SchemaValidator = resolveModule('SchemaValidator')
local SessionManager = resolveModule('SessionManager')
local PerformanceMonitor = resolveModule('PerformanceMonitor')
local SecurityManager = resolveModule('SecurityManager')
local MultiServerCoordination = resolveModule('MultiServerCoordination')

local DataStoreManager = {}
DataStoreManager.sessionId = HttpService:GenerateGUID()

-- Cache DataStore instances to avoid recreating them
local dataStores = {}

-- Get or create a DataStore instance
local function getDataStore(dataStoreName)
    if not dataStores[dataStoreName] then
        dataStores[dataStoreName] = DataStoreService:GetDataStore(dataStoreName)
    end
    return dataStores[dataStoreName]
end

-- Read data from a DataStore with all the plugin features
function DataStoreManager.getData(dataStoreName, keyName, userId)
    -- Check permissions
    if userId and not SecurityManager.hasPermission(userId, "read") then
        return nil, "Insufficient permissions to read data"
    end
    
    -- Try to get data from cache first
    local cachedData = CacheManager.get(dataStoreName, keyName)
    if cachedData then
        return cachedData
    end
    
    -- If not in cache, check if we need to acquire a session lock
    local locked = SessionManager.acquireLock(dataStoreName, keyName, DataStoreManager.sessionId)
    if not locked then
        return nil, "Failed to acquire lock for reading data"
    end
      -- Get data from DataStore
    local success, result = PerformanceMonitor.timeOperation(
        "GetAsync",
        function()
            local dataStore = getDataStore(dataStoreName)
            return dataStore:GetAsync(keyName)
        end,
        dataStoreName,
        keyName
    )
    
    -- Notify multi-server coordination about this data access
    MultiServerCoordination.notifyDataAccess(dataStoreName, keyName, "read")
    
    -- Release the lock if we only acquired it for reading
    SessionManager.releaseLock(dataStoreName, keyName, DataStoreManager.sessionId)
    
    if success then
        -- Validate data against schema if one exists
        local schema = SchemaManager.loadSchema(dataStoreName, keyName)
        if schema then
            local isValid, validatedData = SchemaValidator.validate(result, schema)
            if not isValid then
                warn("DataStoreManager: Data validation failed for", dataStoreName, keyName, validatedData)
                -- validatedData contains the error message in this case
            else
                result = validatedData
            end
        end
        
        -- Store in cache for future use
        CacheManager.set(dataStoreName, keyName, result, 300) -- Cache for 5 minutes
        
        return result
    else
        return nil, result -- Error message
    end
end

-- Write data to a DataStore with all the plugin features
function DataStoreManager.setData(dataStoreName, keyName, data, userId)
    -- Check permissions
    if userId and not SecurityManager.hasPermission(userId, "write") then
        return false, "Insufficient permissions to write data"
    end
    
    -- Validate data against schema if one exists
    local schema = SchemaManager.loadSchema(dataStoreName, keyName)
    if schema then
        local isValid, validatedData = SchemaValidator.validate(data, schema)
        if not isValid then
            return false, "Data validation failed: " .. validatedData
        end
        data = validatedData
    end
    
    -- Acquire a session lock for writing
    local locked = SessionManager.acquireLock(dataStoreName, keyName, DataStoreManager.sessionId)
    if not locked then
        return false, "Failed to acquire lock for writing data"
    end
    
    -- Set data in the DataStore
    local success, result = PerformanceMonitor.timeOperation(
        "SetAsync",
        function()
            local dataStore = getDataStore(dataStoreName)
            return dataStore:SetAsync(keyName, data)
        end,
        dataStoreName,
        keyName
    )
    
    -- Keep the lock active if successful (to be released later) or release it if failed
    if not success then
        SessionManager.releaseLock(dataStoreName, keyName, DataStoreManager.sessionId)
        return false, result
    end
      -- Update cache with the new data
    CacheManager.set(dataStoreName, keyName, data, 300) -- Cache for 5 minutes
    
    -- Notify multi-server coordination about this data access
    MultiServerCoordination.notifyDataAccess(dataStoreName, keyName, "write")
    
    return true
end

-- Update data in a DataStore with all the plugin features
function DataStoreManager.updateData(dataStoreName, keyName, updateFunction, userId)
    -- Check permissions
    if userId and not SecurityManager.hasPermission(userId, "write") then
        return nil, "Insufficient permissions to update data"
    end
    
    -- Acquire a session lock for updating
    local locked = SessionManager.acquireLock(dataStoreName, keyName, DataStoreManager.sessionId)
    if not locked then
        return nil, "Failed to acquire lock for updating data"
    end
    
    -- Get schema if it exists
    local schema = SchemaManager.loadSchema(dataStoreName, keyName)
    
    -- Update data in the DataStore
    local success, result = PerformanceMonitor.timeOperation(
        "UpdateAsync",
        function()
            local dataStore = getDataStore(dataStoreName)
            return dataStore:UpdateAsync(keyName, function(oldData)
                -- Apply the user's update function
                local newData = updateFunction(oldData)
                
                -- Validate new data against schema if one exists
                if schema then
                    local isValid, validatedData = SchemaValidator.validate(newData, schema)
                    if not isValid then
                        warn("DataStoreManager: Data validation failed in UpdateAsync:", validatedData)
                        return nil -- Abort the update
                    end
                    return validatedData
                end
                
                return newData
            end)
        end,
        dataStoreName,
        keyName
    )
    
    -- Release the lock
    SessionManager.releaseLock(dataStoreName, keyName, DataStoreManager.sessionId)
      if success then
        -- Update cache with the new data
        CacheManager.set(dataStoreName, keyName, result, 300) -- Cache for 5 minutes
        
        -- Notify multi-server coordination about this data access
        MultiServerCoordination.notifyDataAccess(dataStoreName, keyName, "write")
        
        return result
    else
        return nil, result -- Error message
    end
end

-- Remove data from a DataStore with all the plugin features
function DataStoreManager.removeData(dataStoreName, keyName, userId)
    -- Check permissions
    if userId and not SecurityManager.hasPermission(userId, "delete") then
        return false, "Insufficient permissions to delete data"
    end
    
    -- Acquire a session lock for deleting
    local locked = SessionManager.acquireLock(dataStoreName, keyName, DataStoreManager.sessionId)
    if not locked then
        return false, "Failed to acquire lock for deleting data"
    end
    
    -- Remove data from the DataStore
    local success, result = PerformanceMonitor.timeOperation(
        "RemoveAsync",
        function()
            local dataStore = getDataStore(dataStoreName)
            return dataStore:RemoveAsync(keyName)
        end,
        dataStoreName,
        keyName
    )
      -- Release the lock
    SessionManager.releaseLock(dataStoreName, keyName, DataStoreManager.sessionId)
    
    -- Invalidate cache
    CacheManager.invalidate(dataStoreName, keyName)
    
    -- Notify multi-server coordination about this data removal
    MultiServerCoordination.notifyDataAccess(dataStoreName, keyName, "delete")
    
    return success, result
end

-- List keys in a DataStore with pagination
function DataStoreManager.listKeys(dataStoreName, pageSize, cursor, userId)
    -- Check permissions
    if userId and not SecurityManager.hasPermission(userId, "read") then
        return nil, "Insufficient permissions to list keys"
    end
    
    -- List keys from the DataStore
    local success, result = PerformanceMonitor.timeOperation(
        "ListKeysAsync",
        function()
            local dataStore = getDataStore(dataStoreName)
            return dataStore:ListKeysAsync(pageSize or 50, cursor)
        end,
        dataStoreName,
        nil
    )
    
    if success then
        return {
            keys = result:GetCurrentPage(),
            nextCursor = result.ExclusiveStartKey
        }
    else
        return nil, result -- Error message
    end
end

-- Initialize the plugin
function DataStoreManager.initialize()
    SessionManager.initialize()
    
    -- Setup a periodic task to optimize the cache
    task.spawn(function()
        while true do
            task.wait(300) -- Every 5 minutes
            CacheManager.optimizeCacheDurations()
        end
    end)
    
    print("DataStoreManager initialized with session ID:", DataStoreManager.sessionId)
end

return DataStoreManager
