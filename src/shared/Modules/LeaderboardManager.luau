local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local LeaderboardManager = {}

-- Leaderboard categories
local CATEGORIES = {
    COINS = "coins",
    OBJECTS_PLACED = "objects_placed",
    DAILY_STREAK = "daily_streak",
    TOTAL_PURCHASES = "total_purchases"
}

-- Local state
local leaderboardData = {}

-- Initialize leaderboard data
function LeaderboardManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getLeaderboardEvent = Instance.new("RemoteFunction")
    getLeaderboardEvent.Name = "GetLeaderboard"
    getLeaderboardEvent.Parent = remotes
    
    local updateLeaderboardEvent = Instance.new("RemoteEvent")
    updateLeaderboardEvent.Name = "UpdateLeaderboard"
    updateLeaderboardEvent.Parent = remotes
    
    -- Set up event handlers
    getLeaderboardEvent.OnServerInvoke = function(player, category)
        return LeaderboardManager.getLeaderboard(category)
    end
    
    updateLeaderboardEvent.OnServerEvent:Connect(function(player, category, value)
        LeaderboardManager.updatePlayerScore(player, category, value)
    end)
end

-- Update player score
function LeaderboardManager.updatePlayerScore(player, category, value)
    if not CATEGORIES[category] then return end
    
    local userId = player.UserId
    if not leaderboardData[userId] then
        leaderboardData[userId] = {
            name = player.Name,
            scores = {}
        }
    end
    
    leaderboardData[userId].scores[category] = value
    LeaderboardManager.broadcastUpdate(category)
end

-- Get leaderboard for category
function LeaderboardManager.getLeaderboard(category)
    if not CATEGORIES[category] then return {} end
    
    local scores = {}
    for userId, data in pairs(leaderboardData) do
        if data.scores[category] then
            table.insert(scores, {
                userId = userId,
                name = data.name,
                score = data.scores[category]
            })
        end
    end
    
    -- Sort by score
    table.sort(scores, function(a, b)
        return a.score > b.score
    end)
    
    return scores
end

-- Broadcast leaderboard update
function LeaderboardManager.broadcastUpdate(category)
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local updateEvent = remotes:WaitForChild("UpdateLeaderboard")
    
    updateEvent:FireAllClients(category, LeaderboardManager.getLeaderboard(category))
end

-- Get player rank
function LeaderboardManager.getPlayerRank(player, category)
    local leaderboard = LeaderboardManager.getLeaderboard(category)
    for i, entry in ipairs(leaderboard) do
        if entry.userId == player.UserId then
            return i
        end
    end
    return nil
end

-- Get player stats
function LeaderboardManager.getPlayerStats(player)
    local userId = player.UserId
    if not leaderboardData[userId] then return nil end
    
    return leaderboardData[userId].scores
end

return LeaderboardManager 