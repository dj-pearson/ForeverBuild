local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local FriendsUI = {}

-- UI Elements
local screenGui
local mainFrame
local friendsList
local friendRequestsList
local activityFeed
local statusButton
local addFriendButton

-- Remote events
local getFriendsEvent = ReplicatedStorage.Remotes.GetFriends
local sendFriendRequestEvent = ReplicatedStorage.Remotes.SendFriendRequest
local acceptFriendRequestEvent = ReplicatedStorage.Remotes.AcceptFriendRequest
local rejectFriendRequestEvent = ReplicatedStorage.Remotes.RejectFriendRequest
local updateFriendStatusEvent = ReplicatedStorage.Remotes.UpdateFriendStatus
local getFriendActivityEvent = ReplicatedStorage.Remotes.GetFriendActivity
local friendRequestNotificationEvent = ReplicatedStorage.Remotes.FriendRequestNotification
local friendsListUpdateEvent = ReplicatedStorage.Remotes.FriendsListUpdate
local friendStatusUpdateEvent = ReplicatedStorage.Remotes.FriendStatusUpdate

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
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(1, -420, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Friends"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create status button
    statusButton = Instance.new("TextButton")
    statusButton.Name = "StatusButton"
    statusButton.Size = UDim2.new(0, 100, 0, 30)
    statusButton.Position = UDim2.new(0, 10, 0, 60)
    statusButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    statusButton.BorderSizePixel = 0
    statusButton.Text = "Online"
    statusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusButton.TextSize = 16
    statusButton.Font = Enum.Font.Gotham
    statusButton.Parent = mainFrame
    
    -- Create add friend button
    addFriendButton = Instance.new("TextButton")
    addFriendButton.Name = "AddFriendButton"
    addFriendButton.Size = UDim2.new(0, 100, 0, 30)
    addFriendButton.Position = UDim2.new(1, -110, 0, 60)
    addFriendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    addFriendButton.BorderSizePixel = 0
    addFriendButton.Text = "Add Friend"
    addFriendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addFriendButton.TextSize = 16
    addFriendButton.Font = Enum.Font.Gotham
    addFriendButton.Parent = mainFrame
    
    -- Create friends list
    friendsList = Instance.new("ScrollingFrame")
    friendsList.Name = "FriendsList"
    friendsList.Size = UDim2.new(1, -20, 0, 200)
    friendsList.Position = UDim2.new(0, 10, 0, 100)
    friendsList.BackgroundTransparency = 1
    friendsList.BorderSizePixel = 0
    friendsList.ScrollBarThickness = 6
    friendsList.Parent = mainFrame
    
    -- Create friend requests list
    friendRequestsList = Instance.new("ScrollingFrame")
    friendRequestsList.Name = "FriendRequestsList"
    friendRequestsList.Size = UDim2.new(1, -20, 0, 150)
    friendRequestsList.Position = UDim2.new(0, 10, 0, 310)
    friendRequestsList.BackgroundTransparency = 1
    friendRequestsList.BorderSizePixel = 0
    friendRequestsList.ScrollBarThickness = 6
    friendRequestsList.Parent = mainFrame
    
    -- Create activity feed
    activityFeed = Instance.new("ScrollingFrame")
    activityFeed.Name = "ActivityFeed"
    activityFeed.Size = UDim2.new(1, -20, 0, 200)
    activityFeed.Position = UDim2.new(0, 10, 0, 470)
    activityFeed.BackgroundTransparency = 1
    activityFeed.BorderSizePixel = 0
    activityFeed.ScrollBarThickness = 6
    activityFeed.Parent = mainFrame
    
    -- Set up button events
    statusButton.MouseButton1Click:Connect(function()
        FriendsUI.showStatusMenu()
    end)
    
    addFriendButton.MouseButton1Click:Connect(function()
        FriendsUI.showAddFriendDialog()
    end)
end

-- Show status menu
function FriendsUI.showStatusMenu()
    local statuses = {
        {name = "Online", color = Color3.fromRGB(0, 170, 0)},
        {name = "Away", color = Color3.fromRGB(255, 170, 0)},
        {name = "Busy", color = Color3.fromRGB(255, 50, 50)},
        {name = "Offline", color = Color3.fromRGB(100, 100, 100)}
    }
    
    local menu = Instance.new("Frame")
    menu.Name = "StatusMenu"
    menu.Size = UDim2.new(0, 100, 0, #statuses * 30)
    menu.Position = UDim2.new(0, 0, 1, 0)
    menu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    menu.BorderSizePixel = 0
    menu.Parent = statusButton
    
    for i, status in ipairs(statuses) do
        local button = Instance.new("TextButton")
        button.Name = status.name
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        button.BackgroundColor3 = status.color
        button.BorderSizePixel = 0
        button.Text = status.name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 16
        button.Font = Enum.Font.Gotham
        button.Parent = menu
        
        button.MouseButton1Click:Connect(function()
            updateFriendStatusEvent:FireServer(status.name:lower())
            statusButton.Text = status.name
            statusButton.BackgroundColor3 = status.color
            menu:Destroy()
        end)
    end
end

-- Show add friend dialog
function FriendsUI.showAddFriendDialog()
    local dialog = Instance.new("Frame")
    dialog.Name = "AddFriendDialog"
    dialog.Size = UDim2.new(0, 300, 0, 150)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
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
    input.Name = "UserIdInput"
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 50)
    input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = "Enter User ID"
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextSize = 16
    input.Font = Enum.Font.Gotham
    input.Parent = dialog
    
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0, 100, 0, 30)
    sendButton.Position = UDim2.new(0.5, -50, 1, -40)
    sendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "Send Request"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 16
    sendButton.Font = Enum.Font.Gotham
    sendButton.Parent = dialog
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = dialog
    
    sendButton.MouseButton1Click:Connect(function()
        local userId = tonumber(input.Text)
        if userId then
            sendFriendRequestEvent:FireServer(userId)
            dialog:Destroy()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Update friends list
function FriendsUI.updateFriendsList(friends)
    -- Clear existing friends
    for _, child in ipairs(friendsList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add friends
    for i, friend in ipairs(friends) do
        local entry = Instance.new("Frame")
        entry.Name = "Friend" .. friend.userId
        entry.Size = UDim2.new(1, 0, 0, 40)
        entry.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(45, 45, 45)
        entry.BorderSizePixel = 0
        entry.Parent = friendsList
        
        -- Status indicator
        local status = Instance.new("Frame")
        status.Name = "Status"
        status.Size = UDim2.new(0, 10, 0, 10)
        status.Position = UDim2.new(0, 10, 0.5, -5)
        status.BackgroundColor3 = friend.status == "online" and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        status.BorderSizePixel = 0
        status.Parent = entry
        
        -- Name
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.Size = UDim2.new(0.7, -20, 1, 0)
        name.Position = UDim2.new(0, 30, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = friend.name
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextSize = 16
        name.Font = Enum.Font.Gotham
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = entry
        
        -- Last seen
        local lastSeen = Instance.new("TextLabel")
        lastSeen.Name = "LastSeen"
        lastSeen.Size = UDim2.new(0.3, -10, 1, 0)
        lastSeen.Position = UDim2.new(0.7, 0, 0, 0)
        lastSeen.BackgroundTransparency = 1
        lastSeen.Text = friend.status == "online" and "Online" or "Last seen: " .. os.date("%H:%M", friend.lastSeen)
        lastSeen.TextColor3 = Color3.fromRGB(200, 200, 200)
        lastSeen.TextSize = 14
        lastSeen.Font = Enum.Font.Gotham
        lastSeen.TextXAlignment = Enum.TextXAlignment.Right
        lastSeen.Parent = entry
    end
end

-- Update friend requests list
function FriendsUI.updateFriendRequestsList(requests)
    -- Clear existing requests
    for _, child in ipairs(friendRequestsList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add requests
    for i, request in ipairs(requests) do
        local entry = Instance.new("Frame")
        entry.Name = "Request" .. request.requestId
        entry.Size = UDim2.new(1, 0, 0, 40)
        entry.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(45, 45, 45)
        entry.BorderSizePixel = 0
        entry.Parent = friendRequestsList
        
        -- Name
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.Size = UDim2.new(0.6, -10, 1, 0)
        name.Position = UDim2.new(0, 10, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = request.fromName
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextSize = 16
        name.Font = Enum.Font.Gotham
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = entry
        
        -- Accept button
        local acceptButton = Instance.new("TextButton")
        acceptButton.Name = "AcceptButton"
        acceptButton.Size = UDim2.new(0, 60, 0, 25)
        acceptButton.Position = UDim2.new(0.6, 5, 0.5, -12.5)
        acceptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        acceptButton.BorderSizePixel = 0
        acceptButton.Text = "Accept"
        acceptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        acceptButton.TextSize = 14
        acceptButton.Font = Enum.Font.Gotham
        acceptButton.Parent = entry
        
        -- Reject button
        local rejectButton = Instance.new("TextButton")
        rejectButton.Name = "RejectButton"
        rejectButton.Size = UDim2.new(0, 60, 0, 25)
        rejectButton.Position = UDim2.new(0.8, 5, 0.5, -12.5)
        rejectButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        rejectButton.BorderSizePixel = 0
        rejectButton.Text = "Reject"
        rejectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        rejectButton.TextSize = 14
        rejectButton.Font = Enum.Font.Gotham
        rejectButton.Parent = entry
        
        acceptButton.MouseButton1Click:Connect(function()
            acceptFriendRequestEvent:FireServer(request.requestId)
        end)
        
        rejectButton.MouseButton1Click:Connect(function()
            rejectFriendRequestEvent:FireServer(request.requestId)
        end)
    end
end

-- Update activity feed
function FriendsUI.updateActivityFeed(activities)
    -- Clear existing activities
    for _, child in ipairs(activityFeed:GetChildren()) do
        child:Destroy()
    end
    
    -- Add activities
    for i, activity in ipairs(activities) do
        local entry = Instance.new("Frame")
        entry.Name = "Activity" .. i
        entry.Size = UDim2.new(1, 0, 0, 40)
        entry.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(45, 45, 45)
        entry.BorderSizePixel = 0
        entry.Parent = activityFeed
        
        -- Activity text
        local text = Instance.new("TextLabel")
        text.Name = "Text"
        text.Size = UDim2.new(0.8, -10, 1, 0)
        text.Position = UDim2.new(0, 10, 0, 0)
        text.BackgroundTransparency = 1
        text.Text = activity.data.text
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextSize = 14
        text.Font = Enum.Font.Gotham
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Parent = entry
        
        -- Timestamp
        local timestamp = Instance.new("TextLabel")
        timestamp.Name = "Timestamp"
        timestamp.Size = UDim2.new(0.2, -10, 1, 0)
        timestamp.Position = UDim2.new(0.8, 0, 0, 0)
        timestamp.BackgroundTransparency = 1
        timestamp.Text = os.date("%H:%M", activity.timestamp)
        timestamp.TextColor3 = Color3.fromRGB(200, 200, 200)
        timestamp.TextSize = 12
        timestamp.Font = Enum.Font.Gotham
        timestamp.TextXAlignment = Enum.TextXAlignment.Right
        timestamp.Parent = entry
    end
end

-- Show UI
function FriendsUI.show()
    mainFrame.Visible = true
    
    -- Get initial data
    local friends = getFriendsEvent:InvokeServer()
    if friends then
        FriendsUI.updateFriendsList(friends)
    end
    
    local activities = getFriendActivityEvent:InvokeServer()
    if activities then
        FriendsUI.updateActivityFeed(activities)
    end
end

-- Hide UI
function FriendsUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function FriendsUI.init()
    FriendsUI.create()
    
    -- Set up event handlers
    friendRequestNotificationEvent.OnClientEvent:Connect(function(request)
        FriendsUI.updateFriendRequestsList({request})
    end)
    
    friendsListUpdateEvent.OnClientEvent:Connect(function()
        local friends = getFriendsEvent:InvokeServer()
        if friends then
            FriendsUI.updateFriendsList(friends)
        end
    end)
    
    friendStatusUpdateEvent.OnClientEvent:Connect(function(update)
        local friends = getFriendsEvent:InvokeServer()
        if friends then
            FriendsUI.updateFriendsList(friends)
        end
    end)
end

return FriendsUI 