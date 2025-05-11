local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local WeaponUI = {}

-- UI Elements
local screenGui
local mainFrame
local weaponIcon
local weaponName
local weaponStats
local fireMode
local attachments

-- Create UI
function WeaponUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WeaponUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(1, -320, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create weapon icon
    weaponIcon = Instance.new("ImageLabel")
    weaponIcon.Name = "WeaponIcon"
    weaponIcon.Size = UDim2.new(0, 80, 0, 80)
    weaponIcon.Position = UDim2.new(0, 10, 0, 10)
    weaponIcon.BackgroundTransparency = 1
    weaponIcon.Image = ""
    weaponIcon.Parent = mainFrame
    
    -- Create weapon name
    weaponName = Instance.new("TextLabel")
    weaponName.Name = "WeaponName"
    weaponName.Size = UDim2.new(1, -100, 0, 30)
    weaponName.Position = UDim2.new(0, 100, 0, 10)
    weaponName.BackgroundTransparency = 1
    weaponName.Text = ""
    weaponName.TextColor3 = Color3.fromRGB(255, 255, 255)
    weaponName.TextSize = 24
    weaponName.Font = Enum.Font.GothamBold
    weaponName.TextXAlignment = Enum.TextXAlignment.Left
    weaponName.Parent = mainFrame
    
    -- Create weapon stats
    weaponStats = Instance.new("TextLabel")
    weaponStats.Name = "WeaponStats"
    weaponStats.Size = UDim2.new(1, -100, 0, 60)
    weaponStats.Position = UDim2.new(0, 100, 0, 40)
    weaponStats.BackgroundTransparency = 1
    weaponStats.Text = ""
    weaponStats.TextColor3 = Color3.fromRGB(200, 200, 200)
    weaponStats.TextSize = 16
    weaponStats.Font = Enum.Font.Gotham
    weaponStats.TextXAlignment = Enum.TextXAlignment.Left
    weaponStats.TextYAlignment = Enum.TextYAlignment.Top
    weaponStats.Parent = mainFrame
    
    -- Create fire mode
    fireMode = Instance.new("TextLabel")
    fireMode.Name = "FireMode"
    fireMode.Size = UDim2.new(1, -20, 0, 30)
    fireMode.Position = UDim2.new(0, 10, 0, 100)
    fireMode.BackgroundTransparency = 1
    fireMode.Text = ""
    fireMode.TextColor3 = Color3.fromRGB(255, 255, 255)
    fireMode.TextSize = 18
    fireMode.Font = Enum.Font.GothamBold
    fireMode.TextXAlignment = Enum.TextXAlignment.Left
    fireMode.Parent = mainFrame
    
    -- Create attachments
    attachments = Instance.new("TextLabel")
    attachments.Name = "Attachments"
    attachments.Size = UDim2.new(1, -20, 0, 50)
    attachments.Position = UDim2.new(0, 10, 0, 140)
    attachments.BackgroundTransparency = 1
    attachments.Text = ""
    attachments.TextColor3 = Color3.fromRGB(200, 200, 200)
    attachments.TextSize = 16
    attachments.Font = Enum.Font.Gotham
    attachments.TextXAlignment = Enum.TextXAlignment.Left
    attachments.TextYAlignment = Enum.TextYAlignment.Top
    attachments.Parent = mainFrame
end

-- Update weapon info
function WeaponUI.updateWeaponInfo(weaponData)
    -- Update weapon icon
    weaponIcon.Image = weaponData.icon
    
    -- Update weapon name
    weaponName.Text = weaponData.name
    
    -- Update weapon stats
    local statsText = string.format(
        "Damage: %d\nRange: %d\nFire Rate: %d\nMobility: %d",
        weaponData.damage,
        weaponData.range,
        weaponData.fireRate,
        weaponData.mobility
    )
    weaponStats.Text = statsText
    
    -- Update fire mode
    fireMode.Text = "Fire Mode: " .. weaponData.fireMode
    
    -- Update attachments
    local attachmentsText = "Attachments:\n"
    for _, attachment in ipairs(weaponData.attachments) do
        attachmentsText = attachmentsText .. "• " .. attachment .. "\n"
    end
    attachments.Text = attachmentsText
end

-- Show weapon UI
function WeaponUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide weapon UI
function WeaponUI.hide()
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
function WeaponUI.init()
    WeaponUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.WeaponEquipped, function(weaponData)
        WeaponUI.updateWeaponInfo(weaponData)
        WeaponUI.show()
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.WeaponUnequipped, function()
        WeaponUI.hide()
    end)
end

return WeaponUI 