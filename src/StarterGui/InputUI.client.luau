local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local InputUI = {}

-- UI Elements
local screenGui
local mainFrame
local messageText
local inputBox
local submitButton
local cancelButton

-- Create UI
function InputUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InputUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.3, 0, 0.3, 0)
    mainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
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
    title.Text = "Input"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create message text
    messageText = Instance.new("TextLabel")
    messageText.Name = "MessageText"
    messageText.Size = UDim2.new(1, -40, 0, 40)
    messageText.Position = UDim2.new(0, 20, 0, 50)
    messageText.BackgroundTransparency = 1
    messageText.Text = ""
    messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageText.TextSize = 16
    messageText.Font = Enum.Font.Gotham
    messageText.TextWrapped = true
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Top
    messageText.Parent = mainFrame
    
    -- Create input box
    inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -40, 0, 40)
    inputBox.Position = UDim2.new(0, 20, 0, 100)
    inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = "Enter text..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.Parent = mainFrame
    
    -- Create submit button
    submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0, 100, 0, 40)
    submitButton.Position = UDim2.new(0.5, -110, 1, -60)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Submit"
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.Gotham
    submitButton.Parent = mainFrame
    
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
function InputUI.show(message, onSubmit, onCancel)
    mainFrame.Visible = true
    messageText.Text = message
    inputBox.Text = ""
    
    -- Animate in
    mainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.35, 0, 0.35, 0),
        BackgroundTransparency = 0
    })
    tween:Play()
    
    -- Set up button events
    submitButton.MouseButton1Click:Connect(function()
        InputUI.hide()
        if onSubmit then
            onSubmit(inputBox.Text)
        end
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        InputUI.hide()
        if onCancel then
            onCancel()
        end
    end)
    
    -- Set up enter key event
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            InputUI.hide()
            if onSubmit then
                onSubmit(inputBox.Text)
            end
        end
    end)
    
    -- Focus input box
    inputBox:CaptureFocus()
end

-- Hide UI
function InputUI.hide()
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
function InputUI.init()
    InputUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowInput, function(message, onSubmit, onCancel)
        InputUI.show(message, onSubmit, onCancel)
    end)
end

return InputUI 