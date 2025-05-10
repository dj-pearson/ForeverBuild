local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)
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
local challengesFrame
local challengeList
local challengeDetails
local submissionList
local submitButton
local voteButton

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
    
    -- Create challenges frame
    challengesFrame = Instance.new("Frame")
    challengesFrame.Name = "ChallengesFrame"
    challengesFrame.Size = UDim2.new(0, 800, 0, 600)
    challengesFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    challengesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    challengesFrame.BorderSizePixel = 0
    challengesFrame.Visible = false
    challengesFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Building Challenges"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = challengesFrame
    
    -- Challenge list
    challengeList = Instance.new("ScrollingFrame")
    challengeList.Name = "ChallengeList"
    challengeList.Size = UDim2.new(0.3, -20, 0, 500)
    challengeList.Position = UDim2.new(0, 10, 0, 50)
    challengeList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    challengeList.BorderSizePixel = 0
    challengeList.ScrollBarThickness = 6
    challengeList.Parent = challengesFrame
    
    -- Challenge details
    challengeDetails = Instance.new("Frame")
    challengeDetails.Name = "ChallengeDetails"
    challengeDetails.Size = UDim2.new(0.7, -20, 0, 300)
    challengeDetails.Position = UDim2.new(0.3, 10, 0, 50)
    challengeDetails.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    challengeDetails.BorderSizePixel = 0
    challengeDetails.Parent = challengesFrame
    
    -- Submission list
    submissionList = Instance.new("ScrollingFrame")
    submissionList.Name = "SubmissionList"
    submissionList.Size = UDim2.new(0.7, -20, 0, 200)
    submissionList.Position = UDim2.new(0.3, 10, 0, 360)
    submissionList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    submissionList.BorderSizePixel = 0
    submissionList.ScrollBarThickness = 6
    submissionList.Parent = challengesFrame
    
    -- Submit button
    submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0, 150, 0, 40)
    submitButton.Position = UDim2.new(0.3, 10, 0, 570)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Submit Entry"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.Gotham
    submitButton.Parent = challengesFrame
    
    -- Vote button
    voteButton = Instance.new("TextButton")
    voteButton.Name = "VoteButton"
    voteButton.Size = UDim2.new(0, 150, 0, 40)
    voteButton.Position = UDim2.new(0.3, 170, 0, 570)
    voteButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    voteButton.BorderSizePixel = 0
    voteButton.Text = "Vote"
    voteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    voteButton.TextSize = 16
    voteButton.Font = Enum.Font.Gotham
    voteButton.Parent = challengesFrame
    
    -- Set up button events
    submitButton.MouseButton1Click:Connect(function()
        BuildingChallengeUI.showSubmitDialog()
    end)
    
    voteButton.MouseButton1Click:Connect(function()
        BuildingChallengeUI.voteSubmission()
    end)
    
    -- Set up keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingChallengeUI.showSubmitDialog()
        end
    end)
end

