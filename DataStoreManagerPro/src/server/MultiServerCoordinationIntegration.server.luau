--luau
-- DataStore Plugin/MultiServerCoordinationIntegration.server.luau

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

function DataExplorer.initMultiServerCoordinationUI()
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
