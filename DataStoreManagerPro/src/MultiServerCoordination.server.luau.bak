--luau
-- DataStore Plugin/MultiServerCoordination.luau

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")

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

local DataStoreManager = resolveModule('DataStoreManager')
local SessionManager = resolveModule('SessionManager')
local DataVisualization = resolveModule('DataVisualization')
local StyleGuide = resolveModule('StyleGuide')

local MultiServerCoordination = {}

-- Constants
local MESSAGE_TOPIC_PREFIX = "DataStorePro_"
local COORDINATION_STORE_NAME = "MultiServerCoordinationStore"
local MESSAGE_TYPES = {
    DATA_ACCESS = "DataAccess",
    LOCK_REQUEST = "LockRequest",
    LOCK_RESPONSE = "LockResponse",
    LOCK_RELEASE = "LockRelease",
    CONFLICT_ALERT = "ConflictAlert",
    CONSISTENCY_CHECK = "ConsistencyCheck",
    CONSISTENCY_RESULT = "ConsistencyResult"
}

-- Internal state
local serverState = {
    serverId = HttpService:GenerateGUID(false),
    activeServers = {},
    dataAccessLog = {},
    activeLocks = {},
    pendingConflicts = {},
    consistencyChecks = {},
    isInitialized = false
}

-- Initialize the Multi-Server Coordination system
function MultiServerCoordination.initialize()
    if serverState.isInitialized then return end
    
    -- Subscribe to messaging service topics
    for _, msgType in pairs(MESSAGE_TYPES) do
        local topic = MESSAGE_TOPIC_PREFIX .. msgType
        
        pcall(function()
            MessagingService:SubscribeAsync(topic, function(message)
                MultiServerCoordination.handleIncomingMessage(msgType, HttpService:JSONDecode(message.Data))
            end)
        end)
    end
    
    -- Register this server with the coordination system
    MultiServerCoordination.registerServer()
    
    -- Setup recurring coordination tasks
    task.spawn(function()
        while true do
            MultiServerCoordination.checkDataConsistency()
            task.wait(60) -- Check every minute
        end
    end)
    
    task.spawn(function()
        while true do
            MultiServerCoordination.refreshActiveServers()
            task.wait(30) -- Refresh every 30 seconds
        end
    end)
    
    serverState.isInitialized = true
end

-- Register this server with the coordination system
function MultiServerCoordination.registerServer()
    local coordinationStore = DataStoreService:GetDataStore(COORDINATION_STORE_NAME)
    local success, serverData = pcall(function()
        return {
            serverId = serverState.serverId,
            lastActive = os.time(),
            playerCount = #game.Players:GetPlayers(),
            placeId = game.PlaceId,
            jobId = game.JobId
        }
    end)
    
    if success then
        -- Save to DataStore so other servers can discover us
        pcall(function()
            coordinationStore:SetAsync("Server_" .. serverState.serverId, serverData)
        end)
        
        -- Broadcast presence to other servers
        pcall(function()
            MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. "ServerRegistry", HttpService:JSONEncode({
                type = "ServerActive",
                server = serverData
            }))
        end)
    end
end

-- Refresh the list of active servers
function MultiServerCoordination.refreshActiveServers()
    local coordinationStore = DataStoreService:GetDataStore(COORDINATION_STORE_NAME)
    
    -- First, update our own timestamp
    pcall(function()
        coordinationStore:UpdateAsync("Server_" .. serverState.serverId, function(oldData)
            if oldData then
                oldData.lastActive = os.time()
                oldData.playerCount = #game.Players:GetPlayers()
                return oldData
            end
            return nil
        end)
    end)
    
    -- Then, try to get a list of active servers
    pcall(function()
        -- Use OrderedDataStore pattern to get a list of servers
        local activeServers = {}
        local pages = coordinationStore:ListKeysAsync()
        
        while true do
            local results = pages:GetCurrentPage()
            for _, result in ipairs(results) do
                if string.find(result.KeyName, "Server_") == 1 then
                    local success, serverData = pcall(function()
                        return coordinationStore:GetAsync(result.KeyName)
                    end)
                    
                    if success and serverData then
                        -- Check if server is still active (within last 2 minutes)
                        if os.time() - serverData.lastActive < 120 then
                            table.insert(activeServers, serverData)
                        else
                            -- Clean up inactive server
                            pcall(function()
                                coordinationStore:RemoveAsync(result.KeyName)
                            end)
                        end
                    end
                end
            end
            
            if pages.IsFinished then
                break
            end
            pages:AdvanceToNextPageAsync()
        end
        
        serverState.activeServers = activeServers
    end)
    
    return serverState.activeServers
