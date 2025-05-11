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
local CachingSystemIntegration = safeRequire("CachingSystemIntegration")
local LoadTestingIntegration = safeRequire("LoadTestingIntegration")
local CodeGeneratorIntegration = safeRequire("CodeGeneratorIntegration")
local APIIntegrationIntegration = safeRequire("APIIntegrationIntegration")
local AccessControlIntegration = safeRequire("AccessControlIntegration")
local MultiServerCoordinationIntegration = safeRequire("MultiServerCoordinationIntegration")
local PerformanceAnalyzerIntegration = safeRequire("PerformanceAnalyzerIntegration")

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
    cacheViewerPane = nil
}

-- Helper function to create text labels
local function createLabel(text, parent)
	local label = Instance.new("TextButton")
    label.BorderSizePixel = 0
	label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
    label.AutoButtonColor = false
    label.Text = text
	label.Size = UDim2.new(1, 0, 0, 18)
    label.Parent = parent
    return label
end

-- Create the main UI frame
function DataExplorer.createMainUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    mainFrame.BorderSizePixel = 0
    DataExplorer.mainFrame = mainFrame

    -- Create a split-pane layout (Using ScrollingFrame for potential future scrolling)
    local splitPane = Instance.new("ScrollingFrame")
    splitPane.Size = UDim2.new(1, 0, 1, 0)
    splitPane.Name = "SplitPane"
    splitPane.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be adjusted later
    splitPane.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    splitPane.ScrollBarInset = Enum.ScrollBarInset.Always
    splitPane.ElasticBehavior = Enum.ElasticBehavior.Never
    splitPane.Parent = mainFrame
    DataExplorer.splitPane = splitPane    -- Create a UIListLayout for the panes within the ScrollingFrame
    local horizontalLayout = Instance.new("UIListLayout")
    horizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    horizontalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    horizontalLayout.Parent = splitPane

    -- Create the navigation pane (tree view)
    local navigationPane = Instance.new("Frame")
    navigationPane.Size = UDim2.new(0.3, 0, 1, 0) -- 30% of the width
    navigationPane.Name = "NavigationPane"
    navigationPane.Parent = splitPane
    DataExplorer.navigationPane = navigationPane -- Save the navigation pane for later use

    -- Add a layout for potential items in the navigation pane
    local navigationLayout = Instance.new("UIListLayout")
    navigationLayout.FillDirection = Enum.FillDirection.Vertical
    navigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navigationLayout.Parent = navigationPane
    
    -- Create a Pane to display performance data
    local performancePane = Instance.new("Frame")
    performancePane.Size = UDim2.new(1, 0, 0.2, 0)
    performancePane.Position = UDim2.new(0,0,0.6,0) -- under the treeview
    performancePane.Name = "PerformancePane"
    performancePane.Parent = navigationPane
    DataExplorer.performancePane = performancePane


        -- Create the cache viewer pane
    local cacheViewerPane = Instance.new("Frame")
    cacheViewerPane.Size = UDim2.new(1, 0, 0.4, 0) -- 40% of the height
    cacheViewerPane.Position = UDim2.new(0, 0, 1, 0) -- At the bottom of the Navigation Pane
    cacheViewerPane.Name = "CacheViewerPane"
    cacheViewerPane.Parent = navigationPane
    DataExplorer.cacheViewerPane = cacheViewerPane -- Store the reference to the cache viewer panel
    -- Create the lock Status pane
    local lockStatusPane = Instance.new("Frame")
    lockStatusPane.Size = UDim2.new(1, 0, 0.2, 0) -- 20% of the height
    lockStatusPane.Position = UDim2.new(0,0,0.8,0) -- at the bottom of the Navigation Pane
    lockStatusPane.Name = "LockStatusPane"
    lockStatusPane.Parent = navigationPane
    DataExplorer.lockStatusPane = lockStatusPane

    -- Create a title for the lock status pane
    local lockStatusTitle = Instance.new("TextLabel")
    lockStatusTitle.Size = UDim2.new(1, -80, 0, 24)
    lockStatusTitle.Position = UDim2.new(0, 5, 0, 0)
    lockStatusTitle.BackgroundTransparency = 1
    lockStatusTitle.Text = "Session Locks"
    lockStatusTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockStatusTitle.Font = Enum.Font.SourceSansBold
    lockStatusTitle.TextSize = 14
    lockStatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    lockStatusTitle.Parent = lockStatusPane
    
    -- Create a button to open the session management UI
    local sessionManagementButton = Instance.new("TextButton")
    sessionManagementButton.Size = UDim2.new(0, 70, 0, 24)
    sessionManagementButton.Position = UDim2.new(1, -75, 0, 0)
    sessionManagementButton.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
    sessionManagementButton.BorderSizePixel = 0
    sessionManagementButton.Text = "Manage"
    sessionManagementButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sessionManagementButton.Font = Enum.Font.SourceSansSemibold
    sessionManagementButton.TextSize = 14
    sessionManagementButton.Name = "SessionManagementButton"
    sessionManagementButton.Parent = lockStatusPane
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = sessionManagementButton
    
    -- Create a container for the lock status content
    local lockStatusContent = Instance.new("Frame")
    lockStatusContent.Size = UDim2.new(1, 0, 1, -24)
    lockStatusContent.Position = UDim2.new(0, 0, 0, 24)
    lockStatusContent.BackgroundTransparency = 1
    lockStatusContent.Name = "LockStatusContent"
    lockStatusContent.Parent = lockStatusPane
    DataExplorer.lockStatusContent = lockStatusContent
    
    -- Add a layout for the lock status content
    local lockStatusLayout = Instance.new("UIListLayout")
    lockStatusLayout.FillDirection = Enum.FillDirection.Vertical
    lockStatusLayout.SortOrder = Enum.SortOrder.LayoutOrder
    lockStatusLayout.Padding = UDim.new(0, 2)
    lockStatusLayout.Parent = lockStatusContent

-- Create the content pane (for displaying data)
    local contentPane = Instance.new("ScrollingFrame")
    contentPane.Size = UDim2.new(0.7, 0, 1, 0) -- 70% of the width
    contentPane.Name = "ContentPane"
    contentPane.Parent = splitPane
    DataExplorer.contentPane = contentPane

    -- Add a layout for potential items in the content pane
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentPane

    -- Add a splitter to resize the panes (This will require scripting later)
    -- Placed outside the horizontal layout to overlap
    local splitter = Instance.new("Frame")
    splitter.Size = UDim2.new(0, 5, 1, 0)    
    splitter.Position = UDim2.new(navigationPane.Size.X.Scale, navigationPane.Size.X.Offset - splitter.Size.X.Offset / 2, 0, 0)
    splitter.Name = "Splitter"
    splitter.Draggable = true
    splitter.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
    splitter.ZIndex = 2
    splitter.Parent = mainFrame

        --Add cache content display
    function DataExplorer.updateCacheViewerUI()
        local cacheViewerPane = DataExplorer.cacheViewerPane
        if not cacheViewerPane then return end

        -- Clear existing cache viewer UI
        for _, child in ipairs(cacheViewerPane:GetChildren()) do
            child:Destroy()
        end

        -- Get cache contents
        local cacheContents = CacheManager.getCacheContents()

        if #cacheContents > 0 then
            for _, cacheEntry in ipairs(cacheContents) do
                local entryFrame = Instance.new("Frame")
                entryFrame.Size = UDim2.new(1, 0, 0, 20) -- Fixed height for each entry
                entryFrame.BackgroundTransparency = 1
                entryFrame.Parent = cacheViewerPane

                local entryLayout = Instance.new("UIListLayout")
                entryLayout.FillDirection = Enum.FillDirection.Horizontal
                entryLayout.SortOrder = Enum.SortOrder.LayoutOrder
                entryLayout.Parent = entryFrame
                
                local dataStoreLabel = createLabel(cacheEntry.dataStoreName, entryFrame)
                dataStoreLabel.Size = UDim2.new(0.2,0,1,0)
                local keyLabel = createLabel(cacheEntry.keyName, entryFrame)
                keyLabel.Size = UDim2.new(0.3,0,1,0)
                local sizeLabel = createLabel(string.format("%.2f KB", cacheEntry.estimatedSize / 1024), entryFrame)
                sizeLabel.Size = UDim2.new(0.15,0,1,0)
                local lastAccessedLabel = createLabel(os.date("%Y-%m-%d %H:%M:%S", cacheEntry.lastAccessed), entryFrame)
                lastAccessedLabel.Size = UDim2.new(0.25,0,1,0)
                local accessCountLabel = createLabel(tostring(cacheEntry.accessCount), entryFrame)
                accessCountLabel.Size = UDim2.new(0.1,0,1,0)


            end
        else
            local noDataLabel = createLabel("No data in cache", cacheViewerPane)
            noDataLabel.Parent = cacheViewerPane
        end
    end
    return mainFrame
end

