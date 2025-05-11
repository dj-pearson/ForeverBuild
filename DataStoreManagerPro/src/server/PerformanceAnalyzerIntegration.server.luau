--[[
    PerformanceAnalyzerIntegration.luau
    Part of DataStore Manager Pro
    
    This file contains the integration code to add the Performance Analyzer UI
    to the main DataExplorer interface.
]]

-- Get module resolver from init script or define a local one
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
        createUI = function() return Instance.new("Frame") end,
        mainFrame = Instance.new("Frame") -- Add mainFrame for integration modules
    }
end

local DataExplorer = resolveModule('DataExplorer')

function DataExplorer.initPerformanceAnalyzerUI()
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
            contentPane.Visible = true
            navPane.Visible = true
            performanceButton.Text = "Performance Analyzer"
            performanceButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182) -- Purple
            
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
            
            if DataExplorer.coordinationContainer then
                DataExplorer.coordinationContainer.Visible = false
            end
        else
            -- Show performance analyzer UI and hide normal UI
            DataExplorer.performanceAnalyzerContainer.Visible = true
            contentPane.Visible = false
            navPane.Visible = false
            performanceButton.Text = "Back to Explorer"
            performanceButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80) -- Red
            
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
            
            if DataExplorer.coordinationContainer then
                DataExplorer.coordinationContainer.Visible = false
            end
        end
    end)
end
