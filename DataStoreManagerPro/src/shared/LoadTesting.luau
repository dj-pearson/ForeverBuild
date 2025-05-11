--[[
    LoadTesting.luau
    Part of DataStore Manager Pro
    
    This module provides functionality for simulating and analyzing load on
    DataStore operations, helping developers optimize their data management.
]]

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PerformanceMonitor = require(script.Parent.PerformanceMonitor)
local CacheManager = require(script.Parent.CacheManager)

local LoadTesting = {}

-- Load testing configuration
LoadTesting.currentTest = nil
LoadTesting.config = {
    duration = 30, -- Default test duration in seconds
    interval = 0.2, -- Time between operations
    operationsPerInterval = 5, -- Number of operations to perform in each interval
    maxConcurrent = 20, -- Maximum concurrent operations
    dataStoreNames = {}, -- DataStores to test
    operations = { "GetAsync", "SetAsync", "UpdateAsync", "RemoveAsync" }, -- Operations to test
    dataKeys = {}, -- Keys to use for testing
    dataSizes = { "small", "medium", "large" }, -- Data sizes to test
    randomizeData = true, -- Whether to randomize data for each set operation
    useCache = true -- Whether to enable caching during the test
}

-- Test results
LoadTesting.results = {
    operationResults = {},
    summary = {},
    breakingPoints = {},
    errors = {}
}

-- Current test state
LoadTesting.testState = {
    isRunning = false,
    startTime = 0,
    endTime = 0,
    completedOperations = 0,
    failedOperations = 0,
    currentStep = "",
    progress = 0
}

-- Sample data templates for different sizes
LoadTesting.sampleData = {
    small = { value = 1, text = "small" },
    medium = {
        value = 1,
        text = "medium",
        array = table.create(50, "medium data"),
        nested = {
            a = 1, b = 2, c = 3,
            deep = { d = 4, e = 5, f = table.create(20, "nested") }
        }
    },
    large = {
        value = 1,
        text = "large",
        array = table.create(200, "large data"),
        nested = {
            a = 1, b = 2, c = 3,
            deep = { d = 4, e = 5, f = table.create(100, "nested") },
            objects = table.create(50, {
                id = 0,
                name = "object",
                properties = table.create(20, "property"),
                metadata = { created = os.time(), modified = os.time() }
            })
        }
    }
}

-- Initialize the load testing module
function LoadTesting.initialize()
    print("LoadTesting: Initializing load testing module...")
    
    -- Prepare some default test keys
    for i = 1, 50 do
        table.insert(LoadTesting.config.dataKeys, "TestKey_" .. i)
    end
    
    return true
end

-- Configure a new load test
function LoadTesting.configureTest(config)
    -- Merge the provided config with defaults
    for key, value in pairs(config) do
        LoadTesting.config[key] = value
    end
    
    return LoadTesting.config
end

-- Start a load test with the current configuration
function LoadTesting.startTest()
    if LoadTesting.testState.isRunning then
        return false, "A test is already running"
    end
    
    -- Reset test state and results
    LoadTesting.testState = {
        isRunning = true,
        startTime = os.time(),
        endTime = 0,
        completedOperations = 0,
        failedOperations = 0,
        currentStep = "Starting test...",
        progress = 0
    }
    
    LoadTesting.results = {
        operationResults = {},
        summary = {},
        breakingPoints = {},
        errors = {}
    }
    
    for _, operation in ipairs(LoadTesting.config.operations) do
        LoadTesting.results.operationResults[operation] = {
            totalTime = 0,
            count = 0,
            errors = 0,
            averageTime = 0,
            minTime = math.huge,
            maxTime = 0,
            timesBySecond = {}
        }
    end
    
    -- Set cache configuration for testing
    if not LoadTesting.config.useCache then
        CacheManager.disableCache()
    else
        CacheManager.enableCache()
        CacheManager.setCacheSizeLimit(100) -- Adjust cache size for testing
    end
    
    -- Start the test in a separate thread
    task.spawn(function()
        LoadTesting._runTest()
    end)
    
    return true, "Test started successfully"
end

