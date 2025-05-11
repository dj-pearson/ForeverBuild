--[[
    PerformanceAnalyzer.luau
    Part of DataStore Manager Pro
    
    This module provides advanced performance analysis for DataStore operations,
    helping developers identify bottlenecks and optimize their data access patterns.
]]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local PerformanceMonitor = require(script.Parent.PerformanceMonitor)

local PerformanceAnalyzer = {}

-- Configuration settings with defaults
PerformanceAnalyzer.config = {
    sampleSize = 100, -- Number of operations to analyze for trends
    slowOperationThreshold = 0.5, -- Operations taking longer than this (in seconds) are flagged
    samplingInterval = 60, -- Time between sampling periods in seconds
    detailedLogging = true, -- Whether to capture detailed performance logs
    alertThresholds = {
        critical = 2.0, -- Operations taking longer than this (in seconds) trigger critical alerts
        warning = 1.0, -- Operations taking longer than this (in seconds) trigger warnings
    }
}

-- Internal state
local performanceData = {
    operationHistory = {}, -- Recent operations for trend analysis
    bottlenecks = {}, -- Identified performance bottlenecks
    optimizationSuggestions = {}, -- Generated suggestions for improvement
    dataStorePerformance = {}, -- Performance by DataStore
    keyPerformance = {}, -- Performance by key
    serverLoad = {}, -- Server load measurements over time
    historicalTrends = {}, -- Long-term performance trends
}

-- Initialize the Performance Analyzer
function PerformanceAnalyzer.initialize()
    print("PerformanceAnalyzer: Initializing performance analysis system...")
    
    -- Set up periodic data collection
    task.spawn(function()
        while true do
            PerformanceAnalyzer.collectPerformanceData()
            task.wait(PerformanceAnalyzer.config.samplingInterval)
        end
    end)
    
    -- Set up scheduled analysis
    task.spawn(function()
        while true do
            PerformanceAnalyzer.analyzePerformanceTrends()
            task.wait(PerformanceAnalyzer.config.samplingInterval * 5) -- Less frequent than data collection
        end
    end)
    
    return true
end

-- Collect current performance data from PerformanceMonitor
function PerformanceAnalyzer.collectPerformanceData()
    local currentData = PerformanceMonitor.getPerformanceData()
    local operationSummary = PerformanceMonitor.getOperationSummary()
    
    -- Track server stats
    local serverStats = {
        timestamp = os.time(),
        memoryUsageMB = math.floor(collectgarbage("count") / 1024 * 100) / 100,
        heartbeatTime = RunService.Heartbeat:Wait(), -- Approximate server load
    }
    
    table.insert(performanceData.serverLoad, serverStats)
    if #performanceData.serverLoad > PerformanceAnalyzer.config.sampleSize then
        table.remove(performanceData.serverLoad, 1)
    end
    
    -- Process operation data
    for operationType, operationData in pairs(currentData) do
        for dataStore, storeData in pairs(operationData) do
            for key, metrics in pairs(storeData) do
                -- Record operation in history
                local operationRecord = {
                    timestamp = os.time(),
                    operationType = operationType,
                    dataStore = dataStore,
                    key = key,
                    duration = metrics.duration,
                    success = metrics.success,
                    retries = metrics.retries or 0,
                }
                
                table.insert(performanceData.operationHistory, operationRecord)
                
                -- Maintain history size
                if #performanceData.operationHistory > PerformanceAnalyzer.config.sampleSize * 3 then
                    table.remove(performanceData.operationHistory, 1)
                end
                
                -- Track performance by DataStore
                if not performanceData.dataStorePerformance[dataStore] then
                    performanceData.dataStorePerformance[dataStore] = {
                        operations = 0,
                        totalDuration = 0,
                        slowOperations = 0,
                        failedOperations = 0,
                        averageDuration = 0,
                    }
                end
                
                local dsPerf = performanceData.dataStorePerformance[dataStore]
                dsPerf.operations = dsPerf.operations + 1
                dsPerf.totalDuration = dsPerf.totalDuration + metrics.duration
                dsPerf.averageDuration = dsPerf.totalDuration / dsPerf.operations
                
                if metrics.duration > PerformanceAnalyzer.config.slowOperationThreshold then
                    dsPerf.slowOperations = dsPerf.slowOperations + 1
                end
                
                if not metrics.success then
                    dsPerf.failedOperations = dsPerf.failedOperations + 1
                end
                
                -- Track performance by key
                local keyId = dataStore .. ":" .. key
                if not performanceData.keyPerformance[keyId] then
                    performanceData.keyPerformance[keyId] = {
                        operations = 0,
                        totalDuration = 0,
                        slowOperations = 0,
                        failedOperations = 0,
                        averageDuration = 0,
                    }
                end
                
                local keyPerf = performanceData.keyPerformance[keyId]
                keyPerf.operations = keyPerf.operations + 1
                keyPerf.totalDuration = keyPerf.totalDuration + metrics.duration
                keyPerf.averageDuration = keyPerf.totalDuration / keyPerf.operations
                
                if metrics.duration > PerformanceAnalyzer.config.slowOperationThreshold then
                    keyPerf.slowOperations = keyPerf.slowOperations + 1
                end
                
                if not metrics.success then
                    keyPerf.failedOperations = keyPerf.failedOperations + 1
                end
                
                -- Flag slow operations and generate alerts
                if metrics.duration > PerformanceAnalyzer.config.alertThresholds.critical then
                    PerformanceAnalyzer.addBottleneck({
                        severity = "critical",
                        message = string.format(
                            "Critical: %s operation on %s:%s took %.2f seconds", 
                            operationType, dataStore, key, metrics.duration
                        ),
                        dataStore = dataStore,
                        key = key,
                        operationType = operationType,
                        duration = metrics.duration,
                        timestamp = os.time(),
                    })
                elseif metrics.duration > PerformanceAnalyzer.config.alertThresholds.warning then
                    PerformanceAnalyzer.addBottleneck({
                        severity = "warning",
                        message = string.format(
                            "Warning: %s operation on %s:%s took %.2f seconds", 
                            operationType, dataStore, key, metrics.duration
                        ),
                        dataStore = dataStore,
                        key = key,
                        operationType = operationType,
                        duration = metrics.duration,
                        timestamp = os.time(),
                    })
                end
            end
        end
    end
