--luau
-- DataStore Plugin/CacheManager.luau

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

local CacheManager = {}

local cacheHits = 0
local cacheMisses = 0

local cache = {} 
local cacheSizeLimit = 100 -- Maximum number of items in the cache
local lastAccessed = {} -- Table to track the last access time for each cache entry
local AVERAGE_ENTRY_SIZE = 1024 -- Average size of a cache entry in bytes (1KB) - Adjust as needed
local DEFAULT_DURATION = 60 -- Default duration for cache entries (in seconds)





local function estimateValueSize(value)
	local valueType = typeof(value)

	if valueType == "string" then
		-- Estimate string size based on length (assuming 1 byte per character)
		return #value
	elseif valueType == "number" or valueType == "boolean" then
		-- Fixed size for numbers and booleans (8 bytes for number, 1 for boolean)
		return valueType == "number" and 8 or 1
	elseif valueType == "table" then
		-- Recursively estimate the size of table contents
		local tableSize = 0
		for _, v in pairs(value) do
			tableSize = tableSize + estimateValueSize(v)
		end
		return tableSize
	else
		-- For other types, return 0 (or a small fixed size if you prefer)
		return 0
	end
end

-- Stores data in the cache with an optional expiration duration (in seconds)
function CacheManager.set(dataStoreName, keyName, data, duration)
    local cacheKey = dataStoreName .. "_" .. keyName
    local expirationTime = duration and (os.time() + duration) or nil
	local entry = {
        data = data,
        expirationTime = expirationTime,
		lastAccessed = os.time(),
		accessCount = 0
    }

	cache[cacheKey] = entry
	lastAccessed[cacheKey] = os.time()

		-- Check if we need to remove oldest entries to maintain cache size limit
	if table.getn(cache) > cacheSizeLimit then
		local oldestKey
		local oldestTime = math.huge
		for key, entry in pairs(cache) do
			if entry.lastAccessed < oldestTime then
				oldestTime = entry.lastAccessed
				oldestKey = key
			end
		end
		if oldestKey then
			cache[oldestKey] = nil
			lastAccessed[oldestKey] = nil
		end
	end
end



-- Retrieves data from the cache. Returns data if found and not expired, otherwise returns nil.
function CacheManager.get(dataStoreName, keyName)
    local cacheKey = dataStoreName .. "_" .. keyName
    local cachedEntry = cache[cacheKey]

    if cachedEntry then
        if cachedEntry.expirationTime and os.time() > cachedEntry.expirationTime then
            -- Cache entry expired, remove it
            cache[cacheKey] = nil
            cacheMisses = cacheMisses + 1
            return nil
        else
            -- Cache entry is valid
			cachedEntry.accessCount = cachedEntry.accessCount + 1
			lastAccessed[cacheKey] = os.time()
            cacheHits = cacheHits + 1
            return cachedEntry.data
        end
    else
		cacheMisses = cacheMisses + 1

    
        


        -- No cache entry found
        return nil
    end
end

-- Removes a specific entry from the cache.
function CacheManager.invalidate(dataStoreName, keyName)
	local cacheKey = dataStoreName .. "_" .. keyName
	cache[cacheKey] = nil
end

-- Clears the entire cache
function CacheManager.clear()
	cache = {}
	lastAccessed = {}
end

-- Returns the cache hit and miss counts
function CacheManager.getCacheAnalytics()
	return {
		hits = cacheHits,
		misses = cacheMisses
	}
end

-- Returns a table representing the current contents of the cache, excluding expired entries.
function CacheManager.getCacheContents()
	local contents = {}
	for cacheKey, entry in pairs(cache) do
		if not entry.expirationTime or os.time() <= entry.expirationTime then
			local dataStoreName, keyName = cacheKey:match("(.+)_(.+)")
			if dataStoreName and keyName then
				contents[cacheKey] = {
					dataStoreName = dataStoreName,
					keyName = keyName,
					-- You might want to include more info about the data here (e.g., type, summary)
				}
			end
		end
	end
	return contents
end

-- Estimates the total memory usage of the in-memory cache.
function CacheManager.estimateMemoryUsage()
	local totalSize = 0

	-- Iterate through all values in the cache and estimate their sizes
	for _, entry in pairs(cache) do
		totalSize = totalSize + estimateValueSize(entry.data)
	end

	return totalSize
end



function CacheManager.setCacheSizeLimit(size)
	if typeof(size) == "number" then
		cacheSizeLimit = size
	end
end

-- Adjusts cache entry expiration times based on access count
function CacheManager.optimizeCacheDurations()
	for cacheKey, entry in pairs(cache) do
		if entry.accessCount > 10 then
			-- Increase expiration for frequently accessed entries
			entry.expirationTime = entry.expirationTime and math.max(entry.expirationTime, os.time() + (DEFAULT_DURATION * 2))
		elseif entry.accessCount < 2 then
			-- Shorten expiration for rarely accessed entries
			entry.expirationTime = entry.expirationTime and math.min(entry.expirationTime, os.time() + (DEFAULT_DURATION / 2))
		end
		-- Reset access count to prevent infinite extension
		entry.accessCount = 0
	end
end




return CacheManager