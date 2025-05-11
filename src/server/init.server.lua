local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

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
local serverFolder = ensureFolder(ServerScriptService, "server")
local modulesFolder = ensureFolder(serverFolder, "Modules")

-- Initialize the server module resolver
local ServerModuleResolver = require(script.ServerModuleResolver)
local serverResolver = ServerModuleResolver.new()

-- Initialize the remote manager
local RemoteManager = require(ReplicatedStorage.Shared.RemoteManager)
local remoteManager = RemoteManager.new()

-- Load shared modules using the shared resolver
local Shared = require(ReplicatedStorage.Shared)
local Logger = Shared.getModule("Logger")
local ModuleManager = Shared.getModule("ModuleManager")
local PerformanceManager = Shared.getModule("PerformanceManager")
local StateManager = Shared.getModule("StateManager")
local NetworkManager = Shared.getModule("NetworkManager")
local UIManager = Shared.getModule("UIManager")

-- Load server modules using the server resolver
local SecurityManager = serverResolver:getModule("Security.SecurityManager")
local GameManager = serverResolver:getModule("Game.GameManager")
local SpawnManager = serverResolver:getModule("Game.SpawnManager")
local FriendManager = serverResolver:getModule("Social.FriendManager")
local SocialHubManager = serverResolver:getModule("Social.SocialHubManager")
local SocialInteractionManager = serverResolver:getModule("Social.SocialInteractionManager")
local PlayerProfileManager = serverResolver:getModule("Social.PlayerProfileManager")
local SocialMediaManager = serverResolver:getModule("Social.SocialMediaManager")
local BuildingToolsManager = serverResolver:getModule("Building.BuildingToolsManager")
local BuildingTemplateManager = serverResolver:getModule("Building.BuildingTemplateManager")
local BuildingChallengeManager = serverResolver:getModule("Building.BuildingChallengeManager")
local ProgressionManager = serverResolver:getModule("Progression.ProgressionManager")
local AchievementManager = serverResolver:getModule("Achievement.AchievementManager")
local DataStoreManager = serverResolver:getModule("Data.DataStoreManager")
local TutorialHandler = serverResolver:getModule("Tutorial.TutorialHandler")

-- Initialize Logger first
if Logger then
    Logger.init()
end

-- Initialize ModuleManager
if ModuleManager then
    ModuleManager.init()
    
    -- Register modules in correct order
    ModuleManager.registerModule("PerformanceManager", PerformanceManager)
    ModuleManager.registerModule("SecurityManager", SecurityManager)
    ModuleManager.registerModule("StateManager", StateManager)
    ModuleManager.registerModule("NetworkManager", NetworkManager)
    ModuleManager.registerModule("UIManager", UIManager)
    ModuleManager.registerModule("GameManager", GameManager, {})
    ModuleManager.registerModule("SpawnManager", SpawnManager, { "GameManager" })
    ModuleManager.registerModule("FriendManager", FriendManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("SocialHubManager", SocialHubManager, { "GameManager", "SecurityManager", "PerformanceManager" })
    ModuleManager.registerModule("SocialInteractionManager", SocialInteractionManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("PlayerProfileManager", PlayerProfileManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("SocialMediaManager", SocialMediaManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("BuildingToolsManager", BuildingToolsManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("BuildingTemplateManager", BuildingTemplateManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("BuildingChallengeManager", BuildingChallengeManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("ProgressionManager", ProgressionManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("AchievementManager", AchievementManager, { "GameManager", "SecurityManager", "ProgressionManager" })
    
    -- Initialize all modules
    ModuleManager.initializeAll()
end

-- Set up periodic cleanup
task.spawn(function()
    while true do
        task.wait(300) -- Every 5 minutes
        if PerformanceManager then PerformanceManager.cleanup() end
        if NetworkManager then NetworkManager.cleanup() end
    end
end)

-- Set up periodic state sync
task.spawn(function()
    while true do
        task.wait(1/30) -- 30 times per second
        if StateManager then StateManager.syncState() end
    end
end)

-- Initialize individual modules if they exist
if BuildingToolsManager then BuildingToolsManager.init() end
if BuildingTemplateManager then BuildingTemplateManager.init() end
if BuildingChallengeManager then BuildingChallengeManager.init() end
if ProgressionManager then ProgressionManager.init() end
if AchievementManager then AchievementManager.init() end
if DataStoreManager then DataStoreManager:Initialize() end
if TutorialHandler then TutorialHandler.init() end

if Logger then
    Logger.info("Server initialization completed")
end

-- Return the initialized server system
return {
    Initialize = function()
        print("Server: All systems initialized successfully")
    end,
    Modules = serverResolver,
    Remotes = remoteManager,
    getModule = function(modulePath)
        return serverResolver:getModule(modulePath)
    end,
    getModulesInFolder = function(folderPath)
        return serverResolver:getModulesInFolder(folderPath)
    end
} 