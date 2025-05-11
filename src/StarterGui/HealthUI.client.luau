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
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create health bar background
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Name = "HealthBarBg"
    healthBarBg.Size = UDim2.new(1, -20, 0, 20)
    healthBarBg.Position = UDim2.new(0, 10, 0, 10)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = mainFrame
    
    -- Create health bar
    healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBarBg
    
    -- Create health text
    healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.Position = UDim2.new(0, 0, 0, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = "100"
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 14
    healthText.Font = Enum.Font.GothamBold
    healthText.Parent = healthBarBg
    
    -- Create shield bar background
    local shieldBarBg = Instance.new("Frame")
    shieldBarBg.Name = "ShieldBarBg"
    shieldBarBg.Size = UDim2.new(1, -20, 0, 20)
    shieldBarBg.Position = UDim2.new(0, 10, 1, -30)
    shieldBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    shieldBarBg.BorderSizePixel = 0
    shieldBarBg.Parent = mainFrame
    
    -- Create shield bar
    shieldBar = Instance.new("Frame")
    shieldBar.Name = "ShieldBar"
    shieldBar.Size = UDim2.new(1, 0, 1, 0)
    shieldBar.Position = UDim2.new(0, 0, 0, 0)
    shieldBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    shieldBar.BorderSizePixel = 0
    shieldBar.Parent = shieldBarBg
    
    -- Create shield text
    shieldText = Instance.new("TextLabel")
    shieldText.Name = "ShieldText"
    shieldText.Size = UDim2.new(1, 0, 1, 0)
    shieldText.Position = UDim2.new(0, 0, 0, 0)
    shieldText.BackgroundTransparency = 1
    shieldText.Text = "100"
    shieldText.TextColor3 = Color3.fromRGB(255, 255, 255)
    shieldText.TextSize = 14
    shieldText.Font = Enum.Font.GothamBold
    shieldText.Parent = shieldBarBg
end

-- Update health
function HealthUI.updateHealth(health, maxHealth)
    -- Update health bar
    local healthPercent = health / maxHealth
    local tweenInfo = TweenInfo.new(0.3)
    local tween = TweenService:Create(healthBar, tweenInfo, {
        Size = UDim2.new(healthPercent, 0, 1, 0)
    })
    tween:Play()
    
    -- Update health text
    healthText.Text = tostring(math.floor(health))
    
    -- Update health bar color
    local color
    if healthPercent > 0.6 then
        color = Color3.fromRGB(0, 255, 0) -- Green
    elseif healthPercent > 0.3 then
        color = Color3.fromRGB(255, 255, 0) -- Yellow
    else
        color = Color3.fromRGB(255, 0, 0) -- Red
    end
    
    local colorTween = TweenService:Create(healthBar, tweenInfo, {
        BackgroundColor3 = color
    })
    colorTween:Play()
end

-- Update shield
function HealthUI.updateShield(shield, maxShield)
    -- Update shield bar
    local shieldPercent = shield / maxShield
    local tweenInfo = TweenInfo.new(0.3)
    local tween = TweenService:Create(shieldBar, tweenInfo, {
        Size = UDim2.new(shieldPercent, 0, 1, 0)
    })
    tween:Play()
    
    -- Update shield text
    shieldText.Text = tostring(math.floor(shield))
    
    -- Update shield bar color
    local color
    if shieldPercent > 0.6 then
        color = Color3.fromRGB(0, 150, 255) -- Blue
    elseif shieldPercent > 0.3 then
        color = Color3.fromRGB(255, 255, 0) -- Yellow
    else
        color = Color3.fromRGB(255, 0, 0) -- Red
    end
    
    local colorTween = TweenService:Create(shieldBar, tweenInfo, {
        BackgroundColor3 = color
    })
    colorTween:Play()
end

-- Show health UI
function HealthUI.show()
    mainFrame.Visible = true
end

-- Hide health UI
function HealthUI.hide()
    mainFrame.Visible = false
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
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.HealthUIVisibilityUpdate, function(visible)
        if visible then
            HealthUI.show()
        else
            HealthUI.hide()
        end
    end)
end

return HealthUI 