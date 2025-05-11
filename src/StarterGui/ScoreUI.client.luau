local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local ScoreUI = {}

-- UI Elements
local screenGui
local mainFrame
local scoreText
local killsText
local deathsText
local kdText

-- Create UI
function ScoreUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScoreUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(1, -220, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create score text
    scoreText = Instance.new("TextLabel")
    scoreText.Name = "ScoreText"
    scoreText.Size = UDim2.new(1, -20, 0, 30)
    scoreText.Position = UDim2.new(0, 10, 0, 10)
    scoreText.BackgroundTransparency = 1
    scoreText.Text = "Score: 0"
    scoreText.TextColor3 = Color3.fromRGB(255, 255, 255)
    scoreText.TextSize = 20
    scoreText.Font = Enum.Font.GothamBold
    scoreText.TextXAlignment = Enum.TextXAlignment.Left
    scoreText.Parent = mainFrame
    
    -- Create kills text
    killsText = Instance.new("TextLabel")
    killsText.Name = "KillsText"
    killsText.Size = UDim2.new(0.5, -15, 0, 20)
    killsText.Position = UDim2.new(0, 10, 0, 40)
    killsText.BackgroundTransparency = 1
    killsText.Text = "Kills: 0"
    killsText.TextColor3 = Color3.fromRGB(0, 255, 0)
    killsText.TextSize = 16
    killsText.Font = Enum.Font.Gotham
    killsText.TextXAlignment = Enum.TextXAlignment.Left
    killsText.Parent = mainFrame
    
    -- Create deaths text
    deathsText = Instance.new("TextLabel")
    deathsText.Name = "DeathsText"
    deathsText.Size = UDim2.new(0.5, -15, 0, 20)
    deathsText.Position = UDim2.new(0.5, 5, 0, 40)
    deathsText.BackgroundTransparency = 1
    deathsText.Text = "Deaths: 0"
    deathsText.TextColor3 = Color3.fromRGB(255, 0, 0)
    deathsText.TextSize = 16
    deathsText.Font = Enum.Font.Gotham
    deathsText.TextXAlignment = Enum.TextXAlignment.Left
    deathsText.Parent = mainFrame
    
    -- Create K/D text
    kdText = Instance.new("TextLabel")
    kdText.Name = "KDText"
    kdText.Size = UDim2.new(1, -20, 0, 20)
    kdText.Position = UDim2.new(0, 10, 0, 60)
    kdText.BackgroundTransparency = 1
    kdText.Text = "K/D: 0.00"
    kdText.TextColor3 = Color3.fromRGB(255, 255, 255)
    kdText.TextSize = 16
    kdText.Font = Enum.Font.Gotham
    kdText.TextXAlignment = Enum.TextXAlignment.Left
    kdText.Parent = mainFrame
end

-- Update score
function ScoreUI.updateScore(score)
    scoreText.Text = "Score: " .. tostring(score)
end

-- Update kills
function ScoreUI.updateKills(kills)
    killsText.Text = "Kills: " .. tostring(kills)
    ScoreUI.updateKD(kills, tonumber(string.match(deathsText.Text, "%d+")))
end

-- Update deaths
function ScoreUI.updateDeaths(deaths)
    deathsText.Text = "Deaths: " .. tostring(deaths)
    ScoreUI.updateKD(tonumber(string.match(killsText.Text, "%d+")), deaths)
end

-- Update K/D
function ScoreUI.updateKD(kills, deaths)
    local kd = deaths > 0 and kills / deaths or kills
    kdText.Text = "K/D: " .. string.format("%.2f", kd)
end

-- Show score UI
function ScoreUI.show()
    mainFrame.Visible = true
end

-- Hide score UI
function ScoreUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function ScoreUI.init()
    ScoreUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ScoreUpdate, function(score)
        ScoreUI.updateScore(score)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.KillsUpdate, function(kills)
        ScoreUI.updateKills(kills)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.DeathsUpdate, function(deaths)
        ScoreUI.updateDeaths(deaths)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.ScoreUIVisibilityUpdate, function(visible)
        if visible then
            ScoreUI.show()
        else
            ScoreUI.hide()
        end
    end)
end

return ScoreUI 