function DataExplorer.updateLockStatusUI()
    local lockStatusContent = DataExplorer.lockStatusContent
    if not lockStatusContent then return end

    -- Clear existing lock status UI
    for _, child in ipairs(lockStatusContent:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Get active locks
    local activeLocks = SessionManager.getActiveLocks()

    if #activeLocks > 0 then
        for i, lockInfo in ipairs(activeLocks) do
            local lockFrame = Instance.new("Frame")
            lockFrame.Size = UDim2.new(1, -10, 0, 24)
            lockFrame.Position = UDim2.new(0, 5, 0, 0)
            lockFrame.BackgroundColor3 = lockInfo.isExpired and Color3.fromRGB(70, 30, 30) or Color3.fromRGB(35, 35, 40)
            lockFrame.BorderSizePixel = 0
            lockFrame.Name = "LockFrame_" .. i
            lockFrame.LayoutOrder = i
            lockFrame.Parent = lockStatusContent
            
            -- Add rounded corners
            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 4)
            frameCorner.Parent = lockFrame
            
            -- Create status indicator
            local statusIndicator = Instance.new("Frame")
            statusIndicator.Size = UDim2.new(0, 4, 1, 0)
            statusIndicator.Position = UDim2.new(0, 0, 0, 0)
            statusIndicator.BackgroundColor3 = lockInfo.isExpired and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 180, 80)
            statusIndicator.BorderSizePixel = 0
            statusIndicator.Parent = lockFrame
            
            -- Add rounded corners to indicator
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(0, 4)
            indicatorCorner.Parent = statusIndicator
            
            -- Create lock label
            local lockLabel = Instance.new("TextLabel")
            lockLabel.Size = UDim2.new(1, -70, 1, 0)
            lockLabel.Position = UDim2.new(0, 10, 0, 0)
            lockLabel.BackgroundTransparency = 1
            lockLabel.Text = lockInfo.dataStoreName .. ":" .. lockInfo.keyName
            lockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            lockLabel.Font = Enum.Font.Code
            lockLabel.TextSize = 14
            lockLabel.TextXAlignment = Enum.TextXAlignment.Left
            lockLabel.TextTruncate = Enum.TextTruncate.AtEnd
            lockLabel.Parent = lockFrame
            
            -- Create force unlock button
            local forceUnlockButton = Instance.new("TextButton")
            forceUnlockButton.Size = UDim2.new(0, 60, 0, 20)
            forceUnlockButton.Position = UDim2.new(1, -65, 0.5, -10)
            forceUnlockButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            forceUnlockButton.BorderSizePixel = 0
            forceUnlockButton.Text = "Unlock"
            forceUnlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            forceUnlockButton.Font = Enum.Font.SourceSans
            forceUnlockButton.TextSize = 14
            forceUnlockButton.Parent = lockFrame
            
            -- Add rounded corners to button
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = forceUnlockButton

            -- Force unlock function
            forceUnlockButton.MouseButton1Click:Connect(function()
                SessionManager.forceReleaseLock(lockInfo.dataStoreName, lockInfo.keyName)
                DataExplorer.updateLockStatusUI() -- Refresh the lock status UI
            end)
        end
    else
        local noLocksLabel = Instance.new("TextLabel")
        noLocksLabel.Size = UDim2.new(1, -10, 0, 24)
        noLocksLabel.Position = UDim2.new(0, 5, 0, 0)
        noLocksLabel.BackgroundTransparency = 1
        noLocksLabel.Text = "No active locks"
        noLocksLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        noLocksLabel.Font = Enum.Font.SourceSans
        noLocksLabel.TextSize = 14
        noLocksLabel.TextXAlignment = Enum.TextXAlignment.Center
        noLocksLabel.Parent = lockStatusContent
    end
end

-- Update performance data UI
function DataExplorer.updatePerformanceDataUI()
    if not DataExplorer.performanceDataUI then return end
    
    local stats = DataExplorer.performanceStats
    if not stats then return end
    
    -- Update the UI with current stats
    DataExplorer.performanceDataUI.requestsPerSecond.Text = string.format("%.1f", stats.requestsPerSecond)
    DataExplorer.performanceDataUI.averageLatency.Text = string.format("%.1f ms", stats.averageLatency)
    DataExplorer.performanceDataUI.cacheHitRate.Text = string.format("%.1f%%", stats.cacheHitRate * 100)
    DataExplorer.performanceDataUI.memoryUsage.Text = string.format("%.1f MB", stats.memoryUsage)
end

-- Update cache viewer UI
function DataExplorer.updateCacheViewerUI()
    if not DataExplorer.cacheViewerUI then return end
    
    local cacheStats = DataExplorer.cacheStats
    if not cacheStats then return end
    
    -- Update the UI with current cache stats
    DataExplorer.cacheViewerUI.totalItems.Text = tostring(cacheStats.totalItems)
    DataExplorer.cacheViewerUI.memoryUsage.Text = string.format("%.1f MB", cacheStats.memoryUsage)
    DataExplorer.cacheViewerUI.hitRate.Text = string.format("%.1f%%", cacheStats.hitRate * 100)
    DataExplorer.cacheViewerUI.missRate.Text = string.format("%.1f%%", cacheStats.missRate * 100)
end

-- Connect the update functions to RunService
RunService.Heartbeat:Connect(DataExplorer.updatePerformanceDataUI)
RunService.Heartbeat:Connect(DataExplorer.updateCacheViewerUI)

function DataExplorer.initBulkOperationsUI()
    local mainFrame = DataExplorer.mainFrame
    if not mainFrame then return end
    
    -- Create a button to open bulk operations
    local bulkOperationsButton = Instance.new("TextButton")
    bulkOperationsButton.Size = UDim2.new(0, 150, 0, 30)
    bulkOperationsButton.Position = UDim2.new(1, -160, 0, 10)
    bulkOperationsButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    bulkOperationsButton.BorderSizePixel = 0
    bulkOperationsButton.Text = "Bulk Operations"
    bulkOperationsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    bulkOperationsButton.Font = Enum.Font.SourceSansBold
    bulkOperationsButton.TextSize = 14
    bulkOperationsButton.ZIndex = 5
    bulkOperationsButton.Parent = mainFrame
    
    -- Store reference in DataExplorer
    DataExplorer.bulkOperationsButton = bulkOperationsButton
    
    -- Create the bulk operations container (initially invisible)
    local bulkOperationsContainer = BulkOperationsUI.createTab(mainFrame)
    DataExplorer.bulkOperationsContainer = bulkOperationsContainer
      -- Toggle visibility when button is clicked
    bulkOperationsButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if bulkOperationsContainer.Visible then
            -- Hide bulk operations and show normal UI
            bulkOperationsContainer.Visible = false
            contentPane.Visible = true
            navPane.Visible = true
            bulkOperationsButton.Text = "Bulk Operations"
            bulkOperationsButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        else
            -- Show bulk operations and hide normal UI
            bulkOperationsContainer.Visible = true
            contentPane.Visible = false
            navPane.Visible = false
            bulkOperationsButton.Text = "Back to Explorer"
            bulkOperationsButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
              -- Also ensure schema builder is hidden
            if DataExplorer.schemaBuilderContainer and DataExplorer.schemaBuilderContainer.Visible then
                DataExplorer.schemaBuilderContainer.Visible = false
                DataExplorer.schemaBuilderButton.Text = "Schema Builder"
                DataExplorer.schemaBuilderButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            end
        end
    end)
end
    
-- Add Schema Builder button
    local schemaBuilderButton = Instance.new("TextButton")
    schemaBuilderButton.Size = UDim2.new(0, 130, 0, 28)
    schemaBuilderButton.Position = UDim2.new(1, -280, 0, 10) -- Position to the left of Bulk Operations button
    schemaBuilderButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80) -- Green color
    schemaBuilderButton.BorderSizePixel = 0
    schemaBuilderButton.Text = "Schema Builder"
    schemaBuilderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    schemaBuilderButton.Font = Enum.Font.SourceSansSemibold
    schemaBuilderButton.TextSize = 14
    schemaBuilderButton.ZIndex = 5
    
    -- Store reference in DataExplorer
    DataExplorer.schemaBuilderButton = schemaBuilderButton
    
    -- Add rounded corners
    local schemaButtonCorner = Instance.new("UICorner")
    schemaButtonCorner.CornerRadius = UDim.new(0, 4)
    schemaButtonCorner.Parent = schemaBuilderButton
    
    schemaBuilderButton.Parent = DataExplorer.mainFrame
    
    -- Create the schema builder container (initially invisible)
    local schemaBuilderContainer = SchemaBuilderUI.createUI(DataExplorer.mainFrame)
    DataExplorer.schemaBuilderContainer = schemaBuilderContainer.container
    DataExplorer.schemaBuilderContainer.Visible = false
    
    -- Toggle visibility when schema builder button is clicked
    schemaBuilderButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if DataExplorer.schemaBuilderContainer.Visible then
            -- Hide schema builder and show normal UI
            DataExplorer.schemaBuilderContainer.Visible = false
            contentPane.Visible = true
            navPane.Visible = true
            schemaBuilderButton.Text = "Schema Builder"
            schemaBuilderButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            
            -- Also ensure bulk operations is hidden
            DataExplorer.bulkOperationsContainer.Visible = false
            DataExplorer.bulkOperationsButton.Text = "Bulk Operations"
            DataExplorer.bulkOperationsButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        else
            -- Show schema builder and hide normal UI
            DataExplorer.schemaBuilderContainer.Visible = true
            contentPane.Visible = false
            navPane.Visible = false
            schemaBuilderButton.Text = "Back to Explorer"
            schemaBuilderButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            
            -- Also ensure bulk operations is hidden
            DataExplorer.bulkOperationsContainer.Visible = false
            DataExplorer.bulkOperationsButton.Text = "Bulk Operations"
            DataExplorer.bulkOperationsButton.BackgroundColor3 = Color3.fromRGB(66, 133, 244)
        end
    end)




