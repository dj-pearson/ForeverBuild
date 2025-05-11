--luau
-- DataStore Plugin/MonitoringDashboard.luau

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local PerformanceMonitor = require(script.Parent.PerformanceMonitor)
local DataVisualization = require(script.Parent.DataVisualization)
local StyleGuide = require(script.Parent.StyleGuide)

local MonitoringDashboard = {}

-- Store real-time usage data
local usageStats = {
    reads = { total = 0, history = {} },
    writes = { total = 0, history = {} },
    memory = { current = 0, history = {} },
    errors = { total = 0, byType = {}, history = {} },
    requestRates = { current = 0, history = {} },
    quotaUsage = { current = 0, max = 0, history = {} },
}

-- Configuration
local maxHistoryPoints = 100  -- Store up to 100 data points for trending
local updateInterval = 5      -- Update stats every 5 seconds

-- Initialize the dashboard UI
function MonitoringDashboard.createDashboardUI(parent)
    local dashboardFrame = Instance.new("Frame")
    dashboardFrame.Size = UDim2.new(1, 0, 1, 0)
    dashboardFrame.BackgroundTransparency = 1
    dashboardFrame.Name = "MonitoringDashboardFrame"
    dashboardFrame.Parent = parent
    
    -- Create tab buttons for different sections
    local tabButtons = Instance.new("Frame")
    tabButtons.Size = UDim2.new(1, 0, 0, 30)
    tabButtons.BackgroundColor3 = StyleGuide.getColor("secondaryBackground")
    tabButtons.Name = "TabButtons"
    tabButtons.Parent = dashboardFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabButtons
    
    -- Create the tabs
    local tabs = {
        {name = "Overview", layoutOrder = 1},
        {name = "Requests", layoutOrder = 2},
        {name = "Quota", layoutOrder = 3},
        {name = "Errors", layoutOrder = 4}
    }
    
    local tabInstances = {}
    local activeTab = nil
    
    for _, tabInfo in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.BackgroundColor3 = StyleGuide.getColor("background")
        tabButton.TextColor3 = StyleGuide.getColor("text")
        tabButton.Text = tabInfo.name
        tabButton.Font = Enum.Font.SourceSansSemibold
        tabButton.TextSize = 14
        tabButton.Name = tabInfo.name .. "Tab"
        tabButton.LayoutOrder = tabInfo.layoutOrder
        tabButton.Parent = tabButtons
        
        -- Create the content frame for this tab
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 1, -30)
        contentFrame.Position = UDim2.new(0, 0, 0, 30)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = false
        contentFrame.Name = tabInfo.name .. "Content"
        contentFrame.Parent = dashboardFrame
        
        tabInstances[tabInfo.name] = {
            button = tabButton,
            content = contentFrame
        }
        
        -- Add click handlers for tabs
        tabButton.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.button.BackgroundColor3 = StyleGuide.getColor("background")
                activeTab.content.Visible = false
            end
            
            tabButton.BackgroundColor3 = StyleGuide.getColor("accent")
            contentFrame.Visible = true
            activeTab = tabInstances[tabInfo.name]
            
            -- Refresh the content when tab is selected
            MonitoringDashboard.refreshTabContent(tabInfo.name, contentFrame)
        end)
    end
    
    -- Set the default active tab
    activeTab = tabInstances["Overview"]
    activeTab.button.BackgroundColor3 = StyleGuide.getColor("accent")
    activeTab.content.Visible = true
    MonitoringDashboard.refreshTabContent("Overview", activeTab.content)
    
    -- Store reference to tab instances
    MonitoringDashboard.tabInstances = tabInstances
    
    return dashboardFrame
end

