local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local SocialInteractionUI = {}

-- UI Elements
local screenGui
local mainFrame
local interactionList
local closeButton

-- Create UI
function SocialInteractionUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SocialInteractionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
    mainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
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
    title.Text = "Social Interactions"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create interaction list
    interactionList = Instance.new("ScrollingFrame")
    interactionList.Name = "InteractionList"
    interactionList.Size = UDim2.new(1, -20, 1, -50)
    interactionList.Position = UDim2.new(0, 10, 0, 50)
    interactionList.BackgroundTransparency = 1
    interactionList.BorderSizePixel = 0
    interactionList.ScrollBarThickness = 6
    interactionList.CanvasSize = UDim2.new(0, 0, 0, 0)
    interactionList.Parent = mainFrame
    
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
        SocialInteractionUI.hide()
    end)
end

-- Show UI
function SocialInteractionUI.show()
    mainFrame.Visible = true
end

-- Hide UI
function SocialInteractionUI.hide()
    mainFrame.Visible = false
end

-- Update interaction list
function SocialInteractionUI.updateInteractions(interactions)
    -- Clear existing interactions
    for _, child in ipairs(interactionList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new interactions
    local yOffset = 0
    for _, interaction in ipairs(interactions) do
        local interactionButton = Instance.new("TextButton")
        interactionButton.Name = interaction.id
        interactionButton.Size = UDim2.new(1, 0, 0, 50)
        interactionButton.Position = UDim2.new(0, 0, 0, yOffset)
        interactionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        interactionButton.BorderSizePixel = 0
        interactionButton.Text = interaction.name
        interactionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        interactionButton.TextSize = 16
        interactionButton.Font = Enum.Font.GothamBold
        interactionButton.Parent = interactionList
        
        -- Interaction description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -20, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = interaction.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextSize = 14
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = interactionButton
        
        -- Set up interaction button event
        interactionButton.MouseButton1Click:Connect(function()
            RemoteManager:fireServer(Constants.RemoteEvents.SocialInteraction, interaction.id)
            SocialInteractionUI.hide()
        end)
        
        yOffset = yOffset + 70
    end
    
    -- Update canvas size
    interactionList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function SocialInteractionUI.init()
    SocialInteractionUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.InteractionUpdate, function(interactions)
        SocialInteractionUI.updateInteractions(interactions)
    end)
end

return SocialInteractionUI 