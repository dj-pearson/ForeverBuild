local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local ScoreboardUI = {}

-- UI Elements
local screenGui
local mainFrame
local playerList
local headerFrame

-- Create UI
function ScoreboardUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScoreboardUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create header frame
    headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    -- Create header text
    local headerText = Instance.new("TextLabel")
    headerText.Name = "HeaderText"
    headerText.Size = UDim2.new(1, 0, 1, 0)
    headerText.Position = UDim2.new(0, 0, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "SCOREBOARD"
    headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerText.TextSize = 20
    headerText.Font = Enum.Font.GothamBold
    headerText.Parent = headerFrame
    
    -- Create player list
    playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, 0, 1, -40)
    playerList.Position = UDim2.new(0, 0, 0, 40)
    playerList.BackgroundTransparency = 1
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 6
    playerList.ScrollingDirection = Enum.ScrollingDirection.Y
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.Parent = mainFrame
    
    -- Create list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = playerList
end

-- Create player row
function ScoreboardUI.createPlayerRow(player, stats)
    local rowFrame = Instance.new("Frame")
    rowFrame.Name = player.Name
    rowFrame.Size = UDim2.new(1, 0, 0, 40)
    rowFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    rowFrame.BorderSizePixel = 0
    rowFrame.Parent = playerList
    
    -- Create player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Padding.Left = UDim.new(0, 10)
    nameLabel.Parent = rowFrame
    
    -- Create kills
    local killsLabel = Instance.new("TextLabel")
    killsLabel.Name = "KillsLabel"
    killsLabel.Size = UDim2.new(0.2, 0, 1, 0)
    killsLabel.Position = UDim2.new(0.3, 0, 0, 0)
    killsLabel.BackgroundTransparency = 1
    killsLabel.Text = tostring(stats.kills)
    killsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killsLabel.TextSize = 14
    killsLabel.Font = Enum.Font.GothamBold
    killsLabel.Parent = rowFrame
    
    -- Create deaths
    local deathsLabel = Instance.new("TextLabel")
    deathsLabel.Name = "DeathsLabel"
    deathsLabel.Size = UDim2.new(0.2, 0, 1, 0)
    deathsLabel.Position = UDim2.new(0.5, 0, 0, 0)
    deathsLabel.BackgroundTransparency = 1
    deathsLabel.Text = tostring(stats.deaths)
    deathsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    deathsLabel.TextSize = 14
    deathsLabel.Font = Enum.Font.GothamBold
    deathsLabel.Parent = rowFrame
    
    -- Create K/D ratio
    local kdLabel = Instance.new("TextLabel")
    kdLabel.Name = "KDLabel"
    kdLabel.Size = UDim2.new(0.3, 0, 1, 0)
    kdLabel.Position = UDim2.new(0.7, 0, 0, 0)
    kdLabel.BackgroundTransparency = 1
    kdLabel.Text = string.format("%.2f", stats.kills / math.max(1, stats.deaths))
    kdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    kdLabel.TextSize = 14
    kdLabel.Font = Enum.Font.GothamBold
    kdLabel.Parent = rowFrame
    
    return rowFrame
end

-- Update scoreboard
function ScoreboardUI.updateScoreboard(playerStats)
    -- Clear existing rows
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create new rows
    for player, stats in pairs(playerStats) do
        local rowFrame = ScoreboardUI.createPlayerRow(player, stats)
        rowFrame.Parent = playerList
    end
    
    -- Update canvas size
    local totalHeight = 0
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset + 2
        end
    end
    playerList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

-- Show scoreboard
function ScoreboardUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide scoreboard
function ScoreboardUI.hide()
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
function ScoreboardUI.init()
    ScoreboardUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ScoreboardUpdate, function(playerStats)
        ScoreboardUI.updateScoreboard(playerStats)
    end)
    
    -- Set up input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Tab then
            ScoreboardUI.show()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Tab then
            ScoreboardUI.hide()
        end
    end)
end

return ScoreboardUI 