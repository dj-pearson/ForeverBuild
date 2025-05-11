-- DataStoreManagerPro init.server.luau
-- This script initializes the DataStoreManagerPro plugin on the server

local ServerScriptService = game:GetService("ServerScriptService")
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
local modulesFolder = ensureFolder(ServerScriptService, "Modules")
local sharedFolder = ensureFolder(ReplicatedStorage, "Shared")

-- Initialize ModuleResolver
local ModuleResolver = require(script.Parent.shared.ModuleResolver)
local moduleResolver = ModuleResolver.new()

-- Initialize core modules using the resolver
local function initializeCoreModules()
    local coreModules = {
        DataStoreManager = script.Parent.server.DataStoreManager,
        CacheManager = script.Parent.server.CacheManager,
        SchemaManager = script.Parent.server.SchemaManager,
        SchemaValidator = script.Parent.server.SchemaValidator,
        SessionManager = script.Parent.server.SessionManager,
        SecurityManager = script.Parent.server.SecurityManager
    }
    
    local initializedModules = {}
    for name, module in pairs(coreModules) do
        local success, result = pcall(function()
            return require(module)
        end)
        if success then
            initializedModules[name] = result
        else
            warn("Failed to load core module:", name, "-", result)
        end
    end
    
    return initializedModules
end

-- Initialize integration modules
local function initializeIntegrationModules()
    local integrationModules = {
        MultiServerCoordination = script.Parent.server.MultiServerCoordination,
        PerformanceAnalyzer = script.Parent.server.PerformanceAnalyzer,
        MonitoringDashboard = script.Parent.server.MonitoringDashboard
    }
    
    local initializedModules = {}
    for name, module in pairs(integrationModules) do
        local success, result = pcall(function()
            return require(module)
        end)
        if success then
            initializedModules[name] = result
        else
            warn("Failed to load integration module:", name, "-", result)
        end
    end
    
    return initializedModules
end

-- Initialize the system
local function initialize()
    -- Initialize core modules
    local coreModules = initializeCoreModules()
    
    -- Initialize core systems in dependency order
    if coreModules.SecurityManager then coreModules.SecurityManager:Initialize() end
    if coreModules.CacheManager then coreModules.CacheManager:Initialize() end
    if coreModules.SchemaManager then coreModules.SchemaManager:Initialize() end
    if coreModules.SchemaValidator then coreModules.SchemaValidator:Initialize() end
    if coreModules.SessionManager then coreModules.SessionManager:Initialize() end
    if coreModules.DataStoreManager then coreModules.DataStoreManager:Initialize() end
    
    -- Initialize integration modules
    local integrationModules = initializeIntegrationModules()
    
    -- Initialize integrations
    if integrationModules.MultiServerCoordination then integrationModules.MultiServerCoordination:Initialize() end
    if integrationModules.PerformanceAnalyzer then integrationModules.PerformanceAnalyzer:Initialize() end
    if integrationModules.MonitoringDashboard then integrationModules.MonitoringDashboard:Initialize() end
    
    print("DataStoreManagerPro: All systems initialized successfully")
    
    -- Return all initialized modules
    return {
        core = coreModules,
        integrations = integrationModules
    }
end

-- Return the initialized system
return {
    Initialize = initialize,
    ModuleResolver = moduleResolver
} 