function DataExplorer.displayKeyContent(dataStoreName: string, keyName: string)
    local contentPane = DataExplorer.contentPane
    if not contentPane then return end
    
    -- Clear the content pane
    for _, child in ipairs(contentPane:GetChildren()) do
        child:Destroy()
    end
    
    -- Attempt to acquire a lock for reading/editing
    local lockAcquired = SessionManager.acquireLock(dataStoreName, keyName, DataExplorer.sessionId)
    if not lockAcquired then
        -- Create a locked notification
        local lockNotification = Instance.new("Frame")
        lockNotification.Size = UDim2.new(1, 0, 0, 40)
        lockNotification.Position = UDim2.new(0, 0, 0, 0)
        lockNotification.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        lockNotification.BackgroundTransparency = 0.2
        lockNotification.BorderSizePixel = 0
        lockNotification.Parent = contentPane
        
        local lockIcon = Instance.new("ImageLabel")
        lockIcon.Size = UDim2.new(0, 24, 0, 24)
        lockIcon.Position = UDim2.new(0, 10, 0.5, -12)
        lockIcon.BackgroundTransparency = 1
        lockIcon.Image = "rbxassetid://6031225819" -- Lock icon
        lockIcon.Parent = lockNotification
        
        local lockText = Instance.new("TextLabel")
        lockText.Size = UDim2.new(1, -50, 1, 0)
        lockText.Position = UDim2.new(0, 40, 0, 0)
        lockText.BackgroundTransparency = 1
        lockText.Text = "This key is currently locked by another session. Read-only mode enabled."
        lockText.TextColor3 = Color3.fromRGB(255, 255, 255)
        lockText.TextXAlignment = Enum.TextXAlignment.Left
        lockText.Font = Enum.Font.SourceSansBold
        lockText.TextSize = 14
        lockText.Parent = lockNotification
        
        local forceUnlockBtn = Instance.new("TextButton")
        forceUnlockBtn.Size = UDim2.new(0, 120, 0, 28)
        forceUnlockBtn.Position = UDim2.new(1, -130, 0.5, -14)
        forceUnlockBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        forceUnlockBtn.BorderSizePixel = 0
        forceUnlockBtn.Text = "Force Unlock"
        forceUnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        forceUnlockBtn.Parent = lockNotification
        
        forceUnlockBtn.MouseButton1Click:Connect(function()
            SessionManager.forceReleaseLock(dataStoreName, keyName)
            DataExplorer.displayKeyContent(dataStoreName, keyName) -- Refresh
        end)
    end
    
    -- Retrieve schema if exists for current datastore/key
    local currentSchema = SchemaManager.loadSchema(dataStoreName, keyName)
    
    -- Create header
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 60)
    headerFrame.Position = UDim2.new(0, 0, 0, lockAcquired and 0 or 50)
    headerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = contentPane
    
    -- Display the key name and datastore
    local keyTitle = Instance.new("TextLabel")
    keyTitle.Size = UDim2.new(1, -20, 0, 24)
    keyTitle.Position = UDim2.new(0, 10, 0, 5)
    keyTitle.BackgroundTransparency = 1
    keyTitle.Text = keyName
    keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyTitle.TextXAlignment = Enum.TextXAlignment.Left
    keyTitle.Font = Enum.Font.SourceSansBold
    keyTitle.TextSize = 18
    keyTitle.Parent = headerFrame
    
    local datastoreSubtitle = Instance.new("TextLabel")
    datastoreSubtitle.Size = UDim2.new(1, -20, 0, 18)
    datastoreSubtitle.Position = UDim2.new(0, 10, 0, 30)
    datastoreSubtitle.BackgroundTransparency = 1
    datastoreSubtitle.Text = "DataStore: " .. dataStoreName
    datastoreSubtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    datastoreSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    datastoreSubtitle.Font = Enum.Font.SourceSans
    datastoreSubtitle.TextSize = 14
    datastoreSubtitle.Parent = headerFrame
    
    -- Add button panel for actions
    local actionPanel = Instance.new("Frame")
    actionPanel.Size = UDim2.new(0, 300, 0, 50)
    actionPanel.Position = UDim2.new(1, -310, 0, 5)
    actionPanel.BackgroundTransparency = 1
    actionPanel.Parent = headerFrame
    
    local panelLayout = Instance.new("UIListLayout")
    panelLayout.FillDirection = Enum.FillDirection.Horizontal
    panelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    panelLayout.Padding = UDim.new(0, 10)
    panelLayout.Parent = actionPanel
    
    -- Create validation message area
    local validationMessageFrame = Instance.new("Frame")
    validationMessageFrame.Size = UDim2.new(1, 0, 0, 0) -- Will auto-expand if needed
    validationMessageFrame.Position = UDim2.new(0, 0, 0, headerFrame.Position.Y.Offset + headerFrame.Size.Y.Offset)
    validationMessageFrame.BackgroundTransparency = 1
    validationMessageFrame.Visible = false
    validationMessageFrame.Name = "ValidationMessageFrame"
    validationMessageFrame.Parent = contentPane
    
    local validationMessage = Instance.new("TextLabel")
    validationMessage.Size = UDim2.new(1, -20, 1, 0)
    validationMessage.Position = UDim2.new(0, 10, 0, 0)
    validationMessage.BackgroundTransparency = 1
    validationMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
    validationMessage.TextXAlignment = Enum.TextXAlignment.Left
    validationMessage.TextWrapped = true
    validationMessage.Font = Enum.Font.SourceSans
    validationMessage.TextSize = 14
    validationMessage.Name = "ValidationMessage"
    validationMessage.Parent = validationMessageFrame
    
    -- Add a tab system for different views
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(1, 0, 0, 30)
    tabsFrame.Position = UDim2.new(0, 0, 0, headerFrame.Position.Y.Offset + headerFrame.Size.Y.Offset)
    tabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Parent = contentPane
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.Padding = UDim.new(0, 2)
    tabsLayout.Parent = tabsFrame
    
    -- Create content area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, 0, 1, -(tabsFrame.Position.Y.Offset + tabsFrame.Size.Y.Offset + 10))
    contentArea.Position = UDim2.new(0, 0, 0, tabsFrame.Position.Y.Offset + tabsFrame.Size.Y.Offset + 5)
    contentArea.BackgroundTransparency = 1
    contentArea.Name = "ContentArea"
    contentArea.Parent = contentPane
    
    -- Function to create a tab
    local function createTab(name, selected)
        local tab = Instance.new("TextButton")
        tab.Size = UDim2.new(0, 100, 1, 0)
        tab.BackgroundColor3 = selected and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
        tab.BorderSizePixel = 0
        tab.Text = name
        tab.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        tab.Font = Enum.Font.SourceSansSemibold
        tab.Name = "Tab_" .. name
        tab.Parent = tabsFrame
        
        return tab
    end
    
    -- Function to create a view container
    local function createViewContainer(name)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Visible = false
        container.Name = "View_" .. name
        container.Parent = contentArea
        
        return container
    end
    
    -- Create tabs and view containers
    local tabJsonEditor = createTab("JSON Editor", true)
    local tabTreeView = createTab("Tree View", false)
    local tabRawView = createTab("Raw View", false)
    local tabVisualizer = createTab("Visualizer", false)
    local tabSchema = createTab("Schema", false)
    
    local viewJsonEditor = createViewContainer("JSON Editor")
    local viewTreeView = createViewContainer("Tree View")
    local viewRawView = createViewContainer("Raw View")
    local viewVisualizer = createViewContainer("Visualizer")
    local viewSchema = createViewContainer("Schema")
    
    -- Make JSON Editor visible by default
    viewJsonEditor.Visible = true
    
    -- Function to switch tabs
    local function switchTab(selectedTabName)
        for _, tab in ipairs(tabsFrame:GetChildren()) do
            if tab:IsA("TextButton") and tab.Name:match("^Tab_") then
                local isSelected = tab.Name == "Tab_" .. selectedTabName
                tab.BackgroundColor3 = isSelected and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(40, 40, 50)
                tab.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            end
        end
        
        for _, view in ipairs(contentArea:GetChildren()) do
            if view:IsA("Frame") and view.Name:match("^View_") then
                view.Visible = view.Name == "View_" .. selectedTabName
            end
        end
    end
    
    -- Connect tab click events
    tabJsonEditor.MouseButton1Click:Connect(function() switchTab("JSON Editor") end)
    tabTreeView.MouseButton1Click:Connect(function() switchTab("Tree View") end)
    tabRawView.MouseButton1Click:Connect(function() switchTab("Raw View") end)
    tabVisualizer.MouseButton1Click:Connect(function() switchTab("Visualizer") end)
    tabSchema.MouseButton1Click:Connect(function() switchTab("Schema") end)
    
    -- Fetch the data from DataStore
    local dataStore = DataStoreService:GetDataStore(dataStoreName)
    
    -- Check cache first before fetching from DataStore
    local cachedData = CacheManager.get(dataStoreName, keyName)
    local success, data, operationDuration
    
    if cachedData then
        success, data = true, cachedData
        print("DataExplorer: Retrieved data from cache for", dataStoreName .. ":" .. keyName)
    else
        success, data, operationDuration = PerformanceMonitor.timeOperation(
            "GetAsync",
            function() return pcall(dataStore.GetAsync, dataStore, keyName) end,
            dataStoreName,
            keyName
        )
        print("Operation: GetAsync, Duration:", operationDuration)
        
        -- Cache the data if retrieved successfully
        if success and data then
            CacheManager.set(dataStoreName, keyName, data, 300) -- Cache for 5 minutes
        end
    end
    
    if not success or not data then
        -- Show error
        validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
        validationMessageFrame.Visible = true
        validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        validationMessageFrame.BackgroundTransparency = 0.7
        validationMessage.Text = "Error fetching data: " .. (not success and tostring(data) or "No data found")
        return
    end
    
    -- Convert data to a JSON-encoded string for editing
    local encodedData = HttpService:JSONEncode(data)
    
    -- Save function
    local function saveData(dataToSave)
        if not lockAcquired then
            validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
            validationMessageFrame.Visible = true
            validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            validationMessageFrame.BackgroundTransparency = 0.7
            validationMessage.Text = "Cannot save: Key is locked by another session"
            return false
        end
        
        -- Validate data before saving
        if currentSchema then
            local isValid, validationResult = SchemaManager.validateData(dataToSave, currentSchema)
            if not isValid then
                validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
                validationMessageFrame.Visible = true
                validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                validationMessageFrame.BackgroundTransparency = 0.7
                validationMessage.Text = "Data validation failed: " .. validationResult
                return false
            end
        end
        
        -- Save the data
        local success2, result, operationDuration2 = PerformanceMonitor.timeOperation(
            "SetAsync",
            function() return pcall(dataStore.SetAsync, dataStore, keyName, dataToSave) end,
            dataStoreName,
            keyName
        )
        print("Operation: SetAsync, Duration:", operationDuration2)
        
        if success2 then
            -- Update cache
            CacheManager.set(dataStoreName, keyName, dataToSave, 300)
            
            -- Show success message
            validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
            validationMessageFrame.Visible = true
            validationMessageFrame.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            validationMessageFrame.BackgroundTransparency = 0.7
            validationMessage.Text = "Data saved successfully"
            validationMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            -- Hide the message after 3 seconds
            task.delay(3, function()
                validationMessageFrame.Visible = false
            end)
            
            return true
        else
            -- Show error message
            validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
            validationMessageFrame.Visible = true
            validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            validationMessageFrame.BackgroundTransparency = 0.7
            validationMessage.Text = "Error saving data: " .. tostring(result)
            validationMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
            return false
        end
    end
    
    -- Create save button
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0, 100, 0, 36)
    saveButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.Font = Enum.Font.SourceSansBold
    saveButton.TextSize = 16
    saveButton.AutoButtonColor = true
    saveButton.Parent = actionPanel
    
    -- Create other action buttons
    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.new(0, 100, 0, 36)
    refreshButton.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    refreshButton.BorderSizePixel = 0
    refreshButton.Text = "Refresh"
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Font = Enum.Font.SourceSansBold
    refreshButton.TextSize = 16
    refreshButton.AutoButtonColor = true
    refreshButton.Parent = actionPanel
    
    refreshButton.MouseButton1Click:Connect(function()
        DataExplorer.displayKeyContent(dataStoreName, keyName)
    end)
    
    -- Implement the JSON Editor View
    local jsonEditor = Instance.new("TextBox")
    jsonEditor.Size = UDim2.new(1, -20, 1, -10)
    jsonEditor.Position = UDim2.new(0, 10, 0, 5)
    jsonEditor.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    jsonEditor.BorderColor3 = Color3.fromRGB(60, 60, 80)
    jsonEditor.ClearTextOnFocus = false
    jsonEditor.Font = Enum.Font.Code
    jsonEditor.TextColor3 = Color3.fromRGB(255, 255, 255)
    jsonEditor.TextSize = 14
    jsonEditor.TextXAlignment = Enum.TextXAlignment.Left
    jsonEditor.TextYAlignment = Enum.TextYAlignment.Top
    jsonEditor.Text = encodedData
    jsonEditor.MultiLine = true
    jsonEditor.TextWrapped = false
    jsonEditor.Name = "JSONEditor"
    jsonEditor.Parent = viewJsonEditor
    
    -- Implement Save functionality
    saveButton.MouseButton1Click:Connect(function()
        local success, decodedData = pcall(HttpService.JSONDecode, HttpService, jsonEditor.Text)
        if success then
            saveData(decodedData)
        else
            -- Show error message
            validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
            validationMessageFrame.Visible = true
            validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            validationMessageFrame.BackgroundTransparency = 0.7
            validationMessage.Text = "Invalid JSON: " .. decodedData
            validationMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    -- Function to create a formatted JSON view with syntax highlighting
    local function createFormattedJsonView(container, jsonData)
        local formattedView = Instance.new("ScrollingFrame")
        formattedView.Size = UDim2.new(1, -20, 1, -10)
        formattedView.Position = UDim2.new(0, 10, 0, 5)
        formattedView.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        formattedView.BorderColor3 = Color3.fromRGB(60, 60, 80)
        formattedView.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be set later
        formattedView.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
        formattedView.ScrollBarThickness = 6
        formattedView.ScrollingDirection = Enum.ScrollingDirection.Y
        formattedView.Parent = container
        
        local textLayout = Instance.new("UIListLayout")
        textLayout.SortOrder = Enum.SortOrder.LayoutOrder
        textLayout.Parent = formattedView
        
        -- Helper function to create a text line
        local function createTextLine(text, color, indent)
            local line = Instance.new("TextLabel")
            line.Size = UDim2.new(1, -indent, 0, 18)
            line.Position = UDim2.new(0, indent, 0, 0)
            line.BackgroundTransparency = 1
            line.Text = text
            line.TextColor3 = color or Color3.fromRGB(255, 255, 255)
            line.TextXAlignment = Enum.TextXAlignment.Left
            line.Font = Enum.Font.Code
            line.TextSize = 14
            line.LayoutOrder = textLayout.AbsoluteContentSize.Y
            line.Parent = formattedView
            return line
        end
        
        -- Format the JSON nicely
        local formattingSuccess, formattedJson = pcall(function()
            local lines = {}
            local indentLevel = 0
            local inString = false
            local currentLine = ""
            
            local function addLine()
                if currentLine ~= "" then
                    table.insert(lines, {text = currentLine, indent = indentLevel * 20})
                    currentLine = ""
                end
            end
            
            -- Very basic JSON formatter (in practice, we'd use a proper parser)
            for i = 1, #jsonData do
                local char = string.sub(jsonData, i, i)
                
                if char == '"' and string.sub(jsonData, i-1, i-1) ~= "\\" then
                    inString = not inString
                end
                
                if not inString then
                    if char == "{" or char == "[" then
                        addLine()
                        table.insert(lines, {text = char, indent = indentLevel * 20})
                        indentLevel = indentLevel + 1
                        addLine()
                    elseif char == "}" or char == "]" then
                        addLine()
                        indentLevel = indentLevel - 1
                        table.insert(lines, {text = char, indent = indentLevel * 20})
                    elseif char == "," then
                        currentLine = currentLine .. char
                        addLine()
                    elseif char == ":" then
                        currentLine = currentLine .. char .. " "
                    elseif char ~= " " and char ~= "\t" and char ~= "\n" and char ~= "\r" then
                        currentLine = currentLine .. char
                    end
                else
                    currentLine = currentLine .. char
                end
            end
            
            addLine()
            return lines
        end)
        
        if formattingSuccess then
            for _, line in ipairs(formattedJson) do
                createTextLine(line.text, nil, line.indent)
            end
        else
            createTextLine("Error formatting JSON: " .. tostring(formattedJson), Color3.fromRGB(255, 100, 100), 0)
        end
    end
    
    -- Implement Raw View
    createFormattedJsonView(viewRawView, encodedData)
    
    -- Implement the Tree View (recursive table explorer)
    local function createTreeView(container, data)
        local treeRoot = Instance.new("ScrollingFrame")
        treeRoot.Size = UDim2.new(1, -20, 1, -10)
        treeRoot.Position = UDim2.new(0, 10, 0, 5)
        treeRoot.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        treeRoot.BorderColor3 = Color3.fromRGB(60, 60, 80)
        treeRoot.CanvasSize = UDim2.new(0, 0, 0, 0)
        treeRoot.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
        treeRoot.ScrollBarThickness = 6
        treeRoot.Parent = container
        
        local treeLayout = Instance.new("UIListLayout")
        treeLayout.SortOrder = Enum.SortOrder.LayoutOrder
        treeLayout.Padding = UDim.new(0, 1)
        treeLayout.Parent = treeRoot
        
        -- Recursively create tree nodes
        local function createTreeNode(key, value, depth, parent)
            local nodeFrame = Instance.new("Frame")
            nodeFrame.Size = UDim2.new(1, 0, 0, 24)
            nodeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            nodeFrame.BackgroundTransparency = 0.2
            nodeFrame.LayoutOrder = parent.AbsoluteSize.Y
            nodeFrame.Parent = parent
            
            local indent = depth * 20
            
            -- Toggle button for tables
            local isExpandable = type(value) == "table"
            if isExpandable then
                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Size = UDim2.new(0, 16, 0, 16)
                toggleBtn.Position = UDim2.new(0, indent, 0.5, -8)
                toggleBtn.Text = "+"
                toggleBtn.BackgroundTransparency = 1
                toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleBtn.Name = "ToggleBtn"
                toggleBtn.Parent = nodeFrame
                
                -- Content frame for children (initially hidden)
                local contentFrame = Instance.new("Frame")
                contentFrame.Size = UDim2.new(1, 0, 0, 0)
                contentFrame.BackgroundTransparency = 1
                contentFrame.Visible = false
                contentFrame.Name = "Content_" .. tostring(key)
                contentFrame.LayoutOrder = nodeFrame.LayoutOrder + 1
                contentFrame.Parent = parent
                
                -- Content layout
                local contentLayout = Instance.new("UIListLayout")
                contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                contentLayout.Parent = contentFrame
                
                -- Store expanded state
                toggleBtn:SetAttribute("Expanded", false)
                toggleBtn:SetAttribute("ContentFrame", contentFrame.Name)
                
                -- Toggle content visibility
                toggleBtn.MouseButton1Click:Connect(function()
                    local expanded = toggleBtn:GetAttribute("Expanded")
                    expanded = not expanded
                    toggleBtn:SetAttribute("Expanded", expanded)
                    toggleBtn.Text = expanded and "-" or "+"
                    contentFrame.Visible = expanded
                    
                    -- Create children on first expansion
                    if expanded and not toggleBtn:GetAttribute("ChildrenCreated") then
                        toggleBtn:SetAttribute("ChildrenCreated", true)
                        
                        -- Add children
                        if type(value) == "table" then
                            -- Sort keys to ensure consistent display
                            local keys = {}
                            for k in pairs(value) do
                                table.insert(keys, k)
                            end
                            table.sort(keys, function(a, b)
                                if type(a) == type(b) then
                                    if type(a) == "number" then
                                        return a < b
                                    else
                                        return tostring(a) < tostring(b)
                                    end
                                else
                                    return type(a) == "number"
                                end
                            end)
                            
                            for _, k in ipairs(keys) do
                                createTreeNode(k, value[k], depth + 1, contentFrame)
                            end
                        end
                    end
                end)
            end
            
            -- Key label
            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(0.5, -indent - (isExpandable and 20 or 0), 1, 0)
            keyLabel.Position = UDim2.new(0, indent + (isExpandable and 20 or 0), 0, 0)
            keyLabel.BackgroundTransparency = 1
            keyLabel.TextXAlignment = Enum.TextXAlignment.Left
            keyLabel.Text = tostring(key) .. ":"
            keyLabel.TextColor3 = Color3.fromRGB(80, 160, 255)
            keyLabel.Font = Enum.Font.Code
            keyLabel.TextSize = 14
            keyLabel.Parent = nodeFrame
            
            -- Value display - different formatting based on type
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.5, 0, 1, 0)
            valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.Parent = nodeFrame
            
            if type(value) == "string" then
                valueLabel.Text = '"' .. value .. '"'
                valueLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
            elseif type(value) == "number" then
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = Color3.fromRGB(255, 200, 150)
            elseif type(value) == "boolean" then
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = Color3.fromRGB(255, 160, 160)
            elseif type(value) == "table" then
                local count = 0
                for _ in pairs(value) do
                    count = count + 1
                end
                valueLabel.Text = "{...} (" .. count .. " items)"
                valueLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
            else
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            valueLabel.Font = Enum.Font.Code
            valueLabel.TextSize = 14
        end
        
        -- Start creating the tree with the root object
        if type(data) == "table" then
            -- Sort keys for consistent display
            local keys = {}
            for k in pairs(data) do
                table.insert(keys, k)
            end
            table.sort(keys, function(a, b)
                if type(a) == type(b) then
                    if type(a) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                else
                    return type(a) == "number"
                end
            end)
            
            for _, k in ipairs(keys) do
                createTreeNode(k, data[k], 0, treeRoot)
            end
        else
            -- If it's not a table, just display the value
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(1, -10, 0, 24)
            valueLabel.Position = UDim2.new(0, 5, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.Text = tostring(data)
            valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueLabel.Font = Enum.Font.Code
            valueLabel.TextSize = 14
            valueLabel.Parent = treeRoot
        end
    end
    
    -- Implement Tree View
    createTreeView(viewTreeView, data)
    
    -- Implement Visualizer based on data type
    local function createVisualizer(container, data)
        local function createBasicStatsView()
            local statsFrame = Instance.new("Frame")
            statsFrame.Size = UDim2.new(1, -20, 0, 200)
            statsFrame.Position = UDim2.new(0, 10, 0, 10)
            statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            statsFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
            statsFrame.Parent = container
            
            local statsLayout = Instance.new("UIListLayout")
            statsLayout.Padding = UDim.new(0, 5)
            statsLayout.Parent = statsFrame
            
            -- Helper to create stat rows
            local function addStat(name, value, color)
                local statRow = Instance.new("Frame")
                statRow.Size = UDim2.new(1, 0, 0, 24)
                statRow.BackgroundTransparency = 1
                statRow.Parent = statsFrame
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = name
                nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Font = Enum.Font.SourceSansSemibold
                nameLabel.TextSize = 14
                nameLabel.Parent = statRow
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.7, 0, 1, 0)
                valueLabel.Position = UDim2.new(0.3, 0, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = tostring(value)
                valueLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.Font = Enum.Font.SourceSans
                valueLabel.TextSize = 14
                valueLabel.Parent = statRow
            end
            
            -- Count total size
            local function countSize(obj)
                local jsonStr = HttpService:JSONEncode(obj)
                return #jsonStr
            end
            
            -- Analyze data structure
            local dataSize = countSize(data)
            local dataType = type(data)
            local itemCount = 0
            local nestedLevels = 0
            
            local function analyzeTable(tbl, level)
                nestedLevels = math.max(nestedLevels, level)
                for k, v in pairs(tbl) do
                    itemCount = itemCount + 1
                    if type(v) == "table" then
                        analyzeTable(v, level + 1)
                    end
                end
            end
            
            if dataType == "table" then
                analyzeTable(data, 1)
            end
            
            -- Add stats
            addStat("Data Type", dataType:upper(), Color3.fromRGB(100, 180, 255))
            addStat("Data Size", string.format("%.2f KB", dataSize / 1024), Color3.fromRGB(255, 200, 100))
            
            if dataType == "table" then
                addStat("Item Count", itemCount, Color3.fromRGB(180, 255, 120))
                addStat("Nested Levels", nestedLevels, Color3.fromRGB(255, 150, 150))
            end
            
            -- Return the stats frame for further customization
            return statsFrame
        end
        
        local statsView = createBasicStatsView()
        
        -- Create chart area (if data is suitable for visualization)
        if type(data) == "table" then
            local chartFrame = Instance.new("Frame")
            chartFrame.Size = UDim2.new(1, -20, 0, 300)
            chartFrame.Position = UDim2.new(0, 10, 0, statsView.Size.Y.Offset + 20)
            chartFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            chartFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
            chartFrame.Parent = container
            
            -- Try to detect if the data is suitable for charts
            local numericalData = {}
            local hasNumericalData = false
            
            -- Look for arrays of numbers or objects with numerical properties
            if type(data) == "table" then
                -- Check if it's an array of numbers
                local isArray = true
                local allNumbers = true
                local i = 1
                
                for k, v in pairs(data) do
                    if k ~= i then
                        isArray = false
                    end
                    if type(v) ~= "number" then
                        allNumbers = false
                    else
                        table.insert(numericalData, v)
                    end
                    i = i + 1
                end
                
                hasNumericalData = isArray and allNumbers and #numericalData > 0
                
                -- If not a simple array, look for objects with common numerical properties
                if not hasNumericalData then
                    local commonProps = {}
                    local firstItem = true
                    
                    for _, item in pairs(data) do
                        if type(item) == "table" then
                            if firstItem then
                                for prop, value in pairs(item) do
                                    if type(value) == "number" then
                                        commonProps[prop] = true
                                    end
                                end
                                firstItem = false
                            else
                                for prop in pairs(commonProps) do
                                    if type(item[prop]) ~= "number" then
                                        commonProps[prop] = nil
                                    end
                                end
                            end
                        end
                    end
                    
                    -- If we found common numerical properties, extract them
                    local propNames = {}
                    for prop in pairs(commonProps) do
                        table.insert(propNames, prop)
                    end
                    
                    if #propNames > 0 then
                        hasNumericalData = true
                        numericalData = {}
                        
                        -- Extract property values
                        for _, item in pairs(data) do
                            if type(item) == "table" then
                                local entry = {}
                                for _, prop in ipairs(propNames) do
                                    entry[prop] = item[prop]
                                end
                                table.insert(numericalData, entry)
                            end
                        end
                    end
                end
            end
            
            -- If we found numerical data, create a chart
            if hasNumericalData then
                local chartTitle = Instance.new("TextLabel")
                chartTitle.Size = UDim2.new(1, 0, 0, 30)
                chartTitle.BackgroundTransparency = 1
                chartTitle.Text = "Data Visualization"
                chartTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                chartTitle.Font = Enum.Font.SourceSansBold
                chartTitle.TextSize = 16
                chartTitle.Parent = chartFrame
                
                local chartArea = Instance.new("Frame")
                chartArea.Size = UDim2.new(1, -20, 1, -40)
                chartArea.Position = UDim2.new(0, 10, 0, 30)
                chartArea.BackgroundTransparency = 1
                chartArea.Parent = chartFrame
                
                -- Create a basic bar chart if simple array of numbers
                if type(numericalData[1]) == "number" then
                    local maxValue = 0
                    for _, value in ipairs(numericalData) do
                        maxValue = math.max(maxValue, value)
                    end
                    
                    local barWidth = chartArea.Size.X.Scale / #numericalData
                    local padding = 0.1 * barWidth
                    
                    for i, value in ipairs(numericalData) do
                        local barHeight = (value / maxValue) * chartArea.Size.Y.Scale
                        
                        local bar = Instance.new("Frame")
                        bar.Size = UDim2.new(barWidth - padding, 0, barHeight, 0)
                        bar.Position = UDim2.new((i-1) * barWidth + padding/2, 0, 1 - barHeight, 0)
                        bar.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
                        bar.BorderSizePixel = 0
                        bar.Parent = chartArea
                        
                        local valueLabel = Instance.new("TextLabel")
                        valueLabel.Size = UDim2.new(1, 0, 0, 20)
                        valueLabel.Position = UDim2.new(0, 0, -20/chartArea.Size.Y.Offset, 0)
                        valueLabel.BackgroundTransparency = 1
                        valueLabel.Text = tostring(value)
                        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        valueLabel.Font = Enum.Font.SourceSans
                        valueLabel.TextSize = 12
                        valueLabel.Parent = bar
                    end
                else
                    -- For more complex data, show a property selector
                    local propNames = {}
                    for prop in pairs(numericalData[1]) do
                        table.insert(propNames, prop)
                    end
                    
                    local selectorFrame = Instance.new("Frame")
                    selectorFrame.Size = UDim2.new(1, 0, 0, 30)
                    selectorFrame.BackgroundTransparency = 1
                    selectorFrame.Parent = chartArea
                    
                    local selectorLabel = Instance.new("TextLabel")
                    selectorLabel.Size = UDim2.new(0.3, 0, 1, 0)
                    selectorLabel.BackgroundTransparency = 1
                    selectorLabel.Text = "Select Property:"
                    selectorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    selectorLabel.TextXAlignment = Enum.TextXAlignment.Left
                    selectorLabel.Font = Enum.Font.SourceSansSemibold
                    selectorLabel.TextSize = 14
                    selectorLabel.Parent = selectorFrame
                    
                    local propDropdown = Instance.new("TextButton")
                    propDropdown.Size = UDim2.new(0.5, 0, 1, 0)
                    propDropdown.Position = UDim2.new(0.3, 0, 0, 0)
                    propDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    propDropdown.BorderColor3 = Color3.fromRGB(70, 70, 90)
                    propDropdown.Text = propNames[1]
                    propDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
                    propDropdown.Font = Enum.Font.SourceSans
                    propDropdown.TextSize = 14
                    propDropdown.Parent = selectorFrame
                    
                    -- For simplicity, we're just picking the first property without a dropdown implementation
                    -- In a real implementation, you'd create a proper dropdown menu
                    
                    -- Create a simple bar chart for the first property
                    local chartFrame = Instance.new("Frame")
                    chartFrame.Size = UDim2.new(1, 0, 1, -40)
                    chartFrame.Position = UDim2.new(0, 0, 0, 40)
                    chartFrame.BackgroundTransparency = 1
                    chartFrame.Parent = chartArea
                    
                    local selectedProp = propNames[1]
                    local maxValue = 0
                    for _, entry in ipairs(numericalData) do
                        maxValue = math.max(maxValue, entry[selectedProp] or 0)
                    end
                    
                    local barWidth = chartFrame.Size.X.Scale / #numericalData
                    local padding = 0.1 * barWidth
                    
                    for i, entry in ipairs(numericalData) do
                        local value = entry[selectedProp] or 0
                        local barHeight = (value / maxValue) * chartFrame.Size.Y.Scale
                        
                        local bar = Instance.new("Frame")
                        bar.Size = UDim2.new(barWidth - padding, 0, barHeight, 0)
                        bar.Position = UDim2.new((i-1) * barWidth + padding/2, 0, 1 - barHeight, 0)
                        bar.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
                        bar.BorderSizePixel = 0
                        bar.Parent = chartFrame
                        
                        local valueLabel = Instance.new("TextLabel")
                        valueLabel.Size = UDim2.new(1, 0, 0, 20)
                        valueLabel.Position = UDim2.new(0, 0, -20/chartFrame.Size.Y.Offset, 0)
                        valueLabel.BackgroundTransparency = 1
                        valueLabel.Text = tostring(value)
                        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        valueLabel.Font = Enum.Font.SourceSans
                        valueLabel.TextSize = 12
                        valueLabel.Parent = bar
                    end
                end
            else
                -- If no suitable data for visualization, show message
                local noChartMessage = Instance.new("TextLabel")
                noChartMessage.Size = UDim2.new(1, 0, 1, 0)
                noChartMessage.BackgroundTransparency = 1
                noChartMessage.Text = "No suitable numerical data found for visualization"
                noChartMessage.TextColor3 = Color3.fromRGB(200, 200, 200)
                noChartMessage.Font = Enum.Font.SourceSans
                noChartMessage.TextSize = 16
                noChartMessage.Parent = chartFrame
            end
        end
    end
    
    -- Implement Visualizer
    createVisualizer(viewVisualizer, data)
    
    -- Implement the Schema View
    local currentSchema = SchemaManager.loadSchema(dataStoreName, keyName)
    
    -- Create schema edit container
    local schemaContainer = Instance.new("Frame")
    schemaContainer.Size = UDim2.new(1, 0, 1, 0)
    schemaContainer.BackgroundTransparency = 1
    schemaContainer.Parent = viewSchema
    
    if currentSchema then
        -- Create a display for the current schema
        local schemaInfoFrame = Instance.new("Frame")
        schemaInfoFrame.Size = UDim2.new(1, -20, 0, 40)
        schemaInfoFrame.Position = UDim2.new(0, 10, 0, 10)
        schemaInfoFrame.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        schemaInfoFrame.BackgroundTransparency = 0.7
        schemaInfoFrame.BorderSizePixel = 0
        schemaInfoFrame.Parent = schemaContainer
        
        local schemaInfoLabel = Instance.new("TextLabel")
        schemaInfoLabel.Size = UDim2.new(1, -20, 1, 0)
        schemaInfoLabel.Position = UDim2.new(0, 10, 0, 0)
        schemaInfoLabel.BackgroundTransparency = 1
        schemaInfoLabel.Text = "Schema exists for this key"
        schemaInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        schemaInfoLabel.Font = Enum.Font.SourceSansSemibold
        schemaInfoLabel.TextSize = 16
        schemaInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        schemaInfoLabel.Parent = schemaInfoFrame
        
        -- Schema editor button
        local editSchemaButton = Instance.new("TextButton")
        editSchemaButton.Size = UDim2.new(0, 120, 0, 32)
        editSchemaButton.Position = UDim2.new(0, 10, 0, 60)
        editSchemaButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        editSchemaButton.BorderSizePixel = 0
        editSchemaButton.Text = "Edit Schema"
        editSchemaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        editSchemaButton.Font = Enum.Font.SourceSansSemibold
        editSchemaButton.TextSize = 14
        editSchemaButton.Parent = schemaContainer
        
        -- Add rounded corners to button
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = editSchemaButton
        
        -- Schema validation button
        local validateButton = Instance.new("TextButton")
        validateButton.Size = UDim2.new(0, 120, 0, 32)
        validateButton.Position = UDim2.new(0, 140, 0, 60)
        validateButton.BackgroundColor3 = Color3.fromRGB(70, 180, 70)
        validateButton.BorderSizePixel = 0
        validateButton.Text = "Validate Data"
        validateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        validateButton.Font = Enum.Font.SourceSansSemibold
        validateButton.TextSize = 14
        validateButton.Parent = schemaContainer
        
        -- Add rounded corners to button
        local validationButtonCorner = Instance.new("UICorner")
        validationButtonCorner.CornerRadius = UDim.new(0, 4)
        validationButtonCorner.Parent = validateButton
        
        -- Display schema
        local schemaDisplay = Instance.new("ScrollingFrame")
        schemaDisplay.Size = UDim2.new(1, -20, 1, -110)
        schemaDisplay.Position = UDim2.new(0, 10, 0, 100)
        schemaDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        schemaDisplay.BorderColor3 = Color3.fromRGB(60, 60, 80)
        schemaDisplay.BorderSizePixel = 1
        schemaDisplay.CanvasSize = UDim2.new(0, 0, 0, 0)
        schemaDisplay.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
        schemaDisplay.ScrollBarThickness = 6
        schemaDisplay.ScrollingDirection = Enum.ScrollingDirection.Y
        schemaDisplay.Parent = schemaContainer
        
        local schemaLayout = Instance.new("UIListLayout")
        schemaLayout.Padding = UDim.new(0, 4)
        schemaLayout.SortOrder = Enum.SortOrder.LayoutOrder
        schemaLayout.Parent = schemaDisplay
        
        -- Format and display the schema
        local function addSchemaEntry(name, schema, indent)
            indent = indent or 0
            
            local entryFrame = Instance.new("Frame")
            entryFrame.Size = UDim2.new(1, 0, 0, 24)
            entryFrame.BackgroundTransparency = 1
            entryFrame.LayoutOrder = #schemaDisplay:GetChildren()
            entryFrame.Parent = schemaDisplay
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, indent * 20, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name .. ":"
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.Code
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = entryFrame
            
            local typeLabel = Instance.new("TextLabel")
            typeLabel.Size = UDim2.new(0.6, 0, 1, 0)
            typeLabel.Position = UDim2.new(0.4, 0, 0, 0)
            typeLabel.BackgroundTransparency = 1
            
            if typeof(schema) == "table" then
                typeLabel.Text = schema.type or "table"
                typeLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
                
                -- Recursively add nested properties
                if schema.type == "table" and schema.properties then
                    for propName, propSchema in pairs(schema.properties) do
                        addSchemaEntry(propName, propSchema, indent + 1)
                    end
                elseif schema.type == "array" and schema.items then
                    addSchemaEntry("(items)", schema.items, indent + 1)
                end
            else
                typeLabel.Text = tostring(schema)
                typeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            end
            
            typeLabel.Font = Enum.Font.Code
            typeLabel.TextSize = 14
            typeLabel.TextXAlignment = Enum.TextXAlignment.Left
            typeLabel.Parent = entryFrame
        end
        
        -- Display the schema structure recursively
        if typeof(currentSchema) == "table" then
            for fieldName, fieldSchema in pairs(currentSchema) do
                addSchemaEntry(fieldName, fieldSchema, 0)
            end
        end
        
        -- Connect validate button
        validateButton.MouseButton1Click:Connect(function()
            -- Get current data
            local success, decodedData
            if tabJsonEditor.Visible then
                success, decodedData = pcall(HttpService.JSONDecode, HttpService, jsonEditor.Text)
            else
                success, decodedData = pcall(HttpService.JSONDecode, HttpService, encodedData)
            end
            
            if not success then
                -- Show error message
                validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
                validationMessageFrame.Visible = true
                validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                validationMessageFrame.BackgroundTransparency = 0.7
                validationMessage.Text = "Invalid JSON: Cannot validate"
                validationMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
                return
            end
            
            -- Validate against schema
            local isValid, validationResult = SchemaValidator.validate(decodedData, currentSchema)
            
            -- Show validation result
            validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
            validationMessageFrame.Visible = true
            
            if isValid then
                validationMessageFrame.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
                validationMessageFrame.BackgroundTransparency = 0.7
                validationMessage.Text = "Data is valid according to schema"
                validationMessage.TextColor3 = Color3.fromRGB(220, 255, 220)
            else
                validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                validationMessageFrame.BackgroundTransparency = 0.7
                validationMessage.Text = "Validation failed: " .. tostring(validationResult)
                validationMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
        
        -- Connect edit schema button
        editSchemaButton.MouseButton1Click:Connect(function()
            -- Clear the schema view
            for _, child in ipairs(schemaContainer:GetChildren()) do
                child:Destroy()
            end
            
            -- Create schema editor
            local editorFrame = SchemaEditor.createSchemaEditorUI(schemaContainer, dataStoreName, keyName)
            editorFrame.Size = UDim2.new(1, 0, 1, 0)
            editorFrame.Parent = schemaContainer
        end)
    else
        -- No schema exists - show create options
        local noSchemaLabel = Instance.new("TextLabel")
        noSchemaLabel.Size = UDim2.new(1, -20, 0, 30)
        noSchemaLabel.Position = UDim2.new(0, 10, 0, 10)
        noSchemaLabel.BackgroundTransparency = 1
        noSchemaLabel.Text = "No schema exists for this key"
        noSchemaLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        noSchemaLabel.Font = Enum.Font.SourceSansSemibold
        noSchemaLabel.TextSize = 16
        noSchemaLabel.TextXAlignment = Enum.TextXAlignment.Left
        noSchemaLabel.Parent = schemaContainer
        
        local createButton = Instance.new("TextButton")
        createButton.Size = UDim2.new(0, 150, 0, 36)
        createButton.Position = UDim2.new(0, 10, 0, 50)
        createButton.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
        createButton.BorderSizePixel = 0
        createButton.Text = "Create Schema"
        createButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        createButton.Font = Enum.Font.SourceSansSemibold
        createButton.TextSize = 16
        createButton.Parent = schemaContainer
        
        -- Add rounded corners
        local createButtonCorner = Instance.new("UICorner")
        createButtonCorner.CornerRadius = UDim.new(0, 4)
        createButtonCorner.Parent = createButton
        
        -- Connect create button
        createButton.MouseButton1Click:Connect(function()
            -- Clear the schema view
            for _, child in ipairs(schemaContainer:GetChildren()) do
                child:Destroy()
            end
            
            -- Create schema editor
            local editorFrame = SchemaEditor.createSchemaEditorUI(schemaContainer, dataStoreName, keyName)
            editorFrame.Size = UDim2.new(1, 0, 1, 0)
            editorFrame.Parent = schemaContainer
        end)
        
        -- Option to auto-generate from data
        local generateButton = Instance.new("TextButton")
        generateButton.Size = UDim2.new(0, 200, 0, 36)
        generateButton.Position = UDim2.new(0, 170, 0, 50)
        generateButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        generateButton.BorderSizePixel = 0
        generateButton.Text = "Generate from Data"
        generateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        generateButton.Font = Enum.Font.SourceSansSemibold
        generateButton.TextSize = 16
        generateButton.Parent = schemaContainer
        
        -- Add rounded corners
        local generateButtonCorner = Instance.new("UICorner")
        generateButtonCorner.CornerRadius = UDim.new(0, 4)
        generateButtonCorner.Parent = generateButton
        
        -- Connect generate button
        generateButton.MouseButton1Click:Connect(function()
            -- Parse the current data
            local success, decodedData = pcall(HttpService.JSONDecode, HttpService, encodedData)
            
            if not success then
                -- Show error message
                validationMessageFrame.Size = UDim2.new(1, 0, 0, 40)
                validationMessageFrame.Visible = true
                validationMessageFrame.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                validationMessageFrame.BackgroundTransparency = 0.7
                validationMessage.Text = "Invalid JSON: Cannot generate schema"
                validationMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
                return
            end
            
            -- Generate schema from data
            local generatedSchema = generateSchemaFromData(decodedData)
            
            -- Save the generated schema
            SchemaManager.saveSchema(generatedSchema, dataStoreName, keyName)
            
            -- Refresh the schema view
            DataExplorer.displayKeyContent(dataStoreName, keyName)
            switchTab("Schema")
        end)
    end
end

-- Create and show the Session Management UI
function DataExplorer.showSessionManagementUI()
    -- Check if the UI already exists
    if DataExplorer.sessionManagementUI then
        -- Toggle visibility
        DataExplorer.sessionManagementUI.Visible = not DataExplorer.sessionManagementUI.Visible
        return
    end
    
    -- Create the session management UI
    local uiContainer = Instance.new("Frame")
    uiContainer.Name = "SessionManagementContainer"
    uiContainer.Size = UDim2.new(0.7, 0, 0.8, 0)
    uiContainer.Position = UDim2.new(0.15, 0, 0.1, 0)
    uiContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    uiContainer.BorderSizePixel = 0
    uiContainer.ZIndex = 100
    uiContainer.Parent = DataExplorer.mainFrame
    
    -- Add rounded corners
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = uiContainer
    
    -- Add a close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.Position = UDim2.new(1, -32, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.ZIndex = 101
    closeButton.Parent = uiContainer
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = closeButton
    
    -- Connect close button
    closeButton.MouseButton1Click:Connect(function()
        uiContainer.Visible = false
    end)
    
    -- Create the session management UI inside the container
    local sessionManagementUI = SessionManagementUI.createUI(uiContainer)
    sessionManagementUI.Visible = true
    sessionManagementUI.Position = UDim2.new(0, 0, 0, 0)
    sessionManagementUI.Size = UDim2.new(1, 0, 1, 0)
    sessionManagementUI.Parent = uiContainer
    
    -- Store a reference to the UI
    DataExplorer.sessionManagementUI = uiContainer
end

function DataExplorer.initMonitoringDashboardUI()
    local mainFrame = DataExplorer.mainFrame
    if not mainFrame then return end
    
    -- Create a button to open monitoring dashboard
    local monitoringButton = Instance.new("TextButton")
    monitoringButton.Size = UDim2.new(0, 150, 0, 28)
    monitoringButton.Position = UDim2.new(1, -450, 0, 10) -- Position it to the left of Schema Builder button
    monitoringButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173) -- Purple color for monitoring
    monitoringButton.BorderSizePixel = 0
    monitoringButton.Text = "Monitoring Dashboard"
    monitoringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    monitoringButton.Font = Enum.Font.SourceSansSemibold
    monitoringButton.TextSize = 14
    monitoringButton.ZIndex = 5
    monitoringButton.Parent = mainFrame
    
    -- Add rounded corners
    local monitoringButtonCorner = Instance.new("UICorner")
    monitoringButtonCorner.CornerRadius = UDim.new(0, 4)
    monitoringButtonCorner.Parent = monitoringButton
    
    -- Create a container for the monitoring dashboard (initially invisible)
    local monitoringDashboardContainer = Instance.new("Frame")
    monitoringDashboardContainer.Size = UDim2.new(1, 0, 1, 0)
    monitoringDashboardContainer.Position = UDim2.new(0, 0, 0, 0)
    monitoringDashboardContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    monitoringDashboardContainer.Visible = false
    monitoringDashboardContainer.Name = "MonitoringDashboardContainer"
    monitoringDashboardContainer.Parent = mainFrame
    DataExplorer.monitoringDashboardContainer = monitoringDashboardContainer
    
    -- Create the monitoring dashboard
    local MonitoringDashboard = require(script.Parent.MonitoringDashboard)
    MonitoringDashboard.createDashboardUI(monitoringDashboardContainer)
    
    -- Toggle visibility when monitoring button is clicked
    monitoringButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if DataExplorer.monitoringDashboardContainer.Visible then
            -- Hide monitoring dashboard and show normal UI
            DataExplorer.monitoringDashboardContainer.Visible = false
            contentPane.Visible = true
            navPane.Visible = true
            monitoringButton.Text = "Monitoring Dashboard"
            monitoringButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
            
            -- Also ensure other containers are hidden
            if DataExplorer.schemaBuilderContainer then
                DataExplorer.schemaBuilderContainer.Visible = false
            end
            
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.dataMigrationContainer then
                DataExplorer.dataMigrationContainer.Visible = false
            end
        else
            -- Show monitoring dashboard and hide normal UI
            DataExplorer.monitoringDashboardContainer.Visible = true
            contentPane.Visible = false
            navPane.Visible = false
            monitoringButton.Text = "Back to Explorer"
            monitoringButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            
            -- Also ensure other containers are hidden
            if DataExplorer.schemaBuilderContainer then
                DataExplorer.schemaBuilderContainer.Visible = false
            end
            
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.dataMigrationContainer then
                DataExplorer.dataMigrationContainer.Visible = false
            end
        end
    end)
end

function DataExplorer.initDataMigrationUI()
    local mainFrame = DataExplorer.mainFrame
    if not mainFrame then return end
    
    -- Create a button to open data migration tools
    local dataMigrationButton = Instance.new("TextButton")
    dataMigrationButton.Size = UDim2.new(0, 150, 0, 30)
    dataMigrationButton.Position = UDim2.new(1, -160, 0, 50) -- Position below other buttons
    dataMigrationButton.BackgroundColor3 = Color3.fromRGB(142, 145, 250) -- Purple color
    dataMigrationButton.BorderSizePixel = 0
    dataMigrationButton.Text = "Data Migration"
    dataMigrationButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dataMigrationButton.Font = Enum.Font.SourceSansBold
    dataMigrationButton.TextSize = 14
    dataMigrationButton.ZIndex = 5
    dataMigrationButton.Parent = mainFrame
    
    -- Add rounded corners
    local migrationButtonCorner = Instance.new("UICorner")
    migrationButtonCorner.CornerRadius = UDim.new(0, 4)
    migrationButtonCorner.Parent = dataMigrationButton
    
    -- Create the data migration container (initially invisible)
    local dataMigrationContainer = DataMigrationUI.createTab(mainFrame)
    DataExplorer.dataMigrationContainer = dataMigrationContainer
    
    -- Toggle visibility when button is clicked
    dataMigrationButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if dataMigrationContainer.Visible then
            -- Hide data migration and show normal UI
            dataMigrationContainer.Visible = false
            contentPane.Visible = true
            navPane.Visible = true
            dataMigrationButton.Text = "Data Migration"
            dataMigrationButton.BackgroundColor3 = Color3.fromRGB(142, 145, 250)
            
            -- Also ensure other containers are hidden
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.schemaBuilderContainer then
                DataExplorer.schemaBuilderContainer.Visible = false
            end
            
            if DataExplorer.monitoringDashboardContainer then
                DataExplorer.monitoringDashboardContainer.Visible = false
            end
        else
            -- Show data migration and hide normal UI
            dataMigrationContainer.Visible = true
            contentPane.Visible = false
            navPane.Visible = false
            dataMigrationButton.Text = "Back to Explorer"
            dataMigrationButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            
            -- Also ensure other containers are hidden
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.schemaBuilderContainer then
                DataExplorer.schemaBuilderContainer.Visible = false
            end
            
            if DataExplorer.monitoringDashboardContainer then
                DataExplorer.monitoringDashboardContainer.Visible = false
            end
        end
    end)
end

function DataExplorer.initMultiServerCoordinationUI()
    if MultiServerCoordinationIntegration and MultiServerCoordinationIntegration.initMultiServerCoordinationUI then
        MultiServerCoordinationIntegration.initMultiServerCoordinationUI(DataExplorer)
    else
        local mainFrame = DataExplorer.mainFrame
        if not mainFrame then return end
    
        -- Create a button to open multi-server coordination UI
        local coordinationButton = Instance.new("TextButton")
        coordinationButton.Size = UDim2.new(0, 150, 0, 28)
        coordinationButton.Position = UDim2.new(1, -600, 0, 10) -- Position it to the left of other buttons
        coordinationButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219) -- Blue color for coordination
        coordinationButton.BorderSizePixel = 0
        coordinationButton.Text = "Server Coordination"
        coordinationButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        coordinationButton.Font = Enum.Font.SourceSansSemibold
        coordinationButton.TextSize = 14
        coordinationButton.ZIndex = 5
        coordinationButton.Parent = mainFrame
    
    -- Add rounded corners
    local coordinationButtonCorner = Instance.new("UICorner")
    coordinationButtonCorner.CornerRadius = UDim.new(0, 4)
    coordinationButtonCorner.Parent = coordinationButton
    
    -- Create a container for the multi-server coordination UI (initially invisible)
    local coordinationContainer = Instance.new("Frame")
    coordinationContainer.Size = UDim2.new(1, 0, 1, 0)
    coordinationContainer.Position = UDim2.new(0, 0, 0, 0)
    coordinationContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    coordinationContainer.Visible = false
    coordinationContainer.Name = "MultiServerCoordinationContainer"
    coordinationContainer.Parent = mainFrame
    DataExplorer.coordinationContainer = coordinationContainer
    
    -- Create the multi-server coordination UI
    local MultiServerCoordinationUI = require(script.Parent.MultiServerCoordinationUI)
    MultiServerCoordinationUI.createUI(coordinationContainer)
    
    -- Toggle visibility when coordination button is clicked
    coordinationButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if DataExplorer.coordinationContainer.Visible then
            -- Hide coordination UI and show normal UI
            DataExplorer.coordinationContainer.Visible = false
            contentPane.Visible = true
            navPane.Visible = true
            coordinationButton.Text = "Server Coordination"
            coordinationButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
            
            -- Also ensure other containers are hidden
            if DataExplorer.schemaBuilderContainer then
                DataExplorer.schemaBuilderContainer.Visible = false
            end
            
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.monitoringDashboardContainer then
                DataExplorer.monitoringDashboardContainer.Visible = false
            end
            
            if DataExplorer.dataMigrationContainer then
                DataExplorer.dataMigrationContainer.Visible = false
            end
        else
            -- Show coordination UI and hide normal UI
            DataExplorer.coordinationContainer.Visible = true
            contentPane.Visible = false
            navPane.Visible = false
            coordinationButton.Text = "Back to Explorer"
            coordinationButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            
            -- Also ensure other containers are hidden
            if DataExplorer.schemaBuilderContainer then
                DataExplorer.schemaBuilderContainer.Visible = false
            end
            
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.monitoringDashboardContainer then
                DataExplorer.monitoringDashboardContainer.Visible = false
            end
            
            if DataExplorer.dataMigrationContainer then
                DataExplorer.dataMigrationContainer.Visible = false
            end
        end
    end)
    end
