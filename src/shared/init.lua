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
local SharedModuleResolver = require(script.Parent.SharedModuleResolver)
local sharedResolver = SharedModuleResolver.new()

-- Initialize the remote manager
local RemoteManager = require(script.Parent.RemoteManager)
local remoteManager = RemoteManager.new()

-- Initialize the remote event manager
local RemoteEventManager = require(script.Parent.RemoteEventManager)
local remoteEventManager = RemoteEventManager.new()

-- Initialize the achievement manager
local AchievementManager = require(script.Parent.AchievementManager)
local achievementManager = AchievementManager.new()

-- Return the initialized shared system
return {
    Modules = sharedResolver,
    Remotes = remoteManager,
    RemoteEvents = remoteEventManager,
    Achievements = achievementManager,
    getModule = function(moduleName)
        return sharedResolver:getModule(moduleName)
    end,
    getType = function(typeName)
        return sharedResolver:getType(typeName)
    end
} 