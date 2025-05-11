local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

local Tutorial = {}
Tutorial.__index = Tutorial

-- Tutorial state
local tutorialState = {
    isActive = false,
    currentStep = 1,
    steps = {
        {
            title = "Welcome!",
            description = "Welcome to the game! Let's learn the basics.",
            position = UDim2.new(0.5, 0, 0.5, 0)
        },
        {
            title = "Movement",
            description = "Use WASD to move around and Space to jump.",
            position = UDim2.new(0.5, 0, 0.5, 0)
        },
        {
            title = "Building",
            description = "Press B to open the building menu and start creating!",
            position = UDim2.new(0.5, 0, 0.5, 0)
        }
    }
}

-- Create tutorial UI
local function createTutorialUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TutorialUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "TutorialFrame"
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -40, 0, 80)
    description.Position = UDim2.new(0, 20, 0, 50)
    description.BackgroundTransparency = 1
    description.TextColor3 = Color3.fromRGB(255, 255, 255)
    description.Font = Enum.Font.GothamMedium
    description.TextSize = 14
    description.TextWrapped = true
    description.Parent = frame
    
    local nextButton = Instance.new("TextButton")
    nextButton.Name = "NextButton"
    nextButton.Size = UDim2.new(0, 100, 0, 40)
    nextButton.Position = UDim2.new(0.5, -50, 1, -60)
    nextButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextButton.Font = Enum.Font.GothamMedium
    nextButton.TextSize = 14
    nextButton.Text = "Next"
    nextButton.Parent = frame
    
    return screenGui
end

-- Show tutorial step
function Tutorial.ShowStep(stepIndex)
    if not tutorialState.steps[stepIndex] then
        return false
    end
    
    local step = tutorialState.steps[stepIndex]
    local tutorialUI = LocalPlayer:WaitForChild("PlayerGui").TutorialUI
    local frame = tutorialUI.TutorialFrame
    
    frame.Title.Text = step.title
    frame.Description.Text = step.description
    frame.Position = step.position
    frame.Visible = true
    
    tutorialState.currentStep = stepIndex
    return true
end

-- Complete tutorial
function Tutorial.CompleteTutorial()
    tutorialState.isActive = false
    LocalPlayer:WaitForChild("PlayerGui").TutorialUI.TutorialFrame.Visible = false
    
    RemoteManager:invokeServer("CompleteTutorial")
    Logger:info("Tutorial completed")
end

-- Initialize
function Tutorial.Initialize()
    local success, result = pcall(function()
        createTutorialUI()
        
        -- Set up remote event handlers
        RemoteManager:onClientEvent("StartTutorial", function()
            tutorialState.isActive = true
            Tutorial.ShowStep(1)
        end)
        
        -- Set up button handlers
        local nextButton = LocalPlayer:WaitForChild("PlayerGui").TutorialUI.TutorialFrame.NextButton
        nextButton.MouseButton1Click:Connect(function()
            if tutorialState.currentStep < #tutorialState.steps then
                Tutorial.ShowStep(tutorialState.currentStep + 1)
            else
                Tutorial.CompleteTutorial()
            end
        end)
    end)
    
    if not success then
        Logger:error("Failed to initialize Tutorial", { error = result })
        return false
    end
    
    Logger:info("Tutorial initialized successfully")
    return true
end

return Tutorial 