local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types

local TutorialManager = {}

-- Sound IDs
local SOUND_IDS = {
    BUTTON_CLICK = "rbxassetid://9114827380", -- Soft click sound
    BUTTON_HOVER = "rbxassetid://9114827380", -- Soft hover sound
    STEP_CHANGE = "rbxassetid://9114827380", -- Transition sound
    TUTORIAL_COMPLETE = "rbxassetid://9114827380" -- Completion sound
}

-- Tutorial steps
local TUTORIAL_STEPS = {
    {
        id = "welcome",
        title = "Welcome to Infinite Canvas!",
        description = "Let's learn how to create your own space in this infinite world.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Let's Begin",
        skipButton = true,
        highlight = nil
    },
    {
        id = "marketplace",
        title = "The Marketplace",
        description = "Here you can purchase objects to place in your space. Each object has a unique price and can be placed anywhere you want.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = "MarketplaceButton"
    },
    {
        id = "inventory",
        title = "Your Inventory",
        description = "All purchased objects are stored here. Click on an item to select it for placement.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = "InventoryButton"
    },
    {
        id = "placement",
        title = "Placing Objects",
        description = "Click anywhere in the world to place your selected object. You can rotate objects by pressing 'R'.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = nil
    },
    {
        id = "interaction",
        title = "Object Interaction",
        description = "Click on any placed object to see available actions: Move, Clone, or Remove. Each action has a small coin cost.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = nil
    },
    {
        id = "tools",
        title = "Special Tools",
        description = "Purchase tools like Spring Jumps and Magic Carpets to help you explore the world more easily.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = "MarketplaceButton"
    },
    {
        id = "rewards",
        title = "Daily Rewards",
        description = "Come back daily to claim rewards! Your streak increases each day, giving you better rewards.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = "DailyRewardsButton"
    },
    {
        id = "achievements",
        title = "Achievements",
        description = "Complete various tasks to earn achievements and rewards. Check your progress in the Achievements menu.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Next",
        skipButton = true,
        highlight = "AchievementsButton"
    },
    {
        id = "leaderboard",
        title = "Leaderboards",
        description = "Compete with other players on the leaderboards! Track your coins, objects placed, and more.",
        position = UDim2.new(0.5, 0, 0.3, 0),
        nextButton = "Finish",
        skipButton = true,
        highlight = "LeaderboardButton"
    }
}

-- Animation settings
local TWEEN_INFO = {
    SHOW = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    HIDE = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    HIGHLIGHT = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
    BUTTON_HOVER = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    BUTTON_CLICK = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

-- Button colors
local BUTTON_COLORS = {
    NORMAL = {
        NEXT = Color3.fromRGB(60, 60, 60),
        SKIP = Color3.fromRGB(200, 50, 50)
    },
    HOVER = {
        NEXT = Color3.fromRGB(80, 80, 80),
        SKIP = Color3.fromRGB(220, 70, 70)
    },
    CLICK = {
        NEXT = Color3.fromRGB(40, 40, 40),
        SKIP = Color3.fromRGB(180, 40, 40)
    }
}

-- Local state
local currentStep = 1
local tutorialActive = false
local tutorialUI
local highlightFrame

-- Create sound
function TutorialManager.createSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.5
    sound.Parent = SoundService
    return sound
end

-- Play sound
function TutorialManager.playSound(soundType)
    local sound = TutorialManager.createSound(SOUND_IDS[soundType])
    sound:Play()
    game:GetService("Debris"):AddItem(sound, sound.TimeLength)
end

-- Create button with feedback
function TutorialManager.createButton(name, text, position, size, isSkip)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = isSkip and BUTTON_COLORS.NORMAL.SKIP or BUTTON_COLORS.NORMAL.NEXT
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    
    -- Create corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        TutorialManager.playSound("BUTTON_HOVER")
        local tween = TweenService:Create(button, TWEEN_INFO.BUTTON_HOVER, {
            BackgroundColor3 = isSkip and BUTTON_COLORS.HOVER.SKIP or BUTTON_COLORS.HOVER.NEXT,
            Size = size + UDim2.new(0, 4, 0, 4)
        })
        tween:Play()
    end)
    
    -- Add leave effect
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TWEEN_INFO.BUTTON_HOVER, {
            BackgroundColor3 = isSkip and BUTTON_COLORS.NORMAL.SKIP or BUTTON_COLORS.NORMAL.NEXT,
            Size = size
        })
        tween:Play()
    end)
    
    -- Add click effect
    button.MouseButton1Down:Connect(function()
        TutorialManager.playSound("BUTTON_CLICK")
        local tween = TweenService:Create(button, TWEEN_INFO.BUTTON_CLICK, {
            BackgroundColor3 = isSkip and BUTTON_COLORS.CLICK.SKIP or BUTTON_COLORS.CLICK.NEXT,
            Size = size - UDim2.new(0, 2, 0, 2)
        })
        tween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local tween = TweenService:Create(button, TWEEN_INFO.BUTTON_HOVER, {
            BackgroundColor3 = isSkip and BUTTON_COLORS.HOVER.SKIP or BUTTON_COLORS.HOVER.NEXT,
            Size = size + UDim2.new(0, 4, 0, 4)
        })
        tween:Play()
    end)
    
    return button
end

-- Create highlight frame
function TutorialManager.createHighlightFrame()
    local frame = Instance.new("Frame")
    frame.Name = "HighlightFrame"
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.8
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = tutorialUI
    
    -- Create corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return frame
