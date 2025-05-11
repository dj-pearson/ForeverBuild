local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Ensure required folders exist
local sharedFolder = ensureFolder(ReplicatedStorage, "Shared")
local modulesFolder = ensureFolder(sharedFolder, "Modules")
local typesFolder = ensureFolder(sharedFolder, "Types")

-- Initialize the shared module resolver
local SharedModuleResolver = require(script.SharedModuleResolver)
local sharedResolver = SharedModuleResolver.new()

-- Return the initialized shared system
return {
    Modules = sharedResolver,
    getModule = function(moduleName)
        return sharedResolver:getModule(moduleName)
    end,
    getType = function(typeName)
        return sharedResolver:getType(typeName)
    end
} 