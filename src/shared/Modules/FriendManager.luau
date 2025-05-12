local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local FriendManager = {}

-- Friend system constants
local FRIEND_STATUS = {
    ONLINE = "online",
    OFFLINE = "offline",
    AWAY = "away",
    BUSY = "busy"
}

-- Local state
local friendData = {}
local friendRequests = {}
local friendActivity = {}

-- Initialize friend system
function FriendManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getFriendsEvent = Instance.new("RemoteFunction")
    getFriendsEvent.Name = "GetFriends"
    getFriendsEvent.Parent = remotes
    
    local sendFriendRequestEvent = Instance.new("RemoteEvent")
    sendFriendRequestEvent.Name = "SendFriendRequest"
    sendFriendRequestEvent.Parent = remotes
    
    local acceptFriendRequestEvent = Instance.new("RemoteEvent")
    acceptFriendRequestEvent.Name = "AcceptFriendRequest"
    acceptFriendRequestEvent.Parent = remotes
    
    local rejectFriendRequestEvent = Instance.new("RemoteEvent")
    rejectFriendRequestEvent.Name = "RejectFriendRequest"
    rejectFriendRequestEvent.Parent = remotes
    
    local updateFriendStatusEvent = Instance.new("RemoteEvent")
    updateFriendStatusEvent.Name = "UpdateFriendStatus"
    updateFriendStatusEvent.Parent = remotes
    
    local getFriendActivityEvent = Instance.new("RemoteFunction")
    getFriendActivityEvent.Name = "GetFriendActivity"
    getFriendActivityEvent.Parent = remotes
    
    -- Set up event handlers
    getFriendsEvent.OnServerInvoke = function(player)
        return FriendManager.getFriends(player)
    end
    
    sendFriendRequestEvent.OnServerEvent:Connect(function(player, targetUserId)
        FriendManager.sendFriendRequest(player, targetUserId)
    end)
    
    acceptFriendRequestEvent.OnServerEvent:Connect(function(player, requestId)
        FriendManager.acceptFriendRequest(player, requestId)
    end)
    
    rejectFriendRequestEvent.OnServerEvent:Connect(function(player, requestId)
        FriendManager.rejectFriendRequest(player, requestId)
    end)
    
    updateFriendStatusEvent.OnServerEvent:Connect(function(player, status)
        FriendManager.updateFriendStatus(player, status)
    end)
    
    getFriendActivityEvent.OnServerInvoke = function(player)
        return FriendManager.getFriendActivity(player)
    end
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        FriendManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        FriendManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function FriendManager.handlePlayerJoin(player)
    local userId = player.UserId
    
    -- Initialize friend data if not exists
    if not friendData[userId] then
        friendData[userId] = {
            friends = {},
            status = FRIEND_STATUS.ONLINE,
            lastSeen = os.time()
        }
    end
    
    -- Update status
    friendData[userId].status = FRIEND_STATUS.ONLINE
    friendData[userId].lastSeen = os.time()
    
    -- Notify friends
    FriendManager.notifyFriendsOfStatusChange(userId)
end

-- Handle player leaving
function FriendManager.handlePlayerLeave(player)
    local userId = player.UserId
    
    if friendData[userId] then
        friendData[userId].status = FRIEND_STATUS.OFFLINE
        friendData[userId].lastSeen = os.time()
        
        -- Notify friends
        FriendManager.notifyFriendsOfStatusChange(userId)
    end
end

-- Get friends list
function FriendManager.getFriends(player)
    local userId = player.UserId
    if not friendData[userId] then return {} end
    
    local friends = {}
    for friendId, _ in pairs(friendData[userId].friends) do
        local friendData = friendData[friendId]
        if friendData then
            table.insert(friends, {
                userId = friendId,
                status = friendData.status,
                lastSeen = friendData.lastSeen
            })
        end
    end
    
    return friends
end