-- Show submit dialog
function BuildingChallengeUI.showSubmitDialog()
    -- Create dialog
    local dialog = Instance.new("Frame")
    dialog.Name = "SubmitDialog"
    dialog.Size = UDim2.new(0, 400, 0, 300)
    dialog.Position = UDim2.new(0.5, -200, 0.5, -150)
    dialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dialog.BorderSizePixel = 0
    dialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Submit Challenge Entry"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = dialog
    
    -- Description
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -20, 0, 60)
    description.Position = UDim2.new(0, 10, 0, 50)
    description.BackgroundTransparency = 1
    description.Text = "Select your building to submit as an entry for the current challenge."
    description.TextColor3 = Color3.fromRGB(255, 255, 255)
    description.TextSize = 16
    description.Font = Enum.Font.Gotham
    description.TextWrapped = true
    description.Parent = dialog
    
    -- Submit button
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0, 150, 0, 40)
    submitButton.Position = UDim2.new(0.5, -75, 1, -50)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Submit"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.Gotham
    submitButton.Parent = dialog
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 150, 0, 40)
    cancelButton.Position = UDim2.new(0.5, 85, 1, -50)
    cancelButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.Font = Enum.Font.Gotham
    cancelButton.Parent = dialog
    
    -- Set up button events
    submitButton.MouseButton1Click:Connect(function()
        local selectedChallenge = BuildingChallengeUI.getSelectedChallenge()
        if not selectedChallenge then
            BuildingChallengeUI.showError("Please select a challenge")
            return
        end
        
        local submission = BuildingChallengeUI.getSelectedBuilding()
        if not submission then
            BuildingChallengeUI.showError("Please select a building to submit")
            return
        end
        
        local success, message = submitChallengeEvent:InvokeServer(selectedChallenge.id, submission)
        if success then
            BuildingChallengeUI.showNotification("Entry submitted successfully")
            dialog:Destroy()
            BuildingChallengeUI.refreshSubmissions()
        else
            BuildingChallengeUI.showError(message)
        end
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Vote submission
function BuildingChallengeUI.voteSubmission()
    local selectedSubmission = BuildingChallengeUI.getSelectedSubmission()
    if not selectedSubmission then
        BuildingChallengeUI.showError("Please select a submission to vote for")
        return
    end
    
    local success, message = voteChallengeEvent:InvokeServer(selectedSubmission.id)
    if success then
        BuildingChallengeUI.showNotification("Vote recorded")
        BuildingChallengeUI.refreshSubmissions()
    else
        BuildingChallengeUI.showError(message)
    end
end

-- Get selected challenge
function BuildingChallengeUI.getSelectedChallenge()
    -- TODO: Implement getting selected challenge
    -- This could include:
    -- - Getting selected challenge from list
    -- - Validating selection
    return nil
end

-- Get selected building
function BuildingChallengeUI.getSelectedBuilding()
    -- TODO: Implement getting selected building
    -- This could include:
    -- - Getting selected building from BuildingToolsManager
    -- - Converting building to submission format
    return nil
end

-- Get selected submission
function BuildingChallengeUI.getSelectedSubmission()
    -- TODO: Implement getting selected submission
    -- This could include:
    -- - Getting selected submission from list
    -- - Validating selection
    return nil
end

-- Refresh challenges
function BuildingChallengeUI.refreshChallenges()
    local success, challenges = getChallengesEvent:InvokeServer()
    if success then
        -- Clear list
        for _, child in ipairs(challengeList:GetChildren()) do
            child:Destroy()
        end
        
        -- Add challenges
        local y = 0
        for _, challenge in pairs(challenges) do
            local challengeButton = BuildingChallengeUI.createChallengeButton(challenge, y)
            challengeButton.Parent = challengeList
            y = y + 80
        end
    end
end

-- Refresh submissions
function BuildingChallengeUI.refreshSubmissions()
    local selectedChallenge = BuildingChallengeUI.getSelectedChallenge()
    if not selectedChallenge then return end
    
    local success, submissions = getSubmissionsEvent:InvokeServer(selectedChallenge.id)
    if success then
        -- Clear list
        for _, child in ipairs(submissionList:GetChildren()) do
            child:Destroy()
        end
        
        -- Add submissions
        local y = 0
        for _, submission in pairs(submissions) do
            local submissionButton = BuildingChallengeUI.createSubmissionButton(submission, y)
            submissionButton.Parent = submissionList
            y = y + 100
        end
    end
end

-- Create challenge button
function BuildingChallengeUI.createChallengeButton(challenge, y)
    local button = Instance.new("TextButton")
    button.Name = challenge.id
    button.Size = UDim2.new(1, 0, 0, 80) -- Increased height for more info
    button.Position = UDim2.new(0, 0, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = challengeList
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = challenge.title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = button
    
    -- Category and difficulty
    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.Size = UDim2.new(1, -20, 0, 20)
    info.Position = UDim2.new(0, 10, 0, 25)
    info.BackgroundTransparency = 1
    info.Text = challenge.category .. " • " .. challenge.difficulty
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.TextSize = 14
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = button
    
    -- Time remaining
    local timeRemaining = Instance.new("TextLabel")
    timeRemaining.Name = "TimeRemaining"
    timeRemaining.Size = UDim2.new(1, -20, 0, 20)
    timeRemaining.Position = UDim2.new(0, 10, 0, 45)
    timeRemaining.BackgroundTransparency = 1
    timeRemaining.Text = BuildingChallengeUI.formatTimeRemaining(challenge.endTime - os.time())
    timeRemaining.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeRemaining.TextSize = 14
    timeRemaining.Font = Enum.Font.Gotham
    timeRemaining.TextXAlignment = Enum.TextXAlignment.Left
    timeRemaining.Parent = button
    
    -- Add click handler
    button.MouseButton1Click:Connect(function()
        BuildingChallengeUI.selectChallenge(challenge)
    end)
    
    return button
end

-- Format time remaining
function BuildingChallengeUI.formatTimeRemaining(seconds)
    local days = math.floor(seconds / (24 * 60 * 60))
    local hours = math.floor((seconds % (24 * 60 * 60)) / (60 * 60))
    
    if days > 0 then
        return days .. " days, " .. hours .. " hours remaining"
    else
        return hours .. " hours remaining"
    end
end

-- Create submission button
function BuildingChallengeUI.createSubmissionButton(submission, y)
    local button = Instance.new("TextButton")
    button.Name = submission.id
    button.Size = UDim2.new(1, 0, 0, 90)
    button.Position = UDim2.new(0, 0, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = submissionList
    
    -- Creator name
    local creatorName = Instance.new("TextLabel")
    creatorName.Name = "CreatorName"
    creatorName.Size = UDim2.new(1, -20, 0, 20)
    creatorName.Position = UDim2.new(0, 10, 0, 10)
    creatorName.BackgroundTransparency = 1
    creatorName.Text = "By " .. submission.username
    creatorName.TextColor3 = Color3.fromRGB(255, 255, 255)
    creatorName.TextSize = 14
    creatorName.Font = Enum.Font.Gotham
    creatorName.TextXAlignment = Enum.TextXAlignment.Left
    creatorName.Parent = button
    
    -- Submission preview
    local preview = Instance.new("ImageLabel")
    preview.Name = "Preview"
    preview.Size = UDim2.new(1, -20, 0, 50)
    preview.Position = UDim2.new(0, 10, 0, 30)
    preview.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    preview.BorderSizePixel = 0
    preview.Parent = button
    
    -- Add click handler
    button.MouseButton1Click:Connect(function()
        BuildingChallengeUI.selectSubmission(submission)
    end)
    
    return button
end

-- Select challenge
function BuildingChallengeUI.selectChallenge(challenge)
    -- Update challenge details
    local title = challengeDetails:FindFirstChild("Title")
    if not title then
        title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 10)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = challengeDetails
    end
    title.Text = challenge.title
    
    -- Category and difficulty
    local info = challengeDetails:FindFirstChild("Info")
    if not info then
        info = Instance.new("TextLabel")
        info.Name = "Info"
        info.Size = UDim2.new(1, -20, 0, 20)
        info.Position = UDim2.new(0, 10, 0, 40)
        info.BackgroundTransparency = 1
        info.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.TextSize = 16
        info.Font = Enum.Font.Gotham
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Parent = challengeDetails
    end
    info.Text = challenge.category .. " • " .. challenge.difficulty
    
    -- Description
    local description = challengeDetails:FindFirstChild("Description")
    if not description then
        description = Instance.new("TextLabel")
        description.Name = "Description"
        description.Size = UDim2.new(1, -20, 0, 60)
        description.Position = UDim2.new(0, 10, 0, 70)
        description.BackgroundTransparency = 1
        description.TextColor3 = Color3.fromRGB(255, 255, 255)
        description.TextSize = 16
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextWrapped = true
        description.Parent = challengeDetails
    end
    description.Text = challenge.description
    
    -- Rewards
    local rewards = challengeDetails:FindFirstChild("Rewards")
    if not rewards then
        rewards = Instance.new("TextLabel")
        rewards.Name = "Rewards"
        rewards.Size = UDim2.new(1, -20, 0, 40)
        rewards.Position = UDim2.new(0, 10, 0, 140)
        rewards.BackgroundTransparency = 1
        rewards.TextColor3 = Color3.fromRGB(255, 255, 255)
        rewards.TextSize = 16
        rewards.Font = Enum.Font.Gotham
        rewards.TextXAlignment = Enum.TextXAlignment.Left
        rewards.TextWrapped = true
        rewards.Parent = challengeDetails
    end
    rewards.Text = "Rewards:\n1st Place: " .. challenge.rewards.first .. " coins\n2nd Place: " .. challenge.rewards.second .. " coins\n3rd Place: " .. challenge.rewards.third .. " coins"
    
    -- Refresh submissions and leaderboard
    BuildingChallengeUI.refreshSubmissions()
    BuildingChallengeUI.refreshLeaderboard(challenge.id)
end

-- Select submission
function BuildingChallengeUI.selectSubmission(submission)
    -- TODO: Implement selecting submission
    -- This could include:
    -- - Highlighting selected submission
    -- - Showing submission details
    -- - Enabling/disabling vote button
end

-- Show notification
function BuildingChallengeUI.showNotification(message)
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 1, 0)
    messageLabel.Position = UDim2.new(0, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notification
    
    -- Animate notification
    notification.BackgroundTransparency = 1
    messageLabel.TextTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local showTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
        BackgroundTransparency = 0
    })
    
    local showTextTween = game:GetService("TweenService"):Create(messageLabel, tweenInfo, {
        TextTransparency = 0
    })
    
    showTween:Play()
    showTextTween:Play()
    
    -- Hide notification after delay
    task.delay(2, function()
        local hideTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
            BackgroundTransparency = 1
        })
        
        local hideTextTween = game:GetService("TweenService"):Create(messageLabel, tweenInfo, {
            TextTransparency = 1
        })
        
        hideTween:Play()
        hideTextTween:Play()
        
        hideTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Show error