-- Refresh the content of a specific tab
function MonitoringDashboard.refreshTabContent(tabName, contentFrame)
    -- Clear existing content
    for _, child in ipairs(contentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    -- Make sure there's a layout
    if not contentFrame:FindFirstChildOfClass("UIListLayout") then
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = contentFrame
    end
    
    -- Populate content based on tab
    if tabName == "Overview" then
        MonitoringDashboard.createOverviewTab(contentFrame)
    elseif tabName == "Requests" then
        MonitoringDashboard.createRequestsTab(contentFrame)
    elseif tabName == "Quota" then
        MonitoringDashboard.createQuotaTab(contentFrame)
    elseif tabName == "Errors" then
        MonitoringDashboard.createErrorsTab(contentFrame)
    end
end

-- Create Overview tab content
function MonitoringDashboard.createOverviewTab(parent)
    -- Create summary cards for key metrics
    local summaryPanel = Instance.new("Frame")
    summaryPanel.Size = UDim2.new(1, -20, 0, 100)
    summaryPanel.Position = UDim2.new(0, 10, 0, 10)
    summaryPanel.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    summaryPanel.LayoutOrder = 1
    summaryPanel.Name = "SummaryPanel"
    summaryPanel.Parent = parent
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = summaryPanel
    
    -- Create layout for cards
    local cardLayout = Instance.new("UIGridLayout")
    cardLayout.CellSize = UDim2.new(0.25, -10, 1, -20)
    cardLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Parent = summaryPanel
    
    -- Add cards for key metrics
    local metrics = {
        {name = "Reads", value = usageStats.reads.total, color = Color3.fromRGB(52, 152, 219)},
        {name = "Writes", value = usageStats.writes.total, color = Color3.fromRGB(46, 204, 113)},
        {name = "Quota", value = string.format("%.1f%%", usageStats.quotaUsage.current * 100), color = Color3.fromRGB(155, 89, 182)},
        {name = "Errors", value = usageStats.errors.total, color = Color3.fromRGB(231, 76, 60)}
    }
    
    for i, metric in ipairs(metrics) do
        local card = Instance.new("Frame")
        card.LayoutOrder = i
        card.BackgroundColor3 = metric.color
        card.Name = metric.name .. "Card"
        card.Parent = summaryPanel
        
        -- Add rounded corners to card
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 4)
        cardCorner.Parent = card
        
        -- Add metric name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 24)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 16
        nameLabel.Text = metric.name
        nameLabel.Name = "NameLabel"
        nameLabel.Parent = card
        
        -- Add metric value
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, 0, 0, 40)
        valueLabel.Position = UDim2.new(0, 0, 0, 24)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.Font = Enum.Font.SourceSansBold
        valueLabel.TextSize = 24
        valueLabel.Text = tostring(metric.value)
        valueLabel.Name = "ValueLabel"
        valueLabel.Parent = card
    end
    
    -- Create a mini graph for overview trends
    local trendGraph = Instance.new("Frame")
    trendGraph.Size = UDim2.new(1, -20, 0, 200)
    trendGraph.Position = UDim2.new(0, 10, 0, 120)
    trendGraph.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    trendGraph.LayoutOrder = 2
    trendGraph.Name = "TrendGraph"
    trendGraph.Parent = parent
    
    -- Add rounded corners
    local graphCorner = Instance.new("UICorner")
    graphCorner.CornerRadius = UDim.new(0, 6)
    graphCorner.Parent = trendGraph
    
    -- Create the line chart for trends
    local graphData = {
        labels = {"0s", "5s", "10s", "15s", "20s", "25s", "30s", "35s", "40s", "45s", "50s", "55s", "60s"},
        datasets = {
            {
                label = "Reads",
                data = MonitoringDashboard.getLastNItems(usageStats.reads.history, 13),
                color = Color3.fromRGB(52, 152, 219)
            },
            {
                label = "Writes",
                data = MonitoringDashboard.getLastNItems(usageStats.writes.history, 13),
                color = Color3.fromRGB(46, 204, 113)
            }
        }
    }
    
    DataVisualization.createLineChart(trendGraph, graphData, "Operations Over Time", "Seconds", "Count")
end

