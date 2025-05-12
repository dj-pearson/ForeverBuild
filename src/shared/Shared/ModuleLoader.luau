local ModuleLoader = {}

-- Track module loading depth to detect potential stack overflow
local loadingDepth = 0
local MAX_LOADING_DEPTH = 25  -- Reduced from 50 to catch issues earlier
local moduleLoadStack = {}
local moduleLoadHistory = {}  -- Track all module loads for analysis

-- Module status constants
local ModuleStatus = {
    NOT_LOADED = "NOT_LOADED",
    LOADING = "LOADING",
    LOADED = "LOADED",
    ERROR = "ERROR"
}

-- Cache for loaded modules
local loadedModules = {}
local moduleStatuses = {}
local moduleErrors = {}

-- Configuration
ModuleLoader.config = {
    strictMode = true,
    logLevel = "debug", -- Changed to debug for more verbose logging
    maxCacheSize = 100,
    maxRetries = 3,
    retryDelay = 0.1,
    diagnosticMode = true  -- Enable diagnostic mode
}

-- Helper function to log messages
local function log(level, message)
    local levels = {
        debug = 1,
        info = 2,
        warn = 3,
        error = 4
    }
    
    if levels[level] >= levels[ModuleLoader.config.logLevel] then
        if level == "error" then
            error(message)
        else
            print("[ModuleLoader:" .. level:upper() .. "] " .. message)
        end
    end
end

-- Debug logging with stack trace and module history
local function debugLog(message)
    local stackTrace = debug.traceback()
    print("[ModuleLoader] " .. message)
    if ModuleLoader.config.diagnosticMode then
        print("[ModuleLoader] Stack trace:")
        print(stackTrace)
        print("[ModuleLoader] Module load history:")
        for i, entry in ipairs(moduleLoadHistory) do
            print(string.format("%d: %s (depth: %d)", i, entry.path, entry.depth))
        end
    end
end

-- Analyze module dependencies
local function analyzeDependencies()
    local dependencies = {}
    local circularDeps = {}
    
    -- Build dependency graph
    for _, entry in ipairs(moduleLoadHistory) do
        if not dependencies[entry.path] then
            dependencies[entry.path] = {
                requires = {},
                requiredBy = {},
                depth = entry.depth
            }
        end
    end
    
    -- Find potential circular dependencies
    for path, info in pairs(dependencies) do
        local visited = {}
        local function checkCircular(current, start)
            if visited[current] then
                if current == start then
                    table.insert(circularDeps, {start = start, path = current})
                end
                return
            end
            visited[current] = true
            for _, req in ipairs(info.requires) do
                checkCircular(req, start)
            end
        end
        checkCircular(path, path)
    end
    
    return {
        dependencies = dependencies,
        circularDeps = circularDeps,
        maxDepth = #moduleLoadHistory > 0 and moduleLoadHistory[#moduleLoadHistory].depth or 0
    }
end

