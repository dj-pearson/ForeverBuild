--luau
-- DataStore Plugin/SessionManager.luau

-- Ensure this module can only run on the server
if not game:GetService("RunService"):IsServer() then
    error("SessionManager can only be used on the server")
end

local SessionManager = {}

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

local LockDataStore = DataStoreService:GetDataStore("SessionLocks")

local DEFAULT_LOCK_TIMEOUT = 600 -- 10 minutes in seconds
local LOCK_PREFIX = "Lock_"
local MAX_RETRIES = 3
local RETRY_DELAY = 1

-- Configuration settings with defaults
SessionManager.config = {
    lockTimeout = DEFAULT_LOCK_TIMEOUT,
    monitorInterval = 60, -- Check locks every 60 seconds
    autoRetryOnFailure = true,
    maxRetryAttempts = 3,
    retryDelaySeconds = 1,
    notifyOnExpiredLocks = true,
}

-- Lock statistics tracking
SessionManager.stats = {
    totalLocksAcquired = 0,
    totalLocksReleased = 0,
    totalLocksFailed = 0,
    totalForceReleases = 0,
    lockOperations = {}, -- Log of recent lock operations
    lockDurations = {}, -- Track how long locks are held
}

function SessionManager.initialize()
    -- Start monitoring locks when the module is initialized
    coroutine.wrap(SessionManager.monitorLocks)()
end

function SessionManager.acquireLock(dataStoreName, keyName, sessionId)
    local lockKey = LOCK_PREFIX .. dataStoreName .. "_" .. keyName
    local retries = 0
    local success, result
    local startTime = os.clock()
    local operationRecord = {
        operation = "acquire",
        dataStore = dataStoreName,
        key = keyName,
        sessionId = sessionId,
        timestamp = os.time(),
        success = false,
    }

    repeat
        success, result = pcall(function()
            return LockDataStore:UpdateAsync(lockKey, function(oldLockData)
                if oldLockData == nil or oldLockData.sessionId == sessionId then
                    local newLockData = {
                        sessionId = sessionId,
                        timestamp = os.time(),
                        dataStoreName = dataStoreName,
                        keyName = keyName,
                        lockDuration = 0,
                    }
                    return newLockData
                else
                    return oldLockData, "Locked by another session"
                end
            end)
        end)
        
        if not success then
            retries = retries + 1
            warn("SessionManager: Failed to acquire lock for", keyName, ". Attempt", retries, "of", SessionManager.config.maxRetryAttempts, ":", result)
            if retries < SessionManager.config.maxRetryAttempts and SessionManager.config.autoRetryOnFailure then
                task.wait(SessionManager.config.retryDelaySeconds)
            end
        end 
    until success or retries >= SessionManager.config.maxRetryAttempts

    -- Track the operation result
    if success then
        if result == nil or (typeof(result) ~= "string" and result.sessionId == sessionId) then
            operationRecord.success = true
            SessionManager.stats.totalLocksAcquired += 1
            
            -- Add to the operations log
            operationRecord.executionTime = os.clock() - startTime
            table.insert(SessionManager.stats.lockOperations, 1, operationRecord)
            
            -- Keep the operations log from growing too large
            if #SessionManager.stats.lockOperations > 100 then
                table.remove(SessionManager.stats.lockOperations)
            end
            
            return true
        else
            if typeof(result) == "string" then
                warn("SessionManager: Key", keyName, "is already locked by another session")
            end
            SessionManager.stats.totalLocksFailed += 1
            return false
        end
    else 
        warn("SessionManager: Failed to get lock for", keyName, ":", result)
        SessionManager.stats.totalLocksFailed += 1
        return false
    end
end