-- Create Requests tab content
function MonitoringDashboard.createRequestsTab(parent)
    -- Create a requests rate graph
    local requestRateFrame = Instance.new("Frame")
    requestRateFrame.Size = UDim2.new(1, -20, 0, 250)
    requestRateFrame.Position = UDim2.new(0, 10, 0, 10)
    requestRateFrame.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    requestRateFrame.LayoutOrder = 1
    requestRateFrame.Name = "RequestRateFrame"
    requestRateFrame.Parent = parent
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = requestRateFrame
    
    -- Create the line chart for request rates
    local requestRateData = {
        labels = MonitoringDashboard.generateTimeLabels(15),
        datasets = {
            {
                label = "Request Rate",
                data = MonitoringDashboard.getLastNItems(usageStats.requestRates.history, 15),
                color = Color3.fromRGB(52, 152, 219)
            }
        }
    }
    
    DataVisualization.createLineChart(requestRateFrame, requestRateData, "Request Rate Over Time", "Time", "Requests/Second")
    
    -- Create a request type breakdown
    local requestTypesFrame = Instance.new("Frame")
    requestTypesFrame.Size = UDim2.new(1, -20, 0, 200)
    requestTypesFrame.Position = UDim2.new(0, 10, 0, 270)
    requestTypesFrame.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    requestTypesFrame.LayoutOrder = 2
    requestTypesFrame.Name = "RequestTypesFrame"
    requestTypesFrame.Parent = parent
    
    -- Add rounded corners
    local typeCorner = Instance.new("UICorner")
    typeCorner.CornerRadius = UDim.new(0, 6)
    typeCorner.Parent = requestTypesFrame
    
    -- Create the pie chart for request types
    local performanceData = PerformanceMonitor.getOperationSummary()
    local requestTypeData = {
        labels = {"GetAsync", "SetAsync", "UpdateAsync", "RemoveAsync", "ListKeysAsync", "IncrementAsync", "OrderedDataStore", "Other"},
        data = {
            performanceData.GetAsync or 0,
            performanceData.SetAsync or 0,
            performanceData.UpdateAsync or 0,
            performanceData.RemoveAsync or 0,
            performanceData.ListKeysAsync or 0,
            performanceData.IncrementAsync or 0,
            performanceData.OrderedDataStore or 0,
            0 -- Other operations
        },
        colors = {
            Color3.fromRGB(52, 152, 219),  -- Blue
            Color3.fromRGB(46, 204, 113),  -- Green
            Color3.fromRGB(155, 89, 182),  -- Purple
            Color3.fromRGB(231, 76, 60),   -- Red
            Color3.fromRGB(241, 196, 15),  -- Yellow
            Color3.fromRGB(230, 126, 34),  -- Orange
            Color3.fromRGB(149, 165, 166), -- Gray
            Color3.fromRGB(52, 73, 94)     -- Dark Blue
        }
    }
    
    DataVisualization.createPieChart(requestTypesFrame, requestTypeData, "Request Types")
end

-- Create Quota tab content
function MonitoringDashboard.createQuotaTab(parent)
    -- Create a quota usage graph
    local quotaFrame = Instance.new("Frame")
    quotaFrame.Size = UDim2.new(1, -20, 0, 250)
    quotaFrame.Position = UDim2.new(0, 10, 0, 10)
    quotaFrame.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    quotaFrame.LayoutOrder = 1
    quotaFrame.Name = "QuotaFrame"
    quotaFrame.Parent = parent
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = quotaFrame
    
    -- Create the line chart for quota usage
    local quotaData = {
        labels = MonitoringDashboard.generateTimeLabels(15),
        datasets = {
            {
                label = "Quota Usage",
                data = MonitoringDashboard.getLastNItems(usageStats.quotaUsage.history, 15),
                color = Color3.fromRGB(155, 89, 182)
            }
        }
    }
    
    DataVisualization.createLineChart(quotaFrame, quotaData, "Quota Usage Over Time", "Time", "Percentage")
    
    -- Create quota alert settings
    local alertsFrame = Instance.new("Frame")
    alertsFrame.Size = UDim2.new(1, -20, 0, 200)
    alertsFrame.Position = UDim2.new(0, 10, 0, 270)
    alertsFrame.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    alertsFrame.LayoutOrder = 2
    alertsFrame.Name = "AlertsFrame"
    alertsFrame.Parent = parent
    
    -- Add rounded corners
    local alertsCorner = Instance.new("UICorner")
    alertsCorner.CornerRadius = UDim.new(0, 6)
    alertsCorner.Parent = alertsFrame
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = StyleGuide.getColor("text")
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.Text = "Quota Alert Settings"
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = alertsFrame
    
    -- Create slider for quota threshold
    local thresholdLabel = Instance.new("TextLabel")
    thresholdLabel.Size = UDim2.new(0.3, 0, 0, 24)
    thresholdLabel.Position = UDim2.new(0, 10, 0, 40)
    thresholdLabel.BackgroundTransparency = 1
    thresholdLabel.TextColor3 = StyleGuide.getColor("text")
    thresholdLabel.Font = Enum.Font.SourceSans
    thresholdLabel.TextSize = 14
    thresholdLabel.Text = "Alert Threshold (%):"
    thresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
    thresholdLabel.Name = "ThresholdLabel"
    thresholdLabel.Parent = alertsFrame
    
    local thresholdValue = Instance.new("TextBox")
    thresholdValue.Size = UDim2.new(0, 50, 0, 24)
    thresholdValue.Position = UDim2.new(0.3, 15, 0, 40)
    thresholdValue.BackgroundColor3 = StyleGuide.getColor("inputBackground")
    thresholdValue.TextColor3 = StyleGuide.getColor("text")
    thresholdValue.Font = Enum.Font.SourceSans
    thresholdValue.TextSize = 14
    thresholdValue.Text = "80"
    thresholdValue.Name = "ThresholdValue"
    thresholdValue.Parent = alertsFrame
    
    -- Create enable alerts checkbox
    local enableAlerts = Instance.new("Frame")
    enableAlerts.Size = UDim2.new(0, 24, 0, 24)
    enableAlerts.Position = UDim2.new(0, 10, 0, 74)
    enableAlerts.BackgroundColor3 = StyleGuide.getColor("inputBackground")
    enableAlerts.Name = "EnableAlerts"
    enableAlerts.Parent = alertsFrame
    
    local enableAlertsCheck = Instance.new("TextButton")
    enableAlertsCheck.Size = UDim2.new(1, 0, 1, 0)
    enableAlertsCheck.BackgroundTransparency = 1
    enableAlertsCheck.Text = "✓"
    enableAlertsCheck.TextColor3 = StyleGuide.getColor("accent")
    enableAlertsCheck.Font = Enum.Font.SourceSansBold
    enableAlertsCheck.TextSize = 16
    enableAlertsCheck.Name = "Check"
    enableAlertsCheck.Parent = enableAlerts
    
    local enableAlertsLabel = Instance.new("TextLabel")
    enableAlertsLabel.Size = UDim2.new(0, 200, 0, 24)
    enableAlertsLabel.Position = UDim2.new(0, 44, 0, 74)
    enableAlertsLabel.BackgroundTransparency = 1
    enableAlertsLabel.TextColor3 = StyleGuide.getColor("text")
    enableAlertsLabel.Font = Enum.Font.SourceSans
    enableAlertsLabel.TextSize = 14
    enableAlertsLabel.Text = "Enable Quota Alerts"
    enableAlertsLabel.TextXAlignment = Enum.TextXAlignment.Left
    enableAlertsLabel.Name = "EnableAlertsLabel"
    enableAlertsLabel.Parent = alertsFrame
