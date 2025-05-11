-- DataStore Plugin/init.luau

-- Plugin version information
local PluginVersion = "1.0.0"

-- Check if we're running in plugin context
local runningInPluginContext = typeof(plugin) == "Plugin"

-- Create a module resolver to handle both local and cloud environments
local moduleCache = {}

local function resolveModule(moduleName)
    if moduleCache[moduleName] then
        return moduleCache[moduleName]
    end

    -- Try to find the module with appropriate extension
    local moduleScript = script.Parent:FindFirstChild(moduleName)
    
    -- If not found, try with .server suffix
    if not moduleScript then
        moduleScript = script.Parent:FindFirstChild(moduleName .. ".server")
    end
    
    if moduleScript then
        local success, result = pcall(function()
            return require(moduleScript)
        end)
        
        if success and result then
            moduleCache[moduleName] = result
            return result
        else
            error("Failed to require module: " .. moduleName .. " - " .. tostring(result))
        end
    else
        error("Module not found: " .. moduleName)
    end
end

-- Setup plugin UI if we're in plugin context
local toolbar, button
if runningInPluginContext then
    toolbar = plugin:CreateToolbar("DataStore Manager Pro")
    button = toolbar:CreateButton("Open DataStore Manager", "Open the DataStore Manager Pro Interface", "rbxassetid://7634658388")
end

-- Use our resolver to require modules
local DataStoreManager = resolveModule("DataStoreManager")
local DataExplorer = resolveModule("DataExplorer")
local PerformanceMonitor = resolveModule("PerformanceMonitor")
local SchemaManager = resolveModule("SchemaManager")
local SessionManager = resolveModule("SessionManager")
local CacheManager = resolveModule("CacheManager")
local SchemaValidator = resolveModule("SchemaValidator")
local SecurityManager = resolveModule("SecurityManager")
local DataVisualization = resolveModule("DataVisualization")
local StyleGuide = resolveModule("StyleGuide")
local SchemaEditor = resolveModule("SchemaEditor")
local MonitoringDashboard = resolveModule("MonitoringDashboard")
local MonitoringDashboardUI = resolveModule("MonitoringDashboardUI")
local DataMigrationTools = resolveModule("DataMigrationTools")
local MultiServerCoordination = resolveModule("MultiServerCoordination")
local MultiServerCoordinationUI = resolveModule("MultiServerCoordinationUI")
local MultiServerCoordinationIntegration = resolveModule("MultiServerCoordinationIntegration")
local PerformanceAnalyzer = resolveModule("PerformanceAnalyzer")
local PerformanceAnalyzerUI = resolveModule("PerformanceAnalyzerUI")
local PerformanceAnalyzerIntegration = resolveModule("PerformanceAnalyzerIntegration")
local CachingSystemUI = resolveModule("CachingSystemUI")
local LoadTesting = resolveModule("LoadTesting")
local LoadTestingUI = resolveModule("LoadTestingUI")
local CodeGenerator = resolveModule("CodeGenerator")
local CodeGeneratorUI = resolveModule("CodeGeneratorUI")
local APIIntegration = resolveModule("APIIntegration")
local APIIntegrationUI = resolveModule("APIIntegrationUI")
local AccessControl = resolveModule("AccessControl")
local AccessControlUI = resolveModule("AccessControlUI")

-- Define the internal state
local widgetInfo
if runningInPluginContext then
    widgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Right,
        false, -- Floating
        false, -- Enabled by default
        800,   -- Width
        600,   -- Height
        800,   -- MinWidth
        600    -- MinHeight
    )
end

local widget
if runningInPluginContext then
    widget = plugin:CreateDockWidgetPluginGui("DataStoreManagerWidget", widgetInfo)
    widget.Title = "DataStore Manager Pro"
end

-- Initialize the plugin components
DataStoreManager.initialize()
MonitoringDashboard.initialize()
MonitoringDashboardUI.initialize()
DataMigrationTools.initialize()
MultiServerCoordination.initialize()
MultiServerCoordinationUI.initialize()
PerformanceAnalyzer.initialize()
PerformanceAnalyzerUI.initialize()
CachingSystemUI.initialize()
CodeGenerator.initialize()
CodeGeneratorUI.initialize()
APIIntegration.initialize()
APIIntegrationUI.initialize()
AccessControl.initialize()
AccessControlUI.initialize()
MultiServerCoordinationIntegration.initialize()
PerformanceAnalyzerIntegration.initialize()

-- Set up event handlers
if button and widget then 
    button.Click:Connect(function()
        widget.Enabled = not widget.Enabled
        if widget.Enabled and widget:FindFirstChild("DataStoreExplorerFrame") == nil then
            local mainFrame = DataExplorer.createMainGui(widget)
            mainFrame.Parent = widget
            
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
            
            task.spawn(function() 
                while widget.Enabled and widget.Parent do 
                    DataExplorer.updatePerformanceUI()
                    DataExplorer.updateLockStatusUI()
                    DataExplorer.updateCacheViewerUI()
                    task.wait(5) 
                end
            end)
        end
    end)
end

-- Expose the API for external usage
local DataStoreManagerPlugin = {
    DataStoreManager = DataStoreManager,
    SchemaManager = SchemaManager,
    SchemaValidator = SchemaValidator,
    DataVisualization = DataVisualization,
    SchemaEditor = SchemaEditor,
    StyleGuide = StyleGuide,
    DataMigrationTools = DataMigrationTools,
    MultiServerCoordination = MultiServerCoordination,
    
    getData = DataStoreManager.getData,
    setData = DataStoreManager.setData,
    updateData = DataStoreManager.updateData,
    removeData = DataStoreManager.removeData,
    listKeys = DataStoreManager.listKeys,
    
    validateData = SchemaValidator.validate,
    createSchema = SchemaManager.saveSchema,
    loadSchema = SchemaManager.loadSchema,
    
    getPerformanceData = PerformanceMonitor.getPerformanceData,
    getOperationSummary = PerformanceMonitor.getOperationSummary,
    
    migrateKey = DataMigrationTools.migrateKey,
    migrateDataStore = DataMigrationTools.migrateDataStore,
    getMigrationStatus = DataMigrationTools.getMigrationStatus,
    
    requestDistributedLock = MultiServerCoordination.requestDistributedLock,
    releaseDistributedLock = MultiServerCoordination.releaseDistributedLock,
    getActiveServers = MultiServerCoordination.getActiveServers,
    
    getCacheAnalytics = CacheManager.getCacheAnalytics,
    getCacheContents = CacheManager.getCacheContents,
    optimizeCache = CacheManager.optimizeCache,
    preloadData = CacheManager.preloadData,
    
    generateCode = CodeGenerator.generateModuleFromSchema,
    getTemplates = function(moduleType) 
        if CodeGenerator and CodeGenerator.templates then
             return CodeGenerator.templates[moduleType or "module"]
        end
        return {}
    end,
    
    configureWebhook = APIIntegration.configureWebhook,
    triggerWebhook = APIIntegration.triggerWebhook,
    configureOpenCloudAPI = APIIntegration.configureOpenCloudAPI,
    getWebhooks = APIIntegration.getWebhooks,
    
    createBarChart = DataVisualization.createBarChart,
    createLineChart = DataVisualization.createLineChart,
    createPieChart = DataVisualization.createPieChart,
    createTableView = DataVisualization.createTableView,
    
    Version = PluginVersion
}

if not runningInPluginContext then
    print("DataStore Manager Pro loaded successfully in non-plugin context")
    print("Plugin Version:", DataStoreManagerPlugin.Version)
end

return DataStoreManagerPlugin
