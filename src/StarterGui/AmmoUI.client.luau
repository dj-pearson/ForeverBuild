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
end

-- Update ammo
function AmmoUI.updateAmmo(ammo, reserve, weaponData)
    ammoText.Text = tostring(ammo)
    reserveText.Text = tostring(reserve)
    
    -- Update weapon icon
    if weaponData and weaponData.icon then
        weaponIcon.Image = weaponData.icon
    end
    
    -- Update text color based on ammo
    if ammo == 0 then
        ammoText.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        ammoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    -- Update reserve text color based on reserve
    if reserve == 0 then
        reserveText.TextColor3 = Color3.fromRGB(255, 50, 50)
    else
        reserveText.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- Show UI
function AmmoUI.show()
    mainFrame.Visible = true
    
    -- Animate in
    mainFrame.Position = UDim2.new(1, -220, 1, -40)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(1, -220, 1, -80),
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide UI
function AmmoUI.hide()
    -- Animate out
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(1, -220, 1, -40),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Hide after animation
    task.delay(0.5, function()
        mainFrame.Visible = false
    end)
end

-- Initialize
function AmmoUI.init()
    AmmoUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.AmmoUpdate, function(ammo, reserve, weaponData)
        AmmoUI.updateAmmo(ammo, reserve, weaponData)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.WeaponEquipped, function(weaponData)
        if weaponData then
            AmmoUI.show()
        else
            AmmoUI.hide()
        end
    end)
end

return AmmoUI 