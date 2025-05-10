local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Logger = require(script.Parent.Logger)

local PerformanceManager = {}

-- Constants
local CACHE_EXPIRY = 300 -- 5 minutes
local MAX_CACHE_SIZE = 1000
local NETWORK_BATCH_SIZE = 50
local PERFORMANCE_SAMPLE_INTERVAL = 60 -- 1 minute

-- Cache system
local cache = {}
local cacheTimestamps = {}
local cacheHits = 0
local cacheMisses = 0

-- Performance metrics
local metrics = {
    networkCalls = 0,
    networkBytes = 0,
    cacheHits = 0,
    cacheMisses = 0,
    frameTime = {},
    memoryUsage = {},
    lastSampleTime = 0
}

-- Utility: Generate cache key
local function generateCacheKey(...)
    local args = {...}
    local key = ""
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            key = key .. HttpService:JSONEncode(arg)
        else
            key = key .. tostring(arg)
        end
        if i < #args then
            key = key .. "|"
        end
    end
    return key
end

-- Utility: Clean expired cache entries
local function cleanCache()
    local currentTime = os.time()
    local expiredKeys = {}
    
    -- Find expired entries
    for key, timestamp in pairs(cacheTimestamps) do
        if currentTime - timestamp > CACHE_EXPIRY then
            table.insert(expiredKeys, key)
        end
    end
    
    -- Remove expired entries
    for _, key in ipairs(expiredKeys) do
        cache[key] = nil
        cacheTimestamps[key] = nil
    end
    
    -- If still too many entries, remove oldest
    local count = 0
    for _ in pairs(cache) do
        count = count + 1
    end
    
    if count > MAX_CACHE_SIZE then
        local oldestKey = nil
        local oldestTime = math.huge
        
        for key, timestamp in pairs(cacheTimestamps) do
            if timestamp < oldestTime then
                oldestTime = timestamp
                oldestKey = key
            end
        end
        
        if oldestKey then
            cache[oldestKey] = nil
            cacheTimestamps[oldestKey] = nil
        end
    end
end

-- Utility: Sample performance metrics
local function samplePerformanceMetrics()
    local currentTime = os.time()
    if currentTime - metrics.lastSampleTime < PERFORMANCE_SAMPLE_INTERVAL then
        return
    end
    
    -- Sample frame time
    local frameTime = RunService:GetAverageFrameTime()
    table.insert(metrics.frameTime, frameTime)
    if #metrics.frameTime > 60 then
        table.remove(metrics.frameTime, 1)
    end
    
    -- Sample memory usage
    local memoryUsage = game:GetService("Stats"):GetTotalMemoryUsageMb()
    table.insert(metrics.memoryUsage, memoryUsage)
    if #metrics.memoryUsage > 60 then
        table.remove(metrics.memoryUsage, 1)
    end
    
    -- Log metrics
    Logger.info("Performance metrics", {
        frameTime = frameTime,
        memoryUsage = memoryUsage,
        cacheHitRate = metrics.cacheHits / (metrics.cacheHits + metrics.cacheMisses),
        networkCalls = metrics.networkCalls,
        networkBytes = metrics.networkBytes
    })
    
    -- Reset counters
    metrics.networkCalls = 0
    metrics.networkBytes = 0
    metrics.cacheHits = 0
    metrics.cacheMisses = 0
    metrics.lastSampleTime = currentTime
end

-- Public API: Cache operations
function PerformanceManager.getCached(key, ...)
    local cacheKey = generateCacheKey(key, ...)
    cleanCache()
    
    if cache[cacheKey] then
        metrics.cacheHits = metrics.cacheHits + 1
        return cache[cacheKey]
    end
    
    metrics.cacheMisses = metrics.cacheMisses + 1
    return nil
end

function PerformanceManager.setCached(key, value, ...)
    local cacheKey = generateCacheKey(key, ...)
    cleanCache()
    
    cache[cacheKey] = value
    cacheTimestamps[cacheKey] = os.time()
end

function PerformanceManager.clearCache()
    cache = {}
    cacheTimestamps = {}
    metrics.cacheHits = 0
    metrics.cacheMisses = 0
end

-- Public API: Network optimization
function PerformanceManager.batchNetworkCalls(calls)
    local batches = {}
    local currentBatch = {}
    
    for _, call in ipairs(calls) do
        table.insert(currentBatch, call)
        if #currentBatch >= NETWORK_BATCH_SIZE then
            table.insert(batches, currentBatch)
            currentBatch = {}
        end
    end
    
    if #currentBatch > 0 then
        table.insert(batches, currentBatch)
    end
    
    return batches
end

function PerformanceManager.trackNetworkCall(bytes)
    metrics.networkCalls = metrics.networkCalls + 1
    metrics.networkBytes = metrics.networkBytes + (bytes or 0)
end

-- Public API: Performance monitoring
function PerformanceManager.getMetrics()
    return {
        frameTime = metrics.frameTime,
        memoryUsage = metrics.memoryUsage,
        cacheHitRate = metrics.cacheHits / (metrics.cacheHits + metrics.cacheMisses),
        networkCalls = metrics.networkCalls,
        networkBytes = metrics.networkBytes
    }
end

-- Public API: Memory management
function PerformanceManager.cleanup()
    -- Clear cache
    PerformanceManager.clearCache()
    
    -- Force garbage collection
    collectgarbage("count")
    
    -- Log memory usage
    local memoryUsage = game:GetService("Stats"):GetTotalMemoryUsageMb()
    Logger.info("Memory cleanup completed", { memoryUsage = memoryUsage })
end

-- Initialize the PerformanceManager
function PerformanceManager.init()
    Logger.info("Initializing PerformanceManager")
    
    -- Set up performance monitoring
    task.spawn(function()
        while true do
            task.wait(PERFORMANCE_SAMPLE_INTERVAL)
            samplePerformanceMetrics()
        end
    end)
    
    -- Set up periodic cache cleanup
    task.spawn(function()
        while true do
            task.wait(CACHE_EXPIRY)
            cleanCache()
        end
    end)
    
    Logger.info("PerformanceManager initialized successfully")
end

return PerformanceManager 