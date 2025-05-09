local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local LeaderboardUI = {}

-- Local state
local screenGui
local mainFrame
local categoryButtons = {}
local leaderboardList
local currentCategory = "coins"

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
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Leaderboard"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create category buttons container
    local categoryContainer = Instance.new("Frame")
    categoryContainer.Name = "CategoryContainer"
    categoryContainer.Size = UDim2.new(1, 0, 0, 40)
    categoryContainer.Position = UDim2.new(0, 0, 0, 60)
    categoryContainer.BackgroundTransparency = 1
    categoryContainer.Parent = mainFrame
    
    -- Create category buttons
    local categories = {
        {id = "coins", name = "Coins"},
        {id = "objects_placed", name = "Objects Placed"},
        {id = "daily_streak", name = "Daily Streak"},
        {id = "total_purchases", name = "Total Purchases"}
    }
    
    for i, category in ipairs(categories) do
        local button = Instance.new("TextButton")
        button.Name = category.id
        button.Size = UDim2.new(0.25, -10, 1, 0)
        button.Position = UDim2.new((i-1) * 0.25, 5, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.BorderSizePixel = 0
        button.Text = category.name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 16
        button.Font = Enum.Font.Gotham
        button.Parent = categoryContainer
        
        button.MouseButton1Click:Connect(function()
            LeaderboardUI.setCategory(category.id)
        end)
        
        categoryButtons[category.id] = button
    end
    
    -- Create leaderboard list
    leaderboardList = Instance.new("ScrollingFrame")
    leaderboardList.Name = "LeaderboardList"
    leaderboardList.Size = UDim2.new(1, -20, 1, -120)
    leaderboardList.Position = UDim2.new(0, 10, 0, 110)
    leaderboardList.BackgroundTransparency = 1
    leaderboardList.BorderSizePixel = 0
    leaderboardList.ScrollBarThickness = 6
    leaderboardList.Parent = mainFrame
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        LeaderboardUI.hide()
    end)
end

-- Set category
function LeaderboardUI.setCategory(category)
    currentCategory = category
    
    -- Update button colors
    for id, button in pairs(categoryButtons) do
        button.BackgroundColor3 = id == category and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(60, 60, 60)
    end
    
    -- Update leaderboard
    LeaderboardUI.updateLeaderboard()
end

-- Update leaderboard
function LeaderboardUI.updateLeaderboard()
    -- Clear existing entries
    for _, child in ipairs(leaderboardList:GetChildren()) do
        child:Destroy()
    end
    
    -- Get leaderboard data
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local getLeaderboardEvent = remotes:WaitForChild("GetLeaderboard")
    local leaderboard = getLeaderboardEvent:InvokeServer(currentCategory)
    
    -- Create entries
    for i, entry in ipairs(leaderboard) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = "Entry" .. i
        entryFrame.Size = UDim2.new(1, 0, 0, 40)
        entryFrame.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        entryFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(45, 45, 45)
        entryFrame.BorderSizePixel = 0
        entryFrame.Parent = leaderboardList
        
        -- Rank
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Name = "Rank"
        rankLabel.Size = UDim2.new(0, 50, 1, 0)
        rankLabel.Position = UDim2.new(0, 0, 0, 0)
        rankLabel.BackgroundTransparency = 1
        rankLabel.Text = "#" .. i
        rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        rankLabel.TextSize = 18
        rankLabel.Font = Enum.Font.GothamBold
        rankLabel.Parent = entryFrame
        
        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 60, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = entry.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 18
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = entryFrame
        
        -- Score
        local scoreLabel = Instance.new("TextLabel")
        scoreLabel.Name = "Score"
        scoreLabel.Size = UDim2.new(0.3, 0, 1, 0)
        scoreLabel.Position = UDim2.new(0.7, 0, 0, 0)
        scoreLabel.BackgroundTransparency = 1
        scoreLabel.Text = tostring(entry.score)
        scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        scoreLabel.TextSize = 18
        scoreLabel.Font = Enum.Font.GothamBold
        scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
        scoreLabel.Parent = entryFrame
    end
end

-- Show UI
function LeaderboardUI.show()
    mainFrame.Visible = true
    LeaderboardUI.updateLeaderboard()
end

-- Hide UI
function LeaderboardUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function LeaderboardUI.init()
    LeaderboardUI.create()
    
    -- Set up event handlers
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local updateEvent = remotes:WaitForChild("UpdateLeaderboard")
    
    updateEvent.OnClientEvent:Connect(function(category, leaderboard)
        if category == currentCategory then
            LeaderboardUI.updateLeaderboard()
        end
    end)
end

return LeaderboardUI 