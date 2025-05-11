local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local AchievementUI = {}

-- Local variables
local screenGui
local mainFrame
local notificationFrame
local currentCategory = "All"

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getAchievementsEvent = remotes:WaitForChild("GetAchievements")
local checkAchievementEvent = remotes:WaitForChild("CheckAchievement")

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
    mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
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
    
    -- Create category buttons
    local categories = Instance.new("Frame")
    categories.Name = "Categories"
    categories.Size = UDim2.new(1, 0, 0.1, 0)
    categories.Position = UDim2.new(0, 0, 0.1, 0)
    categories.BackgroundTransparency = 1
    categories.Parent = mainFrame
    
    -- All category button
    local allButton = Instance.new("TextButton")
    allButton.Name = "AllButton"
    allButton.Size = UDim2.new(0.25, 0, 1, 0)
    allButton.Position = UDim2.new(0, 0, 0, 0)
    allButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    allButton.BorderSizePixel = 0
    allButton.Text = "All"
    allButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    allButton.TextScaled = true
    allButton.Font = Enum.Font.GothamBold
    allButton.Parent = categories
    
    -- Building category button
    local buildingButton = Instance.new("TextButton")
    buildingButton.Name = "BuildingButton"
    buildingButton.Size = UDim2.new(0.25, 0, 1, 0)
    buildingButton.Position = UDim2.new(0.25, 0, 0, 0)
    buildingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    buildingButton.BorderSizePixel = 0
    buildingButton.Text = "Building"
    buildingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildingButton.TextScaled = true
    buildingButton.Font = Enum.Font.GothamBold
    buildingButton.Parent = categories
    
    -- Collection category button
    local collectionButton = Instance.new("TextButton")
    collectionButton.Name = "CollectionButton"
    collectionButton.Size = UDim2.new(0.25, 0, 1, 0)
    collectionButton.Position = UDim2.new(0.5, 0, 0, 0)
    collectionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    collectionButton.BorderSizePixel = 0
    collectionButton.Text = "Collection"
    collectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    collectionButton.TextScaled = true
    collectionButton.Font = Enum.Font.GothamBold
    collectionButton.Parent = categories
    
    -- Social category button
    local socialButton = Instance.new("TextButton")
    socialButton.Name = "SocialButton"
    socialButton.Size = UDim2.new(0.25, 0, 1, 0)
    socialButton.Position = UDim2.new(0.75, 0, 0, 0)
    socialButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    socialButton.BorderSizePixel = 0
    socialButton.Text = "Social"
    socialButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    socialButton.TextScaled = true
    socialButton.Font = Enum.Font.GothamBold
    socialButton.Parent = categories
    
    -- Create achievements list
    local achievementsList = Instance.new("ScrollingFrame")
    achievementsList.Name = "AchievementsList"
    achievementsList.Size = UDim2.new(1, -20, 1, -70)
    achievementsList.Position = UDim2.new(0, 10, 0, 60)
    achievementsList.BackgroundTransparency = 1
    achievementsList.BorderSizePixel = 0
    achievementsList.ScrollBarThickness = 6
    achievementsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    achievementsList.Parent = mainFrame
    
    -- Create notification frame
    notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0.3, 0, 0.15, 0)
    notificationFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Visible = false
    notificationFrame.Parent = screenGui
    
    -- Notification title
    local notificationTitle = Instance.new("TextLabel")
    notificationTitle.Name = "Title"
    notificationTitle.Size = UDim2.new(1, 0, 0.3, 0)
    notificationTitle.Position = UDim2.new(0, 0, 0, 0)
    notificationTitle.BackgroundTransparency = 1
    notificationTitle.Text = "Achievement Unlocked!"
    notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationTitle.TextScaled = true
    notificationTitle.Font = Enum.Font.GothamBold
    notificationTitle.Parent = notificationFrame
    
    -- Notification achievement name
    local notificationName = Instance.new("TextLabel")
    notificationName.Name = "Name"
    notificationName.Size = UDim2.new(1, 0, 0.3, 0)
    notificationName.Position = UDim2.new(0, 0, 0.3, 0)
    notificationName.BackgroundTransparency = 1
    notificationName.Text = ""
    notificationName.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationName.TextScaled = true
    notificationName.Font = Enum.Font.GothamBold
    notificationName.Parent = notificationFrame
    
    -- Notification reward
    local notificationReward = Instance.new("TextLabel")
    notificationReward.Name = "Reward"
    notificationReward.Size = UDim2.new(1, 0, 0.3, 0)
    notificationReward.Position = UDim2.new(0, 0, 0.6, 0)
    notificationReward.BackgroundTransparency = 1
    notificationReward.Text = ""
    notificationReward.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationReward.TextScaled = true
    notificationReward.Font = Enum.Font.GothamBold
    notificationReward.Parent = notificationFrame
    
    -- Set up event handlers
    allButton.MouseButton1Click:Connect(function()
        AchievementUI.switchCategory("All")
    end)
    
    buildingButton.MouseButton1Click:Connect(function()
        AchievementUI.switchCategory("Building")
    end)
    
    collectionButton.MouseButton1Click:Connect(function()
        AchievementUI.switchCategory("Collection")
    end)
    
    socialButton.MouseButton1Click:Connect(function()
        AchievementUI.switchCategory("Social")
    end)
    
    -- Set up keyboard shortcut
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.A then
            AchievementUI.toggle()
        end
    end)
