local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local AchievementUI = {}

-- Local state
local screenGui
local mainFrame
local achievementList
local notificationFrame

-- Create UI
function AchievementUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AchievementUI"
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
    title.Text = "Achievements"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create achievement list
    achievementList = Instance.new("ScrollingFrame")
    achievementList.Name = "AchievementList"
    achievementList.Size = UDim2.new(1, -20, 1, -70)
    achievementList.Position = UDim2.new(0, 10, 0, 60)
    achievementList.BackgroundTransparency = 1
    achievementList.BorderSizePixel = 0
    achievementList.ScrollBarThickness = 6
    achievementList.Parent = mainFrame
    
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
        AchievementUI.hide()
    end)
    
    -- Create notification frame
    notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, 10, 0, 10)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Visible = false
    notificationFrame.Parent = screenGui
    
    -- Create notification title
    local notificationTitle = Instance.new("TextLabel")
    notificationTitle.Name = "Title"
    notificationTitle.Size = UDim2.new(1, 0, 0, 30)
    notificationTitle.Position = UDim2.new(0, 0, 0, 0)
    notificationTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notificationTitle.BorderSizePixel = 0
    notificationTitle.Text = "Achievement Unlocked!"
    notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationTitle.TextSize = 18
    notificationTitle.Font = Enum.Font.GothamBold
    notificationTitle.Parent = notificationFrame
    
    -- Create notification content
    local notificationContent = Instance.new("TextLabel")
    notificationContent.Name = "Content"
    notificationContent.Size = UDim2.new(1, -20, 1, -40)
    notificationContent.Position = UDim2.new(0, 10, 0, 35)
    notificationContent.BackgroundTransparency = 1
    notificationContent.Text = ""
    notificationContent.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationContent.TextSize = 16
    notificationContent.Font = Enum.Font.Gotham
    notificationContent.TextWrapped = true
    notificationContent.Parent = notificationFrame
end

-- Update achievement list
function AchievementUI.updateAchievements()
    -- Clear existing entries
    for _, child in ipairs(achievementList:GetChildren()) do
        child:Destroy()
    end
    
    -- Get achievement data
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local getAchievementsEvent = remotes:WaitForChild("GetAchievements")
    local achievements = getAchievementsEvent:InvokeServer()
    
    -- Create entries
    for i, achievement in ipairs(achievements) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = "Entry" .. i
        entryFrame.Size = UDim2.new(1, 0, 0, 80)
        entryFrame.Position = UDim2.new(0, 0, 0, (i-1) * 85)
        entryFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(45, 45, 45)
        entryFrame.BorderSizePixel = 0
        entryFrame.Parent = achievementList
        
        -- Icon
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 60, 0, 60)
        icon.Position = UDim2.new(0, 10, 0.5, -30)
        icon.BackgroundTransparency = 1
        icon.Image = achievement.icon
        icon.Parent = entryFrame
        
        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(0.7, -80, 0, 30)
        nameLabel.Position = UDim2.new(0, 80, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = achievement.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 18
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = entryFrame
        
        -- Description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(0.7, -80, 0, 30)
        descLabel.Position = UDim2.new(0, 80, 0, 35)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = achievement.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextSize = 14
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = entryFrame
        
        -- Reward
        local rewardLabel = Instance.new("TextLabel")
        rewardLabel.Name = "Reward"
        rewardLabel.Size = UDim2.new(0.2, 0, 0, 30)
        rewardLabel.Position = UDim2.new(0.8, 0, 0.5, -15)
        rewardLabel.BackgroundTransparency = 1
        rewardLabel.Text = "+" .. achievement.reward .. " coins"
        rewardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        rewardLabel.TextSize = 16
        rewardLabel.Font = Enum.Font.GothamBold
        rewardLabel.Parent = entryFrame
    end
end

-- Show achievement notification
function AchievementUI.showNotification(achievement)
    local content = notificationFrame:FindFirstChild("Content")
    if content then
        content.Text = achievement.name .. "\n" .. achievement.description .. "\nReward: " .. achievement.reward .. " coins"
    end
    
    notificationFrame.Visible = true
    
    -- Animate in
    notificationFrame.Position = UDim2.new(1, 10, 0, 10)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(notificationFrame, tweenInfo, {
        Position = UDim2.new(1, -310, 0, 10)
    })
    tween:Play()
    
    -- Hide after delay
    task.delay(5, function()
        local hideTween = game:GetService("TweenService"):Create(notificationFrame, tweenInfo, {
            Position = UDim2.new(1, 10, 0, 10)
        })
        hideTween:Play()
        hideTween.Completed:Connect(function()
            notificationFrame.Visible = false
        end)
    end)
end

-- Show UI
function AchievementUI.show()
    mainFrame.Visible = true
    AchievementUI.updateAchievements()
end

-- Hide UI
function AchievementUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function AchievementUI.init()
    AchievementUI.create()
    
    -- Set up event handlers
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local unlockEvent = remotes:WaitForChild("UnlockAchievement")
    
    unlockEvent.OnClientEvent:Connect(function(achievement)
        AchievementUI.showNotification(achievement)
        AchievementUI.updateAchievements()
    end)
end

return AchievementUI 