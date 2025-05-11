--[[
    LoadTestingUI.luau
    Part of DataStore Manager Pro
    
    This module provides the user interface for the Load Testing feature,
    allowing developers to test DataStore performance under various load conditions.
]]

local StyleGuide = require(script.Parent.StyleGuide)
local DataVisualization = require(script.Parent.DataVisualization)
local PerformanceAnalyzer = require(script.Parent.PerformanceAnalyzer)

local LoadTestingUI = {}

-- Reference to UI components
LoadTestingUI.container = nil
LoadTestingUI.tabs = {}
LoadTestingUI.charts = {}
LoadTestingUI.testActive = false
LoadTestingUI.testResults = {}

-- Initialize the Load Testing UI
function LoadTestingUI.initialize()
    print("LoadTestingUI: Initializing UI components...")
    return true
end

-- Create the main Load Testing UI
function LoadTestingUI.createUI(container)
    LoadTestingUI.container = container
    
    -- Create the main layout
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Padding = UDim.new(0, 10)
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Parent = container
    
    -- Create tab buttons for different sections
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.LayoutOrder = 1
    tabContainer.Name = "TabContainer"
    tabContainer.Parent = container
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabContainer
    
    -- Create content container for tab content
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -50)
    contentContainer.Position = UDim2.new(0, 0, 0, 50)
    contentContainer.BackgroundTransparency = 1
    contentContainer.LayoutOrder = 2
    contentContainer.Name = "ContentContainer"
    contentContainer.Parent = container
    
    -- Create the tabs
    local tabs = {
        {name = "Test Configuration", color = Color3.fromRGB(41, 128, 185)},
        {name = "Performance Metrics", color = Color3.fromRGB(39, 174, 96)},
        {name = "Limits Analysis", color = Color3.fromRGB(230, 126, 34)},
        {name = "Recommendations", color = Color3.fromRGB(142, 68, 173)}
    }
    
    local tabButtons = {}
    local tabViews = {}
    
    for i, tabInfo in ipairs(tabs) do
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 150, 1, 0)
        tabButton.BackgroundColor3 = tabInfo.color
        tabButton.Text = tabInfo.name
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.Font = Enum.Font.SourceSansSemibold
        tabButton.TextSize = 14
        tabButton.BorderSizePixel = 0
        tabButton.LayoutOrder = i
        tabButton.Parent = tabContainer
        
        -- Add rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = tabButton
        
        -- Create tab content view
        local tabView = Instance.new("Frame")
        tabView.Size = UDim2.new(1, 0, 1, 0)
        tabView.BackgroundTransparency = 1
        tabView.Visible = i == 1 -- Only first tab visible by default
        tabView.Name = tabInfo.name:gsub(" ", "") .. "View"
        tabView.Parent = contentContainer
        
        -- Store references
        tabButtons[i] = tabButton
        tabViews[i] = tabView
        LoadTestingUI.tabs[tabInfo.name] = {button = tabButton, view = tabView}
        
        -- Add click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all views
            for _, view in ipairs(tabViews) do
                view.Visible = false
            end
            
            -- Show selected view
            tabView.Visible = true
            
            -- Update button appearance
            for _, btn in ipairs(tabButtons) do
                btn.BackgroundTransparency = 0.3
            end
            tabButton.BackgroundTransparency = 0
        end)
    end
    
    -- Create test configuration UI
    LoadTestingUI.createTestConfigurationUI(tabViews[1])
    
    -- Create performance metrics UI
    LoadTestingUI.createPerformanceMetricsUI(tabViews[2])
    
    -- Create limits analysis UI
    LoadTestingUI.createLimitsAnalysisUI(tabViews[3])
    
    -- Create recommendations UI
    LoadTestingUI.createRecommendationsUI(tabViews[4])
    
    return LoadTestingUI
end

