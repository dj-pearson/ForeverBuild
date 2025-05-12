local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Try to load shared modules with error handling
local Shared, Constants, Types, RemoteManager
local success = pcall(function()
    Shared = require(ReplicatedStorage.Shared)
    Constants = Shared.Constants
    Types = Shared.Types
    RemoteManager = Shared.RemoteManager
end)

if not success then
    -- Create fallback objects if shared modules aren't available
    print("BuildingToolsUI: Failed to load shared modules, using fallbacks")
    Shared = {}
    Constants = {
        BUILDING_CATEGORIES = {
            "Foundations",
            "Walls",
            "Floors",
            "Roofs",
            "Doors",
            "Windows",
            "Furniture",
            "Decorations"
        },
        BUILDING_TOOLS = {
            PLACE = "place",
            MOVE = "move",
            REMOVE = "remove"
        }
    }
    Types = {}
    RemoteManager = {
        getRemoteEvent = function(name)
            local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if Remotes then
                return Remotes:FindFirstChild(name)
            end
            return nil
        end
    }
end

local BuildingToolsUI = {}

-- UI Elements
local screenGui
local mainFrame
local toolList
local itemList
local closeButton
local currentTool = Constants.BUILDING_TOOLS and Constants.BUILDING_TOOLS.PLACE or "place"
local selectedItemId = nil
local buildingToolHandler = nil

-- Try to get the building tool handler
local function getBuildingToolHandler()
    if _G.BuildingToolHandler then
        return _G.BuildingToolHandler
    end
    
    -- Wait for up to 5 seconds for the handler to become available
    local startTime = tick()
    while tick() - startTime < 5 do
        if _G.BuildingToolHandler then
            return _G.BuildingToolHandler
        end
        task.wait(0.1)
    end
    
    -- If we still don't have it, return nil
    return nil
end

-- Create UI
function BuildingToolsUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildingToolsUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Building Tools"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create tool list
    toolList = Instance.new("ScrollingFrame")
    toolList.Name = "ToolList"
    toolList.Size = UDim2.new(1, -20, 1, -50)
    toolList.Position = UDim2.new(0, 10, 0, 50)
    toolList.BackgroundTransparency = 1
    toolList.BorderSizePixel = 0
    toolList.ScrollBarThickness = 6
    toolList.CanvasSize = UDim2.new(0, 0, 0, 0)
    toolList.Parent = mainFrame
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    closeButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.hide()
    end)
    
    -- Set up keyboard shortcut
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
            if mainFrame.Visible then
                BuildingToolsUI.hide()
            else
                BuildingToolsUI.show()
            end
        end
    end)
end

-- Show UI
function BuildingToolsUI.show()
    mainFrame.Visible = true
end

-- Hide UI
function BuildingToolsUI.hide()
    mainFrame.Visible = false
end

-- Update tool list
function BuildingToolsUI.updateTools(tools)
    -- Clear existing tools
    for _, child in ipairs(toolList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new tools
    local yOffset = 0
    for _, tool in ipairs(tools) do
        local toolButton = Instance.new("TextButton")
        toolButton.Name = tool.id
        toolButton.Size = UDim2.new(1, 0, 0, 50)
        toolButton.Position = UDim2.new(0, 0, 0, yOffset)
        toolButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toolButton.BorderSizePixel = 0
        toolButton.Text = tool.name
        toolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toolButton.TextSize = 16
        toolButton.Font = Enum.Font.GothamBold
        toolButton.Parent = toolList
        
        -- Tool description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -20, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = tool.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = toolButton
          -- Tool button click handler
        toolButton.MouseButton1Click:Connect(function()
            -- Use our local selectTool function
            selectTool(tool.id)
            
            -- Also fire the server event if RemoteManager is available
            if RemoteManager and RemoteManager.fireServer and Constants.RemoteEvents then
                RemoteManager:fireServer(Constants.RemoteEvents.SelectTool, tool.id)
            elseif RemoteManager and RemoteManager.getRemoteEvent then
                local selectToolEvent = RemoteManager.getRemoteEvent("SelectTool")
                if selectToolEvent then
                    selectToolEvent:FireServer(tool.id)
                end
            end
        end)
        
        yOffset = yOffset + 60
    end
    
    -- Update canvas size
    toolList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Create a function to handle item selection
local function selectItem(itemId)
    selectedItemId = itemId
    
    -- Get the building tool handler
    buildingToolHandler = getBuildingToolHandler()
    
    -- If the handler is available, use it to start placing the item
    if buildingToolHandler and currentTool and selectedItemId then
        buildingToolHandler.useBuilderTool(currentTool, selectedItemId)
    else
        print("BuildingToolsUI: Unable to use building tool - handler not available")
    end
    
    -- Update the UI to highlight the selected item
    if itemList then
        for _, button in pairs(itemList:GetChildren()) do
            if button:IsA("TextButton") then
                if button.Name == itemId then
                    button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                else
                    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
        end
    end
end

-- Create a function to handle tool selection
local function selectTool(toolType)
    currentTool = toolType
    
    -- Update the UI to highlight the selected tool
    if toolList then
        for _, button in pairs(toolList:GetChildren()) do
            if button:IsA("TextButton") then
                if button.Name == toolType then
                    button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                else
                    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
        end
    end
    
    -- If an item is selected, update the building tool
    if selectedItemId then
        -- Get the building tool handler
        buildingToolHandler = getBuildingToolHandler()
        
        if buildingToolHandler and currentTool and selectedItemId then
            buildingToolHandler.useBuilderTool(currentTool, selectedItemId)
        end
    end
end

-- Initialize
function BuildingToolsUI.init()
    BuildingToolsUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ToolUpdate, function(tools)
        BuildingToolsUI.updateTools(tools)
    end)
end

return BuildingToolsUI