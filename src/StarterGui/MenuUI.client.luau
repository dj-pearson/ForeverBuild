local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local MenuUI = {}

-- UI Elements
local screenGui
local mainFrame
local titleFrame
local menuFrame
local settingsFrame
local creditsFrame
local currentFrame

-- Create UI
function MenuUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MenuUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title frame
    titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.Size = UDim2.new(1, 0, 0, 100)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = mainFrame
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "FOREVER BUILD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 48
    title.Font = Enum.Font.GothamBold
    title.Parent = titleFrame
    
    -- Create menu frame
    menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(1, 0, 1, -100)
    menuFrame.Position = UDim2.new(0, 0, 0, 100)
    menuFrame.BackgroundTransparency = 1
    menuFrame.Parent = mainFrame
    
    -- Create menu buttons
    local buttons = {
        {text = "Play", action = function() RemoteManager:fireServer(Constants.RemoteEvents.PlayGame) end},
        {text = "Settings", action = function() MenuUI.showFrame(settingsFrame) end},
        {text = "Credits", action = function() MenuUI.showFrame(creditsFrame) end},
        {text = "Quit", action = function() RemoteManager:fireServer(Constants.RemoteEvents.QuitGame) end}
    }
    
    for i, buttonData in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = buttonData.text .. "Button"
        button.Size = UDim2.new(0, 200, 0, 50)
        button.Position = UDim2.new(0.5, -100, 0, 50 + (i - 1) * 70)
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
    settingsFrame.Size = UDim2.new(1, 0, 1, -100)
    settingsFrame.Position = UDim2.new(0, 0, 0, 100)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.Visible = false
    settingsFrame.Parent = mainFrame
    
    -- Create settings title
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Name = "SettingsTitle"
    settingsTitle.Size = UDim2.new(1, 0, 0, 50)
    settingsTitle.Position = UDim2.new(0, 0, 0, 0)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "Settings"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 36
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Parent = settingsFrame
    
    -- Create back button
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 100, 0, 40)
    backButton.Position = UDim2.new(0, 20, 0, 10)
    backButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backButton.BorderSizePixel = 0
    backButton.Text = "Back"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.TextSize = 18
    backButton.Font = Enum.Font.GothamBold
    backButton.Parent = settingsFrame
    
    backButton.MouseButton1Click:Connect(function()
        MenuUI.showFrame(menuFrame)
    end)
    
    -- Create credits frame
    creditsFrame = Instance.new("Frame")
    creditsFrame.Name = "CreditsFrame"
    creditsFrame.Size = UDim2.new(1, 0, 1, -100)
    creditsFrame.Position = UDim2.new(0, 0, 0, 100)
    creditsFrame.BackgroundTransparency = 1
    creditsFrame.Visible = false
    creditsFrame.Parent = mainFrame
    
    -- Create credits title
    local creditsTitle = Instance.new("TextLabel")
    creditsTitle.Name = "CreditsTitle"
    creditsTitle.Size = UDim2.new(1, 0, 0, 50)
    creditsTitle.Position = UDim2.new(0, 0, 0, 0)
    creditsTitle.BackgroundTransparency = 1
    creditsTitle.Text = "Credits"
    creditsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditsTitle.TextSize = 36
    creditsTitle.Font = Enum.Font.GothamBold
    creditsTitle.Parent = creditsFrame
    
    -- Create credits text
    local creditsText = Instance.new("TextLabel")
    creditsText.Name = "CreditsText"
    creditsText.Size = UDim2.new(1, -40, 1, -100)
    creditsText.Position = UDim2.new(0, 20, 0, 60)
    creditsText.BackgroundTransparency = 1
    creditsText.Text = "Game created by:\n\nLead Developer: [Your Name]\nArt Director: [Artist Name]\nSound Designer: [Sound Designer Name]\n\nSpecial thanks to:\n• [Name 1]\n• [Name 2]\n• [Name 3]"
    creditsText.TextColor3 = Color3.fromRGB(200, 200, 200)
    creditsText.TextSize = 20
    creditsText.Font = Enum.Font.Gotham
    creditsText.TextXAlignment = Enum.TextXAlignment.Left
    creditsText.TextYAlignment = Enum.TextYAlignment.Top
    creditsText.Parent = creditsFrame
    
    -- Create back button
    local creditsBackButton = Instance.new("TextButton")
    creditsBackButton.Name = "BackButton"
    creditsBackButton.Size = UDim2.new(0, 100, 0, 40)
    creditsBackButton.Position = UDim2.new(0, 20, 0, 10)
    creditsBackButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    creditsBackButton.BorderSizePixel = 0
    creditsBackButton.Text = "Back"
    creditsBackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditsBackButton.TextSize = 18
    creditsBackButton.Font = Enum.Font.GothamBold
    creditsBackButton.Parent = creditsFrame
    
    creditsBackButton.MouseButton1Click:Connect(function()
        MenuUI.showFrame(menuFrame)
    end)
    
    -- Set initial frame
    currentFrame = menuFrame
end

-- Show frame
function MenuUI.showFrame(frame)
    if currentFrame then
        currentFrame.Visible = false
    end
    currentFrame = frame
    frame.Visible = true
end

-- Show menu UI
function MenuUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide menu UI
function MenuUI.hide()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 1
    })
    tween:Play()
    
    task.delay(0.3, function()
        mainFrame.Visible = false
    end)
end

-- Initialize
function MenuUI.init()
    MenuUI.create()
    
    -- Set up input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
            if mainFrame.Visible then
                MenuUI.hide()
            else
                MenuUI.show()
            end
        end
    end)
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowMenu, function()
        MenuUI.show()
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.HideMenu, function()
        MenuUI.hide()
    end)
end

return MenuUI 