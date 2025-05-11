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

-- Load shared system
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local ModuleManager = Shared.ModuleManager
local RemoteManager = Shared.RemoteManager

-- Initialize core modules
local function initializeCoreModules()
    local coreModules = {
        -- Security and Performance
        SecurityManager = require(modulesFolder.Security.SecurityManager),
        PerformanceManager = require(modulesFolder.Performance.PerformanceManager),
        
        -- State and Network
        StateManager = require(modulesFolder.State.StateManager),
        NetworkManager = require(modulesFolder.Network.NetworkManager),
        
        -- Game Systems
        GameManager = require(modulesFolder.Game.GameManager),
        SpawnManager = require(modulesFolder.Game.SpawnManager),
        
        -- Social Systems
        FriendManager = require(modulesFolder.Social.FriendManager),
        SocialHubManager = require(modulesFolder.Social.SocialHubManager),
        SocialInteractionManager = require(modulesFolder.Social.SocialInteractionManager),
        PlayerProfileManager = require(modulesFolder.Social.PlayerProfileManager),
        SocialMediaManager = require(modulesFolder.Social.SocialMediaManager),
        
        -- Building Systems
        BuildingToolsManager = require(modulesFolder.Building.BuildingToolsManager),
        BuildingTemplateManager = require(modulesFolder.Building.BuildingTemplateManager),
        BuildingChallengeManager = require(modulesFolder.Building.BuildingChallengeManager),
        
        -- Progression Systems
        ProgressionManager = require(modulesFolder.Progression.ProgressionManager),
        AchievementManager = require(modulesFolder.Achievement.AchievementManager),
        
        -- Data Systems
        DataStoreManager = require(modulesFolder.Data.DataStoreManager),
        
        -- Tutorial System
        TutorialHandler = require(modulesFolder.Tutorial.TutorialHandler)
    }
    
    -- Register modules with their dependencies
    ModuleManager.registerModule("PerformanceManager", coreModules.PerformanceManager)
    ModuleManager.registerModule("SecurityManager", coreModules.SecurityManager)
    ModuleManager.registerModule("StateManager", coreModules.StateManager)
    ModuleManager.registerModule("NetworkManager", coreModules.NetworkManager)
    ModuleManager.registerModule("GameManager", coreModules.GameManager, {})
    ModuleManager.registerModule("SpawnManager", coreModules.SpawnManager, { "GameManager" })
    ModuleManager.registerModule("FriendManager", coreModules.FriendManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("SocialHubManager", coreModules.SocialHubManager, { "GameManager", "SecurityManager", "PerformanceManager" })
    ModuleManager.registerModule("SocialInteractionManager", coreModules.SocialInteractionManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("PlayerProfileManager", coreModules.PlayerProfileManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("SocialMediaManager", coreModules.SocialMediaManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("BuildingToolsManager", coreModules.BuildingToolsManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("BuildingTemplateManager", coreModules.BuildingTemplateManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("BuildingChallengeManager", coreModules.BuildingChallengeManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("ProgressionManager", coreModules.ProgressionManager, { "GameManager", "SecurityManager" })
    ModuleManager.registerModule("AchievementManager", coreModules.AchievementManager, { "GameManager", "SecurityManager", "ProgressionManager" })
    
    return coreModules
end

-- Initialize the system
local function initialize()
    -- Initialize core modules
    local coreModules = initializeCoreModules()
    
    -- Initialize all modules in dependency order
    ModuleManager.initializeAll()
    
    -- Set up periodic cleanup
    task.spawn(function()
        while true do
            task.wait(Constants.Performance.CleanupInterval or 300) -- Default to 5 minutes
            if coreModules.PerformanceManager then coreModules.PerformanceManager.cleanup() end
            if coreModules.NetworkManager then coreModules.NetworkManager.cleanup() end
        end
    end)
    
    -- Set up periodic state sync
    task.spawn(function()
        while true do
            task.wait(1/Constants.Game.StateSyncRate or 30) -- Default to 30 times per second
            if coreModules.StateManager then coreModules.StateManager.syncState() end
        end
    end)
    
    -- Initialize individual modules
    for _, module in pairs(coreModules) do
        if module.init then
            module.init()
        end
    end
    
    print("Server: All systems initialized successfully")
end

-- Start initialization
initialize()

-- Return the initialized server system
return {
    Initialize = initialize,
    getModule = function(modulePath)
        return ModuleManager.getModule(modulePath)
    end
} 