-- Internal function to run the test
function LoadTesting._runTest()
    local config = LoadTesting.config
    local endTime = os.time() + config.duration
    local totalIterations = math.ceil(config.duration / config.interval)
    local currentIteration = 0
    
    while os.time() < endTime and LoadTesting.testState.isRunning do
        currentIteration += 1
        LoadTesting.testState.progress = currentIteration / totalIterations
        LoadTesting.testState.currentStep = "Running operations... " .. 
            math.floor(LoadTesting.testState.progress * 100) .. "%"
        
        -- Track current second for time-based analytics
        local currentSecond = os.time() - LoadTesting.testState.startTime
        
        -- Run operations for this interval
        local threads = {}
        for i = 1, config.operationsPerInterval do
            if #threads >= config.maxConcurrent then
                -- Wait for a thread to complete if we've hit the max concurrent operations
                task.wait()
            end
            
            -- Choose a random operation, data store, key, and data size
            local operation = config.operations[math.random(1, #config.operations)]
            local dataStore = config.dataStoreNames[math.random(1, #config.dataStoreNames)]
            local key = config.dataKeys[math.random(1, #config.dataKeys)]
            local dataSize = config.dataSizes[math.random(1, #config.dataSizes)]
            
            -- Spawn a thread to perform the operation
            table.insert(threads, task.spawn(function()
                LoadTesting._performOperation(operation, dataStore, key, dataSize, currentSecond)
            end))
        end
        
        -- Wait for the next interval
        task.wait(config.interval)
    end
    
    -- Finalize the test
    LoadTesting._finalizeTest()
end

-- Perform a single operation as part of the test
function LoadTesting._performOperation(operation, dataStoreName, key, dataSize, currentSecond)
    local operationResults = LoadTesting.results.operationResults[operation]
    if not operationResults.timesBySecond[currentSecond] then
        operationResults.timesBySecond[currentSecond] = {
            totalTime = 0,
            count = 0,
            errors = 0
        }
    end
    
    local success, result, duration
    local dataStore = DataStoreService:GetDataStore(dataStoreName)
    
    -- Generate data if needed for this operation
    local data = nil
    if operation == "SetAsync" or operation == "UpdateAsync" then
        data = table.clone(LoadTesting.sampleData[dataSize])
        if LoadTesting.config.randomizeData then
            -- Add some randomness to the data
            data.random = HttpService:GenerateGUID()
            data.timestamp = os.time()
        end
    end
    
    -- Perform the operation with performance monitoring
    success, result, duration = PerformanceMonitor.timeOperation(
        operation,
        function()
            if operation == "GetAsync" then
                return pcall(dataStore.GetAsync, dataStore, key)
            elseif operation == "SetAsync" then
                return pcall(dataStore.SetAsync, dataStore, key, data)
            elseif operation == "UpdateAsync" then
                return pcall(dataStore.UpdateAsync, dataStore, key, function(oldData)
                    return data
                end)
            elseif operation == "RemoveAsync" then
                return pcall(dataStore.RemoveAsync, dataStore, key)
            else
                return false, "Unknown operation: " .. operation
            end
        end,
        dataStoreName,
        key
    )
    
    -- Update the results
    LoadTesting.testState.completedOperations += 1
    if not success then
        LoadTesting.testState.failedOperations += 1
        operationResults.errors += 1
        operationResults.timesBySecond[currentSecond].errors += 1
        
        -- Record the error
        table.insert(LoadTesting.results.errors, {
            operation = operation,
            dataStore = dataStoreName,
            key = key,
            time = os.time(),
            error = tostring(result)
        })
    end
    
    operationResults.totalTime += duration
    operationResults.count += 1
    operationResults.minTime = math.min(operationResults.minTime, duration)
    operationResults.maxTime = math.max(operationResults.maxTime, duration)
    operationResults.averageTime = operationResults.totalTime / operationResults.count
    
    operationResults.timesBySecond[currentSecond].totalTime += duration
    operationResults.timesBySecond[currentSecond].count += 1
    
    -- Check for breaking points
    if duration > 1.0 then -- Operations taking longer than 1 second may indicate a breaking point
        table.insert(LoadTesting.results.breakingPoints, {
            operation = operation,
            dataStore = dataStoreName,
            key = key,
            duration = duration,
            time = os.time(),
            operationCount = LoadTesting.testState.completedOperations
        })
    end
end

-- Finalize the test and generate summary results
function LoadTesting._finalizeTest()
    LoadTesting.testState.isRunning = false
    LoadTesting.testState.endTime = os.time()
    LoadTesting.testState.currentStep = "Test completed"
    LoadTesting.testState.progress = 1
    
    -- Calculate summary statistics
    local totalOperations = LoadTesting.testState.completedOperations
    local totalErrors = LoadTesting.testState.failedOperations
    local totalTime = LoadTesting.testState.endTime - LoadTesting.testState.startTime
    local operationsPerSecond = totalOperations / totalTime
    local errorRate = totalErrors / totalOperations
    
    LoadTesting.results.summary = {
        totalOperations = totalOperations,
        totalErrors = totalErrors,
        totalTime = totalTime,
        operationsPerSecond = operationsPerSecond,
        errorRate = errorRate,
        averageLatency = 0,
        breakingPointsCount = #LoadTesting.results.breakingPoints
    }
    
    -- Calculate overall average latency
    local totalLatency = 0
    local latencyCount = 0
    
    for _, operation in pairs(LoadTesting.results.operationResults) do
        totalLatency += operation.totalTime
        latencyCount += operation.count
    end
    
    if latencyCount > 0 then
        LoadTesting.results.summary.averageLatency = totalLatency / latencyCount
    end
    
    -- Generate scalability recommendations
    LoadTesting._generateRecommendations()
    
    print("LoadTesting: Test completed. Total operations:", totalOperations, 
          "Operations/sec:", string.format("%.2f", operationsPerSecond),
          "Error rate:", string.format("%.2f%%", errorRate * 100))
end

-- Generate scalability recommendations based on test results
function LoadTesting._generateRecommendations()
    local recommendations = {}
    local summary = LoadTesting.results.summary
    
    -- Check operations per second
    if summary.operationsPerSecond < 5 then
        table.insert(recommendations, {
            severity = "high",
            area = "throughput",
            message = "Low operation throughput detected. Consider optimizing your data structure or implementing caching."
        })
    elseif summary.operationsPerSecond < 20 then
        table.insert(recommendations, {
            severity = "medium",
            area = "throughput",
            message = "Moderate operation throughput. May need optimization for high-traffic games."
        })
    end
    
    -- Check error rate
    if summary.errorRate > 0.1 then
        table.insert(recommendations, {
            severity = "high",
            area = "reliability",
            message = "High error rate detected. Implement retry logic and error handling."
        })
    elseif summary.errorRate > 0.01 then
        table.insert(recommendations, {
            severity = "medium",
            area = "reliability",
            message = "Moderate error rate. Consider implementing retry logic for critical operations."
        })
    end
    
    -- Check latency
    if summary.averageLatency > 0.5 then
        table.insert(recommendations, {
            severity = "high",
            area = "latency",
            message = "High average latency detected. Consider aggressive caching and data optimization."
        })
    elseif summary.averageLatency > 0.2 then
        table.insert(recommendations, {
            severity = "medium",
            area = "latency",
            message = "Moderate latency. Consider caching frequently accessed data."
        })
    end
    
    -- Check breaking points
    if #LoadTesting.results.breakingPoints > 0 then
        table.insert(recommendations, {
            severity = "high",
            area = "scalability",
            message = string.format("Breaking points detected at %d operations/sec. Limit concurrent operations and implement throttling.", 
                math.floor(LoadTesting.results.breakingPoints[1].operationCount / 
                (LoadTesting.results.breakingPoints[1].time - LoadTesting.testState.startTime)))
        })
    end
    
    -- Caching recommendations
    if not LoadTesting.config.useCache and summary.averageLatency > 0.1 then
        table.insert(recommendations, {
            severity = "medium",
            area = "caching",
            message = "Consider enabling caching to reduce latency and DataStore request volume."
        })
    end
    
    LoadTesting.results.recommendations = recommendations
end

-- Stop an ongoing test
function LoadTesting.stopTest()
    if not LoadTesting.testState.isRunning then
        return false, "No test is currently running"
    end
    
    LoadTesting.testState.isRunning = false
    LoadTesting.testState.currentStep = "Test stopped by user"
    
    return true, "Test stopped successfully"
end

-- Get the current test state
function LoadTesting.getTestState()
    return LoadTesting.testState
end

-- Get the test results
function LoadTesting.getTestResults()
    return LoadTesting.results
end

-- Generate test data for a specific size
function LoadTesting.generateTestData(size)
    if LoadTesting.sampleData[size] then
        local data = table.clone(LoadTesting.sampleData[size])
        data.random = HttpService:GenerateGUID()
        data.timestamp = os.time()
        return data
    end
    
    return nil
end

return LoadTesting
