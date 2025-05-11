local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local FriendsUI = {}

-- UI Elements
local screenGui
local mainFrame
local friendList
local closeButton

-- Create UI
function FriendsUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FriendsUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
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
    title.Text = "Friends"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create friend list
    friendList = Instance.new("ScrollingFrame")
    friendList.Name = "FriendList"
    friendList.Size = UDim2.new(1, -20, 1, -50)
    friendList.Position = UDim2.new(0, 10, 0, 50)
    friendList.BackgroundTransparency = 1
    friendList.BorderSizePixel = 0
    friendList.ScrollBarThickness = 6
    friendList.CanvasSize = UDim2.new(0, 0, 0, 0)
    friendList.Parent = mainFrame
    
    -- Create add friend button
    local addFriendButton = Instance.new("TextButton")
    addFriendButton.Name = "AddFriendButton"
    addFriendButton.Size = UDim2.new(0, 120, 0, 30)
    addFriendButton.Position = UDim2.new(0.5, -60, 1, -40)
    addFriendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    addFriendButton.BorderSizePixel = 0
    addFriendButton.Text = "Add Friend"
    addFriendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addFriendButton.TextSize = 16
    addFriendButton.Font = Enum.Font.Gotham
    addFriendButton.Parent = mainFrame
    
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
        FriendsUI.hide()
    end)
    
    addFriendButton.MouseButton1Click:Connect(function()
        FriendsUI.showAddFriendDialog()
    end)
end

-- Show add friend dialog
function FriendsUI.showAddFriendDialog()
    local dialog = Instance.new("Frame")
    dialog.Name = "AddFriendDialog"
    dialog.Size = UDim2.new(0, 300, 0, 200)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -100)
    dialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dialog.BorderSizePixel = 0
    dialog.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Add Friend"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = dialog
    
    local input = Instance.new("TextBox")
    input.Name = "UsernameInput"
    input.Size = UDim2.new(1, -40, 0, 40)
    input.Position = UDim2.new(0, 20, 0, 60)
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = "Enter username"
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 16
    input.Font = Enum.Font.Gotham
    input.Parent = dialog
    
    local addButton = Instance.new("TextButton")
    addButton.Name = "AddButton"
    addButton.Size = UDim2.new(0, 100, 0, 30)
    addButton.Position = UDim2.new(0.5, -50, 1, -40)
    addButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    addButton.BorderSizePixel = 0
    addButton.Text = "Add"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 16
    addButton.Font = Enum.Font.Gotham
    addButton.Parent = dialog
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = dialog
    
    -- Set up button events
    addButton.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            RemoteManager:fireServer(Constants.RemoteEvents.AddFriend, input.Text)
            dialog:Destroy()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Show UI
function FriendsUI.show()
    mainFrame.Visible = true
end

-- Hide UI
function FriendsUI.hide()
    mainFrame.Visible = false
end

-- Update friend list
function FriendsUI.updateFriends(friends)
    -- Clear existing friends
    for _, child in ipairs(friendList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new friends
    local yOffset = 0
    for _, friend in ipairs(friends) do
        local friendButton = Instance.new("Frame")
        friendButton.Name = friend.id
        friendButton.Size = UDim2.new(1, 0, 0, 50)
        friendButton.Position = UDim2.new(0, 0, 0, yOffset)
        friendButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        friendButton.BorderSizePixel = 0
        friendButton.Parent = friendList
        
        -- Friend name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = friend.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 16
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = friendButton
        
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
        
        -- Remove friend button
        local removeButton = Instance.new("TextButton")
        removeButton.Name = "RemoveButton"
        removeButton.Size = UDim2.new(0, 80, 0, 30)
        removeButton.Position = UDim2.new(1, -90, 0.5, -15)
        removeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        removeButton.BorderSizePixel = 0
        removeButton.Text = "Remove"
        removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeButton.TextSize = 14
        removeButton.Font = Enum.Font.Gotham
        removeButton.Parent = friendButton
        
        -- Set up remove button event
        removeButton.MouseButton1Click:Connect(function()
            RemoteManager:fireServer(Constants.RemoteEvents.RemoveFriend, friend.id)
        end)
        
        yOffset = yOffset + 60
    end
    
    -- Update canvas size
    friendList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function FriendsUI.init()
    FriendsUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.FriendUpdate, function(friends)
        FriendsUI.updateFriends(friends)
    end)
end

return FriendsUI 