end

-- Add a bottleneck to the tracked list
function PerformanceAnalyzer.addBottleneck(bottleneck)
    table.insert(performanceData.bottlenecks, bottleneck)
    
    -- Keep bottleneck list at a reasonable size
    if #performanceData.bottlenecks > 100 then
        table.remove(performanceData.bottlenecks, 1)
    end
    
    -- Generate optimization suggestion
    PerformanceAnalyzer.generateOptimizationSuggestion(bottleneck)
    
    -- Return bottleneck ID for reference
    return #performanceData.bottlenecks
end

-- Generate optimization suggestions based on performance data
function PerformanceAnalyzer.generateOptimizationSuggestion(bottleneck)
    local suggestion = {
        relatedBottleneck = bottleneck,
        timestamp = os.time(),
        appliedStatus = "pending",  -- pending, applied, rejected
    }
    
    -- Different suggestions based on operation type
    if bottleneck.operationType == "GetAsync" then
        suggestion.message = string.format(
            "Consider caching frequently accessed data for '%s:%s'", 
            bottleneck.dataStore, bottleneck.key
        )
        suggestion.implementation = string.format([[
-- Add caching for this key
CacheManager.set("%s", "%s", data, 300) -- Cache for 5 minutes
]], bottleneck.dataStore, bottleneck.key)
    elseif bottleneck.operationType == "SetAsync" then
        suggestion.message = string.format(
            "Consider batching writes for '%s' or implementing a write buffer", 
            bottleneck.dataStore
        )
    elseif bottleneck.operationType == "UpdateAsync" then
        suggestion.message = string.format(
            "Consider optimizing the update function for '%s:%s' to be more efficient", 
            bottleneck.dataStore, bottleneck.key
        )
    end
    
    table.insert(performanceData.optimizationSuggestions, suggestion)
    
    -- Keep suggestions list at a reasonable size
    if #performanceData.optimizationSuggestions > 100 then
        table.remove(performanceData.optimizationSuggestions, 1)
    end
    
    return suggestion
end

