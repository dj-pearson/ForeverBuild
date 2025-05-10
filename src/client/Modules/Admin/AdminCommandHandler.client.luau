local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local adminCommandEvent = remotes:WaitForChild("AdminCommand")

-- Create command UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminCommandUI"
screenGui.Parent = playerGui

local commandFrame = Instance.new("Frame")
commandFrame.Name = "CommandFrame"
commandFrame.Size = UDim2.new(0, 400, 0, 40)
commandFrame.Position = UDim2.new(0.5, -200, 0, 10)
commandFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
commandFrame.BorderSizePixel = 0
commandFrame.Visible = false
commandFrame.Parent = screenGui

local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1, -20, 1, 0)
commandBox.Position = UDim2.new(0, 10, 0, 0)
commandBox.BackgroundTransparency = 1
commandBox.Text = ""
commandBox.TextColor3 = Color3.new(1, 1, 1)
commandBox.TextSize = 16
commandBox.PlaceholderText = "Type /help for commands..."
commandBox.Parent = commandFrame

local responseFrame = Instance.new("Frame")
responseFrame.Name = "ResponseFrame"
responseFrame.Size = UDim2.new(0, 400, 0, 100)
responseFrame.Position = UDim2.new(0.5, -200, 0, 60)
responseFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
responseFrame.BorderSizePixel = 0
responseFrame.Visible = false
responseFrame.Parent = screenGui

local responseText = Instance.new("TextLabel")
responseText.Name = "ResponseText"
responseText.Size = UDim2.new(1, -20, 1, -20)
responseText.Position = UDim2.new(0, 10, 0, 10)
responseText.BackgroundTransparency = 1
responseText.Text = ""
responseText.TextColor3 = Color3.new(1, 1, 1)
responseText.TextSize = 16
responseText.TextWrapped = true
responseText.TextXAlignment = Enum.TextXAlignment.Left
responseText.TextYAlignment = Enum.TextYAlignment.Top
responseText.Parent = responseFrame

-- Variables
local isAdmin = false

-- Functions
local function showCommandUI()
    commandFrame.Visible = true
    commandFrame.BackgroundTransparency = 1
    TweenService:Create(commandFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
end

local function hideCommandUI()
    TweenService:Create(commandFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    commandFrame.Visible = false
end

local function showResponse(success, message)
    responseFrame.Visible = true
    responseFrame.BackgroundTransparency = 1
    responseText.TextColor3 = success and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    responseText.Text = message
    
    TweenService:Create(responseFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    
    wait(3)
    TweenService:Create(responseFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    responseFrame.Visible = false
end

local function parseCommand(text)
    if not text:match("^/") then return end
    
    local command = text:match("^/(%S+)")
    local args = {}
    
    for arg in text:gmatch("%S+") do
        if arg ~= "/" .. command then
            table.insert(args, arg)
        end
    end
    
    return command, args
end

-- Event handlers
commandBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    
    local command, args = parseCommand(commandBox.Text)
    if command then
        adminCommandEvent:FireServer(command, args)
    end
    
    commandBox.Text = ""
end)

adminCommandEvent.OnClientEvent:Connect(function(success, message)
    showResponse(success, message)
end)

-- Check for admin status
player:GetAttributeChangedSignal("IsAdmin"):Connect(function()
    isAdmin = player:GetAttribute("IsAdmin")
    if isAdmin then
        showCommandUI()
    else
        hideCommandUI()
    end
end)

-- Initial admin check
isAdmin = player:GetAttribute("IsAdmin")
if isAdmin then
    showCommandUI()
end 