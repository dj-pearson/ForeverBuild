local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SocialInteractionUI = {}

-- UI Elements
local screenGui
local interactionFrame
local likesFrame
local commentsFrame
local commentInput

-- Remote events
local likeObjectEvent = ReplicatedStorage.Remotes.LikeObject
local unlikeObjectEvent = ReplicatedStorage.Remotes.UnlikeObject
local addCommentEvent = ReplicatedStorage.Remotes.AddComment
local removeCommentEvent = ReplicatedStorage.Remotes.RemoveComment
local getObjectInteractionsEvent = ReplicatedStorage.Remotes.GetObjectInteractions
local objectInteractionNotificationEvent = ReplicatedStorage.Remotes.ObjectInteractionNotification

-- Current object
local currentObjectId = nil

-- Create UI
function SocialInteractionUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SocialInteractionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create interaction frame
    interactionFrame = Instance.new("Frame")
    interactionFrame.Name = "InteractionFrame"
    interactionFrame.Size = UDim2.new(0, 300, 0, 400)
    interactionFrame.Position = UDim2.new(1, -320, 0.5, -200)
    interactionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    interactionFrame.BorderSizePixel = 0
    interactionFrame.Visible = false
    interactionFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Object Interactions"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = interactionFrame
    
    -- Create likes frame
    likesFrame = Instance.new("Frame")
    likesFrame.Name = "LikesFrame"
    likesFrame.Size = UDim2.new(1, -20, 0, 100)
    likesFrame.Position = UDim2.new(0, 10, 0, 50)
    likesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    likesFrame.BorderSizePixel = 0
    likesFrame.Parent = interactionFrame
    
    -- Create like button
    local likeButton = Instance.new("TextButton")
    likeButton.Name = "LikeButton"
    likeButton.Size = UDim2.new(0, 100, 0, 30)
    likeButton.Position = UDim2.new(0.5, -50, 0, 10)
    likeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    likeButton.BorderSizePixel = 0
    likeButton.Text = "Like"
    likeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    likeButton.TextSize = 16
    likeButton.Font = Enum.Font.Gotham
    likeButton.Parent = likesFrame
    
    -- Create likes count
    local likesCount = Instance.new("TextLabel")
    likesCount.Name = "LikesCount"
    likesCount.Size = UDim2.new(1, -20, 0, 20)
    likesCount.Position = UDim2.new(0, 10, 0, 50)
    likesCount.BackgroundTransparency = 1
    likesCount.Text = "0 likes"
    likesCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    likesCount.TextSize = 16
    likesCount.Font = Enum.Font.Gotham
    likesCount.Parent = likesFrame
    
    -- Create comments frame
    commentsFrame = Instance.new("ScrollingFrame")
    commentsFrame.Name = "CommentsFrame"
    commentsFrame.Size = UDim2.new(1, -20, 0, 200)
    commentsFrame.Position = UDim2.new(0, 10, 0, 160)
    commentsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    commentsFrame.BorderSizePixel = 0
    commentsFrame.ScrollBarThickness = 6
    commentsFrame.Parent = interactionFrame
    
    -- Create comment input
    commentInput = Instance.new("TextBox")
    commentInput.Name = "CommentInput"
    commentInput.Size = UDim2.new(1, -20, 0, 40)
    commentInput.Position = UDim2.new(0, 10, 1, -50)
    commentInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    commentInput.BorderSizePixel = 0
    commentInput.Text = ""
    commentInput.PlaceholderText = "Add a comment..."
    commentInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    commentInput.TextSize = 16
    commentInput.Font = Enum.Font.Gotham
    commentInput.Parent = interactionFrame
    
    -- Create send button
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.new(0, 80, 0, 30)
    sendButton.Position = UDim2.new(1, -90, 1, -45)
    sendButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "Send"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 16
    sendButton.Font = Enum.Font.Gotham
    sendButton.Parent = interactionFrame
    
    -- Set up button events
    likeButton.MouseButton1Click:Connect(function()
        if currentObjectId then
            local success = likeObjectEvent:InvokeServer(currentObjectId)
            if success then
                SocialInteractionUI.refreshInteractions()
            end
        end
    end)
    
    sendButton.MouseButton1Click:Connect(function()
        if currentObjectId and commentInput.Text ~= "" then
            local success = addCommentEvent:InvokeServer(currentObjectId, commentInput.Text)
            if success then
                commentInput.Text = ""
                SocialInteractionUI.refreshInteractions()
            end
        end
    end)
    
    -- Set up notification handler
    objectInteractionNotificationEvent.OnClientEvent:Connect(function(notification)
        if notification.objectId == currentObjectId then
            SocialInteractionUI.refreshInteractions()
        end
    end)