function SessionManager.releaseLock(dataStoreName, keyName, sessionId)
    local lockKey = LOCK_PREFIX .. dataStoreName .. "_" .. keyName
    local retries = 0
    local success, result
    local startTime = os.clock()
    local operationRecord = {
        operation = "release",
        dataStore = dataStoreName,
        key = keyName,
        sessionId = sessionId,
        timestamp = os.time(),
        success = false
    }

    repeat
        success, result = pcall(function()
            local currentLock = LockDataStore:GetAsync(lockKey)
            if currentLock ~= nil and currentLock.sessionId == sessionId then
                -- Calculate how long the lock was held
                if currentLock.timestamp then
                    local duration = os.time() - currentLock.timestamp
                    table.insert(SessionManager.stats.lockDurations, duration)
                    -- Keep only the last 100 entries
                    if #SessionManager.stats.lockDurations > 100 then
                        table.remove(SessionManager.stats.lockDurations, 1)
                    end
                end
                
                LockDataStore:RemoveAsync(lockKey)
                return true
            elseif currentLock == nil then
                return true
            else
                warn("SessionManager: Cannot release lock for", keyName, ". It is held by session", currentLock.sessionId, "not", sessionId)
                return false
            end
        end)
        if not success then
            retries = retries + 1
            warn("SessionManager: Failed to release lock for", keyName, ". Attempt", retries, "of", SessionManager.config.maxRetryAttempts, ":", result)
            if retries < SessionManager.config.maxRetryAttempts and SessionManager.config.autoRetryOnFailure then
                task.wait(SessionManager.config.retryDelaySeconds)
            end
        end
    until success or retries >= SessionManager.config.maxRetryAttempts

    -- Track the operation result
    if success and result then
        operationRecord.success = true
        SessionManager.stats.totalLocksReleased += 1
    end
    
    -- Add to the operations log
    operationRecord.executionTime = os.clock() - startTime
    table.insert(SessionManager.stats.lockOperations, 1, operationRecord)
    
    -- Keep the operations log from growing too large
    if #SessionManager.stats.lockOperations > 100 then
        table.remove(SessionManager.stats.lockOperations)
    end

    if success then
        return result
    else
        warn("SessionManager: Failed to release lock for", keyName, "after retries:", result)
        return false
    end
end

function SessionManager.forceReleaseLock(dataStoreName, keyName)
    local lockKey = LOCK_PREFIX .. dataStoreName .. "_" .. keyName
    local startTime = os.clock()
    local operationRecord = {
        operation = "force_release",
        dataStore = dataStoreName,
        key = keyName,
        timestamp = os.time(),
        success = false
    }
    
    local removeSuccess, removeError = pcall(LockDataStore.RemoveAsync, LockDataStore, lockKey)

    if removeSuccess then
        print("SessionManager: Force-released lock for", keyName)
        operationRecord.success = true
        SessionManager.stats.totalForceReleases += 1
    else
        warn("SessionManager: Failed to force-release lock for", keyName, ":", removeError)
    end
    
    -- Add to the operations log
    operationRecord.executionTime = os.clock() - startTime
    table.insert(SessionManager.stats.lockOperations, 1, operationRecord)
    
    -- Keep the operations log from growing too large
    if #SessionManager.stats.lockOperations > 100 then
        table.remove(SessionManager.stats.lockOperations)
    end
    
    return removeSuccess
end

