local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local NotificationUI = {}

-- UI Elements
local screenGui
local notificationFrame
local notifications = {}

-- Create UI
function NotificationUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create notification frame
    notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, 300, 0, 0)
    notificationFrame.Position = UDim2.new(1, -320, 0, 20)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.Parent = screenGui
end

-- Create notification
function NotificationUI.createNotification(title, message, type, duration)
    -- Create notification frame
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = notificationFrame
    
    -- Create type indicator
    local typeIndicator = Instance.new("Frame")
    typeIndicator.Name = "TypeIndicator"
    typeIndicator.Size = UDim2.new(0, 4, 1, 0)
    typeIndicator.Position = UDim2.new(0, 0, 0, 0)
    typeIndicator.BackgroundColor3 = NotificationUI.getTypeColor(type)
    typeIndicator.BorderSizePixel = 0
    typeIndicator.Parent = frame
    
    -- Create title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    -- Create message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = frame
    
    -- Calculate message height
    local textSize = messageLabel.TextBounds
    messageLabel.Size = UDim2.new(1, -20, 0, textSize.Y)
    
    -- Update frame size
    frame.Size = UDim2.new(1, 0, 0, 50 + textSize.Y)
    
    -- Add to notifications list
    table.insert(notifications, frame)
    
    -- Update positions
    NotificationUI.updatePositions()
    
    -- Animate in
    frame.Position = UDim2.new(1, 0, 0, 0)
    frame.Size = UDim2.new(1, 0, 0, 0)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(frame, tweenInfo, {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 50 + textSize.Y)
    })
    tween:Play()
    
    -- Set up auto-remove
    task.delay(duration or 5, function()
        NotificationUI.removeNotification(frame)
    end)
    
    return frame
end

-- Remove notification
function NotificationUI.removeNotification(frame)
    -- Find index
    local index = table.find(notifications, frame)
    if not index then return end
    
    -- Remove from list
    table.remove(notifications, index)
    
    -- Animate out
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(frame, tweenInfo, {
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 0)
    })
    tween:Play()
    
    -- Remove after animation
    task.delay(0.3, function()
        frame:Destroy()
        NotificationUI.updatePositions()
    end)
end

-- Update positions
function NotificationUI.updatePositions()
    local yOffset = 0
    for _, notification in ipairs(notifications) do
        notification.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset = yOffset + notification.Size.Y.Offset + 10
    end
end

-- Get type color
function NotificationUI.getTypeColor(type)
    if type == "success" then
        return Color3.fromRGB(0, 255, 0)
    elseif type == "warning" then
        return Color3.fromRGB(255, 255, 0)
    elseif type == "error" then
        return Color3.fromRGB(255, 0, 0)
    else
        return Color3.fromRGB(0, 0, 255)
    end
end

-- Show notification
function NotificationUI.showNotification(title, message, type, duration)
    return NotificationUI.createNotification(title, message, type, duration)
end

-- Initialize
function NotificationUI.init()
    NotificationUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowNotification, function(data)
        NotificationUI.showNotification(data.title, data.message, data.type, data.duration)
    end)
end

return NotificationUI 