function BuildingChallengeUI.showError(message)
    -- Create error dialog
    local errorDialog = Instance.new("Frame")
    errorDialog.Name = "ErrorDialog"
    errorDialog.Size = UDim2.new(0, 300, 0, 150)
    errorDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    errorDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    errorDialog.BorderSizePixel = 0
    errorDialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Error"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = errorDialog
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 50)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.Parent = errorDialog
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = errorDialog
    
    closeButton.MouseButton1Click:Connect(function()
        errorDialog:Destroy()
    end)
end

-- Show challenges
function BuildingChallengeUI.showChallenges()
    challengesFrame.Visible = true
    BuildingChallengeUI.refreshChallenges()
end

-- Hide challenges
function BuildingChallengeUI.hideChallenges()
    challengesFrame.Visible = false
end

-- Refresh leaderboard
function BuildingChallengeUI.refreshLeaderboard(challengeId)
    local leaderboardFrame = challengeDetails:FindFirstChild("LeaderboardFrame")
    if not leaderboardFrame then
        leaderboardFrame = Instance.new("Frame")
        leaderboardFrame.Name = "LeaderboardFrame"
        leaderboardFrame.Size = UDim2.new(1, -20, 0, 150)
        leaderboardFrame.Position = UDim2.new(0, 10, 0, 190)
        leaderboardFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        leaderboardFrame.BorderSizePixel = 0
        leaderboardFrame.Parent = challengeDetails
        
        -- Title
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        title.BorderSizePixel = 0
        title.Text = "Leaderboard"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.Parent = leaderboardFrame
        
        -- Entries
        local entries = Instance.new("ScrollingFrame")
        entries.Name = "Entries"
        entries.Size = UDim2.new(1, 0, 0, 120)
        entries.Position = UDim2.new(0, 0, 0, 30)
        entries.BackgroundTransparency = 1
        entries.ScrollBarThickness = 6
        entries.Parent = leaderboardFrame
    end
    
    -- Get leaderboard data
    local leaderboard = BuildingChallengeManager.getLeaderboard(challengeId)
    
    -- Clear existing entries
    local entries = leaderboardFrame:FindFirstChild("Entries")
    for _, child in ipairs(entries:GetChildren()) do
        child:Destroy()
    end
    
    -- Add entries
    local y = 0
    for i, entry in ipairs(leaderboard) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = "Entry" .. i
        entryFrame.Size = UDim2.new(1, 0, 0, 30)
        entryFrame.Position = UDim2.new(0, 0, 0, y)
        entryFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        entryFrame.BorderSizePixel = 0
        entryFrame.Parent = entries
        
        -- Rank
        local rank = Instance.new("TextLabel")
        rank.Name = "Rank"
        rank.Size = UDim2.new(0, 30, 1, 0)
        rank.Position = UDim2.new(0, 0, 0, 0)
        rank.BackgroundTransparency = 1
        rank.Text = "#" .. i
        rank.TextColor3 = Color3.fromRGB(255, 255, 255)
        rank.TextSize = 14
        rank.Font = Enum.Font.GothamBold
        rank.TextXAlignment = Enum.TextXAlignment.Center
        rank.Parent = entryFrame
        
        -- Votes
        local votes = Instance.new("TextLabel")
        votes.Name = "Votes"
        votes.Size = UDim2.new(0, 60, 1, 0)
        votes.Position = UDim2.new(1, -60, 0, 0)
        votes.BackgroundTransparency = 1
        votes.Text = entry.votes .. " votes"
        votes.TextColor3 = Color3.fromRGB(255, 255, 255)
        votes.TextSize = 14
        votes.Font = Enum.Font.Gotham
        votes.TextXAlignment = Enum.TextXAlignment.Right
        votes.Parent = entryFrame
        
        y = y + 30
    end