function SessionManager.getActiveLocks()
    local activeLocks = {}
    local lockKeys = {}
    local nextPageToken
    local success, listKeys
    
    repeat
        success, listKeys = pcall(LockDataStore.ListKeysAsync, LockDataStore, nil, nil, nextPageToken)
        if success then
            for _, keyInfo in ipairs(listKeys.Keys) do
                if string.sub(keyInfo.Key, 1, #LOCK_PREFIX) == LOCK_PREFIX then
                    table.insert(lockKeys, keyInfo.Key)
                end
            end
            nextPageToken = listKeys.NextPageToken
        else
            warn("SessionManager: Failed to list keys:", listKeys)
        end
    until nextPageToken == nil or not success

    for _, lockKey in ipairs(lockKeys) do
        local datastoreName, keyName = SessionManager.parseLockKey(lockKey)
        local lockData = SessionManager.getLockStatus(datastoreName, keyName)
        
        if lockData then 
            table.insert(activeLocks, {
                dataStoreName = datastoreName,
                keyName = keyName,
                sessionId = lockData.sessionId,
                timestamp = lockData.timestamp,
                lockDuration = lockData.timestamp and (os.time() - lockData.timestamp) or 0,
                isExpired = lockData.timestamp and ((os.time() - lockData.timestamp) > SessionManager.config.lockTimeout)
            })
        end
    end
    
    return activeLocks
end

-- Helper function to parse lock key
function SessionManager.parseLockKey(lockKey)
    local keyPart = string.sub(lockKey, #LOCK_PREFIX+1)
    local datastoreName = keyPart:match("^([^_]+)")
    local keyName = keyPart:match("_(.+)$")
    return datastoreName, keyName
end
-- Optional: Add a function to check the lock status
function SessionManager.getLockStatus(dataStoreName, keyName)
    local lockKey = LOCK_PREFIX .. dataStoreName .. "_" .. keyName
    local success, lockData = pcall(LockDataStore.GetAsync, LockDataStore, lockKey)

    if success then
        if lockData then
            -- Add datastore and key information if not present
            lockData.dataStoreName = lockData.dataStoreName or dataStoreName
            lockData.keyName = lockData.keyName or keyName
            
            -- Calculate how long the lock has been held
            if lockData.timestamp then
                lockData.lockDuration = os.time() - lockData.timestamp
                lockData.isExpired = lockData.lockDuration > SessionManager.config.lockTimeout
            end
        end
        return lockData -- Returns lock data (including sessionId) or nil
    else
        warn("SessionManager: Failed to get lock status for", keyName, ":", lockData)
        return nil
    end
end

function SessionManager.monitorLocks()
    while true do
        local activeLocks = SessionManager.getActiveLocks()
        local expiredLocks = 0
        
        for _, lockInfo in ipairs(activeLocks) do
            if lockInfo.timestamp then
                local timeElapsed = os.time() - lockInfo.timestamp
                if timeElapsed > SessionManager.config.lockTimeout then
                    expiredLocks += 1
                    SessionManager.forceReleaseLock(lockInfo.dataStoreName, lockInfo.keyName)
                    print("SessionManager: Released expired lock for", lockInfo.keyName, "held by session", lockInfo.sessionId)
                end
            end
        end
        
        if expiredLocks > 0 and SessionManager.config.notifyOnExpiredLocks then
            -- Could trigger a callback or UI update here
            print("SessionManager: Released " .. expiredLocks .. " expired locks")
        end
        
        task.wait(SessionManager.config.monitorInterval) -- Check based on configured interval
    end
end

-- Get configuration settings
function SessionManager.getConfig()
    return SessionManager.config
end

-- Update configuration settings
function SessionManager.updateConfig(newConfig)
    for key, value in pairs(newConfig) do
        if SessionManager.config[key] ~= nil then
            SessionManager.config[key] = value
        end
    end
    return SessionManager.config
end

-- Get statistics about lock operations
function SessionManager.getStats()
    local stats = table.clone(SessionManager.stats)
    
    -- Calculate average lock duration
    if #SessionManager.stats.lockDurations > 0 then
        local total = 0
        for _, duration in ipairs(SessionManager.stats.lockDurations) do
            total += duration
        end
        stats.averageLockDuration = total / #SessionManager.stats.lockDurations
    else
        stats.averageLockDuration = 0
    end
    
    return stats
end

-- Clear statistics
function SessionManager.resetStats()
    SessionManager.stats = {
        totalLocksAcquired = 0,
        totalLocksReleased = 0,
        totalLocksFailed = 0,
        totalForceReleases = 0,
        lockOperations = {},
        lockDurations = {},
    }
end

return SessionManager