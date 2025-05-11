--luau
-- DataStore Plugin/PerformanceMonitor.luau

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

local PerformanceMonitor = {}
local performanceData = {} -- Table to store performance data, format: {{operationName, duration, datastoreName, keyName, success}}
local quotaInfo = {
    reads = {
        used = 0,
        max = 100, -- Default, will be updated based on actual limits
        resetTime = 0,
    },
    writes = {
        used = 0,
        max = 60, -- Default, will be updated based on actual limits
        resetTime = 0,
    },
    dataSize = {
        average = 0,
        largest = 0,
        total = 0,
        sampleCount = 0,
    },
}

-- Store operation timings by category
local operationTiming = {
    read = {},
    write = {},
    other = {},
}

-- Track key access frequency 
local keyAccessFrequency = {}

-- Track errors
local errorData = {
    total = 0,
    byType = {},
    history = {},
    lastPeriod = 0,
    lastErrorTime = 0
}

function PerformanceMonitor.timeOperation(operationName, func, dataStoreName, keyName)
    local startTime = os.clock() -- Use os.clock() for higher precision timing
    local success, result = pcall(func)
    local endTime = os.clock()
    local duration = endTime - startTime
	
	local data = {
		operationName = operationName,
		duration = duration,
		dataStoreName = dataStoreName,
		keyName = keyName,
		success = success,
        timestamp = os.time(),
	}
	
	table.insert(performanceData, data)

    -- Categorize the operation
    local category = "other"
    if string.find(operationName:lower(), "get") or string.find(operationName:lower(), "read") or string.find(operationName:lower(), "load") then
        category = "read"
        quotaInfo.reads.used += 1
    elseif string.find(operationName:lower(), "set") or string.find(operationName:lower(), "write") or string.find(operationName:lower(), "save") or string.find(operationName:lower(), "update") then
        category = "write"
        quotaInfo.writes.used += 1
    end
    
    -- Add to operation timing by category
    table.insert(operationTiming[category], duration)
    
    -- Track key access frequency
    local key = string.format("%s:%s", dataStoreName or "unknown", keyName or "unknown")
    keyAccessFrequency[key] = (keyAccessFrequency[key] or 0) + 1

    -- Track data size if result is available and successful
    if success and result and type(result) == "table" then
        local size = PerformanceMonitor.estimateDataSize(result)
        quotaInfo.dataSize.total += size
        quotaInfo.dataSize.sampleCount += 1
        quotaInfo.dataSize.average = quotaInfo.dataSize.total / quotaInfo.dataSize.sampleCount
        quotaInfo.dataSize.largest = math.max(quotaInfo.dataSize.largest, size)
    end
    
    -- Track error information if the operation failed
    if not success then
        errorData.total += 1
        errorData.lastErrorTime = os.time()
        
        -- Extract error type
        local errorType = "Unknown Error"
        if type(result) == "string" then
            -- Try to extract error type from error message
            local errorPattern = "([%w%s_]+Error)"
            local foundErrorType = string.match(result, errorPattern)
            if foundErrorType then
                errorType = foundErrorType
            elseif string.find(result, "quota") then
                errorType = "Quota Exceeded"
            elseif string.find(result, "permission") then
                errorType = "Permission Denied"
            elseif string.find(result, "too large") then
                errorType = "Data Size Error"
            elseif string.find(result, "throttled") or string.find(result, "rate limit") then
                errorType = "Rate Limited"
            end
        end
        
        -- Update error counts by type
        errorData.byType[errorType] = (errorData.byType[errorType] or 0) + 1
        
        -- Store full error details
        table.insert(errorData.history, {
            timestamp = os.time(),
            operation = operationName,
            dataStore = dataStoreName,
            key = keyName,
            errorType = errorType,
            message = tostring(result)
        })
        
        -- Keep history manageable
        if #errorData.history > 100 then
            table.remove(errorData.history, 1)
        end
    end

    return success, result, duration
end

function PerformanceMonitor.getPerformanceData()
	return performanceData
end

function PerformanceMonitor.getOperationSummary()
	local summary = {}
	for _, data in ipairs(performanceData) do
		local operationName = data.operationName
		if not summary[operationName] then
			summary[operationName] = {
				count = 0,
				totalDuration = 0,
				averageDuration = 0,
                failures = 0,
                successRate = 100
			}
		end
		summary[operationName].count += 1
		summary[operationName].totalDuration += data.duration
        if not data.success then
            summary[operationName].failures += 1
        end
	end

	-- Calculate average duration and success rate
	for operationName, data in pairs(summary) do
		data.averageDuration = data.totalDuration / data.count
        data.successRate = ((data.count - data.failures) / data.count) * 100
	end

	return summary
end

-- Estimate data size in bytes for a given value
function PerformanceMonitor.estimateDataSize(value)
    local valueType = typeof(value)

    if valueType == "string" then
        return #value
    elseif valueType == "number" then
        return 8 -- Typical size for a double-precision floating-point
    elseif valueType == "boolean" then
        return 1
    elseif valueType == "table" then
        local size = 0
        for k, v in pairs(value) do
            -- Add size for the key
            size += typeof(k) == "string" and #k or 8
            -- Add size for the value (recursively)
            size += PerformanceMonitor.estimateDataSize(v)
        end
        return size
    else
        return 0 -- Default for unsupported types
    end
end

-- Get quota information and limits
function PerformanceMonitor.getQuotaInfo()
    return quotaInfo
end

-- Reset quota usage (call this when quota resets, typically at the start of a new day)
function PerformanceMonitor.resetQuota()
    quotaInfo.reads.used = 0
    quotaInfo.writes.used = 0
    quotaInfo.reads.resetTime = os.time()
    quotaInfo.writes.resetTime = os.time()
end

-- Update quota limits (call this if you know the actual limits)
function PerformanceMonitor.updateQuotaLimits(readLimit, writeLimit)
    if readLimit then quotaInfo.reads.max = readLimit end
    if writeLimit then quotaInfo.writes.max = writeLimit end
end

-- Get operation timing statistics
function PerformanceMonitor.getTimingStats(category)
    local timings = category and operationTiming[category] or nil
    if not timings then
        return nil
    end
    
    -- Calculate basic statistics
    local count = #timings
    if count == 0 then return { count = 0 } end
    
    local sum = 0
    local min = math.huge
    local max = 0
    
    for _, duration in ipairs(timings) do
        sum += duration
        min = math.min(min, duration)
        max = math.max(max, duration)
    end
    
    return {
        count = count,
        average = sum / count,
        min = min,
        max = max,
        total = sum
    }
end

-- Add function to get error data
function PerformanceMonitor.getErrorData()
    -- Update lastPeriod based on errors in the last 5 minutes
    local recentErrors = 0
    local currentTime = os.time()
    local periodStart = currentTime - 300 -- 5 minutes
    
    for _, errorInfo in ipairs(errorData.history) do
        if errorInfo.timestamp >= periodStart then
            recentErrors += 1
        end
    end
    
    errorData.lastPeriod = recentErrors
    
    return errorData
end

-- Get most frequently accessed keys
function PerformanceMonitor.getMostAccessedKeys(limit)
    limit = limit or 10 -- Default to top 10
    
    local keyPairs = {}
    for key, count in pairs(keyAccessFrequency) do
        table.insert(keyPairs, {key = key, count = count})
    end
    
    table.sort(keyPairs, function(a, b) return a.count > b.count end)
    
    local result = {}
    for i = 1, math.min(limit, #keyPairs) do
        table.insert(result, keyPairs[i])
    end
    
    return result
end

return PerformanceMonitor