end


function DataExplorer.initPerformanceAnalyzerUI()
    if PerformanceAnalyzerIntegration and PerformanceAnalyzerIntegration.initPerformanceAnalyzerUI then
        PerformanceAnalyzerIntegration.initPerformanceAnalyzerUI(DataExplorer)
    else
        local mainFrame = DataExplorer.mainFrame
        if not mainFrame then return end
    
        -- Create a button to open the performance analyzer UI
    local performanceButton = Instance.new("TextButton")
    performanceButton.Size = UDim2.new(0, 150, 0, 28)
    performanceButton.Position = UDim2.new(1, -450, 0, 10) -- Position it to the left of other buttons
    performanceButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182) -- Purple color for performance
    performanceButton.BorderSizePixel = 0
    performanceButton.Text = "Performance Analyzer"
    performanceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    performanceButton.Font = Enum.Font.SourceSansSemibold
    performanceButton.TextSize = 14
    performanceButton.ZIndex = 5
    performanceButton.Parent = mainFrame
    
    -- Add rounded corners
    local performanceButtonCorner = Instance.new("UICorner")
    performanceButtonCorner.CornerRadius = UDim.new(0, 4)
    performanceButtonCorner.Parent = performanceButton
    
    -- Create a container for the performance analyzer UI (initially invisible)
    local performanceContainer = Instance.new("Frame")
    performanceContainer.Size = UDim2.new(1, 0, 1, 0)
    performanceContainer.Position = UDim2.new(0, 0, 0, 0)
    performanceContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    performanceContainer.Visible = false
    performanceContainer.Name = "PerformanceAnalyzerContainer"
    performanceContainer.Parent = mainFrame
    DataExplorer.performanceAnalyzerContainer = performanceContainer
    
    -- Create the performance analyzer UI
    local PerformanceAnalyzerUI = require(script.Parent.PerformanceAnalyzerUI)
    PerformanceAnalyzerUI.createUI(performanceContainer)
    
    -- Toggle visibility when performance button is clicked
    performanceButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if DataExplorer.performanceAnalyzerContainer.Visible then
            -- Hide performance analyzer UI and show normal UI
            DataExplorer.performanceAnalyzerContainer.Visible = false
            if contentPane then contentPane.Visible = true end
            if navPane then navPane.Visible = true end
        else
            -- Hide normal UI and show performance analyzer UI
            DataExplorer.performanceAnalyzerContainer.Visible = true
            if contentPane then contentPane.Visible = false end
            if navPane then navPane.Visible = false end
            
            -- Hide other containers
            if DataExplorer.bulkOperationsContainer then
                DataExplorer.bulkOperationsContainer.Visible = false
            end
            
            if DataExplorer.monitoringDashboardContainer then
                DataExplorer.monitoringDashboardContainer.Visible = false
            end
            
            if DataExplorer.dataMigrationContainer then
                DataExplorer.dataMigrationContainer.Visible = false
            end
            
            if DataExplorer.coordinationContainer then
                DataExplorer.coordinationContainer.Visible = false
            end
            
            if DataExplorer.cachingSystemContainer then
                DataExplorer.cachingSystemContainer.Visible = false
            end
        end
    end)
