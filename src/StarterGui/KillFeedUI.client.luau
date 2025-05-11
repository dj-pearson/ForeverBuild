local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local KillFeedUI = {}

-- UI Elements
local screenGui
local mainFrame
local killFeedEntries = {}

-- Create UI
function KillFeedUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KillFeedUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 200)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui
end

-- Create kill feed entry
function KillFeedUI.createKillFeedEntry(killer, victim, weapon)
    -- Create entry frame
    local entry = Instance.new("Frame")
    entry.Name = "KillFeedEntry"
    entry.Size = UDim2.new(1, 0, 0, 30)
    entry.BackgroundTransparency = 1
    entry.Parent = mainFrame
    
    -- Create killer name
    local killerName = Instance.new("TextLabel")
    killerName.Name = "KillerName"
    killerName.Size = UDim2.new(0, 150, 1, 0)
    killerName.Position = UDim2.new(0, 0, 0, 0)
    killerName.BackgroundTransparency = 1
    killerName.Text = killer.name
    killerName.TextColor3 = killer.team == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
    killerName.TextSize = 18
    killerName.Font = Enum.Font.GothamBold
    killerName.TextXAlignment = Enum.TextXAlignment.Right
    killerName.Parent = entry
    
    -- Create weapon icon
    local weaponIcon = Instance.new("TextLabel")
    weaponIcon.Name = "WeaponIcon"
    weaponIcon.Size = UDim2.new(0, 30, 1, 0)
    weaponIcon.Position = UDim2.new(0.5, -15, 0, 0)
    weaponIcon.BackgroundTransparency = 1
    weaponIcon.Text = weapon.icon
    weaponIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    weaponIcon.TextSize = 18
    weaponIcon.Font = Enum.Font.GothamBold
    weaponIcon.Parent = entry
    
    -- Create victim name
    local victimName = Instance.new("TextLabel")
    victimName.Name = "VictimName"
    victimName.Size = UDim2.new(0, 150, 1, 0)
    victimName.Position = UDim2.new(1, -150, 0, 0)
    victimName.BackgroundTransparency = 1
    victimName.Text = victim.name
    victimName.TextColor3 = victim.team == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
    victimName.TextSize = 18
    victimName.Font = Enum.Font.GothamBold
    victimName.TextXAlignment = Enum.TextXAlignment.Left
    victimName.Parent = entry
    
    -- Add to entries table
    table.insert(killFeedEntries, entry)
    
    -- Animate entry
    entry.Position = UDim2.new(0, 0, 0, -30)
    entry.BackgroundTransparency = 1
    
    local showTween = TweenService:Create(entry, TweenInfo.new(0.3), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.5
    })
    
    local hideTween = TweenService:Create(entry, TweenInfo.new(0.3), {
        Position = UDim2.new(0, 0, 0, -30),
        BackgroundTransparency = 1
    })
    
    showTween:Play()
    
    -- Remove entry after delay
    task.delay(5, function()
        hideTween:Play()
        hideTween.Completed:Connect(function()
            entry:Destroy()
            table.remove(killFeedEntries, table.find(killFeedEntries, entry))
            KillFeedUI.updatePositions()
        end)
    end)
    
    -- Update positions
    KillFeedUI.updatePositions()
end

-- Update positions
function KillFeedUI.updatePositions()
    for i, entry in ipairs(killFeedEntries) do
        entry.Position = UDim2.new(0, 0, 0, (i-1) * 30)
    end
end

-- Initialize
function KillFeedUI.init()
    KillFeedUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.KillFeedUpdate, function(killer, victim, weapon)
        KillFeedUI.createKillFeedEntry(killer, victim, weapon)
    end)
end

return KillFeedUI 