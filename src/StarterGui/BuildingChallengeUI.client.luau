local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local BuildingChallengeManager = require(ReplicatedStorage.Shared.Modules.Building.BuildingChallengeManager)

-- Special rewards
local SPECIAL_REWARDS = {
    {
        name = "Master Builder",
        description = "Win 10 challenges",
        reward = 5000
    },
    {
        name = "Community Favorite",
        description = "Get 100 total votes",
        reward = 3000
    },
    {
        name = "Theme Expert",
        description = "Win challenges in 5 different categories",
        reward = 4000
    }
}

local BuildingChallengeUI = {}

-- UI Elements
local screenGui
local mainFrame
local challengeList
local closeButton

-- Remote events
local getChallengesEvent = ReplicatedStorage.Remotes.GetChallenges
local submitChallengeEvent = ReplicatedStorage.Remotes.SubmitChallenge
local voteChallengeEvent = ReplicatedStorage.Remotes.VoteChallenge
local getSubmissionsEvent = ReplicatedStorage.Remotes.GetSubmissions
local getVotesEvent = ReplicatedStorage.Remotes.GetVotes

-- Create UI
function BuildingChallengeUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildingChallengeUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
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
    title.Text = "Building Challenges"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create challenge list
    challengeList = Instance.new("ScrollingFrame")
    challengeList.Name = "ChallengeList"
    challengeList.Size = UDim2.new(1, -20, 1, -50)
    challengeList.Position = UDim2.new(0, 10, 0, 50)
    challengeList.BackgroundTransparency = 1
    challengeList.BorderSizePixel = 0
    challengeList.ScrollBarThickness = 6
    challengeList.CanvasSize = UDim2.new(0, 0, 0, 0)
    challengeList.Parent = mainFrame
    
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
        BuildingChallengeUI.hide()
    end)
end

-- Show UI
function BuildingChallengeUI.show()
    mainFrame.Visible = true
end

-- Hide UI
function BuildingChallengeUI.hide()
    mainFrame.Visible = false
end

-- Update challenge list
function BuildingChallengeUI.updateChallenges(challenges)
    -- Clear existing challenges
    for _, child in ipairs(challengeList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new challenges
    local yOffset = 0
    for _, challenge in ipairs(challenges) do
        local challengeButton = Instance.new("TextButton")
        challengeButton.Name = challenge.id
        challengeButton.Size = UDim2.new(1, 0, 0, 100)
        challengeButton.Position = UDim2.new(0, 0, 0, yOffset)
        challengeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        challengeButton.BorderSizePixel = 0
        challengeButton.Text = challenge.name
        challengeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        challengeButton.TextSize = 16
        challengeButton.Font = Enum.Font.GothamBold
        challengeButton.Parent = challengeList
        
        -- Challenge description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -20, 0, 40)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = challenge.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = challengeButton
        
        -- Challenge status
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "Status"
        statusLabel.Size = UDim2.new(0, 100, 0, 20)
        statusLabel.Position = UDim2.new(1, -110, 0, 5)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = challenge.completed and "Completed!" or "In Progress"
        statusLabel.TextColor3 = challenge.completed and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = challengeButton
        
        -- Challenge button click handler
        challengeButton.MouseButton1Click:Connect(function()
            RemoteManager:fireServer(Constants.RemoteEvents.StartChallenge, challenge.id)
        end)
        
        yOffset = yOffset + 110
    end
    
    -- Update canvas size
    challengeList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function BuildingChallengeUI.init()
    BuildingChallengeUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ChallengeUpdate, function(challenges)
        BuildingChallengeUI.updateChallenges(challenges)
    end)
end

return BuildingChallengeUI 