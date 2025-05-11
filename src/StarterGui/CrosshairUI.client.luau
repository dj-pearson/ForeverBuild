local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local CrosshairUI = {}

-- UI Elements
local screenGui
local mainFrame
local crosshairFrame
local dot
local lines = {}

-- Create UI
function CrosshairUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CrosshairUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui
    
    -- Create crosshair frame
    crosshairFrame = Instance.new("Frame")
    crosshairFrame.Name = "CrosshairFrame"
    crosshairFrame.Size = UDim2.new(0, 20, 0, 20)
    crosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
    crosshairFrame.BackgroundTransparency = 1
    crosshairFrame.Parent = mainFrame
    
    -- Create center dot
    dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 2, 0, 2)
    dot.Position = UDim2.new(0.5, -1, 0.5, -1)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = crosshairFrame
    
    -- Create crosshair lines
    local linePositions = {
        {UDim2.new(0, -8, 0.5, -1), UDim2.new(0, 8, 0, 2)}, -- Left
        {UDim2.new(1, 0, 0.5, -1), UDim2.new(0, 8, 0, 2)}, -- Right
        {UDim2.new(0.5, -1, 0, -8), UDim2.new(0, 2, 0, 8)}, -- Top
        {UDim2.new(0.5, -1, 1, 0), UDim2.new(0, 2, 0, 8)} -- Bottom
    }
    
    for i, pos in ipairs(linePositions) do
        local line = Instance.new("Frame")
        line.Name = "Line" .. i
        line.Size = pos[2]
        line.Position = pos[1]
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.BorderSizePixel = 0
        line.Parent = crosshairFrame
        table.insert(lines, line)
    end
end

-- Update crosshair spread
function CrosshairUI.updateSpread(spread)
    -- Calculate line positions based on spread
    local linePositions = {
        {UDim2.new(0, -spread, 0.5, -1), UDim2.new(0, spread, 0, 2)}, -- Left
        {UDim2.new(1, 0, 0.5, -1), UDim2.new(0, spread, 0, 2)}, -- Right
        {UDim2.new(0.5, -1, 0, -spread), UDim2.new(0, 2, 0, spread)}, -- Top
        {UDim2.new(0.5, -1, 1, 0), UDim2.new(0, 2, 0, spread)} -- Bottom
    }
    
    -- Update line positions
    for i, line in ipairs(lines) do
        local tweenInfo = TweenInfo.new(0.1)
        local tween = TweenService:Create(line, tweenInfo, {
            Position = linePositions[i][1],
            Size = linePositions[i][2]
        })
        tween:Play()
    end
end

-- Update crosshair color
function CrosshairUI.updateColor(color)
    local tweenInfo = TweenInfo.new(0.1)
    
    -- Update dot color
    local dotTween = TweenService:Create(dot, tweenInfo, {
        BackgroundColor3 = color
    })
    dotTween:Play()
    
    -- Update line colors
    for _, line in ipairs(lines) do
        local lineTween = TweenService:Create(line, tweenInfo, {
            BackgroundColor3 = color
        })
        lineTween:Play()
    end
end

-- Show crosshair
function CrosshairUI.show()
    mainFrame.Visible = true
end

-- Hide crosshair
function CrosshairUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function CrosshairUI.init()
    CrosshairUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.CrosshairSpreadUpdate, function(spread)
        CrosshairUI.updateSpread(spread)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.CrosshairColorUpdate, function(color)
        CrosshairUI.updateColor(color)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.CrosshairVisibilityUpdate, function(visible)
        if visible then
            CrosshairUI.show()
        else
            CrosshairUI.hide()
        end
    end)
    
    -- Set up input handling
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            CrosshairUI.updateSpread(4) -- Tighter spread when aiming
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            CrosshairUI.updateSpread(8) -- Normal spread when not aiming
        end
    end)
end

return CrosshairUI 