local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local modulesFolder = ensureFolder(ServerScriptService, "Modules")
local sharedFolder = ensureFolder(ReplicatedStorage, "Shared")
local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")

-- Helper function to safely require modules
local function safeRequire(modulePath)
    if not modulePath then
        warn("Invalid module path provided to safeRequire")
        return nil
    end
    
    local success, result = pcall(function()
        return require(modulePath)
    end)
    
    if success then
        return result
    else
        warn("Failed to load module:", modulePath.Name, "-", result)
        return nil
    end
end

-- Initialize core modules
local function initializeCoreModules()
    -- First initialize DataStoreManager as other modules depend on it
    local dataStoreManager = safeRequire(modulesFolder.Data.DataStoreManager)
    if not dataStoreManager then
        warn("Failed to load DataStoreManager - this will affect other modules")
        return nil
    end

    -- Then initialize SecurityManager as it's used by many modules
    local securityManager = safeRequire(modulesFolder.Security.SecurityManager)
    if not securityManager then
        warn("Failed to load SecurityManager - this will affect other modules")
        return nil
    end

    -- Initialize remaining modules
    local coreModules = {
        -- Security and Performance
        SecurityManager = securityManager,
        PerformanceManager = safeRequire(modulesFolder.Performance.PerformanceManager),
        
        -- State and Network
        StateManager = safeRequire(modulesFolder.State.StateManager),
        NetworkManager = safeRequire(modulesFolder.Network.NetworkManager),
        
        -- Game Systems
        GameManager = safeRequire(modulesFolder.Game.GameManager),
        SpawnManager = safeRequire(modulesFolder.Game.SpawnManager),
        
        -- Social Systems
        FriendManager = safeRequire(modulesFolder.Social.FriendManager),
        SocialHubManager = safeRequire(modulesFolder.Social.SocialHubManager),
        SocialInteractionManager = safeRequire(modulesFolder.Social.SocialInteractionManager),
        PlayerProfileManager = safeRequire(modulesFolder.Social.PlayerProfileManager),
        SocialMediaManager = safeRequire(modulesFolder.Social.SocialMediaManager),
        
        -- Building Systems
        BuildingToolsManager = safeRequire(modulesFolder.Building.BuildingToolsManager),
        BuildingTemplateManager = safeRequire(modulesFolder.Building.BuildingTemplateManager),
        BuildingChallengeManager = safeRequire(modulesFolder.Building.BuildingChallengeManager),
        
        -- Progression Systems
        ProgressionManager = safeRequire(modulesFolder.Progression.ProgressionManager),
        AchievementManager = safeRequire(modulesFolder.Achievement.AchievementManager),
        
        -- Data Systems
        DataStoreManager = dataStoreManager,
        
        -- Tutorial System
        TutorialHandler = safeRequire(modulesFolder.Tutorial.TutorialHandler)
    }
    
    -- Initialize modules in dependency order
    for name, module in pairs(coreModules) do
        if module and module.Initialize then
            local success, result = pcall(function()
                return module:Initialize()
            end)
            if not success then
                warn("Failed to initialize module:", name, "-", result)
            end
        end
    end
    
    return coreModules
end

-- Initialize the system
local function initialize()
    -- Create necessary remote events
    local remotes = {
        "ReportObject",
        "AdminCommand",
        "CompleteTutorial",
        "GetTutorialStatus"
    }
    
    for _, remoteName in ipairs(remotes) do
        local remote = Instance.new("RemoteEvent")
        remote.Name = remoteName
        remote.Parent = remotesFolder
    end
    
    local coreModules = initializeCoreModules()
    if not coreModules then
        warn("Failed to initialize core modules")
        return nil
    end
    
    print("Core modules initialized successfully")
    return coreModules
end

-- Start initialization
local modules = initialize()

-- Return the initialized server system
return {
    Initialize = initialize,
    getModule = function(moduleName)
        return modules and modules[moduleName]
    end
} 