local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local LeaderboardUI = {}

-- UI Elements
local screenGui
local mainFrame
local playerList
local closeButton

-- Create UI
function LeaderboardUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaderboardUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Leaderboard"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create player list
    playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, -20, 1, -50)
    playerList.Position = UDim2.new(0, 10, 0, 50)
    playerList.BackgroundTransparency = 1
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 6
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.Parent = mainFrame
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    closeButton.MouseButton1Click:Connect(function()
        LeaderboardUI.hide()
    end)
end

-- Create player entry
function LeaderboardUI.createPlayerEntry(player, rank, score)
    local entry = Instance.new("Frame")
    entry.Name = player.UserId
    entry.Size = UDim2.new(1, 0, 0, 50)
    entry.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    entry.BorderSizePixel = 0
    entry.Parent = playerList
    
    -- Create rank
    local rankLabel = Instance.new("TextLabel")
    rankLabel.Name = "Rank"
    rankLabel.Size = UDim2.new(0, 40, 1, 0)
    rankLabel.Position = UDim2.new(0, 0, 0, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = "#" .. rank
    rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rankLabel.TextSize = 16
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.TextXAlignment = Enum.TextXAlignment.Center
    rankLabel.Parent = entry
    
    -- Create player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.6, -50, 1, 0)
    nameLabel.Position = UDim2.new(0, 50, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = entry
    
    -- Create score
    local scoreLabel = Instance.new("TextLabel")
    scoreLabel.Name = "Score"
    scoreLabel.Size = UDim2.new(0.3, -10, 1, 0)
    scoreLabel.Position = UDim2.new(0.7, 0, 0, 0)
    scoreLabel.BackgroundTransparency = 1
    scoreLabel.Text = tostring(score)
    scoreLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    scoreLabel.TextSize = 16
    scoreLabel.Font = Enum.Font.GothamBold
    scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
    scoreLabel.Parent = entry
    
    -- Highlight current player
    if player == Players.LocalPlayer then
        entry.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
    
    return entry
end

-- Show UI
function LeaderboardUI.show()
    mainFrame.Visible = true
    
    -- Animate in
    mainFrame.Position = UDim2.new(0.35, 0, 0.4, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.35, 0, 0.2, 0),
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide UI
function LeaderboardUI.hide()
    -- Animate out
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.35, 0, 0.4, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Hide after animation
    task.delay(0.5, function()
        mainFrame.Visible = false
    end)
end

-- Update leaderboard
function LeaderboardUI.updateLeaderboard(players)
    -- Clear existing entries
    for _, child in ipairs(playerList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new entries
    local yOffset = 0
    for i, playerData in ipairs(players) do
        local entry = LeaderboardUI.createPlayerEntry(playerData.player, i, playerData.score)
        entry.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset = yOffset + 60
    end
    
    -- Update canvas size
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function LeaderboardUI.init()
    LeaderboardUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.LeaderboardUpdate, function(players)
        LeaderboardUI.updateLeaderboard(players)
    end)
    
    -- Set up keyboard shortcut
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Tab then
            if mainFrame.Visible then
                LeaderboardUI.hide()
            else
                LeaderboardUI.show()
            end
        end
    end)
end

return LeaderboardUI 