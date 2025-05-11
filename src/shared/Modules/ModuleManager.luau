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

return ModuleManager 