end

-- Switch between categories
function AchievementUI.switchCategory(category)
    currentCategory = category
    
    -- Update button colors
    for _, button in ipairs(mainFrame.Categories:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = (button.Name:match(category) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(60, 60, 60))
        end
    end
    
    -- Refresh achievements list
    AchievementUI.refreshAchievements()
end

-- Refresh achievements display
function AchievementUI.refreshAchievements()
    local success, data = getAchievementsEvent:InvokeServer()
    if not success then return end
    
    -- Clear existing achievements
    local achievementsList = mainFrame.AchievementsList
    for _, child in ipairs(achievementsList:GetChildren()) do
        child:Destroy()
    end
    
    -- Create achievement buttons
    local yOffset = 0
    for _, achievement in ipairs(data) do
        -- Skip if not in current category
        if currentCategory ~= "All" and achievement.category ~= currentCategory then
            continue
        end
        
        -- Create achievement button
        local achievementButton = Instance.new("TextButton")
        achievementButton.Name = achievement.id
        achievementButton.Size = UDim2.new(0.9, 0, 0.15, 0)
        achievementButton.Position = UDim2.new(0.05, 0, 0, yOffset)
        achievementButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        achievementButton.BorderSizePixel = 0
        achievementButton.Text = ""
        achievementButton.Parent = achievementsList
        
        -- Achievement icon
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0.1, 0, 1, 0)
        icon.Position = UDim2.new(0, 0, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = achievement.icon
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.TextScaled = true
        icon.Font = Enum.Font.GothamBold
        icon.Parent = achievementButton
        
        -- Achievement name
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.Size = UDim2.new(0.4, 0, 0.5, 0)
        name.Position = UDim2.new(0.1, 0, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = achievement.name
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextScaled = true
        name.Font = Enum.Font.GothamBold
        name.Parent = achievementButton
        
        -- Achievement description
        local description = Instance.new("TextLabel")
        description.Name = "Description"
        description.Size = UDim2.new(0.4, 0, 0.5, 0)
        description.Position = UDim2.new(0.1, 0, 0.5, 0)
        description.BackgroundTransparency = 1
        description.Text = achievement.description
        description.TextColor3 = Color3.fromRGB(200, 200, 200)
        description.TextScaled = true
        description.Font = Enum.Font.Gotham
        description.Parent = achievementButton
        
        -- Progress bar
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(0.3, 0, 0.3, 0)
        progressBar.Position = UDim2.new(0.5, 0, 0.35, 0)
        progressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        progressBar.BorderSizePixel = 0
        progressBar.Parent = achievementButton
        
        local progressFill = Instance.new("Frame")
        progressFill.Name = "ProgressFill"
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.Position = UDim2.new(0, 0, 0, 0)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        progressFill.BorderSizePixel = 0
        progressFill.Parent = progressBar
        
        local progressText = Instance.new("TextLabel")
        progressText.Name = "ProgressText"
        progressText.Size = UDim2.new(1, 0, 1, 0)
        progressText.Position = UDim2.new(0, 0, 0, 0)
        progressText.BackgroundTransparency = 1
        progressText.Text = "0/100"
        progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
        progressText.TextScaled = true
        progressText.Font = Enum.Font.GothamBold
        progressText.Parent = progressBar
        
        -- Update progress
        local progress = data.progress[achievement.id] or 0
        local required = achievement.requirements.count
        local fillAmount = math.min(progress / required, 1)
        
        progressFill.Size = UDim2.new(fillAmount, 0, 1, 0)
        progressText.Text = progress .. "/" .. required
        
        -- Update appearance based on unlock status
        if data.unlocked[achievement.id] then
            achievementButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            achievementButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            progressFill.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        end
        
        yOffset = yOffset + 0.15
    end
    
    -- Update canvas size
    achievementsList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Show achievement notification
function AchievementUI.showNotification(achievement)
    -- Update notification content
    local notificationName = notificationFrame.Name
    local notificationReward = notificationFrame.Reward
    
    notificationName.Text = achievement.name
    notificationReward.Text = "+" .. achievement.xpReward .. " XP"
    
    -- Show notification
    notificationFrame.Visible = true
    
    -- Hide after delay
    task.delay(3, function()
        notificationFrame.Visible = false
    end)
end

-- Toggle UI visibility
function AchievementUI.toggle()
    mainFrame.Visible = not mainFrame.Visible
    
    if mainFrame.Visible then
        -- Refresh achievements
        AchievementUI.refreshAchievements()
    end
end

-- Initialize UI
function AchievementUI.init()
    AchievementUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.AchievementUpdate, function(achievements)
        AchievementUI.updateAchievements(achievements)
    end)
end

return AchievementUI 