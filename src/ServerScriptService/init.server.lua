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
local modulesFolder = ensureFolder(ServerScriptService, "Modules")
local dataFolder = ensureFolder(modulesFolder, "Data")
local securityFolder = ensureFolder(modulesFolder, "Security")
local tutorialFolder = ensureFolder(modulesFolder, "Tutorial")

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

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

-- Initialize core modules
local function initializeCoreModules()
    -- Load DataStoreManager first as it's a dependency
    local DataStoreManager = safeRequire(dataFolder.DataStoreManager)
    if not DataStoreManager then
        Logger:error("Failed to load DataStoreManager - this will affect other modules")
        return false
    end
    
    -- Load SecurityManager
    local SecurityManager = safeRequire(securityFolder.SecurityManager)
    if not SecurityManager then
        Logger:error("Failed to load SecurityManager")
        return false
    end
    
    -- Load TutorialHandler
    local TutorialHandler = safeRequire(tutorialFolder.TutorialHandler)
    if not TutorialHandler then
        Logger:error("Failed to load TutorialHandler")
        return false
    end
    
    -- Initialize modules in dependency order
    if not DataStoreManager.Initialize() then
        Logger:error("Failed to initialize DataStoreManager")
        return false
    end
    
    if not SecurityManager.Initialize() then
        Logger:error("Failed to initialize SecurityManager")
        return false
    end
    
    if not TutorialHandler.Initialize() then
        Logger:error("Failed to initialize TutorialHandler")
        return false
    end
    
    Logger:info("Core modules initialized successfully")
    return true
end

-- Initialize the system
local function initialize()
    -- Initialize core modules
    if not initializeCoreModules() then
        Logger:error("Failed to initialize core modules")
        return nil
    end
    
    Logger:info("Server system initialized successfully")
    return true
end

-- Start initialization
local success = initialize()
if not success then
    Logger:error("Failed to initialize server system")
end

return {
    Initialize = initialize
} 