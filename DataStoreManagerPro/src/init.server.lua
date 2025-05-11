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

-- Initialize ModuleResolver first
local ModuleResolver = require(script.Parent.shared.ModuleResolver)
local resolveModule = ModuleResolver.resolveModule

-- Initialize core modules using the resolver
local DataStoreManager = resolveModule("DataStoreManager", script.Parent.server)
local CacheManager = resolveModule("CacheManager", script.Parent.server)
local SchemaManager = resolveModule("SchemaManager", script.Parent.server)
local SchemaValidator = resolveModule("SchemaValidator", script.Parent.server)
local SessionManager = resolveModule("SessionManager", script.Parent.server)
local SecurityManager = resolveModule("SecurityManager", script.Parent.server)

-- Initialize integration modules
local MultiServerCoordination = resolveModule("MultiServerCoordination", script.Parent.server)
local PerformanceAnalyzer = resolveModule("PerformanceAnalyzer", script.Parent.server)
local MonitoringDashboard = resolveModule("MonitoringDashboard", script.Parent.server)

-- Initialize the system
local function initialize()
    -- Initialize core systems in dependency order
    SecurityManager:Initialize()
    CacheManager:Initialize()
    SchemaManager:Initialize()
    SchemaValidator:Initialize()
    SessionManager:Initialize()
    DataStoreManager:Initialize()
    
    -- Initialize integrations
    MultiServerCoordination:Initialize()
    PerformanceAnalyzer:Initialize()
    MonitoringDashboard:Initialize()
    
    print("DataStoreManagerPro: All systems initialized successfully")
end

-- Return the initialized system
return {
    Initialize = initialize,
    DataStoreManager = DataStoreManager,
    CacheManager = CacheManager,
    SchemaManager = SchemaManager,
    SchemaValidator = SchemaValidator,
    SessionManager = SessionManager,
    SecurityManager = SecurityManager,
    MultiServerCoordination = MultiServerCoordination,
    PerformanceAnalyzer = PerformanceAnalyzer,
    MonitoringDashboard = MonitoringDashboard,
    -- Export the resolver for other modules to use
    resolveModule = resolveModule
}
