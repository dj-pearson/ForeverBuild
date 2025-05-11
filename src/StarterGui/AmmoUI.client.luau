local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local AmmoUI = {}

-- UI Elements
local screenGui
local mainFrame
local ammoText
local reserveText
local reloadBar
local reloadText

-- Create UI
function AmmoUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AmmoUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(1, -220, 1, -120)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui
    
    -- Create ammo text
    ammoText = Instance.new("TextLabel")
    ammoText.Name = "AmmoText"
    ammoText.Size = UDim2.new(0, 100, 0, 50)
    ammoText.Position = UDim2.new(0, 0, 0, 0)
    ammoText.BackgroundTransparency = 1
    ammoText.Text = "30"
    ammoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ammoText.TextSize = 48
    ammoText.Font = Enum.Font.GothamBold
    ammoText.TextXAlignment = Enum.TextXAlignment.Right
    ammoText.Parent = mainFrame
    
    -- Create reserve text
    reserveText = Instance.new("TextLabel")
    reserveText.Name = "ReserveText"
    reserveText.Size = UDim2.new(0, 100, 0, 30)
    reserveText.Position = UDim2.new(0, 0, 0, 50)
    reserveText.BackgroundTransparency = 1
    reserveText.Text = "90"
    reserveText.TextColor3 = Color3.fromRGB(200, 200, 200)
    reserveText.TextSize = 24
    reserveText.Font = Enum.Font.Gotham
    reserveText.TextXAlignment = Enum.TextXAlignment.Right
    reserveText.Parent = mainFrame
    
    -- Create reload bar background
    local reloadBg = Instance.new("Frame")
    reloadBg.Name = "ReloadBg"
    reloadBg.Size = UDim2.new(0, 200, 0, 4)
    reloadBg.Position = UDim2.new(0, 0, 0, 90)
    reloadBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    reloadBg.BorderSizePixel = 0
    reloadBg.Visible = false
    reloadBg.Parent = mainFrame
    
    -- Create reload bar
    reloadBar = Instance.new("Frame")
    reloadBar.Name = "ReloadBar"
    reloadBar.Size = UDim2.new(0, 0, 1, 0)
    reloadBar.Position = UDim2.new(0, 0, 0, 0)
    reloadBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    reloadBar.BorderSizePixel = 0
    reloadBar.Parent = reloadBg
    
    -- Create reload text
    reloadText = Instance.new("TextLabel")
    reloadText.Name = "ReloadText"
    reloadText.Size = UDim2.new(1, 0, 0, 20)
    reloadText.Position = UDim2.new(0, 0, 0, -24)
    reloadText.BackgroundTransparency = 1
    reloadText.Text = "RELOADING"
    reloadText.TextColor3 = Color3.fromRGB(255, 255, 255)
    reloadText.TextSize = 16
    reloadText.Font = Enum.Font.GothamBold
    reloadText.Visible = false
    reloadText.Parent = reloadBg
end

-- Update ammo
function AmmoUI.updateAmmo(current, reserve)
    ammoText.Text = tostring(current)
    reserveText.Text = tostring(reserve)
    
    -- Update color based on ammo
    local color
    if current > 0 then
        color = Color3.fromRGB(255, 255, 255) -- White
    else
        color = Color3.fromRGB(255, 0, 0) -- Red
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(ammoText, tweenInfo, {
        TextColor3 = color
    })
    tween:Play()
end

-- Start reload
function AmmoUI.startReload(duration)
    local reloadBg = mainFrame:FindFirstChild("ReloadBg")
    if reloadBg then
        reloadBg.Visible = true
        reloadBar.Size = UDim2.new(0, 0, 1, 0)
        reloadText.Visible = true
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(reloadBar, tweenInfo, {
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
        
        task.delay(duration, function()
            reloadBg.Visible = false
            reloadText.Visible = false
        end)
    end
end

-- Initialize
function AmmoUI.init()
    AmmoUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.AmmoUpdate, function(current, reserve)
        AmmoUI.updateAmmo(current, reserve)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.ReloadStart, function(duration)
        AmmoUI.startReload(duration)
    end)
end

return AmmoUI 