local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local TeamScoreUI = {}

-- UI Elements
local screenGui
local mainFrame
local redTeamFrame
local blueTeamFrame
local redScoreText
local blueScoreText
local redPlayersList
local bluePlayersList

-- Create UI
function TeamScoreUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeamScoreUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create red team frame
    redTeamFrame = Instance.new("Frame")
    redTeamFrame.Name = "RedTeamFrame"
    redTeamFrame.Size = UDim2.new(0.5, -10, 1, -20)
    redTeamFrame.Position = UDim2.new(0, 10, 0, 10)
    redTeamFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    redTeamFrame.BackgroundTransparency = 0.8
    redTeamFrame.BorderSizePixel = 0
    redTeamFrame.Parent = mainFrame
    
    -- Create red team score
    redScoreText = Instance.new("TextLabel")
    redScoreText.Name = "RedScoreText"
    redScoreText.Size = UDim2.new(1, 0, 0, 40)
    redScoreText.Position = UDim2.new(0, 0, 0, 0)
    redScoreText.BackgroundTransparency = 1
    redScoreText.Text = "Red Team: 0"
    redScoreText.TextColor3 = Color3.fromRGB(255, 255, 255)
    redScoreText.TextSize = 24
    redScoreText.Font = Enum.Font.GothamBold
    redScoreText.Parent = redTeamFrame
    
    -- Create red team players list
    redPlayersList = Instance.new("ScrollingFrame")
    redPlayersList.Name = "RedPlayersList"
    redPlayersList.Size = UDim2.new(1, 0, 1, -50)
    redPlayersList.Position = UDim2.new(0, 0, 0, 50)
    redPlayersList.BackgroundTransparency = 1
    redPlayersList.BorderSizePixel = 0
    redPlayersList.ScrollBarThickness = 4
    redPlayersList.CanvasSize = UDim2.new(0, 0, 0, 0)
    redPlayersList.Parent = redTeamFrame
    
    -- Create blue team frame
    blueTeamFrame = Instance.new("Frame")
    blueTeamFrame.Name = "BlueTeamFrame"
    blueTeamFrame.Size = UDim2.new(0.5, -10, 1, -20)
    blueTeamFrame.Position = UDim2.new(0.5, 5, 0, 10)
    blueTeamFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    blueTeamFrame.BackgroundTransparency = 0.8
    blueTeamFrame.BorderSizePixel = 0
    blueTeamFrame.Parent = mainFrame
    
    -- Create blue team score
    blueScoreText = Instance.new("TextLabel")
    blueScoreText.Name = "BlueScoreText"
    blueScoreText.Size = UDim2.new(1, 0, 0, 40)
    blueScoreText.Position = UDim2.new(0, 0, 0, 0)
    blueScoreText.BackgroundTransparency = 1
    blueScoreText.Text = "Blue Team: 0"
    blueScoreText.TextColor3 = Color3.fromRGB(255, 255, 255)
    blueScoreText.TextSize = 24
    blueScoreText.Font = Enum.Font.GothamBold
    blueScoreText.Parent = blueTeamFrame
    
    -- Create blue team players list
    bluePlayersList = Instance.new("ScrollingFrame")
    bluePlayersList.Name = "BluePlayersList"
    bluePlayersList.Size = UDim2.new(1, 0, 1, -50)
    bluePlayersList.Position = UDim2.new(0, 0, 0, 50)
    bluePlayersList.BackgroundTransparency = 1
    bluePlayersList.BorderSizePixel = 0
    bluePlayersList.ScrollBarThickness = 4
    bluePlayersList.CanvasSize = UDim2.new(0, 0, 0, 0)
    bluePlayersList.Parent = blueTeamFrame
end

-- Create player entry
function TeamScoreUI.createPlayerEntry(playerData, parent)
    local entry = Instance.new("Frame")
    entry.Name = playerData.name
    entry.Size = UDim2.new(1, -20, 0, 30)
    entry.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 30)
    entry.BackgroundTransparency = 1
    entry.Parent = parent
    
    -- Create player name
    local nameText = Instance.new("TextLabel")
    nameText.Name = "NameText"
    nameText.Size = UDim2.new(0.6, 0, 1, 0)
    nameText.Position = UDim2.new(0, 0, 0, 0)
    nameText.BackgroundTransparency = 1
    nameText.Text = playerData.name
    nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameText.TextSize = 16
    nameText.Font = Enum.Font.Gotham
    nameText.TextXAlignment = Enum.TextXAlignment.Left
    nameText.Parent = entry
    
    -- Create player stats
    local statsText = Instance.new("TextLabel")
    statsText.Name = "StatsText"
    statsText.Size = UDim2.new(0.4, 0, 1, 0)
    statsText.Position = UDim2.new(0.6, 0, 0, 0)
    statsText.BackgroundTransparency = 1
    statsText.Text = playerData.kills .. "/" .. playerData.deaths
    statsText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsText.TextSize = 16
    statsText.Font = Enum.Font.Gotham
    statsText.TextXAlignment = Enum.TextXAlignment.Right
    statsText.Parent = entry
    
    return entry
end

-- Update team scores
function TeamScoreUI.updateScores(redScore, blueScore)
    redScoreText.Text = "Red Team: " .. tostring(redScore)
    blueScoreText.Text = "Blue Team: " .. tostring(blueScore)
end

-- Update team players
function TeamScoreUI.updatePlayers(redPlayers, bluePlayers)
    -- Clear existing entries
    for _, child in ipairs(redPlayersList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    for _, child in ipairs(bluePlayersList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create new entries
    for _, playerData in ipairs(redPlayers) do
        TeamScoreUI.createPlayerEntry(playerData, redPlayersList)
    end
    
    for _, playerData in ipairs(bluePlayers) do
        TeamScoreUI.createPlayerEntry(playerData, bluePlayersList)
    end
    
    -- Update canvas sizes
    redPlayersList.CanvasSize = UDim2.new(0, 0, 0, #redPlayers * 30)
    bluePlayersList.CanvasSize = UDim2.new(0, 0, 0, #bluePlayers * 30)
end

-- Show team score UI
function TeamScoreUI.show()
    mainFrame.Visible = true
end

-- Hide team score UI
function TeamScoreUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function TeamScoreUI.init()
    TeamScoreUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.TeamScoresUpdate, function(redScore, blueScore)
        TeamScoreUI.updateScores(redScore, blueScore)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.TeamPlayersUpdate, function(redPlayers, bluePlayers)
        TeamScoreUI.updatePlayers(redPlayers, bluePlayers)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.TeamScoreUIVisibilityUpdate, function(visible)
        if visible then
            TeamScoreUI.show()
        else
            TeamScoreUI.hide()
        end
    end)
end

return TeamScoreUI 