end

-- Handle incoming messages from other servers
function MultiServerCoordination.handleIncomingMessage(messageType, data)
    if messageType == MESSAGE_TYPES.DATA_ACCESS then
        -- Another server accessed data
        table.insert(serverState.dataAccessLog, {
            serverId = data.serverId,
            dataStore = data.dataStore,
            key = data.key,
            operation = data.operation,
            timestamp = data.timestamp
        })
        
        -- Check for potential conflicts
        MultiServerCoordination.checkForConflicts(data)
        
    elseif messageType == MESSAGE_TYPES.LOCK_REQUEST then
        -- Another server is requesting a lock
        local alreadyLocked = false
        
        for _, lock in ipairs(serverState.activeLocks) do
            if lock.dataStore == data.dataStore and lock.key == data.key then
                alreadyLocked = true
                break
            end
        end
        
        -- Respond to the lock request
        pcall(function()
            MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.LOCK_RESPONSE, HttpService:JSONEncode({
                requestId = data.requestId,
                dataStore = data.dataStore,
                key = data.key,
                hasLock = alreadyLocked,
                serverId = serverState.serverId
            }))
        end)
        
    elseif messageType == MESSAGE_TYPES.LOCK_RELEASE then
        -- Another server released a lock
        -- This is informational only
        
    elseif messageType == MESSAGE_TYPES.CONFLICT_ALERT then
        -- A conflict was detected
        table.insert(serverState.pendingConflicts, {
            dataStore = data.dataStore,
            key = data.key,
            serverId1 = data.serverId1,
            serverId2 = data.serverId2,
            timestamp = data.timestamp
        })
        
    elseif messageType == MESSAGE_TYPES.CONSISTENCY_CHECK then
        -- Another server is checking for data consistency
        -- Verify our version of the data and respond
        if data.serverId ~= serverState.serverId then
            local success, value = pcall(function()
                local dataStore = DataStoreService:GetDataStore(data.dataStore)
                return dataStore:GetAsync(data.key)
            end)
            
            if success then
                pcall(function()
                    MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.CONSISTENCY_RESULT, HttpService:JSONEncode({
                        checkId = data.checkId,
                        dataStore = data.dataStore,
                        key = data.key,
                        valueHash = HttpService:GenerateGUID(false), -- In a real implementation, this would be a hash of the data
                        serverId = serverState.serverId
                    }))
                end)
            end
        end
    end
end

-- Check for potential conflicts when data is accessed
function MultiServerCoordination.checkForConflicts(accessData)
    -- Look for recent access to the same data
    for _, access in ipairs(serverState.dataAccessLog) do
        -- If different server accessed same data recently (within 5 seconds)
        if access.serverId ~= accessData.serverId and 
           access.dataStore == accessData.dataStore and
           access.key == accessData.key and
           math.abs(access.timestamp - accessData.timestamp) < 5 and
           (access.operation == "write" or accessData.operation == "write") then
            
            -- Potential conflict detected
            local conflictData = {
                dataStore = accessData.dataStore,
                key = accessData.key,
                serverId1 = access.serverId,
                serverId2 = accessData.serverId,
                timestamp = os.time()
            }
            
            table.insert(serverState.pendingConflicts, conflictData)
            
            -- Alert all servers about the conflict
            pcall(function()
                MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.CONFLICT_ALERT, 
                    HttpService:JSONEncode(conflictData))
            end)
            
            break
        end
    end
end

