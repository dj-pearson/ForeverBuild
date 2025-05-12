--[[
    ModuleDependencyManager
    Manages module dependencies and initialization order.
    
    @class ModuleDependencyManager
]]

local ModuleDependencyManager = {}
ModuleDependencyManager.__index = ModuleDependencyManager

-- Create a new ModuleDependencyManager instance
function ModuleDependencyManager.new()
    local self = setmetatable({
        modules = {},
        dependencies = {},
        initialized = {},
    }, ModuleDependencyManager)
    return self
end

-- Register a module with its dependencies
function ModuleDependencyManager:registerModule(moduleName: string, dependencies: {string})
    self.modules[moduleName] = true
    self.dependencies[moduleName] = dependencies or {}
end

-- Check if a module has all its dependencies initialized
local function checkDependencies(self: ModuleDependencyManager, moduleName: string): boolean
    local deps = self.dependencies[moduleName]
    if not deps then return true end
    
    for _, dep in deps do
        if not self.initialized[dep] then
            return false
        end
    end
    return true
end

-- Initialize a module and its dependencies
function ModuleDependencyManager:initializeModule(moduleName: string, initFunction: () -> ()): boolean
    if self.initialized[moduleName] then
        return true
    end
    
    -- Check if all dependencies are initialized
    if not checkDependencies(self, moduleName) then
        warn("Module", moduleName, "has uninitialized dependencies")
        return false
    end
    
    -- Initialize the module
    local success, err = pcall(initFunction)
    if not success then
        warn("Failed to initialize module", moduleName, ":", err)
        return false
    end
    
    self.initialized[moduleName] = true
    return true
end

-- Initialize all modules in the correct order
function ModuleDependencyManager:initializeAll(moduleInitFunctions: {[string]: () -> ()}): boolean
    local initialized = false
    local maxAttempts = #self.modules * 2 -- Prevent infinite loops
    
    while not initialized and maxAttempts > 0 do
        initialized = true
        for moduleName, initFunction in moduleInitFunctions do
            if not self.initialized[moduleName] then
                if not self:initializeModule(moduleName, initFunction) then
                    initialized = false
                end
            end
        end
        maxAttempts -= 1
    end
    
    if not initialized then
        warn("Failed to initialize all modules after maximum attempts")
        return false
    end
    
    return true
end

-- Check if a module is initialized
function ModuleDependencyManager:isInitialized(moduleName: string): boolean
    return self.initialized[moduleName] or false
end

-- Get initialization status of all modules
function ModuleDependencyManager:getInitializationStatus(): {[string]: boolean}
    local status = {}
    for moduleName in self.modules do
        status[moduleName] = self.initialized[moduleName] or false
    end
    return status
end

return ModuleDependencyManager.new() 