local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

local TutorialClient = {}
TutorialClient.__index = TutorialClient

-- Tutorial state
local tutorialState = {
    isActive = false,
    currentStep = 0,
    steps = {
        {
            title = "Welcome!",
            description = "Welcome to the game! Let's get you started with the basics.",
            position = UDim2.new(0.5, 0, 0.5, 0)
        },
        {
            title = "Movement",
            description = "Use WASD to move around and Space to jump.",
            position = UDim2.new(0.5, 0, 0.7, 0)
        },
        {
            title = "Interactions",
            description = "Press E to interact with objects and NPCs.",
            position = UDim2.new(0.5, 0, 0.7, 0)
        }
    }
}

-- Create tutorial UI
local function createTutorialUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TutorialUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local tutorialFrame = Instance.new("Frame")
    tutorialFrame.Name = "TutorialFrame"
    tutorialFrame.Size = UDim2.new(0, 400, 0, 200)
    tutorialFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    tutorialFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tutorialFrame.BorderSizePixel = 0
    tutorialFrame.Visible = false
    tutorialFrame.Parent = screenGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24
    titleLabel.Parent = tutorialFrame
    
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Name = "Description"
    descriptionLabel.Size = UDim2.new(1, -40, 0, 80)
    descriptionLabel.Position = UDim2.new(0, 20, 0, 50)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    descriptionLabel.Font = Enum.Font.GothamMedium
    descriptionLabel.TextSize = 16
    descriptionLabel.TextWrapped = true
    descriptionLabel.Parent = tutorialFrame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Name = "NextButton"
    nextButton.Size = UDim2.new(0, 120, 0, 40)
    nextButton.Position = UDim2.new(1, -140, 1, -50)
    nextButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextButton.Font = Enum.Font.GothamMedium
    nextButton.TextSize = 16
    nextButton.Text = "Next"
    nextButton.Parent = tutorialFrame
    
    return screenGui
end

-- Show tutorial step
function TutorialClient.ShowStep(stepIndex)
    if not tutorialState.steps[stepIndex] then
        TutorialClient.CompleteTutorial()
        return
    end
    
    local step = tutorialState.steps[stepIndex]
    local tutorialFrame = LocalPlayer:WaitForChild("PlayerGui").TutorialUI.TutorialFrame
    
    tutorialFrame.Title.Text = step.title
    tutorialFrame.Description.Text = step.description
    tutorialFrame.Position = step.position
    tutorialFrame.Visible = true
    
    tutorialState.currentStep = stepIndex
    tutorialState.isActive = true
end

-- Complete tutorial
function TutorialClient.CompleteTutorial()
    local tutorialFrame = LocalPlayer:WaitForChild("PlayerGui").TutorialUI.TutorialFrame
    tutorialFrame.Visible = false
    tutorialState.isActive = false
    
    RemoteManager:fireServer(Constants.RemoteEvents.CompleteTutorial)
    Logger:info("Tutorial completed")
end

-- Initialize
function TutorialClient.Initialize()
    local success, result = pcall(function()
        createTutorialUI()
        
        -- Set up tutorial UI
        local tutorialFrame = LocalPlayer:WaitForChild("PlayerGui").TutorialUI.TutorialFrame
        local nextButton = tutorialFrame.NextButton
        
        nextButton.MouseButton1Click:Connect(function()
            TutorialClient.ShowStep(tutorialState.currentStep + 1)
        end)
        
        -- Check tutorial status
        local status = RemoteManager:invokeServer(Constants.RemoteFunctions.GetTutorialStatus)
        if status == "not_started" then
            TutorialClient.ShowStep(1)
        end
    end)
    
    if not success then
        Logger:error("Failed to initialize TutorialClient", { error = result })
        return false
    end
    
    Logger:info("TutorialClient initialized successfully")
    return true
end

return TutorialClient 