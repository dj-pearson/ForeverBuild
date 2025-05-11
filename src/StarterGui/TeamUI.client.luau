local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local TeamUI = {}

-- UI Elements
local screenGui
local mainFrame
local redTeamFrame
local blueTeamFrame
local redTeamList
local blueTeamList
local redTeamScore
local blueTeamScore
local redTeamButton
local blueTeamButton

-- Create UI
function TeamUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeamUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create red team frame
    redTeamFrame = Instance.new("Frame")
    redTeamFrame.Name = "RedTeamFrame"
    redTeamFrame.Size = UDim2.new(0.5, -10, 1, 0)
    redTeamFrame.Position = UDim2.new(0, 0, 0, 0)
    redTeamFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    redTeamFrame.BorderSizePixel = 0
    redTeamFrame.Parent = mainFrame
    
    -- Create blue team frame
    blueTeamFrame = Instance.new("Frame")
    blueTeamFrame.Name = "BlueTeamFrame"
    blueTeamFrame.Size = UDim2.new(0.5, -10, 1, 0)
    blueTeamFrame.Position = UDim2.new(0.5, 10, 0, 0)
    blueTeamFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 40)
    blueTeamFrame.BorderSizePixel = 0
    blueTeamFrame.Parent = mainFrame
    
    -- Create red team score
    redTeamScore = Instance.new("TextLabel")
    redTeamScore.Name = "RedTeamScore"
    redTeamScore.Size = UDim2.new(1, 0, 0, 40)
    redTeamScore.Position = UDim2.new(0, 0, 0, 0)
    redTeamScore.BackgroundTransparency = 1
    redTeamScore.Text = "Red Team: 0"
    redTeamScore.TextColor3 = Color3.fromRGB(255, 0, 0)
    redTeamScore.TextSize = 24
    redTeamScore.Font = Enum.Font.GothamBold
    redTeamScore.Parent = redTeamFrame
    
    -- Create blue team score
    blueTeamScore = Instance.new("TextLabel")
    blueTeamScore.Name = "BlueTeamScore"
    blueTeamScore.Size = UDim2.new(1, 0, 0, 40)
    blueTeamScore.Position = UDim2.new(0, 0, 0, 0)
    blueTeamScore.BackgroundTransparency = 1
    blueTeamScore.Text = "Blue Team: 0"
    blueTeamScore.TextColor3 = Color3.fromRGB(0, 0, 255)
    blueTeamScore.TextSize = 24
    blueTeamScore.Font = Enum.Font.GothamBold
    blueTeamScore.Parent = blueTeamFrame
    
    -- Create red team list
    redTeamList = Instance.new("ScrollingFrame")
    redTeamList.Name = "RedTeamList"
    redTeamList.Size = UDim2.new(1, -20, 1, -100)
    redTeamList.Position = UDim2.new(0, 10, 0, 50)
    redTeamList.BackgroundTransparency = 1
    redTeamList.BorderSizePixel = 0
    redTeamList.ScrollBarThickness = 6
    redTeamList.ScrollingDirection = Enum.ScrollingDirection.Y
    redTeamList.CanvasSize = UDim2.new(0, 0, 0, 0)
    redTeamList.Parent = redTeamFrame
    
    -- Create blue team list
    blueTeamList = Instance.new("ScrollingFrame")
    blueTeamList.Name = "BlueTeamList"
    blueTeamList.Size = UDim2.new(1, -20, 1, -100)
    blueTeamList.Position = UDim2.new(0, 10, 0, 50)
    blueTeamList.BackgroundTransparency = 1
    blueTeamList.BorderSizePixel = 0
    blueTeamList.ScrollBarThickness = 6
    blueTeamList.ScrollingDirection = Enum.ScrollingDirection.Y
    blueTeamList.CanvasSize = UDim2.new(0, 0, 0, 0)
    blueTeamList.Parent = blueTeamFrame
    
    -- Create red team button
    redTeamButton = Instance.new("TextButton")
    redTeamButton.Name = "RedTeamButton"
    redTeamButton.Size = UDim2.new(1, -20, 0, 40)
    redTeamButton.Position = UDim2.new(0, 10, 1, -50)
    redTeamButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    redTeamButton.BorderSizePixel = 0
    redTeamButton.Text = "Join Red Team"
    redTeamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    redTeamButton.TextSize = 18
    redTeamButton.Font = Enum.Font.GothamBold
    redTeamButton.Parent = redTeamFrame
    
    -- Create blue team button
    blueTeamButton = Instance.new("TextButton")
    blueTeamButton.Name = "BlueTeamButton"
    blueTeamButton.Size = UDim2.new(1, -20, 0, 40)
    blueTeamButton.Position = UDim2.new(0, 10, 1, -50)
    blueTeamButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    blueTeamButton.BorderSizePixel = 0
    blueTeamButton.Text = "Join Blue Team"
    blueTeamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    blueTeamButton.TextSize = 18
    blueTeamButton.Font = Enum.Font.GothamBold
    blueTeamButton.Parent = blueTeamFrame
