local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local RoundUI = {}

-- UI Elements
local screenGui
local mainFrame
local roundText
local timeText
local teamScores
local redScore
local blueScore
local roundStatus

-- Create UI
function RoundUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RoundUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 100)
    mainFrame.Position = UDim2.new(0.5, -200, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create round text
    roundText = Instance.new("TextLabel")
    roundText.Name = "RoundText"
    roundText.Size = UDim2.new(1, 0, 0, 30)
    roundText.Position = UDim2.new(0, 0, 0, 0)
    roundText.BackgroundTransparency = 1
    roundText.Text = "Round 1"
    roundText.TextColor3 = Color3.fromRGB(255, 255, 255)
    roundText.TextSize = 24
    roundText.Font = Enum.Font.GothamBold
    roundText.Parent = mainFrame
    
    -- Create time text
    timeText = Instance.new("TextLabel")
    timeText.Name = "TimeText"
    timeText.Size = UDim2.new(1, 0, 0, 30)
    timeText.Position = UDim2.new(0, 0, 0, 30)
    timeText.BackgroundTransparency = 1
    timeText.Text = "2:00"
    timeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeText.TextSize = 20
    timeText.Font = Enum.Font.GothamBold
    timeText.Parent = mainFrame
    
    -- Create team scores
    teamScores = Instance.new("Frame")
    teamScores.Name = "TeamScores"
    teamScores.Size = UDim2.new(1, 0, 0, 40)
    teamScores.Position = UDim2.new(0, 0, 0, 60)
    teamScores.BackgroundTransparency = 1
    teamScores.Parent = mainFrame
    
    -- Create red score
    redScore = Instance.new("TextLabel")
    redScore.Name = "RedScore"
    redScore.Size = UDim2.new(0.5, 0, 1, 0)
    redScore.Position = UDim2.new(0, 0, 0, 0)
    redScore.BackgroundTransparency = 1
    redScore.Text = "Red: 0"
    redScore.TextColor3 = Color3.fromRGB(255, 0, 0)
    redScore.TextSize = 18
    redScore.Font = Enum.Font.GothamBold
    redScore.Parent = teamScores
    
    -- Create blue score
    blueScore = Instance.new("TextLabel")
    blueScore.Name = "BlueScore"
    blueScore.Size = UDim2.new(0.5, 0, 1, 0)
    blueScore.Position = UDim2.new(0.5, 0, 0, 0)
    blueScore.BackgroundTransparency = 1
    blueScore.Text = "Blue: 0"
    blueScore.TextColor3 = Color3.fromRGB(0, 0, 255)
    blueScore.TextSize = 18
    blueScore.Font = Enum.Font.GothamBold
    blueScore.Parent = teamScores
    
    -- Create round status
    roundStatus = Instance.new("TextLabel")
    roundStatus.Name = "RoundStatus"
    roundStatus.Size = UDim2.new(1, 0, 0, 30)
    roundStatus.Position = UDim2.new(0, 0, 0, 100)
    roundStatus.BackgroundTransparency = 1
    roundStatus.Text = ""
    roundStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    roundStatus.TextSize = 20
    roundStatus.Font = Enum.Font.GothamBold
    roundStatus.Parent = mainFrame
end

-- Update round info
function RoundUI.updateRoundInfo(roundData)
    -- Update round text
    roundText.Text = "Round " .. roundData.round
    
    -- Update time text
    local minutes = math.floor(roundData.time / 60)
    local seconds = roundData.time % 60
    timeText.Text = string.format("%d:%02d", minutes, seconds)
    
    -- Update team scores
    redScore.Text = "Red: " .. roundData.redScore
    blueScore.Text = "Blue: " .. roundData.blueScore
    
    -- Update round status
    if roundData.status == "waiting" then
        roundStatus.Text = "Waiting for players..."
        roundStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif roundData.status == "in_progress" then
        roundStatus.Text = "Round in progress"
        roundStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    elseif roundData.status == "ended" then
        roundStatus.Text = roundData.winner .. " team wins!"
        roundStatus.TextColor3 = roundData.winner == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
    end
    
    -- Animate time text if low time
    if roundData.time <= 30 then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(timeText, tweenInfo, {
            TextColor3 = Color3.fromRGB(255, 0, 0)
        })
        tween:Play()
    else
        timeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Show round UI
function RoundUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide round UI
function RoundUI.hide()
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
function RoundUI.init()
    RoundUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.RoundUpdate, function(roundData)
        RoundUI.updateRoundInfo(roundData)
        RoundUI.show()
    end)
end

return RoundUI 