-- Create the test configuration UI
function LoadTestingUI.createTestConfigurationUI(container)
    -- Create a form layout
    local formContainer = Instance.new("Frame")
    formContainer.Size = UDim2.new(0.7, 0, 1, 0)
    formContainer.Position = UDim2.new(0, 0, 0, 0)
    formContainer.BackgroundTransparency = 1
    formContainer.Parent = container
    
    local formLayout = Instance.new("UIListLayout")
    formLayout.Padding = UDim.new(0, 15)
    formLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formLayout.Parent = formContainer
    
    -- Create form title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Load Test Configuration"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 1
    titleLabel.Parent = formContainer
    
    -- Create description
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, 0, 0, 60)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = "Configure load testing parameters below. These settings determine how the system will simulate loads against your DataStores to measure performance under stress."
    descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextSize = 16
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.LayoutOrder = 2
    descriptionLabel.Parent = formContainer
    
    -- Create field container helper function
    local function createFieldContainer(label, layoutOrder)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 70)
        container.BackgroundTransparency = 1
        container.LayoutOrder = layoutOrder
        container.Parent = formContainer
        
        local fieldLabel = Instance.new("TextLabel")
        fieldLabel.Size = UDim2.new(1, 0, 0, 24)
        fieldLabel.Position = UDim2.new(0, 0, 0, 0)
        fieldLabel.BackgroundTransparency = 1
        fieldLabel.Text = label
        fieldLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        fieldLabel.Font = Enum.Font.SourceSansSemibold
        fieldLabel.TextSize = 16
        fieldLabel.TextXAlignment = Enum.TextXAlignment.Left
        fieldLabel.Parent = container
        
        return container, fieldLabel
    end
    
    -- Create fields
    
    -- DataStore Selection field
    local dsContainer, dsLabel = createFieldContainer("Target DataStore", 3)
    
    local dsInput = Instance.new("TextBox")
    dsInput.Size = UDim2.new(1, 0, 0, 36)
    dsInput.Position = UDim2.new(0, 0, 0, 30)
    dsInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    dsInput.BorderSizePixel = 0
    dsInput.Text = ""
    dsInput.PlaceholderText = "Enter DataStore name"
    dsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    dsInput.Font = Enum.Font.SourceSans
    dsInput.TextSize = 16
    dsInput.Parent = dsContainer
    
    -- Add rounded corners
    local dsCorner = Instance.new("UICorner")
    dsCorner.CornerRadius = UDim.new(0, 4)
    dsCorner.Parent = dsInput
    
    LoadTestingUI.dsInput = dsInput
    
    -- Operation Type field
    local opContainer, opLabel = createFieldContainer("Operation Type", 4)
    
    local opSelection = Instance.new("Frame")
    opSelection.Size = UDim2.new(1, 0, 0, 36)
    opSelection.Position = UDim2.new(0, 0, 0, 30)
    opSelection.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    opSelection.BorderSizePixel = 0
    opSelection.Parent = opContainer
    
    -- Add rounded corners
    local opCorner = Instance.new("UICorner")
    opCorner.CornerRadius = UDim.new(0, 4)
    opCorner.Parent = opSelection
    
    local opLayout = Instance.new("UIListLayout")
    opLayout.FillDirection = Enum.FillDirection.Horizontal
    opLayout.Padding = UDim.new(0, 2)
    opLayout.SortOrder = Enum.SortOrder.LayoutOrder
    opLayout.Parent = opSelection
    
    local operations = {"GetAsync", "SetAsync", "UpdateAsync", "Mixed"}
    local opButtons = {}
    
    for i, op in ipairs(operations) do
        local opButton = Instance.new("TextButton")
        opButton.Size = UDim2.new(0.25, -2, 1, 0)
        opButton.BackgroundColor3 = i == 1 and Color3.fromRGB(41, 128, 185) or Color3.fromRGB(70, 70, 85)
        opButton.BorderSizePixel = 0
        opButton.Text = op
        opButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        opButton.Font = Enum.Font.SourceSans
        opButton.TextSize = 16
        opButton.LayoutOrder = i
        opButton.Parent = opSelection
        
        -- Add rounded corners
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = opButton
        
        opButtons[i] = opButton
        
        -- Add click handler
        opButton.MouseButton1Click:Connect(function()
            for j, btn in ipairs(opButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
            end
            opButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            LoadTestingUI.selectedOperation = op
        end)
    end
    
    LoadTestingUI.selectedOperation = "GetAsync"
    
    -- Test Intensity field
    local intensityContainer, intensityLabel = createFieldContainer("Test Intensity", 5)
    
    local intensitySelection = Instance.new("Frame")
    intensitySelection.Size = UDim2.new(1, 0, 0, 36)
    intensitySelection.Position = UDim2.new(0, 0, 0, 30)
    intensitySelection.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    intensitySelection.BorderSizePixel = 0
    intensitySelection.Parent = intensityContainer
    
    -- Add rounded corners
    local intensityCorner = Instance.new("UICorner")
    intensityCorner.CornerRadius = UDim.new(0, 4)
    intensityCorner.Parent = intensitySelection
    
    local intensityLayout = Instance.new("UIListLayout")
    intensityLayout.FillDirection = Enum.FillDirection.Horizontal
    intensityLayout.Padding = UDim.new(0, 2)
    intensityLayout.SortOrder = Enum.SortOrder.LayoutOrder
    intensityLayout.Parent = intensitySelection
    
    local intensities = {"Low", "Medium", "High", "Extreme"}
    local intensityButtons = {}
    
    for i, intensity in ipairs(intensities) do
        local intensityButton = Instance.new("TextButton")
        intensityButton.Size = UDim2.new(0.25, -2, 1, 0)
        intensityButton.BackgroundColor3 = i == 2 and Color3.fromRGB(41, 128, 185) or Color3.fromRGB(70, 70, 85)
        intensityButton.BorderSizePixel = 0
        intensityButton.Text = intensity
        intensityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        intensityButton.Font = Enum.Font.SourceSans
        intensityButton.TextSize = 16
        intensityButton.LayoutOrder = i
        intensityButton.Parent = intensitySelection
        
        -- Add rounded corners
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = intensityButton
        
        intensityButtons[i] = intensityButton
        
        -- Add click handler
        intensityButton.MouseButton1Click:Connect(function()
            for j, btn in ipairs(intensityButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
            end
            intensityButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            LoadTestingUI.selectedIntensity = intensity
        end)
    end
    
    LoadTestingUI.selectedIntensity = "Medium"
    
    -- Test Duration field
    local durationContainer, durationLabel = createFieldContainer("Test Duration (seconds)", 6)
    
    local durationSlider = Instance.new("Frame")
    durationSlider.Size = UDim2.new(1, 0, 0, 36)
    durationSlider.Position = UDim2.new(0, 0, 0, 30)
    durationSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    durationSlider.BorderSizePixel = 0
    durationSlider.Parent = durationContainer
    
    -- Add rounded corners
    local durationCorner = Instance.new("UICorner")
    durationCorner.CornerRadius = UDim.new(0, 4)
    durationCorner.Parent = durationSlider
    
    -- Create a slider track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(0.8, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0.1, 0, 0.5, -2)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Name = "Track"
    sliderTrack.Parent = durationSlider
    
    -- Add rounded corners to track
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = sliderTrack
    
    -- Create a slider handle
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 16, 0, 16)
    sliderHandle.Position = UDim2.new(0.5, -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Text = ""
    sliderHandle.Name = "Handle"
    sliderHandle.Parent = durationSlider
    
    -- Add rounded corners to handle
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 8)
    handleCorner.Parent = sliderHandle
    
    -- Create a duration value display
    local durationValue = Instance.new("TextLabel")
    durationValue.Size = UDim2.new(0, 40, 0, 20)
    durationValue.Position = UDim2.new(1, -50, 0.5, -10)
    durationValue.BackgroundTransparency = 1
    durationValue.Text = "30s"
    durationValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    durationValue.Font = Enum.Font.SourceSans
    durationValue.TextSize = 16
    durationValue.Parent = durationSlider
    
    LoadTestingUI.durationValue = durationValue
    LoadTestingUI.testDuration = 30
    
    -- Add dragging functionality
    local dragging = false
    local minDuration = 10
    local maxDuration = 300 -- 5 minutes
    
    sliderHandle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Calculate position
            local offset = input.Position.X - sliderTrack.AbsolutePosition.X
            local percentage = math.clamp(offset / sliderTrack.AbsoluteSize.X, 0, 1)
            
            -- Update handle position
            sliderHandle.Position = UDim2.new(0.1 + percentage * 0.8, -8, 0.5, -8)
            
            -- Update duration value
            local duration = math.floor(minDuration + percentage * (maxDuration - minDuration))
            durationValue.Text = duration .. "s"
            LoadTestingUI.testDuration = duration
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            -- Get mouse position
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            
            -- Calculate percentage
            local trackStart = sliderTrack.AbsolutePosition.X
            local trackEnd = trackStart + sliderTrack.AbsoluteSize.X
            local percentage = math.clamp((mouse.X - trackStart) / (trackEnd - trackStart), 0, 1)
            
            -- Update handle position
            sliderHandle.Position = UDim2.new(0.1 + percentage * 0.8, -8, 0.5, -8)
            
            -- Update duration value
            local duration = math.floor(minDuration + percentage * (maxDuration - minDuration))
            durationValue.Text = duration .. "s"
            LoadTestingUI.testDuration = duration
        end
    end)
    
    -- Create actions container
    local actionsContainer = Instance.new("Frame")
    actionsContainer.Size = UDim2.new(1, 0, 0, 50)
    actionsContainer.BackgroundTransparency = 1
    actionsContainer.LayoutOrder = 7
    actionsContainer.Parent = formContainer
    
    -- Create start test button
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0, 160, 0, 40)
    startButton.Position = UDim2.new(0, 0, 0, 0)
    startButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    startButton.BorderSizePixel = 0
    startButton.Text = "Start Load Test"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.Font = Enum.Font.SourceSansBold
    startButton.TextSize = 16
    startButton.Parent = actionsContainer
    
    -- Add rounded corners to button
    local startButtonCorner = Instance.new("UICorner")
    startButtonCorner.CornerRadius = UDim.new(0, 4)
    startButtonCorner.Parent = startButton
    
    LoadTestingUI.startButton = startButton
    
    -- Create info area
    local infoContainer = Instance.new("Frame")
    infoContainer.Size = UDim2.new(0.3, -20, 1, 0)
    infoContainer.Position = UDim2.new(0.7, 20, 0, 0)
    infoContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    infoContainer.BorderSizePixel = 0
    infoContainer.Parent = container
    
    -- Add rounded corners
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoContainer
    
    -- Create info title
    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -20, 0, 30)
    infoTitle.Position = UDim2.new(0, 10, 0, 10)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "Test Information"
    infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoTitle.Font = Enum.Font.SourceSansBold
    infoTitle.TextSize = 18
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    infoTitle.Parent = infoContainer
    
    -- Create info content
    local infoContent = Instance.new("TextLabel")
    infoContent.Size = UDim2.new(1, -20, 1, -50)
    infoContent.Position = UDim2.new(0, 10, 0, 40)
    infoContent.BackgroundTransparency = 1
    infoContent.Text = "Load testing simulates realistic DataStore traffic to measure how your game's data systems perform under stress.\n\nUse this tool to:\n• Identify bottlenecks\n• Find breaking points\n• Optimize code\n• Prepare for player surges\n\nResults will show response times, failure rates, and recommendations for optimization."
    infoContent.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoContent.Font = Enum.Font.SourceSans
    infoContent.TextSize = 14
    infoContent.TextWrapped = true
    infoContent.TextXAlignment = Enum.TextXAlignment.Left
    infoContent.TextYAlignment = Enum.TextYAlignment.Top
    infoContent.Parent = infoContainer
    
    -- Add functionality to the start button
    startButton.MouseButton1Click:Connect(function()
        if LoadTestingUI.testActive then
            -- Stop the test
            LoadTestingUI.stopTest()
        else
            -- Validate inputs
            if LoadTestingUI.dsInput.Text == "" then
                LoadTestingUI.showError("Please enter a DataStore name")
                return
            end
            
            -- Start the test
            LoadTestingUI.startTest()
        end
    end)