end

-- Create tutorial UI
function TutorialManager.createUI()
    tutorialUI = Instance.new("ScreenGui")
    tutorialUI.Name = "TutorialUI"
    tutorialUI.ResetOnSpawn = false
    tutorialUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 200)
    mainFrame.Position = TUTORIAL_STEPS[1].position
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = tutorialUI
    
    -- Create corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = ""
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create title corner
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Create description
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -40, 0, 80)
    description.Position = UDim2.new(0, 20, 0, 50)
    description.BackgroundTransparency = 1
    description.Text = ""
    description.TextColor3 = Color3.fromRGB(255, 255, 255)
    description.TextSize = 18
    description.Font = Enum.Font.Gotham
    description.TextWrapped = true
    description.Parent = mainFrame
    
    -- Create next button
    local nextButton = TutorialManager.createButton(
        "NextButton",
        "",
        UDim2.new(0.5, -130, 1, -60),
        UDim2.new(0, 120, 0, 40),
        false
    )
    nextButton.Parent = mainFrame
    
    -- Create skip button
    local skipButton = TutorialManager.createButton(
        "SkipButton",
        "Skip Tutorial",
        UDim2.new(0.5, 10, 1, -60),
        UDim2.new(0, 120, 0, 40),
        true
    )
    skipButton.Parent = mainFrame
    
    -- Create highlight frame
    highlightFrame = TutorialManager.createHighlightFrame()
    
    -- Set up button events
    nextButton.MouseButton1Click:Connect(function()
        TutorialManager.nextStep()
    end)
    
    skipButton.MouseButton1Click:Connect(function()
        TutorialManager.endTutorial()
    end)
    
    return {
        mainFrame = mainFrame,
        title = title,
        description = description,
        nextButton = nextButton,
        skipButton = skipButton
    }
end

-- Update highlight
function TutorialManager.updateHighlight(stepData)
    if not stepData.highlight then
        highlightFrame.Visible = false
        return
    end
    
    local targetButton = Players.LocalPlayer.PlayerGui.MainUI.MainFrame:FindFirstChild(stepData.highlight)
    if not targetButton then return end
    
    -- Calculate highlight position and size
    local targetPos = targetButton.AbsolutePosition
    local targetSize = targetButton.AbsoluteSize
    
    -- Update highlight frame
    highlightFrame.Position = UDim2.new(0, targetPos.X - 5, 0, targetPos.Y - 5)
    highlightFrame.Size = UDim2.new(0, targetSize.X + 10, 0, targetSize.Y + 10)
    highlightFrame.Visible = true
    
    -- Animate highlight
    local tween = TweenService:Create(highlightFrame, TWEEN_INFO.HIGHLIGHT, {
        BackgroundTransparency = 0.8
    })
    tween:Play()
end

-- Show current step
function TutorialManager.showStep(step)
    local stepData = TUTORIAL_STEPS[step]
    if not stepData then return end
    
    -- Play step change sound
    TutorialManager.playSound("STEP_CHANGE")
    
    -- Update UI elements
    tutorialUI.MainFrame.Title.Text = stepData.title
    tutorialUI.MainFrame.Description.Text = stepData.description
    tutorialUI.MainFrame.NextButton.Text = stepData.nextButton
    tutorialUI.MainFrame.SkipButton.Visible = stepData.skipButton
    
    -- Animate main frame
    local showTween = TweenService:Create(tutorialUI.MainFrame, TWEEN_INFO.SHOW, {
        Position = stepData.position,
        Size = UDim2.new(0, 400, 0, 200)
    })
    showTween:Play()
    
    -- Update highlight
    TutorialManager.updateHighlight(stepData)
    
    -- Show UI
    tutorialUI.MainFrame.Visible = true
end

-- Next step
function TutorialManager.nextStep()
    -- Animate out
    local hideTween = TweenService:Create(tutorialUI.MainFrame, TWEEN_INFO.HIDE, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        currentStep = currentStep + 1
        if currentStep > #TUTORIAL_STEPS then
            TutorialManager.endTutorial()
        else
            TutorialManager.showStep(currentStep)
        end
    end)
end

-- Start tutorial
function TutorialManager.startTutorial()
    if tutorialActive then return end
    
    tutorialActive = true
    currentStep = 1
    TutorialManager.showStep(currentStep)
end

-- End tutorial
function TutorialManager.endTutorial()
    -- Play completion sound
    TutorialManager.playSound("TUTORIAL_COMPLETE")
    
    -- Animate out
    local hideTween = TweenService:Create(tutorialUI.MainFrame, TWEEN_INFO.HIDE, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    hideTween:Play()
    
    hideTween.Completed:Connect(function()
        tutorialActive = false
        tutorialUI.MainFrame.Visible = false
        highlightFrame.Visible = false
        
        -- Save tutorial completion
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        local completeTutorialEvent = remotes:WaitForChild("CompleteTutorial")
        completeTutorialEvent:FireServer()
    end)
end

-- Initialize
function TutorialManager.init()
    tutorialUI = TutorialManager.createUI()
    
    -- Check if player needs tutorial
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local getTutorialStatusEvent = remotes:WaitForChild("GetTutorialStatus")
    local needsTutorial = getTutorialStatusEvent:InvokeServer()
    
    if needsTutorial then
        TutorialManager.startTutorial()
    end
end

return TutorialManager 