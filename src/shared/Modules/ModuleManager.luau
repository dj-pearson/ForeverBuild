local Logger = require(script.Parent.Logger)

local ModuleManager = {}

-- Module states
local ModuleState = {
    UNINITIALIZED = "UNINITIALIZED",
    INITIALIZING = "INITIALIZING",
    INITIALIZED = "INITIALIZED",
    FAILED = "FAILED"
}

-- Module registry
local modules = {}
local initializationOrder = {}
local initializationStatus = {}

-- Register a module with its dependencies
function ModuleManager.registerModule(name, module, dependencies)
    if modules[name] then
        Logger.error("Module already registered", { moduleName = name })
        return false
    end
    
    modules[name] = {
        instance = module,
        dependencies = dependencies or {},
        state = ModuleState.UNINITIALIZED
    }
    
    Logger.info("Module registered", { moduleName = name, dependencies = dependencies })
    return true
end

-- Check for circular dependencies
local function hasCircularDependency(moduleName, visited, recursionStack)
    visited[moduleName] = true
    recursionStack[moduleName] = true
    
    local module = modules[moduleName]
    if not module then return false end
    
    for _, depName in ipairs(module.dependencies) do
        if not visited[depName] then
            if hasCircularDependency(depName, visited, recursionStack) then
                return true
            end
        elseif recursionStack[depName] then
            return true
        end
    end
    
    recursionStack[moduleName] = false
    return false
end

-- Sort modules by dependencies
local function sortModules()
    local visited = {}
    local temp = {}
    local order = {}
    
    -- Check for circular dependencies
    for moduleName, _ in pairs(modules) do
        if hasCircularDependency(moduleName, {}, {}) then
            Logger.error("Circular dependency detected", { moduleName = moduleName })
            return false
        end
    end
    
    -- Topological sort
    local function visit(moduleName)
        if temp[moduleName] then
            return false
        end
        if visited[moduleName] then
            return true
        end
        
        temp[moduleName] = true
        
        local module = modules[moduleName]
        for _, depName in ipairs(module.dependencies) do
            if not visit(depName) then
                return false
            end
        end
        
        temp[moduleName] = false
        visited[moduleName] = true
        table.insert(order, 1, moduleName)
        return true
    end
    
    for moduleName, _ in pairs(modules) do
        if not visit(moduleName) then
            return false
        end
    end
    
    initializationOrder = order
    return true
end

-- Initialize a single module
local function initializeModule(moduleName)
    local module = modules[moduleName]
    if not module then
        Logger.error("Module not found", { moduleName = moduleName })
        return false
    end
    
    if module.state == ModuleState.INITIALIZED then
        return true
    end
    
    if module.state == ModuleState.INITIALIZING then
        Logger.error("Circular initialization detected", { moduleName = moduleName })
        return false
    end
    
    module.state = ModuleState.INITIALIZING
    Logger.info("Initializing module", { moduleName = moduleName })
    
    local success, result = pcall(function()
        if type(module.instance.init) == "function" then
            return module.instance.init()
        end
        return true
    end)
    
    if success then
        module.state = ModuleState.INITIALIZED
        Logger.info("Module initialized successfully", { moduleName = moduleName })
        return true
    else
        module.state = ModuleState.FAILED
        Logger.error("Module initialization failed", {
            moduleName = moduleName,
            error = result
        })
        return false
    end
end

-- Initialize all modules in the correct order
function ModuleManager.initializeAll()
    if not sortModules() then
        Logger.error("Failed to sort modules")
        return false
    end
    
    Logger.info("Starting module initialization", { order = initializationOrder })
    
    for _, moduleName in ipairs(initializationOrder) do
        if not initializeModule(moduleName) then
            Logger.error("Module initialization failed", { moduleName = moduleName })
            return false
        end
    end
    
    Logger.info("All modules initialized successfully")
    return true
end

-- Get module initialization status
function ModuleManager.getModuleStatus(moduleName)
    local module = modules[moduleName]
    if not module then
        return nil
    end
    return module.state
end

-- Get all module statuses
function ModuleManager.getAllModuleStatuses()
    local statuses = {}
    for name, module in pairs(modules) do
        statuses[name] = module.state
    end
    return statuses
end

return ModuleManager 