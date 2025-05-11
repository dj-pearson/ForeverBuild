local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local LoadingUI = {}

-- UI Elements
local screenGui
local mainFrame
local loadingBar
local loadingText
local tipText
local progressText

-- Create UI
function LoadingUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create loading bar background
    local barBackground = Instance.new("Frame")
    barBackground.Name = "BarBackground"
    barBackground.Size = UDim2.new(0, 400, 0, 20)
    barBackground.Position = UDim2.new(0.5, -200, 0.5, 0)
    barBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBackground.BorderSizePixel = 0
    barBackground.Parent = mainFrame
    
    -- Create loading bar
    loadingBar = Instance.new("Frame")
    loadingBar.Name = "LoadingBar"
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.Position = UDim2.new(0, 0, 0, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = barBackground
    
    -- Create loading text
    loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(0, 400, 0, 30)
    loadingText.Position = UDim2.new(0.5, -200, 0.5, -50)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextSize = 24
    loadingText.Font = Enum.Font.GothamBold
    loadingText.Parent = mainFrame
    
    -- Create progress text
    progressText = Instance.new("TextLabel")
    progressText.Name = "ProgressText"
    progressText.Size = UDim2.new(0, 400, 0, 30)
    progressText.Position = UDim2.new(0.5, -200, 0.5, 30)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(200, 200, 200)
    progressText.TextSize = 18
    progressText.Font = Enum.Font.Gotham
    progressText.Parent = mainFrame
    
    -- Create tip text
    tipText = Instance.new("TextLabel")
    tipText.Name = "TipText"
    tipText.Size = UDim2.new(0, 600, 0, 60)
    tipText.Position = UDim2.new(0.5, -300, 0.5, 100)
    tipText.BackgroundTransparency = 1
    tipText.Text = ""
    tipText.TextColor3 = Color3.fromRGB(150, 150, 150)
    tipText.TextSize = 16
    tipText.Font = Enum.Font.Gotham
    tipText.TextWrapped = true
    tipText.Parent = mainFrame
end

-- Update progress
function LoadingUI.updateProgress(progress, message, tip)
    -- Update loading bar
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(loadingBar, tweenInfo, {
        Size = UDim2.new(progress, 0, 1, 0)
    })
    tween:Play()
    
    -- Update loading text
    if message then
        loadingText.Text = message
    end
    
    -- Update progress text
    progressText.Text = math.floor(progress * 100) .. "%"
    
    -- Update tip text
    if tip then
        tipText.Text = "Tip: " .. tip
    end
end

-- Show loading UI
function LoadingUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide loading UI
function LoadingUI.hide()
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
function LoadingUI.init()
    LoadingUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.LoadingProgress, function(data)
        LoadingUI.updateProgress(data.progress, data.message, data.tip)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowLoading, function()
        LoadingUI.show()
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.HideLoading, function()
        LoadingUI.hide()
    end)
end

return LoadingUI 