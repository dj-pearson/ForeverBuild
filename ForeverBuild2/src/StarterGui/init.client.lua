--[[
    StarterGui Module - ForeverBuild2
    
    This is the main initialization script for the StarterGui.
    It handles loading and setting up all UI components.
]]

-- Add debug print to confirm script is running
print("StarterGui script starting...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get shared module
local SharedModule = require(ReplicatedStorage.shared)

-- Local references to commonly used modules
local Constants = SharedModule.Constants
local GameManager = SharedModule.GameManager
local CurrencyManager = SharedModule.Economy.CurrencyManager

local StarterGui = {}
StarterGui.__index = StarterGui

function StarterGui.new()
    local self = setmetatable({}, StarterGui)
    self.remoteEvents = ReplicatedStorage.Remotes
    return self
end

function StarterGui:Init()
    print("Initializing StarterGui...")
    
    -- Create main UI
    self:CreateMainUI()
    
    -- Set up event handlers
    self:SetupEventHandlers()
end

function StarterGui:CreateMainUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainUI"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui
    
    self.ui = screenGui
end

function StarterGui:SetupEventHandlers()
    -- Handle item description
    self.remoteEvents.ShowItemDescription.OnClientEvent:Connect(function(description)
        self:ShowItemDescription(description)
    end)
    
    -- Handle notifications
    self.remoteEvents.NotifyPlayer.OnClientEvent:Connect(function(message)
        self:ShowNotification(message)
    end)
end

function StarterGui:ShowItemDescription(description)
    -- Create description UI
    local descriptionUI = Instance.new("ScreenGui")
    descriptionUI.Name = "ItemDescription"
    descriptionUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "DescriptionFrame"
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = descriptionUI
    
    local label = Instance.new("TextLabel")
    label.Name = "DescriptionLabel"
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.Text = description
    label.TextWrapped = true
    label.Parent = frame
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame
    
    closeButton.MouseButton1Click:Connect(function()
        descriptionUI:Destroy()
    end)
end

function StarterGui:ShowNotification(message)
    -- Create notification UI
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    notification.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.Name = "MessageLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.Text = message
    label.Parent = frame
    
    -- Animate and destroy
    game:GetService("Debris"):AddItem(notification, 3)
end

-- Add this to self-initialize
StarterGui.new():Init()

return StarterGui
