local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local SpectatorUI = {}

-- UI Elements
local screenGui
local mainFrame
local targetFrame
local targetName
local targetHealth
local targetShield
local targetAmmo
local targetReserve
local targetWeapon
local targetTeam
local targetKills
local targetDeaths
local targetKD

-- Create UI
function SpectatorUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpectatorUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create target frame
    targetFrame = Instance.new("Frame")
    targetFrame.Name = "TargetFrame"
    targetFrame.Size = UDim2.new(1, 0, 1, 0)
    targetFrame.Position = UDim2.new(0, 0, 0, 0)
    targetFrame.BackgroundTransparency = 1
    targetFrame.Parent = mainFrame
    
    -- Create target name
    targetName = Instance.new("TextLabel")
    targetName.Name = "TargetName"
    targetName.Size = UDim2.new(1, 0, 0, 30)
    targetName.Position = UDim2.new(0, 0, 0, 0)
    targetName.BackgroundTransparency = 1
    targetName.Text = ""
    targetName.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetName.TextSize = 20
    targetName.Font = Enum.Font.GothamBold
    targetName.Parent = targetFrame
    
    -- Create target health
    targetHealth = Instance.new("TextLabel")
    targetHealth.Name = "TargetHealth"
    targetHealth.Size = UDim2.new(1, 0, 0, 20)
    targetHealth.Position = UDim2.new(0, 0, 0, 40)
    targetHealth.BackgroundTransparency = 1
    targetHealth.Text = ""
    targetHealth.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetHealth.TextSize = 16
    targetHealth.Font = Enum.Font.Gotham
    targetHealth.Parent = targetFrame
    
    -- Create target shield
    targetShield = Instance.new("TextLabel")
    targetShield.Name = "TargetShield"
    targetShield.Size = UDim2.new(1, 0, 0, 20)
    targetShield.Position = UDim2.new(0, 0, 0, 60)
    targetShield.BackgroundTransparency = 1
    targetShield.Text = ""
    targetShield.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetShield.TextSize = 16
    targetShield.Font = Enum.Font.Gotham
    targetShield.Parent = targetFrame
    
    -- Create target ammo
    targetAmmo = Instance.new("TextLabel")
    targetAmmo.Name = "TargetAmmo"
    targetAmmo.Size = UDim2.new(1, 0, 0, 20)
    targetAmmo.Position = UDim2.new(0, 0, 0, 90)
    targetAmmo.BackgroundTransparency = 1
    targetAmmo.Text = ""
    targetAmmo.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetAmmo.TextSize = 16
    targetAmmo.Font = Enum.Font.Gotham
    targetAmmo.Parent = targetFrame
    
    -- Create target weapon
    targetWeapon = Instance.new("TextLabel")
    targetWeapon.Name = "TargetWeapon"
    targetWeapon.Size = UDim2.new(1, 0, 0, 20)
    targetWeapon.Position = UDim2.new(0, 0, 0, 110)
    targetWeapon.BackgroundTransparency = 1
    targetWeapon.Text = ""
    targetWeapon.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetWeapon.TextSize = 16
    targetWeapon.Font = Enum.Font.Gotham
    targetWeapon.Parent = targetFrame
    
    -- Create target team
    targetTeam = Instance.new("TextLabel")
    targetTeam.Name = "TargetTeam"
    targetTeam.Size = UDim2.new(1, 0, 0, 20)
    targetTeam.Position = UDim2.new(0, 0, 0, 140)
    targetTeam.BackgroundTransparency = 1
    targetTeam.Text = ""
    targetTeam.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetTeam.TextSize = 16
    targetTeam.Font = Enum.Font.Gotham
    targetTeam.Parent = targetFrame
    
    -- Create target stats
    targetKills = Instance.new("TextLabel")
    targetKills.Name = "TargetKills"
    targetKills.Size = UDim2.new(0.33, 0, 0, 20)
    targetKills.Position = UDim2.new(0, 0, 0, 170)
    targetKills.BackgroundTransparency = 1
    targetKills.Text = ""
    targetKills.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetKills.TextSize = 16
    targetKills.Font = Enum.Font.Gotham
    targetKills.Parent = targetFrame
    
    targetDeaths = Instance.new("TextLabel")
    targetDeaths.Name = "TargetDeaths"
    targetDeaths.Size = UDim2.new(0.33, 0, 0, 20)
    targetDeaths.Position = UDim2.new(0.33, 0, 0, 170)
    targetDeaths.BackgroundTransparency = 1
    targetDeaths.Text = ""
    targetDeaths.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetDeaths.TextSize = 16
    targetDeaths.Font = Enum.Font.Gotham
    targetDeaths.Parent = targetFrame
    
    targetKD = Instance.new("TextLabel")
    targetKD.Name = "TargetKD"
    targetKD.Size = UDim2.new(0.33, 0, 0, 20)
    targetKD.Position = UDim2.new(0.66, 0, 0, 170)
    targetKD.BackgroundTransparency = 1
    targetKD.Text = ""
    targetKD.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetKD.TextSize = 16
    targetKD.Font = Enum.Font.Gotham
    targetKD.Parent = targetFrame
end

-- Update target info
function SpectatorUI.updateTargetInfo(targetData)
    if not targetData then
        SpectatorUI.hide()
        return
    end
    
    targetName.Text = targetData.name
    targetHealth.Text = "Health: " .. targetData.health
    targetShield.Text = "Shield: " .. targetData.shield
    targetAmmo.Text = "Ammo: " .. targetData.ammo .. " / " .. targetData.reserve
    targetWeapon.Text = "Weapon: " .. targetData.weapon
    targetTeam.Text = "Team: " .. targetData.team
    targetKills.Text = "Kills: " .. targetData.kills
    targetDeaths.Text = "Deaths: " .. targetData.deaths
    targetKD.Text = "K/D: " .. string.format("%.2f", targetData.kills / math.max(1, targetData.deaths))
    
    -- Set team color
    local teamColor = targetData.team == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
    targetTeam.TextColor3 = teamColor
    
    -- Set health color
    local healthColor = Color3.fromRGB(255, 255, 255)
    if targetData.health < 30 then
        healthColor = Color3.fromRGB(255, 0, 0)
    elseif targetData.health < 70 then
        healthColor = Color3.fromRGB(255, 255, 0)
    end
    targetHealth.TextColor3 = healthColor
    
    -- Set shield color
    local shieldColor = Color3.fromRGB(255, 255, 255)
    if targetData.shield < 30 then
        shieldColor = Color3.fromRGB(255, 0, 0)
    elseif targetData.shield < 70 then
        shieldColor = Color3.fromRGB(255, 255, 0)
    end
    targetShield.TextColor3 = shieldColor
    
    -- Set ammo color
    local ammoColor = Color3.fromRGB(255, 255, 255)
    if targetData.ammo < 5 then
        ammoColor = Color3.fromRGB(255, 0, 0)
    elseif targetData.ammo < 10 then
        ammoColor = Color3.fromRGB(255, 255, 0)
    end
    targetAmmo.TextColor3 = ammoColor
end

-- Show spectator UI
function SpectatorUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide spectator UI
function SpectatorUI.hide()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 1
    })
    tween:Play()
    
    task.delay(0.3, function()
        mainFrame.Visible = false
    end)
end

-- Initialize
function SpectatorUI.init()
    SpectatorUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.SpectatorUpdate, function(targetData)
        SpectatorUI.updateTargetInfo(targetData)
        if targetData then
            SpectatorUI.show()
        end
    end)
end

return SpectatorUI 