end

-- Show error message
function LoadTestingUI.showError(message)
    -- Implementation of error notification would go here
    print("LoadTestingUI Error: " .. message)
end

-- Start load test
function LoadTestingUI.startTest()
    LoadTestingUI.testActive = true
    LoadTestingUI.startButton.Text = "Stop Test"
    LoadTestingUI.startButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    
    -- Set up test parameters
    local testParams = {
        dataStore = LoadTestingUI.dsInput.Text,
        operation = LoadTestingUI.selectedOperation,
        intensity = LoadTestingUI.selectedIntensity,
        duration = LoadTestingUI.testDuration
    }
    
    -- Display active tab for metrics
    for _, tab in pairs(LoadTestingUI.tabs) do
        if tab.view.Name == "PerformanceMetricsView" then
            tab.view.Visible = true
        else
            tab.view.Visible = false
        end
        
        if tab.button.Text == "Performance Metrics" then
            tab.button.BackgroundTransparency = 0
        else
            tab.button.BackgroundTransparency = 0.3
        end
    end
    
    -- Start the test with PerformanceAnalyzer
    PerformanceAnalyzer.startLoadTest(testParams, function(results)
        LoadTestingUI.testResults = results
        LoadTestingUI.updateTestResults()
        LoadTestingUI.testActive = false
        LoadTestingUI.startButton.Text = "Start Load Test"
        LoadTestingUI.startButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    end)
