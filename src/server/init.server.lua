local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Load shared modules
local Logger = require(ReplicatedStorage.shared.Modules.Logger)
local ModuleManager = require(ReplicatedStorage.shared.Modules.ModuleManager)
local PerformanceManager = require(ReplicatedStorage.shared.Modules.PerformanceManager)
local StateManager = require(ReplicatedStorage.shared.Modules.StateManager)
local NetworkManager = require(ReplicatedStorage.shared.Modules.NetworkManager)
local UIManager = require(ReplicatedStorage.shared.Modules.UIManager)

-- Load server modules
local SecurityManager = require(script.Parent.Modules.Security.SecurityManager)
local GameManager = require(script.Parent.Modules.Game.GameManager)
local SpawnManager = require(script.Parent.Modules.Game.SpawnManager)
local TutorialHandler = require(script.Parent.Modules.Tutorial.TutorialHandler)
local FriendManager = require(script.Parent.Modules.Social.FriendManager)
local SocialHubManager = require(script.Parent.Modules.Social.SocialHubManager)
local SocialInteractionManager = require(script.Parent.Modules.Social.SocialInteractionManager)
local PlayerProfileManager = require(script.Parent.Modules.Social.PlayerProfileManager)
local SocialMediaManager = require(script.Parent.Modules.Social.SocialMediaManager)
local BuildingToolsManager = require(script.Parent.Modules.Building.BuildingToolsManager)
local BuildingTemplateManager = require(script.Parent.Modules.Building.BuildingTemplateManager)
local BuildingChallengeManager = require(script.Parent.Modules.Building.BuildingChallengeManager)
local ProgressionManager = require(script.Parent.Modules.ProgressionManager)

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

Logger.info("Server initialization completed") 