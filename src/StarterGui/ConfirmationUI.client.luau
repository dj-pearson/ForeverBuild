local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local ConfirmationUI = {}

-- UI Elements
local screenGui
local mainFrame
local messageText
local confirmButton
local cancelButton

-- Create UI
function ConfirmationUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ConfirmationUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.3, 0, 0.25, 0)
    mainFrame.Position = UDim2.new(0.35, 0, 0.375, 0)
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
    title.Text = "Confirm"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create message text
    messageText = Instance.new("TextLabel")
    messageText.Name = "MessageText"
    messageText.Size = UDim2.new(1, -40, 1, -100)
    messageText.Position = UDim2.new(0, 20, 0, 60)
    messageText.BackgroundTransparency = 1
    messageText.Text = ""
    messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageText.TextSize = 16
    messageText.Font = Enum.Font.Gotham
    messageText.TextWrapped = true
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Top
    messageText.Parent = mainFrame
    
    -- Create confirm button
    confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0, 100, 0, 40)
    confirmButton.Position = UDim2.new(0.5, -110, 1, -60)
    confirmButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    confirmButton.BorderSizePixel = 0
    confirmButton.Text = "Confirm"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 16
    confirmButton.Font = Enum.Font.Gotham
    confirmButton.Parent = mainFrame
    
    -- Create cancel button
    cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 100, 0, 40)
    cancelButton.Position = UDim2.new(0.5, 10, 1, -60)
    cancelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.Font = Enum.Font.Gotham
    cancelButton.Parent = mainFrame
end

-- Show UI
function ConfirmationUI.show(message, onConfirm, onCancel)
    mainFrame.Visible = true
    messageText.Text = message
    
    -- Animate in
    mainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.35, 0, 0.375, 0),
        BackgroundTransparency = 0
    })
    tween:Play()
    
    -- Set up button events
    confirmButton.MouseButton1Click:Connect(function()
        ConfirmationUI.hide()
        if onConfirm then
            onConfirm()
        end
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        ConfirmationUI.hide()
        if onCancel then
            onCancel()
        end
    end)
end

-- Hide UI
function ConfirmationUI.hide()
    -- Animate out
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.35, 0, 0.2, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Hide after animation
    task.delay(0.5, function()
        mainFrame.Visible = false
    end)
end

-- Initialize
function ConfirmationUI.init()
    ConfirmationUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowConfirmation, function(message, onConfirm, onCancel)
        ConfirmationUI.show(message, onConfirm, onCancel)
    end)
end

return ConfirmationUI 