end

-- Update likes display
function SocialInteractionUI.updateLikes(likes)
    -- Update likes count
    local count = 0
    for _ in pairs(likes) do
        count = count + 1
    end
    
    local likesCount = likesFrame:FindFirstChild("LikesCount")
    if likesCount then
        likesCount.Text = count .. " likes"
    end
    
    -- Update like button
    local likeButton = likesFrame:FindFirstChild("LikeButton")
    if likeButton then
        local isLiked = likes[Players.LocalPlayer.UserId] ~= nil
        likeButton.Text = isLiked and "Unlike" or "Like"
        likeButton.BackgroundColor3 = isLiked and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 120, 255)
    end
end

-- Update comments display
function SocialInteractionUI.updateComments(comments)
    -- Clear existing comments
    for _, child in ipairs(commentsFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Add comments
    local y = 0
    for _, comment in ipairs(comments) do
        local commentFrame = Instance.new("Frame")
        commentFrame.Name = "Comment" .. comment.id
        commentFrame.Size = UDim2.new(1, -10, 0, 60)
        commentFrame.Position = UDim2.new(0, 5, 0, y)
        commentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        commentFrame.BorderSizePixel = 0
        commentFrame.Parent = commentsFrame
        
        -- Username
        local username = Instance.new("TextLabel")
        username.Name = "Username"
        username.Size = UDim2.new(1, -10, 0, 20)
        username.Position = UDim2.new(0, 5, 0, 5)
        username.BackgroundTransparency = 1
        username.Text = comment.username
        username.TextColor3 = Color3.fromRGB(255, 255, 255)
        username.TextSize = 14
        username.Font = Enum.Font.GothamBold
        username.TextXAlignment = Enum.TextXAlignment.Left
        username.Parent = commentFrame
        
        -- Comment text
        local text = Instance.new("TextLabel")
        text.Name = "Text"
        text.Size = UDim2.new(1, -10, 0, 20)
        text.Position = UDim2.new(0, 5, 0, 25)
        text.BackgroundTransparency = 1
        text.Text = comment.text
        text.TextColor3 = Color3.fromRGB(200, 200, 200)
        text.TextSize = 14
        text.Font = Enum.Font.Gotham
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextWrapped = true
        text.Parent = commentFrame
        
        -- Remove button (if comment owner)
        if comment.userId == Players.LocalPlayer.UserId then
            local removeButton = Instance.new("TextButton")
            removeButton.Name = "RemoveButton"
            removeButton.Size = UDim2.new(0, 60, 0, 20)
            removeButton.Position = UDim2.new(1, -65, 0, 5)
            removeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            removeButton.BorderSizePixel = 0
            removeButton.Text = "Remove"
            removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            removeButton.TextSize = 12
            removeButton.Font = Enum.Font.Gotham
            removeButton.Parent = commentFrame
            
            removeButton.MouseButton1Click:Connect(function()
                local success = removeCommentEvent:InvokeServer(currentObjectId, comment.id)
                if success then
                    SocialInteractionUI.refreshInteractions()
                end
            end)
        end
        
        y = y + 65
    end
end

-- Refresh interactions
function SocialInteractionUI.refreshInteractions()
    if not currentObjectId then return end
    
    local interactions = getObjectInteractionsEvent:InvokeServer(currentObjectId)
    if interactions then
        SocialInteractionUI.updateLikes(interactions.likes)
        SocialInteractionUI.updateComments(interactions.comments)
    end
end

-- Show UI for object
function SocialInteractionUI.showForObject(objectId)
    currentObjectId = objectId
    interactionFrame.Visible = true
    SocialInteractionUI.refreshInteractions()
end

-- Hide UI
function SocialInteractionUI.hide()
    currentObjectId = nil
    interactionFrame.Visible = false
end

-- Initialize
function SocialInteractionUI.init()
    SocialInteractionUI.create()
end

return SocialInteractionUI 