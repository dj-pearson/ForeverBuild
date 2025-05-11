local Logger = require(script.Parent.Logger)

local ModuleManager = {}
ModuleManager.__index = ModuleManager

-- Module status constants
local ModuleStatus = {
    NOT_LOADED = "NOT_LOADED",
    LOADING = "LOADING",
    LOADED = "LOADED",
    ERROR = "ERROR"
}

-- Cache for loaded modules
local loadedModules = {}

-- Configuration
ModuleManager.config = {
    autoReload = false,
    strictMode = true,
    logLevel = "warn", -- "debug", "info", "warn", "error"
    maxCacheSize = 100,
    cacheTimeout = 300, -- 5 minutes
}

-- Module loading statistics
ModuleManager.stats = {
    totalLoads = 0,
    cacheHits = 0,
    loadErrors = 0,
    lastLoadTime = 0,
    averageLoadTime = 0
}

-- Helper function to log messages
local function log(level, message)
    local levels = {
        debug = 1,
        info = 2,
        warn = 3,
        error = 4
    }
    
    if levels[level] >= levels[ModuleManager.config.logLevel] then
        if level == "error" then
            error(message)
        else
            print("[ModuleManager:" .. level:upper() .. "] " .. message)
        end
    end
end

-- Initialize the ModuleManager
function ModuleManager.new()
    local self = setmetatable({}, ModuleManager)
    self.modules = {}
    self.moduleStatuses = {}
    self.moduleErrors = {}
    return self
end

-- Register a module with its dependencies
function ModuleManager:registerModule(name, module, dependencies)
    if not name or not module then
        warn("ModuleManager: Invalid module registration - name and module are required")
        return false
    end

    self.modules[name] = {
        module = module,
        dependencies = dependencies or {},
        status = ModuleStatus.NOT_LOADED
    }
    return true
end

-- Get a module's status
function ModuleManager:getModuleStatus(name)
    return self.modules[name] and self.modules[name].status or ModuleStatus.NOT_LOADED
end

-- Get a module's error if any
function ModuleManager:getModuleError(name)
    return self.moduleErrors[name]
end

-- Get all module statuses
function ModuleManager:getAllModuleStatuses()
    local statuses = {}
    for name, moduleData in pairs(self.modules) do
        statuses[name] = {
            status = moduleData.status,
            error = self.moduleErrors[name]
        }
    end
    return statuses
end

-- Check if a module's dependencies are loaded
local function checkDependencies(moduleData, moduleStatuses)
    for _, depName in ipairs(moduleData.dependencies) do
        local depStatus = moduleStatuses[depName]
        if not depStatus or depStatus ~= ModuleStatus.LOADED then
            return false
        end
    end
    return true
end

-- Initialize a single module
function ModuleManager:initializeModule(name)
    local moduleData = self.modules[name]
    if not moduleData then
        warn("ModuleManager: Module not found:", name)
        return false
    end

    -- Skip if already loaded or loading
    if moduleData.status == ModuleStatus.LOADED then
        return true
    end
    if moduleData.status == ModuleStatus.LOADING then
        warn("ModuleManager: Circular dependency detected for module:", name)
        return false
    end

    -- Check dependencies
    if not checkDependencies(moduleData, self.moduleStatuses) then
        warn("ModuleManager: Dependencies not met for module:", name)
        return false
    end

    -- Mark as loading
    moduleData.status = ModuleStatus.LOADING
    self.moduleStatuses[name] = ModuleStatus.LOADING

    -- Initialize the module
    local success, err = pcall(function()
        if type(moduleData.module.init) == "function" then
            moduleData.module.init()
        end
    end)

    if success then
        moduleData.status = ModuleStatus.LOADED
        self.moduleStatuses[name] = ModuleStatus.LOADED
        return true
    else
        moduleData.status = ModuleStatus.ERROR
        self.moduleStatuses[name] = ModuleStatus.ERROR
        self.moduleErrors[name] = err
        warn("ModuleManager: Failed to initialize module:", name, "- Error:", err)
        return false
    end
end

-- Initialize all modules
function ModuleManager:initializeAll()
    local success = true
    local maxAttempts = #self.modules
    local attempts = 0

    while attempts < maxAttempts do
        local allLoaded = true
        local anyProgress = false

        for name, moduleData in pairs(self.modules) do
            if moduleData.status ~= ModuleStatus.LOADED then
                allLoaded = false
                if self:initializeModule(name) then
                    anyProgress = true
                end
            end
        end

        if allLoaded then
            return true
        end

        if not anyProgress then
            -- No progress made in this iteration, some modules must have failed
            success = false
            break
        end

        attempts += 1
    end

    return success
end

-- Get a module by name
function ModuleManager:getModule(name)
    local moduleData = self.modules[name]
    if not moduleData then
        warn("ModuleManager: Module not found:", name)
        return nil
    end
    return moduleData.module
end

-- Load a module with error handling
function ModuleManager.loadModule(modulePath)
    local startTime = os.clock()
    
    -- Check cache first
    if loadedModules[modulePath] then
        ModuleManager.stats.cacheHits += 1
        return loadedModules[modulePath]
    end
    
    -- Try to load the module
    local success, result = pcall(function()
        return require(modulePath)
    end)
    
    -- Update statistics
    ModuleManager.stats.totalLoads += 1
    local loadTime = os.clock() - startTime
    ModuleManager.stats.lastLoadTime = loadTime
    ModuleManager.stats.averageLoadTime = (ModuleManager.stats.averageLoadTime * (ModuleManager.stats.totalLoads - 1) + loadTime) / ModuleManager.stats.totalLoads
    
    if success then
        -- Cache the module
        loadedModules[modulePath] = result
        
        -- Enforce cache size limit
        if #loadedModules > ModuleManager.config.maxCacheSize then
            local oldestKey = next(loadedModules)
            loadedModules[oldestKey] = nil
        end
        
        log("debug", "Successfully loaded module: " .. modulePath)
        return result
    else
        ModuleManager.stats.loadErrors += 1
        log("error", "Failed to load module: " .. modulePath .. " - " .. tostring(result))
        return nil
    end
end

-- Unload a module from cache
function ModuleManager.unloadModule(modulePath)
    if loadedModules[modulePath] then
        loadedModules[modulePath] = nil
        log("debug", "Unloaded module from cache: " .. modulePath)
        return true
    end
    return false
end

-- Clear the module cache
function ModuleManager.clearCache()
    loadedModules = {}
    log("info", "Module cache cleared")
end

-- Get module loading statistics
function ModuleManager.getStats()
    return {
        totalLoads = ModuleManager.stats.totalLoads,
        cacheHits = ModuleManager.stats.cacheHits,
        loadErrors = ModuleManager.stats.loadErrors,
        lastLoadTime = ModuleManager.stats.lastLoadTime,
        averageLoadTime = ModuleManager.stats.averageLoadTime,
        cacheSize = #loadedModules
    }
end

-- Initialize the ModuleManager
function ModuleManager.initialize(config)
    if config then
        for key, value in pairs(config) do
            if ModuleManager.config[key] ~= nil then
                ModuleManager.config[key] = value
            end
        end
    end
    
    log("info", "ModuleManager initialized with config: " .. game:GetService("HttpService"):JSONEncode(ModuleManager.config))
    return true
end

return ModuleManager 