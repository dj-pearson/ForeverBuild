local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local ErrorUI = {}

-- UI Elements
local screenGui
local mainFrame
local errorText
local detailsText
local closeButton

-- Create UI
function ErrorUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ErrorUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.3, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.35, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    title.BorderSizePixel = 0
    title.Text = "Error"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create error text
    errorText = Instance.new("TextLabel")
    errorText.Name = "ErrorText"
    errorText.Size = UDim2.new(1, -40, 0, 0)
    errorText.Position = UDim2.new(0, 20, 0, 50)
    errorText.BackgroundTransparency = 1
    errorText.Text = ""
    errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
    errorText.TextSize = 18
    errorText.Font = Enum.Font.GothamBold
    errorText.TextWrapped = true
    errorText.Parent = mainFrame
    
    -- Create details text
    detailsText = Instance.new("TextLabel")
    detailsText.Name = "DetailsText"
    detailsText.Size = UDim2.new(1, -40, 0, 0)
    detailsText.Position = UDim2.new(0, 20, 0, 0)
    detailsText.BackgroundTransparency = 1
    detailsText.Text = ""
    detailsText.TextColor3 = Color3.fromRGB(200, 200, 200)
    detailsText.TextSize = 14
    detailsText.Font = Enum.Font.Gotham
    detailsText.TextWrapped = true
    detailsText.Parent = mainFrame
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 40)
    closeButton.Position = UDim2.new(0.5, -50, 1, -60)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    closeButton.MouseButton1Click:Connect(function()
        ErrorUI.hide()
    end)
    
    -- Set up hover effects
    closeButton.MouseEnter:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    
    closeButton.MouseLeave:Connect(function()
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
end

-- Show UI
function ErrorUI.show(error, details)
    -- Update text
    errorText.Text = error
    detailsText.Text = details or ""
    
    -- Calculate text heights
    local errorHeight = errorText.TextBounds.Y
    local detailsHeight = detailsText.TextBounds.Y
    
    -- Update positions and sizes
    errorText.Size = UDim2.new(1, -40, 0, errorHeight)
    errorText.Position = UDim2.new(0, 20, 0, 50)
    
    detailsText.Size = UDim2.new(1, -40, 0, detailsHeight)
    detailsText.Position = UDim2.new(0, 20, 0, 50 + errorHeight + 10)
    
    -- Update frame size
    mainFrame.Size = UDim2.new(0.4, 0, 0, 50 + errorHeight + detailsHeight + 80)
    mainFrame.Position = UDim2.new(0.3, 0, 0.5, -mainFrame.Size.Y.Offset / 2)
    
    -- Show and animate in
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0.3, 0, 0.5, -mainFrame.Size.Y.Offset / 2 + 50)
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.3, 0, 0.5, -mainFrame.Size.Y.Offset / 2),
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide UI
function ErrorUI.hide()
    -- Animate out
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.3, 0, 0.5, -mainFrame.Size.Y.Offset / 2 + 50),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Hide after animation
    task.delay(0.5, function()
        mainFrame.Visible = false
    end)
end

-- Initialize
function ErrorUI.init()
    ErrorUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowError, function(error, details)
        ErrorUI.show(error, details)
    end)
end

return ErrorUI 