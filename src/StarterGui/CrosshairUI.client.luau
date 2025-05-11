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
local dotFrame
local spreadFrame
local hitMarkerFrame

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
    
    -- Create dot frame
    dotFrame = Instance.new("Frame")
    dotFrame.Name = "DotFrame"
    dotFrame.Size = UDim2.new(0, 2, 0, 2)
    dotFrame.Position = UDim2.new(0.5, -1, 0.5, -1)
    dotFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dotFrame.BorderSizePixel = 0
    dotFrame.Parent = crosshairFrame
    
    -- Create spread frame
    spreadFrame = Instance.new("Frame")
    spreadFrame.Name = "SpreadFrame"
    spreadFrame.Size = UDim2.new(0, 20, 0, 20)
    spreadFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
    spreadFrame.BackgroundTransparency = 1
    spreadFrame.Parent = mainFrame
    
    -- Create hit marker frame
    hitMarkerFrame = Instance.new("Frame")
    hitMarkerFrame.Name = "HitMarkerFrame"
    hitMarkerFrame.Size = UDim2.new(0, 40, 0, 40)
    hitMarkerFrame.Position = UDim2.new(0.5, -20, 0.5, -20)
    hitMarkerFrame.BackgroundTransparency = 1
    hitMarkerFrame.Visible = false
    hitMarkerFrame.Parent = mainFrame
    
    -- Create hit marker lines
    local lines = {
        {size = UDim2.new(0, 2, 0, 10), position = UDim2.new(0.5, -1, 0, 0)},
        {size = UDim2.new(0, 2, 0, 10), position = UDim2.new(0.5, -1, 1, -10)},
        {size = UDim2.new(0, 10, 0, 2), position = UDim2.new(0, 0, 0.5, -1)},
        {size = UDim2.new(0, 10, 0, 2), position = UDim2.new(1, -10, 0.5, -1)}
    }
    
    for _, line in ipairs(lines) do
        local lineFrame = Instance.new("Frame")
        lineFrame.Name = "Line"
        lineFrame.Size = line.size
        lineFrame.Position = line.position
        lineFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        lineFrame.BorderSizePixel = 0
        lineFrame.Parent = hitMarkerFrame
    end
end

-- Update crosshair spread
function CrosshairUI.updateSpread(spread)
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(spreadFrame, tweenInfo, {
        Size = UDim2.new(0, spread, 0, spread),
        Position = UDim2.new(0.5, -spread/2, 0.5, -spread/2)
    })
    tween:Play()
end

-- Show hit marker
function CrosshairUI.showHitMarker()
    hitMarkerFrame.Visible = true
    hitMarkerFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hitMarkerFrame, tweenInfo, {
        BackgroundTransparency = 0.5
    })
    tween:Play()
    
    task.delay(0.1, function()
        local fadeOutTween = TweenService:Create(hitMarkerFrame, tweenInfo, {
            BackgroundTransparency = 1
        })
        fadeOutTween:Play()
        
        task.delay(0.1, function()
            hitMarkerFrame.Visible = false
        end)
    end)
end

-- Update crosshair color
function CrosshairUI.updateColor(color)
    dotFrame.BackgroundColor3 = color
    
    for _, child in ipairs(hitMarkerFrame:GetChildren()) do
        if child:IsA("Frame") then
            child.BackgroundColor3 = color
        end
    end
end

-- Initialize
function CrosshairUI.init()
    CrosshairUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.CrosshairSpread, function(spread)
        CrosshairUI.updateSpread(spread)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.HitMarker, function()
        CrosshairUI.showHitMarker()
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.CrosshairColor, function(color)
        CrosshairUI.updateColor(color)
    end)
end

return CrosshairUI 