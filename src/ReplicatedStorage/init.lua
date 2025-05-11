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
local remotesFolder = ensureFolder(sharedFolder, "Remotes")

-- Initialize the shared module resolver
local SharedModuleResolver = require(script.SharedModuleResolver)
local sharedResolver = SharedModuleResolver.new()

-- Initialize core modules
local ModuleManager = require(modulesFolder.ModuleManager)
local RemoteManager = require(modulesFolder.RemoteManager)
local Constants = require(modulesFolder.Constants)

-- Initialize the module manager
ModuleManager.init()

-- Create remote events
for _, eventName in pairs(Constants.RemoteEvents) do
    local remote = Instance.new("RemoteEvent")
    remote.Name = eventName
    remote.Parent = remotesFolder
end

-- Create remote functions
for _, functionName in pairs(Constants.RemoteFunctions) do
    local remote = Instance.new("RemoteFunction")
    remote.Name = functionName
    remote.Parent = remotesFolder
end

-- Return the initialized shared system
return {
    Modules = sharedResolver,
    Types = typesFolder,
    Remotes = remotesFolder,
    ModuleManager = ModuleManager,
    RemoteManager = RemoteManager,
    Constants = Constants,
    getModule = function(moduleName)
        return sharedResolver:getModule(moduleName)
    end,
    getType = function(typeName)
        return sharedResolver:getType(typeName)
    end
} 