-- Analyze performance trends over time
function PerformanceAnalyzer.analyzePerformanceTrends()
    -- Skip if not enough data points
    if #performanceData.operationHistory < 10 then
        return
    end
    
    -- Analyze operation timing trends
    local periodData = {
        timestamp = os.time(),
        averageDuration = 0,
        totalOperations = #performanceData.operationHistory,
        failureRate = 0,
        slowOperationRate = 0,
    }
    
    local totalDuration = 0
    local failedOps = 0
    local slowOps = 0
    
    for _, op in ipairs(performanceData.operationHistory) do
        totalDuration = totalDuration + op.duration
        
        if not op.success then
            failedOps = failedOps + 1
        end
        
        if op.duration > PerformanceAnalyzer.config.slowOperationThreshold then
            slowOps = slowOps + 1
        end
    end
    
    periodData.averageDuration = totalDuration / #performanceData.operationHistory
    periodData.failureRate = failedOps / #performanceData.operationHistory
    periodData.slowOperationRate = slowOps / #performanceData.operationHistory
    
    table.insert(performanceData.historicalTrends, periodData)
    
    -- Keep historical trends at a reasonable size
    if #performanceData.historicalTrends > 100 then
        table.remove(performanceData.historicalTrends, 1)
    end
end

-- Get performance bottlenecks
function PerformanceAnalyzer.getBottlenecks()
    return performanceData.bottlenecks
end

-- Get optimization suggestions
function PerformanceAnalyzer.getOptimizationSuggestions()
    return performanceData.optimizationSuggestions
end

-- Get historical performance trends
function PerformanceAnalyzer.getHistoricalTrends()
    return performanceData.historicalTrends
end

-- Get performance data by DataStore
function PerformanceAnalyzer.getDataStorePerformance()
    return performanceData.dataStorePerformance
end

-- Get performance data by key
function PerformanceAnalyzer.getKeyPerformance()
    return performanceData.keyPerformance
end

-- Get server load metrics
function PerformanceAnalyzer.getServerLoad()
    return performanceData.serverLoad
end

-- Run a performance benchmark
function PerformanceAnalyzer.runBenchmark(dataStoreName, keyName, operationType, iterations)
    iterations = iterations or 10
    
    local results = {
        dataStore = dataStoreName,
        key = keyName,
        operationType = operationType,
        iterations = iterations,
        durations = {},
        averageDuration = 0,
        minDuration = math.huge,
        maxDuration = 0,
        totalDuration = 0,
        successRate = 0,
        timestamp = os.time(),
    }
    
    local successes = 0
    
    -- Perform the benchmark
    for i = 1, iterations do
        local start = os.clock()
        local success = false
        
        if operationType == "GetAsync" then
            local data = DataStoreManager.getData(dataStoreName, keyName)
            success = data ~= nil
        elseif operationType == "SetAsync" then
            local testData = { benchmarkTest = true, iteration = i, timestamp = os.time() }
            success, _ = DataStoreManager.setData(dataStoreName, keyName, testData)
        end
        
        local duration = os.clock() - start
        
        if success then
            successes = successes + 1
        end
        
        table.insert(results.durations, duration)
        results.totalDuration = results.totalDuration + duration
        
        if duration < results.minDuration then
            results.minDuration = duration
        end
        
        if duration > results.maxDuration then
            results.maxDuration = duration
        end
        
        -- Small delay between operations to avoid hitting rate limits
        task.wait(0.1)
    end
    
    results.averageDuration = results.totalDuration / iterations
    results.successRate = successes / iterations
    
    return results
end

-- Apply a suggested optimization
function PerformanceAnalyzer.applySuggestion(suggestionIndex)
    local suggestion = performanceData.optimizationSuggestions[suggestionIndex]
    if not suggestion then
        return false, "Suggestion not found"
    end
    
    suggestion.appliedStatus = "applied"
    suggestion.appliedTimestamp = os.time()
    
    return true, "Suggestion marked as applied"
end

-- Reject a suggested optimization
function PerformanceAnalyzer.rejectSuggestion(suggestionIndex)
    local suggestion = performanceData.optimizationSuggestions[suggestionIndex]
    if not suggestion then
        return false, "Suggestion not found"
    end
    
    suggestion.appliedStatus = "rejected"
    suggestion.rejectedTimestamp = os.time()
    
    return true, "Suggestion marked as rejected"
end

-- Update configuration
function PerformanceAnalyzer.configure(newConfig)
    for key, value in pairs(newConfig) do
        if PerformanceAnalyzer.config[key] ~= nil then
            PerformanceAnalyzer.config[key] = value
        end
    end
    
    return PerformanceAnalyzer.config
end

-- Clear collected data
function PerformanceAnalyzer.clearData()
    performanceData = {
        operationHistory = {},
        bottlenecks = {},
        optimizationSuggestions = {},
        dataStorePerformance = {},
        keyPerformance = {},
        serverLoad = {},
        historicalTrends = {},
    }
    return true
end

return PerformanceAnalyzer