end

-- Stop load test
function LoadTestingUI.stopTest()
    PerformanceAnalyzer.stopLoadTest()
    LoadTestingUI.testActive = false
    LoadTestingUI.startButton.Text = "Start Load Test"
    LoadTestingUI.startButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
end

-- Update test results
function LoadTestingUI.updateTestResults()
    -- Implementation would populate charts and data visualizations
    -- with the test results data
end

-- Create performance metrics UI
function LoadTestingUI.createPerformanceMetricsUI(container)
    -- Create metrics container
    local metricsContainer = Instance.new("Frame")
    metricsContainer.Size = UDim2.new(1, 0, 1, 0)
    metricsContainer.BackgroundTransparency = 1
    metricsContainer.Parent = container
    
    -- Create title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Performance Metrics"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = metricsContainer
    
    -- Create chart containers
    local chartLayout = Instance.new("UIGridLayout")
    chartLayout.CellSize = UDim2.new(0.5, -10, 0.5, -10)
    chartLayout.CellPadding = UDim2.new(0, 20, 0, 20)
    chartLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chartLayout.Parent = metricsContainer
    
    -- Response Time Chart
    local responseTimeChart = Instance.new("Frame")
    responseTimeChart.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    responseTimeChart.BorderSizePixel = 0
    responseTimeChart.LayoutOrder = 1
    responseTimeChart.Name = "ResponseTimeChart"
    responseTimeChart.Parent = metricsContainer
    
    -- Add chart title
    local responseTimeTitle = Instance.new("TextLabel")
    responseTimeTitle.Size = UDim2.new(1, 0, 0, 30)
    responseTimeTitle.Position = UDim2.new(0, 0, 0, 0)
    responseTimeTitle.BackgroundTransparency = 1
    responseTimeTitle.Text = "Response Time (ms)"
    responseTimeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    responseTimeTitle.Font = Enum.Font.SourceSansBold
    responseTimeTitle.TextSize = 16
    responseTimeTitle.Parent = responseTimeChart
    
    -- Create chart content placeholder
    local responseTimeContent = Instance.new("Frame")
    responseTimeContent.Size = UDim2.new(1, 0, 1, -30)
    responseTimeContent.Position = UDim2.new(0, 0, 0, 30)
    responseTimeContent.BackgroundTransparency = 1
    responseTimeContent.Name = "Content"
    responseTimeContent.Parent = responseTimeChart
    
    LoadTestingUI.charts.responseTime = responseTimeContent
    
    -- Throughput Chart
    local throughputChart = Instance.new("Frame")
    throughputChart.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    throughputChart.BorderSizePixel = 0
    throughputChart.LayoutOrder = 2
    throughputChart.Name = "ThroughputChart"
    throughputChart.Parent = metricsContainer
    
    -- Add chart title
    local throughputTitle = Instance.new("TextLabel")
    throughputTitle.Size = UDim2.new(1, 0, 0, 30)
    throughputTitle.Position = UDim2.new(0, 0, 0, 0)
    throughputTitle.BackgroundTransparency = 1
    throughputTitle.Text = "Operations Per Second"
    throughputTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    throughputTitle.Font = Enum.Font.SourceSansBold
    throughputTitle.TextSize = 16
    throughputTitle.Parent = throughputChart
    
    -- Create chart content placeholder
    local throughputContent = Instance.new("Frame")
    throughputContent.Size = UDim2.new(1, 0, 1, -30)
    throughputContent.Position = UDim2.new(0, 0, 0, 30)
    throughputContent.BackgroundTransparency = 1
    throughputContent.Name = "Content"
    throughputContent.Parent = throughputChart
    
    LoadTestingUI.charts.throughput = throughputContent
    
    -- Error Rate Chart
    local errorRateChart = Instance.new("Frame")
    errorRateChart.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    errorRateChart.BorderSizePixel = 0
    errorRateChart.LayoutOrder = 3
    errorRateChart.Name = "ErrorRateChart"
    errorRateChart.Parent = metricsContainer
    
    -- Add chart title
    local errorRateTitle = Instance.new("TextLabel")
    errorRateTitle.Size = UDim2.new(1, 0, 0, 30)
    errorRateTitle.Position = UDim2.new(0, 0, 0, 0)
    errorRateTitle.BackgroundTransparency = 1
    errorRateTitle.Text = "Error Rate (%)"
    errorRateTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    errorRateTitle.Font = Enum.Font.SourceSansBold
    errorRateTitle.TextSize = 16
    errorRateTitle.Parent = errorRateChart
    
    -- Create chart content placeholder
    local errorRateContent = Instance.new("Frame")
    errorRateContent.Size = UDim2.new(1, 0, 1, -30)
    errorRateContent.Position = UDim2.new(0, 0, 0, 30)
    errorRateContent.BackgroundTransparency = 1
    errorRateContent.Name = "Content"
    errorRateContent.Parent = errorRateChart
    
    LoadTestingUI.charts.errorRate = errorRateContent
    
    -- Resource Usage Chart
    local resourceUsageChart = Instance.new("Frame")
    resourceUsageChart.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    resourceUsageChart.BorderSizePixel = 0
    resourceUsageChart.LayoutOrder = 4
    resourceUsageChart.Name = "ResourceUsageChart"
    resourceUsageChart.Parent = metricsContainer
    
    -- Add chart title
    local resourceUsageTitle = Instance.new("TextLabel")
    resourceUsageTitle.Size = UDim2.new(1, 0, 0, 30)
    resourceUsageTitle.Position = UDim2.new(0, 0, 0, 0)
    resourceUsageTitle.BackgroundTransparency = 1
    resourceUsageTitle.Text = "Resource Usage"
    resourceUsageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    resourceUsageTitle.Font = Enum.Font.SourceSansBold
    resourceUsageTitle.TextSize = 16
    resourceUsageTitle.Parent = resourceUsageChart
    
    -- Create chart content placeholder
    local resourceUsageContent = Instance.new("Frame")
    resourceUsageContent.Size = UDim2.new(1, 0, 1, -30)
    resourceUsageContent.Position = UDim2.new(0, 0, 0, 30)
    resourceUsageContent.BackgroundTransparency = 1
    resourceUsageContent.Name = "Content"
    resourceUsageContent.Parent = resourceUsageChart
    
    LoadTestingUI.charts.resourceUsage = resourceUsageContent
    
    -- Add rounded corners to all charts
    for _, chart in pairs(metricsContainer:GetChildren()) do
        if chart:IsA("Frame") and chart.Name:match("Chart$") then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = chart
        end
    end
