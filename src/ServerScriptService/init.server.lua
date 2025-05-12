local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Logger = Shared.Logger

-- Helper function to safely require modules
local function safeRequire(module)
    local success, result = pcall(function()
        return require(module)
    end)
    
    if not success then
        Logger:error("Failed to load module", { module = module.Name, error = result })
        return nil
    end
    
    return result
end

-- Initialize core modules
local function initializeCoreModules()
    -- Load core modules
    local dataStoreManager = safeRequire(script.Parent.DataStoreManager)
    if not dataStoreManager then return false end
    
    -- Initialize modules in correct order
    if not dataStoreManager.Initialize() then
        Logger:error("Failed to initialize DataStoreManager")
        return false
    end
    
    return true
end

-- Main initialization
local success, result = pcall(function()
    -- Initialize modules
    if not initializeCoreModules() then
        error("Failed to initialize core modules")
    end
end)

if not success then
    Logger:error("Server initialization failed", { error = result })
else
    Logger:info("Server initialized successfully")
end

return {
    Initialize = initializeCoreModules
} 