end
end

-- Use the integration module's implementation of initCachingSystemUI
DataExplorer.initCachingSystemUI = function()
    if CachingSystemIntegration and CachingSystemIntegration.initCachingSystemUI then
        CachingSystemIntegration.initCachingSystemUI(DataExplorer)
    else
        warn("CachingSystemIntegration module or initCachingSystemUI function not found")
    end
end

-- Use the integration module's implementation of initLoadTestingUI
DataExplorer.initLoadTestingUI = function()
    if LoadTestingIntegration and LoadTestingIntegration.initLoadTestingUI then
        LoadTestingIntegration.initLoadTestingUI(DataExplorer)
    else
        warn("LoadTestingIntegration module or initLoadTestingUI function not found")
    end
end

-- Use the integration module's implementation of initCodeGeneratorUI
DataExplorer.initCodeGeneratorUI = function()
    if CodeGeneratorIntegration and CodeGeneratorIntegration.initCodeGeneratorUI then
        CodeGeneratorIntegration.initCodeGeneratorUI(DataExplorer)
    else
        warn("CodeGeneratorIntegration module or initCodeGeneratorUI function not found")
    end
end

-- Use the integration module's implementation of initAPIIntegrationUI
DataExplorer.initAPIIntegrationUI = function()
    if APIIntegrationIntegration and APIIntegrationIntegration.initAPIIntegrationUI then
        APIIntegrationIntegration.initAPIIntegrationUI(DataExplorer)
    else
        warn("APIIntegrationIntegration module or initAPIIntegrationUI function not found")
    end
end

-- Use the integration module's implementation of initAccessControlUI
DataExplorer.initAccessControlUI = function()
    if AccessControlIntegration and AccessControlIntegration.initialize then
        AccessControlIntegration.initialize(DataExplorer)
    else
        warn("AccessControlIntegration module or initialize function not found")
    end
end

return DataExplorer