end

-- Create limits analysis UI
function LoadTestingUI.createLimitsAnalysisUI(container)
    -- Create analysis container
    local analysisContainer = Instance.new("Frame")
    analysisContainer.Size = UDim2.new(1, 0, 1, 0)
    analysisContainer.BackgroundTransparency = 1
    analysisContainer.Parent = container
    
    -- Create title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Limits Analysis"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = analysisContainer
    
    -- Create description
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, 0, 0, 60)
    descriptionLabel.Position = UDim2.new(0, 0, 0, 50)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = "This analysis identifies the breaking points and limitations of your DataStore operations under load."
    descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextSize = 16
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.Parent = analysisContainer
    
    -- Create breaking point visualization
    local breakingPointContainer = Instance.new("Frame")
    breakingPointContainer.Size = UDim2.new(1, 0, 0.5, -60)
    breakingPointContainer.Position = UDim2.new(0, 0, 0, 120)
    breakingPointContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    breakingPointContainer.BorderSizePixel = 0
    breakingPointContainer.Parent = analysisContainer
    
    -- Add rounded corners
    local breakingPointCorner = Instance.new("UICorner")
    breakingPointCorner.CornerRadius = UDim.new(0, 8)
    breakingPointCorner.Parent = breakingPointContainer
    
    -- Add breaking point title
    local breakingPointTitle = Instance.new("TextLabel")
    breakingPointTitle.Size = UDim2.new(1, -20, 0, 30)
    breakingPointTitle.Position = UDim2.new(0, 10, 0, 10)
    breakingPointTitle.BackgroundTransparency = 1
    breakingPointTitle.Text = "Breaking Point Analysis"
    breakingPointTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    breakingPointTitle.Font = Enum.Font.SourceSansBold
    breakingPointTitle.TextSize = 18
    breakingPointTitle.TextXAlignment = Enum.TextXAlignment.Left
    breakingPointTitle.Parent = breakingPointContainer
    
    -- Create breaking point visualization placeholder
    local breakingPointViz = Instance.new("Frame")
    breakingPointViz.Size = UDim2.new(1, -20, 1, -50)
    breakingPointViz.Position = UDim2.new(0, 10, 0, 40)
    breakingPointViz.BackgroundTransparency = 1
    breakingPointViz.Name = "BreakingPointVisualization"
    breakingPointViz.Parent = breakingPointContainer
    
    LoadTestingUI.breakingPointViz = breakingPointViz
    
    -- Create limits summary
    local limitsSummaryContainer = Instance.new("Frame")
    limitsSummaryContainer.Size = UDim2.new(1, 0, 0.5, -60)
    limitsSummaryContainer.Position = UDim2.new(0, 0, 0.5, 60)
    limitsSummaryContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    limitsSummaryContainer.BorderSizePixel = 0
    limitsSummaryContainer.Parent = analysisContainer
    
    -- Add rounded corners
    local limitsSummaryCorner = Instance.new("UICorner")
    limitsSummaryCorner.CornerRadius = UDim.new(0, 8)
    limitsSummaryCorner.Parent = limitsSummaryContainer
    
    -- Add limits summary title
    local limitsSummaryTitle = Instance.new("TextLabel")
    limitsSummaryTitle.Size = UDim2.new(1, -20, 0, 30)
    limitsSummaryTitle.Position = UDim2.new(0, 10, 0, 10)
    limitsSummaryTitle.BackgroundTransparency = 1
    limitsSummaryTitle.Text = "Limits Summary"
    limitsSummaryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    limitsSummaryTitle.Font = Enum.Font.SourceSansBold
    limitsSummaryTitle.TextSize = 18
    limitsSummaryTitle.TextXAlignment = Enum.TextXAlignment.Left
    limitsSummaryTitle.Parent = limitsSummaryContainer
    
    -- Create limits summary content
    local limitsSummaryContent = Instance.new("ScrollingFrame")
    limitsSummaryContent.Size = UDim2.new(1, -20, 1, -50)
    limitsSummaryContent.Position = UDim2.new(0, 10, 0, 40)
    limitsSummaryContent.BackgroundTransparency = 1
    limitsSummaryContent.BorderSizePixel = 0
    limitsSummaryContent.ScrollBarThickness = 6
    limitsSummaryContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    limitsSummaryContent.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    limitsSummaryContent.Name = "LimitsSummaryContent"
    limitsSummaryContent.Parent = limitsSummaryContainer
    
    -- Add layout for summary items
    local summaryLayout = Instance.new("UIListLayout")
    summaryLayout.SortOrder = Enum.SortOrder.LayoutOrder
    summaryLayout.Padding = UDim.new(0, 10)
    summaryLayout.Parent = limitsSummaryContent
    
    -- Add padding
    local summaryPadding = Instance.new("UIPadding")
    summaryPadding.PaddingLeft = UDim.new(0, 10)
    summaryPadding.PaddingRight = UDim.new(0, 10)
    summaryPadding.PaddingTop = UDim.new(0, 10)
    summaryPadding.PaddingBottom = UDim.new(0, 10)
    summaryPadding.Parent = limitsSummaryContent
    
    LoadTestingUI.limitsSummaryContent = limitsSummaryContent
