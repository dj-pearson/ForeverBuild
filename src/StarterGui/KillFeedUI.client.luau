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
local killFeedList

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
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(1, -420, 0, 20)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui
    
    -- Create kill feed list
    killFeedList = Instance.new("Frame")
    killFeedList.Name = "KillFeedList"
    killFeedList.Size = UDim2.new(1, 0, 1, 0)
    killFeedList.Position = UDim2.new(0, 0, 0, 0)
    killFeedList.BackgroundTransparency = 1
    killFeedList.Parent = mainFrame
end

-- Create kill feed entry
function KillFeedUI.createKillFeedEntry(killer, victim, weapon)
    local entryFrame = Instance.new("Frame")
    entryFrame.Name = "Entry"
    entryFrame.Size = UDim2.new(1, 0, 0, 30)
    entryFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    entryFrame.BackgroundTransparency = 0.5
    entryFrame.BorderSizePixel = 0
    
    -- Create killer name
    local killerLabel = Instance.new("TextLabel")
    killerLabel.Name = "Killer"
    killerLabel.Size = UDim2.new(0, 0, 1, 0)
    killerLabel.Position = UDim2.new(0, 0, 0, 0)
    killerLabel.BackgroundTransparency = 1
    killerLabel.Text = killer
    killerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killerLabel.TextSize = 16
    killerLabel.Font = Enum.Font.GothamBold
    killerLabel.TextXAlignment = Enum.TextXAlignment.Right
    killerLabel.Parent = entryFrame
    
    -- Create weapon icon
    local weaponIcon = Instance.new("ImageLabel")
    weaponIcon.Name = "WeaponIcon"
    weaponIcon.Size = UDim2.new(0, 20, 0, 20)
    weaponIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
    weaponIcon.BackgroundTransparency = 1
    weaponIcon.Image = "rbxassetid://" .. weapon.icon
    weaponIcon.Parent = entryFrame
    
    -- Create victim name
    local victimLabel = Instance.new("TextLabel")
    victimLabel.Name = "Victim"
    victimLabel.Size = UDim2.new(0, 0, 1, 0)
    victimLabel.Position = UDim2.new(1, 0, 0, 0)
    victimLabel.BackgroundTransparency = 1
    victimLabel.Text = victim
    victimLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    victimLabel.TextSize = 16
    victimLabel.Font = Enum.Font.GothamBold
    victimLabel.TextXAlignment = Enum.TextXAlignment.Left
    victimLabel.Parent = entryFrame
    
    -- Size the labels based on text
    local killerSize = TextService:GetTextSize(killer, 16, Enum.Font.GothamBold, Vector2.new(1000, 30))
    local victimSize = TextService:GetTextSize(victim, 16, Enum.Font.GothamBold, Vector2.new(1000, 30))
    
    killerLabel.Size = UDim2.new(0, killerSize.X, 1, 0)
    killerLabel.Position = UDim2.new(0.5, -10 - victimSize.X - 20, 0, 0)
    
    victimLabel.Size = UDim2.new(0, victimSize.X, 1, 0)
    victimLabel.Position = UDim2.new(0.5, 10 + 20, 0, 0)
    
    return entryFrame
end

-- Add kill feed entry
function KillFeedUI.addKillFeedEntry(killer, victim, weapon)
    local entry = KillFeedUI.createKillFeedEntry(killer, victim, weapon)
    entry.Position = UDim2.new(0, 0, 0, 0)
    entry.Parent = killFeedList
    
    -- Move existing entries up
    for _, child in ipairs(killFeedList:GetChildren()) do
        if child ~= entry then
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(child, tweenInfo, {
                Position = UDim2.new(0, 0, 0, child.Position.Y.Offset - 40)
            })
            tween:Play()
        end
    end
    
    -- Fade out and remove entry after delay
    task.delay(5, function()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(entry, tweenInfo, {
            BackgroundTransparency = 1
        })
        tween:Play()
        
        task.delay(0.3, function()
            entry:Destroy()
        end)
    end)
end

-- Initialize
function KillFeedUI.init()
    KillFeedUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.KillFeed, function(killer, victim, weapon)
        KillFeedUI.addKillFeedEntry(killer, victim, weapon)
    end)
end

return KillFeedUI 