-- Send friend request
function FriendManager.sendFriendRequest(player, targetUserId)
    local userId = player.UserId
    
    -- Validate request
    if userId == targetUserId then return end
    if friendData[userId] and friendData[userId].friends[targetUserId] then return end
    
    -- Create request
    local requestId = userId .. "_" .. targetUserId
    friendRequests[requestId] = {
        from = userId,
        to = targetUserId,
        timestamp = os.time()
    }
    
    -- Notify target player
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    if targetPlayer then
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        local notificationEvent = remotes:WaitForChild("FriendRequestNotification")
        notificationEvent:FireClient(targetPlayer, {
            requestId = requestId,
            fromUserId = userId,
            fromName = player.Name
        })
    end
end

-- Accept friend request
function FriendManager.acceptFriendRequest(player, requestId)
    local request = friendRequests[requestId]
    if not request then return end
    
    local userId = player.UserId
    if request.to ~= userId then return end
    
    -- Add friends
    if not friendData[request.from] then
        friendData[request.from] = {
            friends = {},
            status = FRIEND_STATUS.OFFLINE,
            lastSeen = os.time()
        }
    end
    
    if not friendData[userId] then
        friendData[userId] = {
            friends = {},
            status = FRIEND_STATUS.ONLINE,
            lastSeen = os.time()
        }
    end
    
    friendData[request.from].friends[userId] = true
    friendData[userId].friends[request.from] = true
    
    -- Remove request
    friendRequests[requestId] = nil
    
    -- Notify both players
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local updateEvent = remotes:WaitForChild("FriendsListUpdate")
    
    local fromPlayer = Players:GetPlayerByUserId(request.from)
    if fromPlayer then
        updateEvent:FireClient(fromPlayer)
    end
    
    updateEvent:FireClient(player)
end

-- Reject friend request
function FriendManager.rejectFriendRequest(player, requestId)
    local request = friendRequests[requestId]
    if not request then return end
    
    local userId = player.UserId
    if request.to ~= userId then return end
    
    -- Remove request
    friendRequests[requestId] = nil
end

-- Update friend status
function FriendManager.updateFriendStatus(player, status)
    local userId = player.UserId
    if not friendData[userId] then return end
    
    friendData[userId].status = status
    friendData[userId].lastSeen = os.time()
    
    -- Notify friends
    FriendManager.notifyFriendsOfStatusChange(userId)
end

-- Notify friends of status change
function FriendManager.notifyFriendsOfStatusChange(userId)
    if not friendData[userId] then return end
    
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local statusEvent = remotes:WaitForChild("FriendStatusUpdate")
    
    for friendId, _ in pairs(friendData[userId].friends) do
        local friendPlayer = Players:GetPlayerByUserId(friendId)
        if friendPlayer then
            statusEvent:FireClient(friendPlayer, {
                userId = userId,
                status = friendData[userId].status,
                lastSeen = friendData[userId].lastSeen
            })
        end
    end
end

-- Add friend activity
function FriendManager.addFriendActivity(userId, activityType, data)
    if not friendActivity[userId] then
        friendActivity[userId] = {}
    end
    
    table.insert(friendActivity[userId], {
        type = activityType,
        data = data,
        timestamp = os.time()
    })
    
    -- Keep only last 50 activities
    if #friendActivity[userId] > 50 then
        table.remove(friendActivity[userId], 1)
    end
end

-- Get friend activity
function FriendManager.getFriendActivity(player)
    local userId = player.UserId
    if not friendData[userId] then return {} end
    
    local activities = {}
    for friendId, _ in pairs(friendData[userId].friends) do
        if friendActivity[friendId] then
            for _, activity in ipairs(friendActivity[friendId]) do
                table.insert(activities, {
                    userId = friendId,
                    type = activity.type,
                    data = activity.data,
                    timestamp = activity.timestamp
                })
            end
        end
    end
    
    -- Sort by timestamp
    table.sort(activities, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    -- Return only last 20 activities
    local result = {}
    for i = 1, math.min(20, #activities) do
        table.insert(result, activities[i])
    end
    
    return result
end

return FriendManager 