end

-- Create recommendations UI
function LoadTestingUI.createRecommendationsUI(container)
    -- Create recommendations container
    local recommendationsContainer = Instance.new("Frame")
    recommendationsContainer.Size = UDim2.new(1, 0, 1, 0)
    recommendationsContainer.BackgroundTransparency = 1
    recommendationsContainer.Parent = container
    
    -- Create title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Recommendations"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = recommendationsContainer
    
    -- Create description
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, 0, 0, 60)
    descriptionLabel.Position = UDim2.new(0, 0, 0, 50)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = "Based on the load test results, here are recommendations to optimize DataStore performance and scalability."
    descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextSize = 16
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.Parent = recommendationsContainer
    
    -- Create recommendations list
    local recommendationsList = Instance.new("ScrollingFrame")
    recommendationsList.Size = UDim2.new(1, 0, 1, -120)
    recommendationsList.Position = UDim2.new(0, 0, 0, 120)
    recommendationsList.BackgroundTransparency = 1
    recommendationsList.BorderSizePixel = 0
    recommendationsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    recommendationsList.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    recommendationsList.ScrollBarThickness = 6
    recommendationsList.Name = "RecommendationsList"
    recommendationsList.Parent = recommendationsContainer
    
    -- Add layout for recommendation items
    local recsLayout = Instance.new("UIListLayout")
    recsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    recsLayout.Padding = UDim.new(0, 15)
    recsLayout.Parent = recommendationsList
    
    LoadTestingUI.recommendationsList = recommendationsList
    
    -- Helper function to create a recommendation item
    local function createRecommendationItem(title, description, priority, layoutOrder)
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 120)
        item.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        item.BorderSizePixel = 0
        item.LayoutOrder = layoutOrder
        item.Parent = recommendationsList
        
        -- Add rounded corners
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 8)
        itemCorner.Parent = item
        
        -- Add priority indicator
        local priorityColors = {
            ["High"] = Color3.fromRGB(231, 76, 60),   -- Red
            ["Medium"] = Color3.fromRGB(230, 126, 34), -- Orange
            ["Low"] = Color3.fromRGB(46, 204, 113)     -- Green
        }
        
        local priorityIndicator = Instance.new("Frame")
        priorityIndicator.Size = UDim2.new(0, 4, 1, 0)
        priorityIndicator.Position = UDim2.new(0, 0, 0, 0)
        priorityIndicator.BackgroundColor3 = priorityColors[priority] or Color3.fromRGB(200, 200, 200)
        priorityIndicator.BorderSizePixel = 0
        priorityIndicator.Parent = item
        
        -- Add rounded corners to indicator
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 4)
        indicatorCorner.Parent = priorityIndicator
        
        -- Add priority label
        local priorityLabel = Instance.new("TextLabel")
        priorityLabel.Size = UDim2.new(0, 80, 0, 20)
        priorityLabel.Position = UDim2.new(0, 15, 0, 10)
        priorityLabel.BackgroundColor3 = priorityColors[priority] or Color3.fromRGB(200, 200, 200)
        priorityLabel.BorderSizePixel = 0
        priorityLabel.Text = priority .. " Priority"
        priorityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        priorityLabel.Font = Enum.Font.SourceSansSemibold
        priorityLabel.TextSize = 12
        priorityLabel.Parent = item
        
        -- Add rounded corners to priority label
        local priorityLabelCorner = Instance.new("UICorner")
        priorityLabelCorner.CornerRadius = UDim.new(0, 4)
        priorityLabelCorner.Parent = priorityLabel
        
        -- Add title
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -30, 0, 24)
        titleLabel.Position = UDim2.new(0, 15, 0, 40)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = item
        
        -- Add description
        local descriptionLabel = Instance.new("TextLabel")
        descriptionLabel.Size = UDim2.new(1, -30, 0, 50)
        descriptionLabel.Position = UDim2.new(0, 15, 0, 70)
        descriptionLabel.BackgroundTransparency = 1
        descriptionLabel.Text = description
        descriptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descriptionLabel.Font = Enum.Font.SourceSans
        descriptionLabel.TextSize = 14
        descriptionLabel.TextWrapped = true
        descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
        descriptionLabel.Parent = item
        
        -- Adjust frame height based on text content
        local textHeight = descriptionLabel.TextBounds.Y
        item.Size = UDim2.new(1, 0, 0, math.max(120, 70 + textHeight + 10))
        
        return item
    end
    
    -- Add some placeholder recommendations
    createRecommendationItem(
        "Implement Caching",
        "Reduce DataStore calls by implementing a client-side and server-side caching system. This can significantly decrease load and response times.",
        "High",
        1
    )
    
    createRecommendationItem(
        "Use UpdateAsync Instead of SetAsync",
        "Where possible, use UpdateAsync for atomic operations instead of Get + Set patterns to prevent race conditions and data loss.",
        "Medium",
        2
    )
    
    createRecommendationItem(
        "Batch Operations",
        "Group related data under single keys to reduce the number of DataStore operations required.",
        "Medium",
        3
    )
    
    createRecommendationItem(
        "Implement Retry Logic",
        "Add exponential backoff retry logic to handle occasional DataStore errors gracefully.",
        "High",
        4
    )
end

return LoadTestingUI