end

-- Create player entry
function TeamUI.createPlayerEntry(player, team)
    local entryFrame = Instance.new("Frame")
    entryFrame.Name = player.Name
    entryFrame.Size = UDim2.new(1, 0, 0, 30)
    entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    entryFrame.BorderSizePixel = 0
    
    -- Create player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Padding.Left = UDim.new(0, 10)
    nameLabel.Parent = entryFrame
    
    -- Create player stats
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(0.3, 0, 1, 0)
    statsLabel.Position = UDim2.new(0.7, 0, 0, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "0/0"
    statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statsLabel.TextSize = 16
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextXAlignment = Enum.TextXAlignment.Right
    statsLabel.Padding.Right = UDim.new(0, 10)
    statsLabel.Parent = entryFrame
    
    -- Add to appropriate list
    if team == "Red" then
        entryFrame.Parent = redTeamList
    else
        entryFrame.Parent = blueTeamList
    end
    
    return entryFrame
end

-- Update team info
function TeamUI.updateTeamInfo(teamData)
    -- Update team scores
    redTeamScore.Text = "Red Team: " .. teamData.redScore
    blueTeamScore.Text = "Blue Team: " .. teamData.blueScore
    
    -- Clear existing entries
    for _, child in ipairs(redTeamList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    for _, child in ipairs(blueTeamList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add new entries
    for _, playerData in ipairs(teamData.redTeam) do
        local entry = TeamUI.createPlayerEntry(playerData.player, "Red")
        local statsLabel = entry:FindFirstChild("StatsLabel")
        if statsLabel then
            statsLabel.Text = playerData.kills .. "/" .. playerData.deaths
        end
    end
    
    for _, playerData in ipairs(teamData.blueTeam) do
        local entry = TeamUI.createPlayerEntry(playerData.player, "Blue")
        local statsLabel = entry:FindFirstChild("StatsLabel")
        if statsLabel then
            statsLabel.Text = playerData.kills .. "/" .. playerData.deaths
        end
    end
    
    -- Update canvas sizes
    local redHeight = 0
    for _, child in ipairs(redTeamList:GetChildren()) do
        if child:IsA("Frame") then
            redHeight = redHeight + child.Size.Y.Offset + 5
        end
    end
    redTeamList.CanvasSize = UDim2.new(0, 0, 0, redHeight)
    
    local blueHeight = 0
    for _, child in ipairs(blueTeamList:GetChildren()) do
        if child:IsA("Frame") then
            blueHeight = blueHeight + child.Size.Y.Offset + 5
        end
    end
    blueTeamList.CanvasSize = UDim2.new(0, 0, 0, blueHeight)
    
    -- Update button states
    redTeamButton.Text = teamData.currentTeam == "Red" and "Leave Team" or "Join Red Team"
    blueTeamButton.Text = teamData.currentTeam == "Blue" and "Leave Team" or "Join Blue Team"
end

-- Show team UI
function TeamUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide team UI
function TeamUI.hide()
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
function TeamUI.init()
    TeamUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.TeamUpdate, function(teamData)
        TeamUI.updateTeamInfo(teamData)
        TeamUI.show()
    end)
    
    -- Set up button events
    redTeamButton.MouseButton1Click:Connect(function()
        RemoteManager:fireServer(Constants.RemoteEvents.JoinTeam, "Red")
    end)
    
    blueTeamButton.MouseButton1Click:Connect(function()
        RemoteManager:fireServer(Constants.RemoteEvents.JoinTeam, "Blue")
    end)
end

return TeamUI 