-- Check data consistency across servers
function MultiServerCoordination.checkDataConsistency()
    -- Select some keys to check
    local keysToCheck = {}
    
    -- In a real implementation, we would select keys based on
    -- access patterns, importance, etc.
    
    -- For demonstration, just check the most recently accessed keys
    for i = 1, math.min(5, #serverState.dataAccessLog) do
        local access = serverState.dataAccessLog[#serverState.dataAccessLog - (i - 1)]
        table.insert(keysToCheck, {
            dataStore = access.dataStore,
            key = access.key
        })
    end
    
    -- Initiate consistency check for each key
    for _, keyInfo in ipairs(keysToCheck) do
        local checkId = HttpService:GenerateGUID(false)
        
        serverState.consistencyChecks[checkId] = {
            dataStore = keyInfo.dataStore,
            key = keyInfo.key,
            results = {},
            timestamp = os.time(),
            status = "pending"
        }
        
        -- Request consistency check from all servers
        pcall(function()
            MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.CONSISTENCY_CHECK, HttpService:JSONEncode({
                checkId = checkId,
                dataStore = keyInfo.dataStore,
                key = keyInfo.key,
                serverId = serverState.serverId,
                timestamp = os.time()
            }))
        end)
    end
end

-- Notify data access to other servers
function MultiServerCoordination.notifyDataAccess(dataStore, key, operation)
    if not serverState.isInitialized then return end
    
    local accessData = {
        serverId = serverState.serverId,
        dataStore = dataStore,
        key = key,
        operation = operation,
        timestamp = os.time()
    }
    
    -- Add to local log
    table.insert(serverState.dataAccessLog, accessData)
    
    -- Keep log size manageable
    if #serverState.dataAccessLog > 1000 then
        table.remove(serverState.dataAccessLog, 1)
    end
    
    -- Notify other servers
    pcall(function()
        MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.DATA_ACCESS, HttpService:JSONEncode(accessData))
    end)
end

-- Request a lock from all servers
function MultiServerCoordination.requestDistributedLock(dataStore, key, timeoutSeconds)
    if not serverState.isInitialized then return false end
    
    local requestId = HttpService:GenerateGUID(false)
    local lockRequest = {
        requestId = requestId,
        dataStore = dataStore,
        key = key,
        serverId = serverState.serverId,
        timestamp = os.time()
    }
    
    -- Track responses
    local responsesReceived = 0
    local allServersApproved = true
    local responseWaitTime = timeoutSeconds or 5
    
    local responseHandler
    
    -- Create a thread to wait for responses
    local thread = task.spawn(function()
        -- Subscribe to responses
        local success, connection = pcall(function()
            return MessagingService:SubscribeAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.LOCK_RESPONSE, function(message)
                local response = HttpService:JSONDecode(message.Data)
                
                if response.requestId == requestId then
                    responsesReceived += 1
                    
                    if response.hasLock then
                        allServersApproved = false
                    end
                end
            end)
        end)
        
        responseHandler = connection
        
        -- Send the request
        pcall(function()
            MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.LOCK_REQUEST, HttpService:JSONEncode(lockRequest))
        end)
        
        -- Wait for responses
        task.wait(responseWaitTime)
    end)
    
    -- Wait for the thread to finish
    task.wait(responseWaitTime + 0.5)
    
    -- Clean up the subscription
    if responseHandler then
        responseHandler:Disconnect()
    end
    
    -- If all servers approved (or no responses were received), we can acquire the lock
    if allServersApproved then
        table.insert(serverState.activeLocks, {
            dataStore = dataStore,
            key = key,
            timestamp = os.time()
        })
        
        return true
    end
    
    return false
end

-- Release a distributed lock
function MultiServerCoordination.releaseDistributedLock(dataStore, key)
    if not serverState.isInitialized then return end
    
    -- Remove from local locks
    for i, lock in ipairs(serverState.activeLocks) do
        if lock.dataStore == dataStore and lock.key == key then
            table.remove(serverState.activeLocks, i)
            break
        end
    end
    
    -- Notify other servers
    pcall(function()
        MessagingService:PublishAsync(MESSAGE_TOPIC_PREFIX .. MESSAGE_TYPES.LOCK_RELEASE, HttpService:JSONEncode({
            dataStore = dataStore,
            key = key,
            serverId = serverState.serverId,
            timestamp = os.time()
        }))
    end)
end

-- Get active servers for UI display
function MultiServerCoordination.getActiveServers()
    return serverState.activeServers
end

-- Get data access log for UI display
function MultiServerCoordination.getDataAccessLog()
    return serverState.dataAccessLog
end

-- Get pending conflicts for UI display
function MultiServerCoordination.getPendingConflicts()
    return serverState.pendingConflicts
end

-- Get active locks for UI display
function MultiServerCoordination.getActiveLocks()
    return serverState.activeLocks
end

return MultiServerCoordination
