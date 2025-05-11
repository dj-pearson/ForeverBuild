--[[
    LoadTestingIntegration.server.luau
    Part of DataStore Manager Pro
    
    This file contains the integration code to add the Load Testing UI
    to the main DataExplorer interface.
]]

local LoadTestingIntegration = {}

function LoadTestingIntegration.initLoadTestingUI(DataExplorer)
    local mainFrame = DataExplorer.mainFrame
    if not mainFrame then return end
    
    -- Create a button to open the load testing UI
    local loadTestingButton = Instance.new("TextButton")
    loadTestingButton.Size = UDim2.new(0, 150, 0, 28)
    loadTestingButton.Position = UDim2.new(1, -770, 0, 10) -- Position it to the left of other buttons
    loadTestingButton.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Orange color for load testing
    loadTestingButton.BorderSizePixel = 0
    loadTestingButton.Text = "Load Testing"
    loadTestingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadTestingButton.Font = Enum.Font.SourceSansSemibold
    loadTestingButton.TextSize = 14
    loadTestingButton.ZIndex = 5
    loadTestingButton.Parent = mainFrame
    
    -- Add rounded corners
    local loadTestingButtonCorner = Instance.new("UICorner")
    loadTestingButtonCorner.CornerRadius = UDim.new(0, 4)
    loadTestingButtonCorner.Parent = loadTestingButton
    
    -- Create container for load testing UI (hidden by default)
    local loadTestingContainer = Instance.new("Frame")
    loadTestingContainer.Size = UDim2.new(1, -20, 1, -60)
    loadTestingContainer.Position = UDim2.new(0, 10, 0, 50)
    loadTestingContainer.BackgroundTransparency = 1
    loadTestingContainer.Visible = false
    loadTestingContainer.Name = "LoadTestingContainer"
    loadTestingContainer.Parent = mainFrame
    
    -- Store reference to container
    DataExplorer.loadTestingContainer = loadTestingContainer
    
    -- Add button click handler
    loadTestingButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if DataExplorer.loadTestingContainer.Visible then
            -- Hide load testing UI and show normal UI
            DataExplorer.loadTestingContainer.Visible = false
            if contentPane then contentPane.Visible = true end
            if navPane then navPane.Visible = true end
            loadTestingButton.Text = "Load Testing"
            loadTestingButton.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        else
            -- Hide normal UI and show load testing UI
            DataExplorer.loadTestingContainer.Visible = true
            if contentPane then contentPane.Visible = false end
            if navPane then navPane.Visible = false end
            loadTestingButton.Text = "Back to Explorer"
            loadTestingButton.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
            
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
            
            if DataExplorer.performanceAnalyzerContainer then
                DataExplorer.performanceAnalyzerContainer.Visible = false
            end
            
            if DataExplorer.cachingSystemContainer then
                DataExplorer.cachingSystemContainer.Visible = false
            end
            
            -- If the load testing UI is not initialized yet, create it
            if #loadTestingContainer:GetChildren() == 0 then
                local LoadTestingUI = require(script.Parent.LoadTestingUI)
                LoadTestingUI.createUI(loadTestingContainer)
            end
        end
    end)
end

return LoadTestingIntegration
