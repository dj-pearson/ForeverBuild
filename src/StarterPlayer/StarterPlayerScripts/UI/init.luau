local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

local UI = {}
UI.__index = UI

-- UI state
local uiState = {
    isMenuOpen = false,
    currentScreen = nil,
    notifications = {}
}

-- Create UI elements
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main menu
    local mainMenu = Instance.new("Frame")
    mainMenu.Name = "MainMenu"
    mainMenu.Size = UDim2.new(0, 400, 0, 300)
    mainMenu.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainMenu.BorderSizePixel = 0
    mainMenu.Visible = false
    mainMenu.Parent = screenGui
    
    -- Create notification system
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notifications"
    notificationFrame.Size = UDim2.new(0, 300, 0, 0)
    notificationFrame.Position = UDim2.new(1, -320, 0, 20)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.Parent = screenGui
    
    return screenGui
end

-- Show notification
function UI.ShowNotification(message, duration)
    duration = duration or 3
    
    local notification = Instance.new("TextLabel")
    notification.Text = message
    notification.Size = UDim2.new(1, 0, 0, 40)
    notification.Position = UDim2.new(0, 0, 0, #uiState.notifications * 50)
    notification.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Font = Enum.Font.GothamMedium
    notification.TextSize = 14
    notification.Parent = LocalPlayer:WaitForChild("PlayerGui").GameUI.Notifications
    
    table.insert(uiState.notifications, notification)
    
    task.delay(duration, function()
        notification:Destroy()
        table.remove(uiState.notifications, table.find(uiState.notifications, notification))
    end)
end

-- Toggle menu
function UI.ToggleMenu()
    uiState.isMenuOpen = not uiState.isMenuOpen
    LocalPlayer:WaitForChild("PlayerGui").GameUI.MainMenu.Visible = uiState.isMenuOpen
end

-- Initialize
function UI.Initialize()
    local success, result = pcall(function()
        createUI()
        
        -- Set up remote event handlers
        RemoteManager:onClientEvent("ShowNotification", function(message, duration)
            UI.ShowNotification(message, duration)
        end)
        
        -- Set up input handling
        LocalPlayer:GetAttributeChangedSignal("IsMenuOpen"):Connect(function()
            UI.ToggleMenu()
        end)
    end)
    
    if not success then
        Logger:error("Failed to initialize UI", { error = result })
        return false
    end
    
    Logger:info("UI initialized successfully")
    return true
end

return UI 