end

-- Create Errors tab content
function MonitoringDashboard.createErrorsTab(parent)
    -- Create an error rate graph
    local errorRateFrame = Instance.new("Frame")
    errorRateFrame.Size = UDim2.new(1, -20, 0, 250)
    errorRateFrame.Position = UDim2.new(0, 10, 0, 10)
    errorRateFrame.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    errorRateFrame.LayoutOrder = 1
    errorRateFrame.Name = "ErrorRateFrame"
    errorRateFrame.Parent = parent
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = errorRateFrame
    
    -- Create the line chart for error rates
    local errorData = {
        labels = MonitoringDashboard.generateTimeLabels(15),
        datasets = {
            {
                label = "Error Count",
                data = MonitoringDashboard.getLastNItems(usageStats.errors.history, 15),
                color = Color3.fromRGB(231, 76, 60)
            }
        }
    }
    
    DataVisualization.createLineChart(errorRateFrame, errorData, "Errors Over Time", "Time", "Count")
    
    -- Create error breakdown table
    local errorTypesFrame = Instance.new("Frame")
    errorTypesFrame.Size = UDim2.new(1, -20, 0, 200)
    errorTypesFrame.Position = UDim2.new(0, 10, 0, 270)
    errorTypesFrame.BackgroundColor3 = StyleGuide.getColor("cardBackground")
    errorTypesFrame.LayoutOrder = 2
    errorTypesFrame.Name = "ErrorTypesFrame"
    errorTypesFrame.Parent = parent
    
    -- Add rounded corners
    local typeCorner = Instance.new("UICorner")
    typeCorner.CornerRadius = UDim.new(0, 6)
    typeCorner.Parent = errorTypesFrame
    
    -- Create the table for error types
    local errorTypes = {}
    for errorType, count in pairs(usageStats.errors.byType) do
        table.insert(errorTypes, {
            errorType = errorType,
            count = count,
            percentage = count / math.max(usageStats.errors.total, 1) * 100
        })
    end
    
    local errorTableData = {
        headers = {"Error Type", "Count", "Percentage"},
        rows = errorTypes,
        columnFormatters = {
            function(row) return row.errorType end,
            function(row) return tostring(row.count) end,
            function(row) return string.format("%.1f%%", row.percentage) end
        }
    }
    
    DataVisualization.createTableView(errorTypesFrame, errorTableData, "Error Type Breakdown")
