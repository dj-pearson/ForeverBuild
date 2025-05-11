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
    return self
end

-- Get a module from the Modules folder
function SharedModuleResolver:getModule(moduleName)
    local module = self.modulesFolder:FindFirstChild(moduleName)
    if not module then
        warn("SharedModuleResolver: Module not found:", moduleName)
        return nil
    end
    return require(module)
end

-- Get a type definition from the Types folder
function SharedModuleResolver:getType(typeName)
    local typeModule = self.typesFolder:FindFirstChild(typeName)
    if not typeModule then
        warn("SharedModuleResolver: Type not found:", typeName)
        return nil
    end
    return require(typeModule)
end

-- Get all available modules
function SharedModuleResolver:getAllModules()
    local modules = {}
    for _, module in ipairs(self.modulesFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            modules[module.Name] = require(module)
        end
    end
    return modules
end

-- Get all available types
function SharedModuleResolver:getAllTypes()
    local types = {}
    for _, typeModule in ipairs(self.typesFolder:GetChildren()) do
        if typeModule:IsA("ModuleScript") then
            types[typeModule.Name] = require(typeModule)
        end
    end
    return types
end

return SharedModuleResolver 