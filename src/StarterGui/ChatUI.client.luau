local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local ChatUI = {}

-- UI Elements
local screenGui
local mainFrame
local chatList
local inputFrame
local inputBox
local sendButton

-- Create UI
function ChatUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChatUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0, 20, 1, -320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create chat list
    chatList = Instance.new("ScrollingFrame")
    chatList.Name = "ChatList"
    chatList.Size = UDim2.new(1, 0, 1, -50)
    chatList.Position = UDim2.new(0, 0, 0, 0)
    chatList.BackgroundTransparency = 1
    chatList.BorderSizePixel = 0
    chatList.ScrollBarThickness = 6
    chatList.ScrollingDirection = Enum.ScrollingDirection.Y
    chatList.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatList.Parent = mainFrame
    
    -- Create list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = chatList
    
    -- Create input frame
    inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, 0, 0, 40)
    inputFrame.Position = UDim2.new(0, 0, 1, -40)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = mainFrame
    
    -- Create input box
    inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -60, 1, -10)
    inputBox.Position = UDim2.new(0, 5, 0, 5)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = "Type a message..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Center
    inputBox.Parent = inputFrame
    
    -- Create send button
    sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0, 50, 1, -10)
    sendButton.Position = UDim2.new(1, -55, 0, 5)
    sendButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "Send"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 14
    sendButton.Font = Enum.Font.GothamBold
    sendButton.Parent = inputFrame
end

-- Create chat message
function ChatUI.createMessage(sender, message, messageType)
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "MessageFrame"
    messageFrame.Size = UDim2.new(1, 0, 0, 20)
    messageFrame.BackgroundTransparency = 1
    
    -- Create sender name
    local senderLabel = Instance.new("TextLabel")
    senderLabel.Name = "SenderLabel"
    senderLabel.Size = UDim2.new(0, 100, 1, 0)
    senderLabel.Position = UDim2.new(0, 0, 0, 0)
    senderLabel.BackgroundTransparency = 1
    senderLabel.Text = sender.Name .. ":"
    senderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    senderLabel.TextSize = 14
    senderLabel.Font = Enum.Font.GothamBold
    senderLabel.TextXAlignment = Enum.TextXAlignment.Left
    senderLabel.Parent = messageFrame
    
    -- Create message text
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(1, -110, 1, 0)
    messageLabel.Position = UDim2.new(0, 110, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = messageFrame
    
    -- Set message type color
    if messageType == "system" then
        senderLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        messageLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    elseif messageType == "team" then
        senderLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        messageLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    end
    
    -- Calculate message height
    local textSize = messageLabel.TextBounds
    messageFrame.Size = UDim2.new(1, 0, 0, math.max(20, textSize.Y + 10))
    messageLabel.Size = UDim2.new(1, -110, 1, 0)
    
    return messageFrame
end

-- Add message to chat
function ChatUI.addMessage(sender, message, messageType)
    local messageFrame = ChatUI.createMessage(sender, message, messageType)
    messageFrame.Parent = chatList
    
    -- Update canvas size
    local totalHeight = 0
    for _, child in ipairs(chatList:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.Size.Y.Offset + 5
        end
    end
    chatList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    
    -- Scroll to bottom
    chatList.CanvasPosition = Vector2.new(0, totalHeight)
end

-- Send message
function ChatUI.sendMessage()
    local message = inputBox.Text
    if message ~= "" then
        RemoteManager:fireServer(Constants.RemoteEvents.SendChatMessage, message)
        inputBox.Text = ""
    end
end

-- Show chat
function ChatUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
    
    inputBox:CaptureFocus()
end

-- Hide chat
function ChatUI.hide()
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
function ChatUI.init()
    ChatUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ChatMessage, function(sender, message, messageType)
        ChatUI.addMessage(sender, message, messageType)
    end)
    
    -- Set up input handling
    sendButton.MouseButton1Click:Connect(function()
        ChatUI.sendMessage()
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ChatUI.sendMessage()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
            ChatUI.show()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
            ChatUI.hide()
        end
    end)
end

return ChatUI 