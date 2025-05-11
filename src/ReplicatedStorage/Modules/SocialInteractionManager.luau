local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SocialInteractionManager = {}

-- Local state
local objectInteractions = {} -- Stores likes and comments for each object
local playerInteractions = {} -- Tracks player interactions

-- Initialize social interaction system
function SocialInteractionManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local likeObjectEvent = Instance.new("RemoteFunction")
    likeObjectEvent.Name = "LikeObject"
    likeObjectEvent.Parent = remotes
    
    local unlikeObjectEvent = Instance.new("RemoteFunction")
    unlikeObjectEvent.Name = "UnlikeObject"
    unlikeObjectEvent.Parent = remotes
    
    local addCommentEvent = Instance.new("RemoteFunction")
    addCommentEvent.Name = "AddComment"
    addCommentEvent.Parent = remotes
    
    local removeCommentEvent = Instance.new("RemoteFunction")
    removeCommentEvent.Name = "RemoveComment"
    removeCommentEvent.Parent = remotes
    
    local getObjectInteractionsEvent = Instance.new("RemoteFunction")
    getObjectInteractionsEvent.Name = "GetObjectInteractions"
    getObjectInteractionsEvent.Parent = remotes
    
    -- Set up event handlers
    likeObjectEvent.OnServerInvoke = function(player, objectId)
        return SocialInteractionManager.likeObject(player, objectId)
    end
    
    unlikeObjectEvent.OnServerInvoke = function(player, objectId)
        return SocialInteractionManager.unlikeObject(player, objectId)
    end
    
    addCommentEvent.OnServerInvoke = function(player, objectId, comment)
        return SocialInteractionManager.addComment(player, objectId, comment)
    end
    
    removeCommentEvent.OnServerInvoke = function(player, objectId, commentId)
        return SocialInteractionManager.removeComment(player, objectId, commentId)
    end
    
    getObjectInteractionsEvent.OnServerInvoke = function(player, objectId)
        return SocialInteractionManager.getObjectInteractions(objectId)
    end
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        SocialInteractionManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        SocialInteractionManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function SocialInteractionManager.handlePlayerJoin(player)
    playerInteractions[player.UserId] = {
        likes = {},
        comments = {}
    }
end

-- Handle player leaving
function SocialInteractionManager.handlePlayerLeave(player)
    playerInteractions[player.UserId] = nil
end

-- Like an object
function SocialInteractionManager.likeObject(player, objectId)
    local userId = player.UserId
    
    -- Initialize object interactions if not exists
    if not objectInteractions[objectId] then
        objectInteractions[objectId] = {
            likes = {},
            comments = {}
        }
    end
    
    -- Check if already liked
    if objectInteractions[objectId].likes[userId] then
        return false, "Already liked"
    end
    
    -- Add like
    objectInteractions[objectId].likes[userId] = {
        timestamp = os.time(),
        username = player.Name
    }
    
    -- Update player interactions
    playerInteractions[userId].likes[objectId] = true
    
    -- Notify object owner
    SocialInteractionManager.notifyObjectInteraction(objectId, "like", player)
    
    return true
end

-- Unlike an object
function SocialInteractionManager.unlikeObject(player, objectId)
    local userId = player.UserId
    
    -- Check if object exists
    if not objectInteractions[objectId] then
        return false, "Object not found"
    end
    
    -- Check if liked
    if not objectInteractions[objectId].likes[userId] then
        return false, "Not liked"
    end
    
    -- Remove like
    objectInteractions[objectId].likes[userId] = nil
    
    -- Update player interactions
    playerInteractions[userId].likes[objectId] = nil
    
    -- Notify object owner
    SocialInteractionManager.notifyObjectInteraction(objectId, "unlike", player)
    
    return true
end

-- Add a comment
function SocialInteractionManager.addComment(player, objectId, comment)
    local userId = player.UserId
    
    -- Initialize object interactions if not exists
    if not objectInteractions[objectId] then
        objectInteractions[objectId] = {
            likes = {},
            comments = {}
        }
    end
    
    -- Create comment
    local commentId = userId .. "_" .. os.time()
    local commentData = {
        id = commentId,
        userId = userId,
        username = player.Name,
        text = comment,
        timestamp = os.time()
    }
    
    -- Add comment
    table.insert(objectInteractions[objectId].comments, commentData)
    
    -- Update player interactions
    if not playerInteractions[userId].comments[objectId] then
        playerInteractions[userId].comments[objectId] = {}
    end
    table.insert(playerInteractions[userId].comments[objectId], commentId)
    
    -- Notify object owner
    SocialInteractionManager.notifyObjectInteraction(objectId, "comment", player, comment)
    
    return true, commentId
end

-- Remove a comment
function SocialInteractionManager.removeComment(player, objectId, commentId)
    local userId = player.UserId
    
    -- Check if object exists
    if not objectInteractions[objectId] then
        return false, "Object not found"
    end
    
    -- Find comment
    local commentIndex = nil
    for i, comment in ipairs(objectInteractions[objectId].comments) do
        if comment.id == commentId then
            commentIndex = i
            break
        end
    end
    
    if not commentIndex then
        return false, "Comment not found"
    end
    
    -- Check if player owns comment
    local comment = objectInteractions[objectId].comments[commentIndex]
    if comment.userId ~= userId then
        return false, "Not authorized"
    end
    
    -- Remove comment
    table.remove(objectInteractions[objectId].comments, commentIndex)
    
    -- Update player interactions
    for i, id in ipairs(playerInteractions[userId].comments[objectId]) do
        if id == commentId then
            table.remove(playerInteractions[userId].comments[objectId], i)
            break
        end
    end
    
    -- Notify object owner
    SocialInteractionManager.notifyObjectInteraction(objectId, "remove_comment", player)
    
    return true
end

-- Get object interactions
function SocialInteractionManager.getObjectInteractions(objectId)
    if not objectInteractions[objectId] then
        return {
            likes = {},
            comments = {}
        }
    end
    
    -- Sort comments by timestamp
    local sortedComments = {}
    for _, comment in ipairs(objectInteractions[objectId].comments) do
        table.insert(sortedComments, comment)
    end
    table.sort(sortedComments, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    return {
        likes = objectInteractions[objectId].likes,
        comments = sortedComments
    }
end

-- Notify object owner of interaction
function SocialInteractionManager.notifyObjectInteraction(objectId, interactionType, player, comment)
    -- Get object owner
    local objectOwner = nil -- TODO: Get object owner from GameManager
    
    if not objectOwner then return end
    
    -- Create notification
    local notification = {
        type = interactionType,
        objectId = objectId,
        playerName = player.Name,
        timestamp = os.time()
    }
    
    if comment then
        notification.comment = comment
    end
    
    -- Send notification
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local notificationEvent = remotes:WaitForChild("ObjectInteractionNotification")
    notificationEvent:FireClient(objectOwner, notification)
end

 