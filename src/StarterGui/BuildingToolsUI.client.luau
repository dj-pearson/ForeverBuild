local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local BuildingToolsUI = {}

-- UI Elements
local screenGui
local mainFrame
local toolList
local closeButton

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
            RemoteManager:fireServer(Constants.RemoteEvents.SelectTool, tool.id)
        end)
        
        yOffset = yOffset + 60
    end
    
    -- Update canvas size
    toolList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
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