local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local HelpUI = {}

-- UI Elements
local screenGui
local mainFrame
local helpList
local closeButton

-- Create UI
function HelpUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HelpUI"
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
    title.Text = "Help & Tutorials"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create help list
    helpList = Instance.new("ScrollingFrame")
    helpList.Name = "HelpList"
    helpList.Size = UDim2.new(1, -20, 1, -50)
    helpList.Position = UDim2.new(0, 10, 0, 50)
    helpList.BackgroundTransparency = 1
    helpList.BorderSizePixel = 0
    helpList.ScrollBarThickness = 6
    helpList.CanvasSize = UDim2.new(0, 0, 0, 0)
    helpList.Parent = mainFrame
    
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
        HelpUI.hide()
    end)
end

-- Create help section
function HelpUI.createHelpSection(title, content)
    local section = Instance.new("Frame")
    section.Name = title
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    section.BorderSizePixel = 0
    section.Parent = helpList
    
    -- Create section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    -- Create content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -20, 0, 0)
    contentLabel.Position = UDim2.new(0, 10, 0, 50)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 14
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextWrapped = true
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.Parent = section
    
    -- Calculate content height
    local textSize = contentLabel.TextBounds
    contentLabel.Size = UDim2.new(1, -20, 0, textSize.Y)
    
    -- Update section size
    section.Size = UDim2.new(1, 0, 0, textSize.Y + 70)
    
    return section
end

-- Show UI
function HelpUI.show()
    mainFrame.Visible = true
    
    -- Animate in
    mainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.25, 0, 0.15, 0),
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide UI
function HelpUI.hide()
    -- Animate out
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.25, 0, 0.25, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Hide after animation
    task.delay(0.5, function()
        mainFrame.Visible = false
    end)
end

-- Update help content
function HelpUI.updateHelpContent(helpContent)
    -- Clear existing content
    for _, child in ipairs(helpList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new content
    local yOffset = 0
    for _, section in ipairs(helpContent) do
        local sectionFrame = HelpUI.createHelpSection(section.title, section.content)
        sectionFrame.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset = yOffset + sectionFrame.Size.Y.Offset + 10
    end
    
    -- Update canvas size
    helpList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function HelpUI.init()
    HelpUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.HelpUpdate, function(helpContent)
        HelpUI.updateHelpContent(helpContent)
    end)
    
    -- Set up keyboard shortcut
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
            if mainFrame.Visible then
                HelpUI.hide()
            else
                HelpUI.show()
            end
        end
    end)
end

return HelpUI 