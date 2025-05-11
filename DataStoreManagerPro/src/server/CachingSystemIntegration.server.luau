--[[
    CachingSystemIntegration.server.luau
    Part of DataStore Manager Pro
    
    This file contains the integration code to add the Caching System UI
    to the main DataExplorer interface.
]]

local CachingSystemIntegration = {}

function CachingSystemIntegration.initCachingSystemUI(DataExplorer)
    local mainFrame = DataExplorer.mainFrame
    if not mainFrame then return end
    
    -- Create a button to open the caching system UI
    local cachingButton = Instance.new("TextButton")
    cachingButton.Size = UDim2.new(0, 150, 0, 28)
    cachingButton.Position = UDim2.new(1, -610, 0, 10) -- Position it to the left of other buttons
    cachingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219) -- Blue color for caching
    cachingButton.BorderSizePixel = 0
    cachingButton.Text = "Caching System"
    cachingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cachingButton.Font = Enum.Font.SourceSansSemibold
    cachingButton.TextSize = 14
    cachingButton.ZIndex = 5
    cachingButton.Parent = mainFrame
    
    -- Add rounded corners
    local cachingButtonCorner = Instance.new("UICorner")
    cachingButtonCorner.CornerRadius = UDim.new(0, 4)
    cachingButtonCorner.Parent = cachingButton
    
    -- Create container for caching system UI (hidden by default)
    local cachingSystemContainer = Instance.new("Frame")
    cachingSystemContainer.Size = UDim2.new(1, -20, 1, -60)
    cachingSystemContainer.Position = UDim2.new(0, 10, 0, 50)
    cachingSystemContainer.BackgroundTransparency = 1
    cachingSystemContainer.Visible = false
    cachingSystemContainer.Name = "CachingSystemContainer"
    cachingSystemContainer.Parent = mainFrame
    
    -- Store reference to container
    DataExplorer.cachingSystemContainer = cachingSystemContainer
    
    -- Add button click handler
    cachingButton.MouseButton1Click:Connect(function()
        local contentPane = DataExplorer.contentPane
        local navPane = DataExplorer.navigationPane
        
        if DataExplorer.cachingSystemContainer.Visible then
            -- Hide caching system UI and show normal UI
            DataExplorer.cachingSystemContainer.Visible = false
            if contentPane then contentPane.Visible = true end
            if navPane then navPane.Visible = true end
            cachingButton.Text = "Caching System"
            cachingButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
        else
            -- Hide normal UI and show caching system UI
            DataExplorer.cachingSystemContainer.Visible = true
            if contentPane then contentPane.Visible = false end
            if navPane then navPane.Visible = false end
            cachingButton.Text = "Back to Explorer"
            cachingButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            
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
            
            -- If the caching system UI is not initialized yet, create it
            if #cachingSystemContainer:GetChildren() == 0 then
                local CachingSystemUI = require(script.Parent.CachingSystemUI)
                CachingSystemUI.createUI(cachingSystemContainer)
            end
        end
    end)
end

return CachingSystemIntegration