-- Add module resolver at the beginning of the file
local resolver = script.Parent:FindFirstChild("ModuleResolver")
local resolveModule = resolver and require(resolver).resolveModule or function(name)
    local success, result = pcall(function()
        return require(script.Parent:FindFirstChild(name))
    end)
    
    if success and result then
        return result
    end
    
    warn("Failed to resolve module: " .. name)
    return {
        initialize = function() return true end,
        createUI = function() return Instance.new("Frame") end
    }
end

-- Helper function to safely require modules
local function safeRequire(moduleName)
    if ModuleResolver and ModuleResolver.resolveModule then
        return ModuleResolver.resolveModule(moduleName)
    else
        local success, result = pcall(function()
            return require(script.Parent:FindFirstChild(moduleName))
        end)
        return success and result or {}
    end
end

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

-- Use safe require for all module dependencies
local SchemaManager = safeRequire("SchemaManager.server")
local SessionManager = safeRequire("SessionManager.server")
local PerformanceMonitor = safeRequire("PerformanceMonitor")
local CacheManager = safeRequire("CacheManager.server")
local BulkOperationsManager = safeRequire("BulkOperationsManager")
local BulkOperationsUI = safeRequire("BulkOperationsUI")
local SchemaBuilderUI = safeRequire("SchemaBuilderUI")
local SchemaValidator = safeRequire("SchemaValidator.server")
local SchemaEditor = safeRequire("SchemaEditor")
local SchemaVersionViewer = safeRequire("SchemaVersionViewer")
local generateSchemaFromData = safeRequire("generateSchemaFromData")
local SchemaVisualIndicator = safeRequire("SchemaVisualIndicator")
local SessionManagementUI = safeRequire("SessionManagementUI")
local DataMigrationUI = safeRequire("DataMigrationUI")
local MultiServerCoordinationUI = safeRequire("MultiServerCoordinationUI")
local PerformanceAnalyzerUI = safeRequire("PerformanceAnalyzerUI")
local CachingSystemUI = safeRequire("CachingSystemUI")
local LoadTestingUI = safeRequire("LoadTestingUI")
local CodeGeneratorUI = safeRequire("CodeGeneratorUI")
local APIIntegrationUI = safeRequire("APIIntegrationUI")
local AccessControlUI = safeRequire("AccessControlUI")

local DataExplorer = {
    performanceDataUI = {},
    sessionId = HttpService:GenerateGUID(),
    lockStatusUI = {},
    sessionManagementUI = nil,
    dataMigrationContainer = nil,
    coordinationContainer = nil,
    performanceAnalyzerContainer = nil,
    cachingSystemContainer = nil,
    mainFrame = nil,
    loadTestingContainer = nil,
    codeGeneratorContainer = nil,
    apiIntegrationContainer = nil,
    accessControlContainer = nil,
    cacheViewerPane = nil,
    performanceStats = {
        requestsPerSecond = 0,
        averageLatency = 0,
        cacheHitRate = 0,
        memoryUsage = 0
    },
    cacheStats = {
        totalItems = 0,
        memoryUsage = 0,
        hitRate = 0,
        missRate = 0
    }
}

-- Initialize UI components
function DataExplorer.initializeUI()
    if not DataExplorer.mainFrame then
        DataExplorer.mainFrame = DataExplorer.createMainUI()
    end
    
    -- Initialize performance data UI
    if not DataExplorer.performanceDataUI then
        DataExplorer.performanceDataUI = {
            requestsPerSecond = Instance.new("TextLabel"),
            averageLatency = Instance.new("TextLabel"),
            cacheHitRate = Instance.new("TextLabel"),
            memoryUsage = Instance.new("TextLabel")
        }
    end
    
    -- Initialize cache viewer UI
    if not DataExplorer.cacheViewerUI then
        DataExplorer.cacheViewerUI = {
            totalItems = Instance.new("TextLabel"),
            memoryUsage = Instance.new("TextLabel"),
            hitRate = Instance.new("TextLabel"),
            missRate = Instance.new("TextLabel")
        }
    end
    
    -- Initialize other UI components
    DataExplorer.initBulkOperationsUI()
    DataExplorer.initMonitoringDashboardUI()
    DataExplorer.initDataMigrationUI()
    DataExplorer.initMultiServerCoordinationUI()
    DataExplorer.initPerformanceAnalyzerUI()
    DataExplorer.initCachingSystemUI()
    DataExplorer.initLoadTestingUI()
    DataExplorer.initCodeGeneratorUI()
    DataExplorer.initAPIIntegrationUI()
    DataExplorer.initAccessControlUI()
end

-- ... rest of the existing code ... 