local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local PlayerProfileManager = {}

-- Local state
local playerProfiles = {} -- Stores player profile data
local showcaseAreas = {} -- Stores showcase area data

-- Initialize player profile system
function PlayerProfileManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getProfileEvent = Instance.new("RemoteFunction")
    getProfileEvent.Name = "GetPlayerProfile"
    getProfileEvent.Parent = remotes
    
    local updateProfileEvent = Instance.new("RemoteFunction")
    updateProfileEvent.Name = "UpdatePlayerProfile"
    updateProfileEvent.Parent = remotes
    
    local getShowcaseEvent = Instance.new("RemoteFunction")
    getShowcaseEvent.Name = "GetShowcaseArea"
    getShowcaseEvent.Parent = remotes
    
    local updateShowcaseEvent = Instance.new("RemoteFunction")
    updateShowcaseEvent.Name = "UpdateShowcaseArea"
    updateShowcaseEvent.Parent = remotes
    
    -- Set up event handlers
    getProfileEvent.OnServerInvoke = function(player, targetUserId)
        return PlayerProfileManager.getProfile(targetUserId)
    end
    
    updateProfileEvent.OnServerInvoke = function(player, profileData)
        return PlayerProfileManager.updateProfile(player, profileData)
    end
    
    getShowcaseEvent.OnServerInvoke = function(player, targetUserId)
        return PlayerProfileManager.getShowcaseArea(targetUserId)
    end
    
    updateShowcaseEvent.OnServerInvoke = function(player, showcaseData)
        return PlayerProfileManager.updateShowcaseArea(player, showcaseData)
    end
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        PlayerProfileManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        PlayerProfileManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function PlayerProfileManager.handlePlayerJoin(player)
    local userId = player.UserId
    
    -- Initialize profile if not exists
    if not playerProfiles[userId] then
        playerProfiles[userId] = {
            username = player.Name,
            bio = "",
            joinDate = os.time(),
            lastActive = os.time(),
            favoriteObjects = {},
            achievements = {},
            stats = {
                objectsPlaced = 0,
                likesReceived = 0,
                commentsReceived = 0,
                totalVisits = 0
            }
        }
    end
    
    -- Initialize showcase area if not exists
    if not showcaseAreas[userId] then
        showcaseAreas[userId] = {
            objects = {},
            layout = "default",
            theme = "default",
            lastUpdated = os.time()
        }
    end
    
    -- Update last active
    playerProfiles[userId].lastActive = os.time()
end

-- Handle player leaving
function PlayerProfileManager.handlePlayerLeave(player)
    local userId = player.UserId
    if playerProfiles[userId] then
        playerProfiles[userId].lastActive = os.time()
    end
end

-- Get player profile
function PlayerProfileManager.getProfile(userId)
    return playerProfiles[userId]
end

-- Update player profile
function PlayerProfileManager.updateProfile(player, profileData)
    local userId = player.UserId
    
    -- Validate profile data
    if not profileData or type(profileData) ~= "table" then
        return false, "Invalid profile data"
    end
    
    -- Update profile
    playerProfiles[userId] = {
        username = player.Name,
        bio = profileData.bio or playerProfiles[userId].bio,
        joinDate = playerProfiles[userId].joinDate,
        lastActive = os.time(),
        favoriteObjects = profileData.favoriteObjects or playerProfiles[userId].favoriteObjects,
        achievements = playerProfiles[userId].achievements,
        stats = playerProfiles[userId].stats
    }
    
    return true
end

-- Get showcase area
function PlayerProfileManager.getShowcaseArea(userId)
    return showcaseAreas[userId]
end

-- Update showcase area
function PlayerProfileManager.updateShowcaseArea(player, showcaseData)
    local userId = player.UserId
    
    -- Validate showcase data
    if not showcaseData or type(showcaseData) ~= "table" then
        return false, "Invalid showcase data"
    end
    
    -- Update showcase area
    showcaseAreas[userId] = {
        objects = showcaseData.objects or showcaseAreas[userId].objects,
        layout = showcaseData.layout or showcaseAreas[userId].layout,
        theme = showcaseData.theme or showcaseAreas[userId].theme,
        lastUpdated = os.time()
    }
    
    return true
end

-- Add achievement to profile
function PlayerProfileManager.addAchievement(userId, achievement)
    if not playerProfiles[userId] then return false end
    
    table.insert(playerProfiles[userId].achievements, {
        id = achievement.id,
        name = achievement.name,
        description = achievement.description,
        unlockedAt = os.time()
    })
    
    return true
end

-- Update profile stats
function PlayerProfileManager.updateStats(userId, statType, value)
    if not playerProfiles[userId] then return false end
    
    local stats = playerProfiles[userId].stats
    if stats[statType] then
        stats[statType] = stats[statType] + value
    end
    
    return true
end

-- Add object to showcase
function PlayerProfileManager.addToShowcase(userId, objectId)
    if not showcaseAreas[userId] then return false end
    
    -- Check if object already in showcase
    for _, id in ipairs(showcaseAreas[userId].objects) do
        if id == objectId then
            return false, "Object already in showcase"
        end
    end
    
    -- Add object to showcase
    table.insert(showcaseAreas[userId].objects, objectId)
    showcaseAreas[userId].lastUpdated = os.time()
    
    return true
end

-- Remove object from showcase
function PlayerProfileManager.removeFromShowcase(userId, objectId)
    if not showcaseAreas[userId] then return false end
    
    -- Find and remove object
    for i, id in ipairs(showcaseAreas[userId].objects) do
        if id == objectId then
            table.remove(showcaseAreas[userId].objects, i)
            showcaseAreas[userId].lastUpdated = os.time()
            return true
        end
    end
    
    return false, "Object not found in showcase"
end

return PlayerProfileManager 