local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local HealthUI = {}

-- UI Elements
local screenGui
local mainFrame
local healthBar
local healthText
local shieldBar
local shieldText

-- Create UI
function HealthUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HealthUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 60)
    mainFrame.Position = UDim2.new(0, 20, 1, -80)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    mainFrame.Parent = screenGui
    
    -- Create health bar background
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Name = "HealthBarBg"
    healthBarBg.Size = UDim2.new(1, -20, 0, 20)
    healthBarBg.Position = UDim2.new(0, 10, 0, 10)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = mainFrame
    
    -- Create health bar
    healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg
    
    -- Create health text
    healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.Position = UDim2.new(0, 0, 0, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = "100/100"
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 14
    healthText.Font = Enum.Font.GothamBold
    healthText.Parent = healthBarBg
    
    -- Create shield bar background
    local shieldBarBg = Instance.new("Frame")
    shieldBarBg.Name = "ShieldBarBg"
    shieldBarBg.Size = UDim2.new(1, -20, 0, 20)
    shieldBarBg.Position = UDim2.new(0, 10, 0, 40)
    shieldBarBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    shieldBarBg.BorderSizePixel = 0
    shieldBarBg.Parent = mainFrame
    
    -- Create shield bar
    shieldBar = Instance.new("Frame")
    shieldBar.Name = "ShieldBar"
    shieldBar.Size = UDim2.new(1, 0, 1, 0)
    shieldBar.Position = UDim2.new(0, 0, 0, 0)
    shieldBar.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    shieldBar.BorderSizePixel = 0
    shieldBar.Parent = shieldBarBg
    
    -- Create shield text
    shieldText = Instance.new("TextLabel")
    shieldText.Name = "ShieldText"
    shieldText.Size = UDim2.new(1, 0, 1, 0)
    shieldText.Position = UDim2.new(0, 0, 0, 0)
    shieldText.BackgroundTransparency = 1
    shieldText.Text = "100/100"
    shieldText.TextColor3 = Color3.fromRGB(255, 255, 255)
    shieldText.TextSize = 14
    shieldText.Font = Enum.Font.GothamBold
    shieldText.Parent = shieldBarBg
end

-- Update health
function HealthUI.updateHealth(health, maxHealth)
    local healthPercent = health / maxHealth
    healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
    healthText.Text = tostring(health) .. "/" .. tostring(maxHealth)
    
    -- Update color based on health percentage
    if healthPercent > 0.5 then
        healthBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    elseif healthPercent > 0.25 then
        healthBar.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    else
        healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Update shield
function HealthUI.updateShield(shield, maxShield)
    local shieldPercent = shield / maxShield
    shieldBar.Size = UDim2.new(shieldPercent, 0, 1, 0)
    shieldText.Text = tostring(shield) .. "/" .. tostring(maxShield)
    
    -- Update color based on shield percentage
    if shieldPercent > 0.5 then
        shieldBar.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    elseif shieldPercent > 0.25 then
        shieldBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    else
        shieldBar.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
    end
end

-- Initialize
function HealthUI.init()
    HealthUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.HealthUpdate, function(health, maxHealth)
        HealthUI.updateHealth(health, maxHealth)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShieldUpdate, function(shield, maxShield)
        HealthUI.updateShield(shield, maxShield)
    end)
end

return HealthUI 