-- Get a module with stack tracking and retry logic
function ModuleLoader.getModule(modulePath)
    -- Record this load attempt
    table.insert(moduleLoadHistory, {
        path = tostring(modulePath),
        depth = loadingDepth + 1,
        timestamp = os.time()
    })
    
    -- Check if we're too deep in the loading stack
    loadingDepth = loadingDepth + 1
    debugLog(string.format("Loading module: %s (depth: %d)", modulePath, loadingDepth))
    
    if loadingDepth > MAX_LOADING_DEPTH then
        debugLog("STACK OVERFLOW DETECTED!")
        debugLog("Current loading stack:")
        for i, path in ipairs(moduleLoadStack) do
            debugLog(string.format("%d: %s", i, path))
        end
        debugLog("Attempting to load: " .. tostring(modulePath))
        
        -- Analyze dependencies when overflow occurs
        if ModuleLoader.config.diagnosticMode then
            local analysis = analyzeDependencies()
            debugLog("Dependency Analysis:")
            debugLog("Max depth reached: " .. analysis.maxDepth)
            if #analysis.circularDeps > 0 then
                debugLog("Potential circular dependencies found:")
                for _, dep in ipairs(analysis.circularDeps) do
                    debugLog(string.format("  %s -> %s", dep.start, dep.path))
                end
            end
        end
        
        error("Module loading stack overflow detected")
    end

    -- Add current module to stack
    table.insert(moduleLoadStack, tostring(modulePath))
    debugLog("Current module stack: " .. table.concat(moduleLoadStack, " -> "))

    -- Check if module is already loaded
    if loadedModules[modulePath] then
        debugLog("Module already loaded: " .. modulePath)
        table.remove(moduleLoadStack)
        loadingDepth = loadingDepth - 1
        return loadedModules[modulePath]
    end
    
    -- Check if module is currently loading (circular dependency)
    if moduleStatuses[modulePath] == ModuleStatus.LOADING then
        local errorMsg = "Circular dependency detected for module: " .. modulePath
        debugLog(errorMsg)
        log("error", errorMsg)
        return nil
    end
    
    -- Mark module as loading
    moduleStatuses[modulePath] = ModuleStatus.LOADING
    debugLog("Marked module as loading: " .. modulePath)
    
    -- Try to load the module with retries
    local retryCount = 0
    local lastError = nil
    
    while retryCount < ModuleLoader.config.maxRetries do
        local success, result = pcall(function()
            return require(modulePath)
        end)
        
        if success then
            -- Cache the module
            loadedModules[modulePath] = result
            moduleStatuses[modulePath] = ModuleStatus.LOADED
            debugLog("Successfully loaded and cached module: " .. modulePath)
            
            -- Enforce cache size limit
            if #loadedModules > ModuleLoader.config.maxCacheSize then
                local oldestKey = next(loadedModules)
                loadedModules[oldestKey] = nil
                moduleStatuses[oldestKey] = nil
                debugLog("Removed oldest module from cache: " .. oldestKey)
            end
            
            -- Remove current module from stack
            table.remove(moduleLoadStack)
            loadingDepth = loadingDepth - 1
            
            return result
        end
        
        lastError = result
        retryCount = retryCount + 1
        debugLog(string.format("Retry %d/%d loading module %s: %s", 
            retryCount, ModuleLoader.config.maxRetries, modulePath, lastError))
        
        if retryCount < ModuleLoader.config.maxRetries then
            task.wait(ModuleLoader.config.retryDelay)
        end
    end
    
    -- If we get here, all retries failed
    moduleStatuses[modulePath] = ModuleStatus.ERROR
    moduleErrors[modulePath] = lastError
    debugLog("Failed to load module after " .. retryCount .. " retries: " .. modulePath .. " - " .. tostring(lastError))
    log("error", "Failed to load module: " .. modulePath .. " - " .. tostring(lastError))
    
    -- Remove current module from stack
    table.remove(moduleLoadStack)
    loadingDepth = loadingDepth - 1
    
    return nil
end

-- Clear the module cache and history
function ModuleLoader.clearCache()
    loadedModules = {}
    moduleStatuses = {}
    moduleErrors = {}
    loadingDepth = 0
    moduleLoadStack = {}
    moduleLoadHistory = {}
    log("info", "Module cache and history cleared")
end

-- Get module status
function ModuleLoader.getModuleStatus(modulePath)
    return moduleStatuses[modulePath] or ModuleStatus.NOT_LOADED
end

-- Get module error if any
function ModuleLoader.getModuleError(modulePath)
    return moduleErrors[modulePath]
end

-- Get all module statuses
function ModuleLoader.getAllModuleStatuses()
    local statuses = {}
    for path, status in pairs(moduleStatuses) do
        statuses[path] = {
            status = status,
            error = moduleErrors[path]
        }
    end
    return statuses
end

-- Get current loading stack
function ModuleLoader.getLoadingStack()
    return moduleLoadStack
end

-- Get current loading depth
function ModuleLoader.getLoadingDepth()
    return loadingDepth
end

-- Get module load history
function ModuleLoader.getModuleLoadHistory()
    return moduleLoadHistory
end

-- Analyze module dependencies
function ModuleLoader.analyzeDependencies()
    return analyzeDependencies()
end

return ModuleLoader 