end

-- Helper function to get the last N items from a table
function MonitoringDashboard.getLastNItems(tbl, n)
    local result = {}
    local count = #tbl
    local startIdx = math.max(1, count - n + 1)
    
    for i = startIdx, count do
        table.insert(result, tbl[i])
    end
    
    -- Pad with zeros if not enough items
    while #result < n do
        table.insert(result, 1, 0)
    end
    
    return result
end

-- Helper function to generate time labels
function MonitoringDashboard.generateTimeLabels(count)
    local labels = {}
    local now = os.time()
    local interval = updateInterval
    
    for i = count, 1, -1 do
        local time = now - (i - 1) * interval
        local formattedTime = string.format("%02d:%02d", 
            math.floor((time % 3600) / 60),
            time % 60
        )
        table.insert(labels, formattedTime)
    end
    
    return labels
end

-- Update stats from DataStoreService
function MonitoringDashboard.updateStats()
    -- Get current stats
    local budgetData = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
    local maxBudget = 100 -- Default max budget
    
    -- Update usage statistics
    local performanceData = PerformanceMonitor.getOperationSummary()
    
    -- Update reads count
    local newReads = (performanceData.GetAsync or 0) + (performanceData.ListKeysAsync or 0)
    usageStats.reads.total = newReads
    table.insert(usageStats.reads.history, newReads - (usageStats.reads.history[#usageStats.reads.history] or 0))
    if #usageStats.reads.history > maxHistoryPoints then
        table.remove(usageStats.reads.history, 1)
    end
    
    -- Update writes count
    local newWrites = (performanceData.SetAsync or 0) + (performanceData.UpdateAsync or 0) + 
                     (performanceData.RemoveAsync or 0) + (performanceData.IncrementAsync or 0)
    usageStats.writes.total = newWrites
    table.insert(usageStats.writes.history, newWrites - (usageStats.writes.history[#usageStats.writes.history] or 0))
    if #usageStats.writes.history > maxHistoryPoints then
        table.remove(usageStats.writes.history, 1)
    end
    
    -- Update request rates
    local totalRequests = usageStats.reads.total + usageStats.writes.total
    local prevRequests = usageStats.requestRates.history[#usageStats.requestRates.history] or 0
    local newRate = (totalRequests - prevRequests) / updateInterval
    usageStats.requestRates.current = newRate
    table.insert(usageStats.requestRates.history, newRate)
    if #usageStats.requestRates.history > maxHistoryPoints then
        table.remove(usageStats.requestRates.history, 1)
    end
    
    -- Update quota usage
    if budgetData and maxBudget > 0 then
        local quotaPercentage = 1 - (budgetData / maxBudget)
        usageStats.quotaUsage.current = quotaPercentage
        usageStats.quotaUsage.max = maxBudget
        table.insert(usageStats.quotaUsage.history, quotaPercentage)
        if #usageStats.quotaUsage.history > maxHistoryPoints then
            table.remove(usageStats.quotaUsage.history, 1)
        end
    end
    
    -- Update errors (example - in real implementation, track actual errors)
    local errorData = PerformanceMonitor.getErrorData()
    if errorData then
        usageStats.errors.total = errorData.total or 0
        usageStats.errors.byType = errorData.byType or {}
        table.insert(usageStats.errors.history, errorData.lastPeriod or 0)
        if #usageStats.errors.history > maxHistoryPoints then
            table.remove(usageStats.errors.history, 1)
        end
    end
    
    -- Refresh UI if tabs are open
    if MonitoringDashboard.tabInstances then
        for tabName, tabInfo in pairs(MonitoringDashboard.tabInstances) do
            if tabInfo.content.Visible then
                MonitoringDashboard.refreshTabContent(tabName, tabInfo.content)
            end
        end
    end
end

-- Start the monitoring update loop
function MonitoringDashboard.startMonitoring()
    -- Initialize with some default data
    for i = 1, 10 do
        table.insert(usageStats.reads.history, 0)
        table.insert(usageStats.writes.history, 0)
        table.insert(usageStats.errors.history, 0)
        table.insert(usageStats.requestRates.history, 0)
        table.insert(usageStats.quotaUsage.history, 0)
    end
    
    -- Start update loop
    spawn(function()
        while true do
            MonitoringDashboard.updateStats()
            wait(updateInterval)
        end
    end)
end

-- Initialize the dashboard
function MonitoringDashboard.initialize()
    MonitoringDashboard.startMonitoring()
end

return MonitoringDashboard
