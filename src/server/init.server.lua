local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Ensure Remotes folder exists
if not ReplicatedStorage:FindFirstChild("Remotes") then
    local remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

-- Load shared and server modules
local Logger = require(ReplicatedStorage.Shared.Modules.Logger)
local ModuleManager = require(ReplicatedStorage.Shared.Modules.ModuleManager)
local PerformanceManager = require(ReplicatedStorage.Shared.Modules.PerformanceManager)
local StateManager = require(ReplicatedStorage.Shared.Modules.StateManager)
local NetworkManager = require(ReplicatedStorage.Shared.Modules.NetworkManager)
local UIManager = require(ReplicatedStorage.Shared.Modules.UIManager)

-- Load server modules
local SecurityManager = require(ServerScriptService.Server.Modules.Security.SecurityManager)
local GameManager = require(ServerScriptService.Server.Modules.Game.GameManager)
local SpawnManager = require(ServerScriptService.Server.Modules.Game.SpawnManager)
local TutorialHandler = require(ServerScriptService.Server.Modules.Tutorial.TutorialHandler)
local FriendManager = require(ServerScriptService.Server.Modules.Social.FriendManager)
local SocialHubManager = require(ServerScriptService.Server.Modules.Social.SocialHubManager)
local SocialInteractionManager = require(ServerScriptService.Server.Modules.Social.SocialInteractionManager)
local PlayerProfileManager = require(ServerScriptService.Server.Modules.Social.PlayerProfileManager)
local SocialMediaManager = require(ServerScriptService.Server.Modules.Social.SocialMediaManager)
local BuildingToolsManager = require(ServerScriptService.Server.Modules.Building.BuildingToolsManager)
local BuildingTemplateManager = require(ServerScriptService.Server.Modules.Building.BuildingTemplateManager)
local BuildingChallengeManager = require(ServerScriptService.Server.Modules.Building.BuildingChallengeManager)
local ProgressionManager = require(ServerScriptService.Server.Modules.ProgressionManager)
local AchievementManager = require(ServerScriptService.Server.Modules.AchievementManager)

-- Initialize Logger first
Logger.init()

-- Initialize ModuleManager
ModuleManager.init()

-- Register modules in correct order
ModuleManager.registerModule("PerformanceManager", PerformanceManager)
ModuleManager.registerModule("SecurityManager", SecurityManager)
ModuleManager.registerModule("StateManager", StateManager)
ModuleManager.registerModule("NetworkManager", NetworkManager)
ModuleManager.registerModule("UIManager", UIManager)
ModuleManager.registerModule("GameManager", GameManager, {})
ModuleManager.registerModule("SpawnManager", SpawnManager, { "GameManager" })
ModuleManager.registerModule("TutorialHandler", TutorialHandler, { "GameManager", "SecurityManager", "PerformanceManager" })
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

-- Set up periodic cleanup
task.spawn(function()
    while true do
        task.wait(300) -- Every 5 minutes
        PerformanceManager.cleanup()
        NetworkManager.cleanup()
    end
end)

-- Set up periodic state sync
task.spawn(function()
    while true do
        task.wait(1/30) -- 30 times per second
        StateManager.syncState()
    end
end)

-- Initialize modules
BuildingToolsManager.init()
BuildingTemplateManager.init()
BuildingChallengeManager.init()
ProgressionManager.init()
AchievementManager.init()

Logger.info("Server initialization completed") 