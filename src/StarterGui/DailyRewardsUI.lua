local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local DailyRewardsUI = {}

-- UI Elements
local screenGui
local mainFrame
local rewardButtons = {}
local claimButton
local closeButton
local streakLabel
local timeRemainingLabel

-- Remote events
local claimDailyRewardEvent = ReplicatedStorage.Remotes.ClaimDailyReward
local getDailyRewardInfoEvent = ReplicatedStorage.Remotes.GetDailyRewardInfo

-- Create UI
function DailyRewardsUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DailyRewardsUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Daily Rewards"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create streak label
    streakLabel = Instance.new("TextLabel")
    streakLabel.Name = "StreakLabel"
    streakLabel.Size = UDim2.new(1, 0, 0, 30)
    streakLabel.Position = UDim2.new(0, 0, 0, 50)
    streakLabel.BackgroundTransparency = 1
    streakLabel.Text = "Current Streak: 0"
    streakLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    streakLabel.TextSize = 24
    streakLabel.Font = Enum.Font.Gotham
    streakLabel.Parent = mainFrame
    
    -- Create time remaining label
    timeRemainingLabel = Instance.new("TextLabel")
    timeRemainingLabel.Name = "TimeRemainingLabel"
    timeRemainingLabel.Size = UDim2.new(1, 0, 0, 30)
    timeRemainingLabel.Position = UDim2.new(0, 0, 0, 80)
    timeRemainingLabel.BackgroundTransparency = 1
    timeRemainingLabel.Text = "Next reward available in: --:--:--"
    timeRemainingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeRemainingLabel.TextSize = 24
    timeRemainingLabel.Font = Enum.Font.Gotham
    timeRemainingLabel.Parent = mainFrame
    
    -- Create reward buttons container
    local rewardContainer = Instance.new("Frame")
    rewardContainer.Name = "RewardContainer"
    rewardContainer.Size = UDim2.new(1, -40, 0, 200)
    rewardContainer.Position = UDim2.new(0, 20, 0, 120)
    rewardContainer.BackgroundTransparency = 1
    rewardContainer.Parent = mainFrame
    
    -- Create reward buttons
    for i = 1, 7 do
        local button = Instance.new("TextButton")
        button.Name = "Day" .. i
        button.Size = UDim2.new(0, 70, 0, 70)
        button.Position = UDim2.new(0, (i - 1) * 80, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.BorderSizePixel = 0
        button.Text = "Day " .. i
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.Gotham
        button.Parent = rewardContainer
        
        -- Create reward amount label
        local amountLabel = Instance.new("TextLabel")
        amountLabel.Name = "AmountLabel"
        amountLabel.Size = UDim2.new(1, 0, 0, 20)
        amountLabel.Position = UDim2.new(0, 0, 1, -20)
        amountLabel.BackgroundTransparency = 1
        amountLabel.Text = (i * 50 + 50) .. " Coins"
        amountLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        amountLabel.TextSize = 16
        amountLabel.Font = Enum.Font.Gotham
        amountLabel.Parent = button
        
        rewardButtons[i] = button
    end
    
    -- Create claim button
    claimButton = Instance.new("TextButton")
    claimButton.Name = "ClaimButton"
    claimButton.Size = UDim2.new(0, 200, 0, 50)
    claimButton.Position = UDim2.new(0.5, -100, 1, -70)
    claimButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    claimButton.BorderSizePixel = 0
    claimButton.Text = "Claim Reward"
    claimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    claimButton.TextSize = 24
    claimButton.Font = Enum.Font.GothamBold
    claimButton.Parent = mainFrame
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    claimButton.MouseButton1Click:Connect(function()
        claimDailyRewardEvent:FireServer()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
end

-- Update reward buttons
function DailyRewardsUI.updateRewardButtons(rewardInfo)
    for i, button in ipairs(rewardButtons) do
        if i < rewardInfo.nextDay then
            -- Past days
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            button.Text = "Claimed"
        elseif i == rewardInfo.nextDay then
            -- Current day
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            button.Text = "Day " .. i
        else
            -- Future days
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.Text = "Day " .. i
        end
    end
    
    -- Update streak label
    streakLabel.Text = "Current Streak: " .. rewardInfo.streak
    
    -- Update claim button
    claimButton.Visible = rewardInfo.canClaim
end

-- Update time remaining
function DailyRewardsUI.updateTimeRemaining(timeRemaining)
    if timeRemaining <= 0 then
        timeRemainingLabel.Text = "Reward available now!"
        return
    end
    
    local hours = math.floor(timeRemaining / 3600)
    local minutes = math.floor((timeRemaining % 3600) / 60)
    local seconds = timeRemaining % 60
    
    timeRemainingLabel.Text = string.format(
        "Next reward available in: %02d:%02d:%02d",
        hours,
        minutes,
        seconds
    )
end

-- Show UI
function DailyRewardsUI.show()
    mainFrame.Visible = true
    
    -- Get initial reward info
    local rewardInfo = getDailyRewardInfoEvent:InvokeServer()
    if rewardInfo then
        DailyRewardsUI.updateRewardButtons(rewardInfo)
        
        -- Start time remaining update loop
        if not rewardInfo.canClaim then
            local timeRemaining = 24 * 60 * 60 -- 24 hours in seconds
            DailyRewardsUI.updateTimeRemaining(timeRemaining)
            
            -- Update every second
            game:GetService("RunService").Heartbeat:Connect(function()
                timeRemaining = timeRemaining - 1/60
                if timeRemaining <= 0 then
                    timeRemaining = 0
                    DailyRewardsUI.updateTimeRemaining(timeRemaining)
                    return
                end
                DailyRewardsUI.updateTimeRemaining(timeRemaining)
            end)
        end
    end
end

-- Hide UI
function DailyRewardsUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function DailyRewardsUI.init()
    DailyRewardsUI.create()
    
    -- Set up claim response
    claimDailyRewardEvent.OnClientEvent:Connect(function(success, data)
        if success then
            -- Update UI with new reward info
            DailyRewardsUI.updateRewardButtons({
                nextDay = data.nextDay,
                streak = data.streak,
                canClaim = false,
            })
            
            -- Show reward notification
            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 300, 0, 100)
            notification.Position = UDim2.new(0.5, -150, 0.8, -50)
            notification.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            notification.BorderSizePixel = 0
            notification.Text = "Reward Claimed!\n+" .. data.reward.amount .. " Coins"
            notification.TextColor3 = Color3.fromRGB(255, 255, 255)
            notification.TextSize = 32
            notification.Font = Enum.Font.GothamBold
            notification.Parent = screenGui
            
            -- Animate and remove notification
            game:GetService("TweenService"):Create(
                notification,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, -150, 0.7, -50)}
            ):Play()
            
            task.delay(2, function()
                game:GetService("TweenService"):Create(
                    notification,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Position = UDim2.new(0.5, -150, 0.8, -50)}
                ):Play()
                
                task.delay(0.5, function()
                    notification:Destroy()
                end)
            end)
        end
    end)
end

return DailyRewardsUI 