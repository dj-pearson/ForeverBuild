local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local SocialHubUI = {}

-- UI Elements
local screenGui
local mainFrame
local friendList
local chatFrame
local closeButton

-- Create UI
function SocialHubUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SocialHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
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
    title.Text = "Social Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create friend list
    friendList = Instance.new("ScrollingFrame")
    friendList.Name = "FriendList"
    friendList.Size = UDim2.new(0.3, -20, 1, -50)
    friendList.Position = UDim2.new(0, 10, 0, 50)
    friendList.BackgroundTransparency = 1
    friendList.BorderSizePixel = 0
    friendList.ScrollBarThickness = 6
    friendList.CanvasSize = UDim2.new(0, 0, 0, 0)
    friendList.Parent = mainFrame
    
    -- Create chat frame
    chatFrame = Instance.new("Frame")
    chatFrame.Name = "ChatFrame"
    chatFrame.Size = UDim2.new(0.7, -20, 1, -50)
    chatFrame.Position = UDim2.new(0.3, 10, 0, 50)
    chatFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    chatFrame.BorderSizePixel = 0
    chatFrame.Parent = mainFrame
    
    -- Create chat messages
    local chatMessages = Instance.new("ScrollingFrame")
    chatMessages.Name = "ChatMessages"
    chatMessages.Size = UDim2.new(1, 0, 1, -50)
    chatMessages.Position = UDim2.new(0, 0, 0, 0)
    chatMessages.BackgroundTransparency = 1
    chatMessages.BorderSizePixel = 0
    chatMessages.ScrollBarThickness = 6
    chatMessages.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatMessages.Parent = chatFrame
    
    -- Create chat input
    local chatInput = Instance.new("TextBox")
    chatInput.Name = "ChatInput"
    chatInput.Size = UDim2.new(1, -20, 0, 40)
    chatInput.Position = UDim2.new(0, 10, 1, -50)
    chatInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    chatInput.BorderSizePixel = 0
    chatInput.Text = ""
    chatInput.PlaceholderText = "Type a message..."
    chatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatInput.TextSize = 16
    chatInput.Font = Enum.Font.Gotham
    chatInput.Parent = chatFrame
    
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
        SocialHubUI.hide()
    end)
    
    -- Set up chat input events
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed and chatInput.Text ~= "" then
            RemoteManager:fireServer(Constants.RemoteEvents.ChatMessage, chatInput.Text)
            chatInput.Text = ""
        end
    end)
end

-- Show UI
function SocialHubUI.show()
    mainFrame.Visible = true
end

-- Hide UI
function SocialHubUI.hide()
    mainFrame.Visible = false
end

-- Update friend list
function SocialHubUI.updateFriends(friends)
    -- Clear existing friends
    for _, child in ipairs(friendList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new friends
    local yOffset = 0
    for _, friend in ipairs(friends) do
        local friendButton = Instance.new("TextButton")
        friendButton.Name = friend.id
        friendButton.Size = UDim2.new(1, 0, 0, 50)
        friendButton.Position = UDim2.new(0, 0, 0, yOffset)
        friendButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        friendButton.BorderSizePixel = 0
        friendButton.Text = friend.name
        friendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        friendButton.TextSize = 16
        friendButton.Font = Enum.Font.GothamBold
        friendButton.Parent = friendList
        
        -- Friend status
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "Status"
        statusLabel.Size = UDim2.new(0, 100, 0, 20)
        statusLabel.Position = UDim2.new(1, -110, 0, 15)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = friend.online and "Online" or "Offline"
        statusLabel.TextColor3 = friend.online and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = friendButton
        
        -- Friend button click handler
        friendButton.MouseButton1Click:Connect(function()
            RemoteManager:fireServer(Constants.RemoteEvents.SelectFriend, friend.id)
        end)
        
        yOffset = yOffset + 60
    end
    
    -- Update canvas size
    friendList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Add chat message
function SocialHubUI.addMessage(message)
    local chatMessages = chatFrame:FindFirstChild("ChatMessages")
    if not chatMessages then return end
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 30)
    messageLabel.Position = UDim2.new(0, 10, 0, chatMessages.CanvasSize.Y.Offset)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message.sender .. ": " .. message.text
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = chatMessages
    
    -- Update canvas size
    chatMessages.CanvasSize = UDim2.new(0, 0, 0, chatMessages.CanvasSize.Y.Offset + 40)
    
    -- Scroll to bottom
    chatMessages.CanvasPosition = Vector2.new(0, chatMessages.CanvasSize.Y.Offset)
end

-- Initialize
function SocialHubUI.init()
    SocialHubUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.FriendUpdate, function(friends)
        SocialHubUI.updateFriends(friends)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.ChatMessage, function(message)
        SocialHubUI.addMessage(message)
    end)
end

return SocialHubUI 