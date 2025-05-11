local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModuleResolver = {}
SharedModuleResolver.__index = SharedModuleResolver

-- Create necessary folders if they don't exist
local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

-- Initialize the resolver
function SharedModuleResolver.new()
    local self = setmetatable({}, SharedModuleResolver)
    self.sharedFolder = ensureFolder(ReplicatedStorage, "Shared")
    self.modulesFolder = ensureFolder(self.sharedFolder, "Modules")
    self.typesFolder = ensureFolder(self.sharedFolder, "Types")
    self.moduleCache = {}
    self.typeCache = {}
    return self
end

-- Get a module from the Modules folder
function SharedModuleResolver:getModule(moduleName)
    -- Check cache first
    if self.moduleCache[moduleName] then
        return self.moduleCache[moduleName]
    end
    
    -- Try to find the module
    local module = self.modulesFolder:FindFirstChild(moduleName)
    if not module then
        warn("SharedModuleResolver: Module not found:", moduleName)
        return nil
    end
    
    -- Load and cache the module
    local success, result = pcall(function()
        return require(module)
    end)
    
    if success then
        self.moduleCache[moduleName] = result
        return result
    else
        warn("SharedModuleResolver: Failed to load module:", moduleName, "-", result)
        return nil
    end
end

-- Get a type definition from the Types folder
function SharedModuleResolver:getType(typeName)
    -- Check cache first
    if self.typeCache[typeName] then
        return self.typeCache[typeName]
    end
    
    -- Try to find the type
    local typeModule = self.typesFolder:FindFirstChild(typeName)
    if not typeModule then
        warn("SharedModuleResolver: Type not found:", typeName)
        return nil
    end
    
    -- Load and cache the type
    local success, result = pcall(function()
        return require(typeModule)
    end)
    
    if success then
        self.typeCache[typeName] = result
        return result
    else
        warn("SharedModuleResolver: Failed to load type:", typeName, "-", result)
        return nil
    end
end

-- Get all available modules
function SharedModuleResolver:getAllModules()
    local modules = {}
    for _, module in ipairs(self.modulesFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local success, result = pcall(function()
                return require(module)
            end)
            if success then
                modules[module.Name] = result
                self.moduleCache[module.Name] = result
            else
                warn("SharedModuleResolver: Failed to load module:", module.Name, "-", result)
            end
        end
    end
    return modules
end

-- Get all available types
function SharedModuleResolver:getAllTypes()
    local types = {}
    for _, typeModule in ipairs(self.typesFolder:GetChildren()) do
        if typeModule:IsA("ModuleScript") then
            local success, result = pcall(function()
                return require(typeModule)
            end)
            if success then
                types[typeModule.Name] = result
                self.typeCache[typeModule.Name] = result
            else
                warn("SharedModuleResolver: Failed to load type:", typeModule.Name, "-", result)
            end
        end
    end
    return types
end

return SharedModuleResolver 