end

-- Show achievements
function BuildingChallengeUI.showAchievements()
    local achievementsFrame = Instance.new("Frame")
    achievementsFrame.Name = "AchievementsFrame"
    achievementsFrame.Size = UDim2.new(0, 400, 0, 500)
    achievementsFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    achievementsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    achievementsFrame.BorderSizePixel = 0
    achievementsFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Achievements"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = achievementsFrame
    
    -- Get player achievements
    local achievements = BuildingChallengeManager.getPlayerAchievements(Players.LocalPlayer)
    
    -- Add achievement entries
    local y = 50
    for _, reward in ipairs(SPECIAL_REWARDS) do
        local entry = Instance.new("Frame")
        entry.Name = reward.name
        entry.Size = UDim2.new(1, -20, 0, 80)
        entry.Position = UDim2.new(0, 10, 0, y)
        entry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        entry.BorderSizePixel = 0
        entry.Parent = achievementsFrame
        
        -- Name
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.Size = UDim2.new(1, -20, 0, 20)
        name.Position = UDim2.new(0, 10, 0, 10)
        name.BackgroundTransparency = 1
        name.Text = reward.name
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextSize = 16
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = entry
        
        -- Description
        local description = Instance.new("TextLabel")
        description.Name = "Description"
        description.Size = UDim2.new(1, -20, 0, 20)
        description.Position = UDim2.new(0, 10, 0, 30)
        description.BackgroundTransparency = 1
        description.Text = reward.description
        description.TextColor3 = Color3.fromRGB(200, 200, 200)
        description.TextSize = 14
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.Parent = entry
        
        -- Progress
        local progress = Instance.new("TextLabel")
        progress.Name = "Progress"
        progress.Size = UDim2.new(1, -20, 0, 20)
        progress.Position = UDim2.new(0, 10, 0, 50)
        progress.BackgroundTransparency = 1
        progress.Text = "Reward: " .. reward.reward .. " coins"
        progress.TextColor3 = Color3.fromRGB(200, 200, 200)
        progress.TextSize = 14
        progress.Font = Enum.Font.Gotham
        progress.TextXAlignment = Enum.TextXAlignment.Left
        progress.Parent = entry
        
        y = y + 90
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = achievementsFrame
    
    closeButton.MouseButton1Click:Connect(function()
        achievementsFrame:Destroy()
    end)
end

-- Initialize
function BuildingChallengeUI.init()
    BuildingChallengeUI.create()
end

return BuildingChallengeUI 