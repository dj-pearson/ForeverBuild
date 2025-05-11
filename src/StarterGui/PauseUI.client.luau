local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local PauseUI = {}

-- UI Elements
local screenGui
local mainFrame
local blurEffect
local menuFrame
local settingsFrame
local currentFrame

-- Create UI
function PauseUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PauseUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create blur effect
    blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "BlurEffect"
    blurEffect.Size = 20
    blurEffect.Enabled = false
    blurEffect.Parent = screenGui
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create menu frame
    menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(1, 0, 1, 0)
    menuFrame.Position = UDim2.new(0, 0, 0, 0)
    menuFrame.BackgroundTransparency = 1
    menuFrame.Parent = mainFrame
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 100)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "PAUSED"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 48
    title.Font = Enum.Font.GothamBold
    title.Parent = menuFrame
    
    -- Create menu buttons
    local buttons = {
        {text = "Resume", action = function() PauseUI.hide() end},
        {text = "Settings", action = function() PauseUI.showFrame(settingsFrame) end},
        {text = "Leave Game", action = function() RemoteManager:fireServer(Constants.RemoteEvents.LeaveGame) end}
    }
    
    for i, buttonData in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = buttonData.text .. "Button"
        button.Size = UDim2.new(0.8, 0, 0, 50)
        button.Position = UDim2.new(0.1, 0, 0, 150 + (i - 1) * 70)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.BorderSizePixel = 0
        button.Text = buttonData.text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 24
        button.Font = Enum.Font.GothamBold
        button.Parent = menuFrame
        
        button.MouseButton1Click:Connect(buttonData.action)
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)
    end
    
    -- Create settings frame
    settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Size = UDim2.new(1, 0, 1, 0)
    settingsFrame.Position = UDim2.new(0, 0, 0, 0)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.Visible = false
    settingsFrame.Parent = mainFrame
    
    -- Create settings title
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 100)
    settingsTitle.Position = UDim2.new(0, 0, 0, 0)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "Settings"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 48
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsFrame
    
    -- Create back button
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0.8, 0, 0, 50)
    backButton.Position = UDim2.new(0.1, 0, 1, -70)
    backButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backButton.BorderSizePixel = 0
    backButton.Text = "Back"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.TextSize = 24
    backButton.Font = Enum.Font.GothamBold
    backButton.Parent = settingsFrame
    
    backButton.MouseButton1Click:Connect(function()
        PauseUI.showFrame(menuFrame)
    end)
    
    -- Add hover effect
    backButton.MouseEnter:Connect(function()
        TweenService:Create(backButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        }):Play()
    end)
    
    backButton.MouseLeave:Connect(function()
        TweenService:Create(backButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
    
    -- Set initial frame
    currentFrame = menuFrame
end

-- Show frame
function PauseUI.showFrame(frame)
    if currentFrame then
        currentFrame.Visible = false
    end
    currentFrame = frame
    frame.Visible = true
end

-- Show pause UI
function PauseUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    blurEffect.Enabled = true
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide pause UI
function PauseUI.hide()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 1
    })
    tween:Play()
    
    task.delay(0.3, function()
        mainFrame.Visible = false
        blurEffect.Enabled = false
    end)
end

-- Initialize
function PauseUI.init()
    PauseUI.create()
    
    -- Set up input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
            if mainFrame.Visible then
                PauseUI.hide()
            else
                PauseUI.show()
            end
        end
    end)
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowPause, function()
        PauseUI.show()
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.HidePause, function()
        PauseUI.hide()
    end)
end

return PauseUI 