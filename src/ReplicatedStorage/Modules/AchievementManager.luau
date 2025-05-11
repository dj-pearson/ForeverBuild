local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local AchievementManager = {}

-- Local state
local playerAchievements = {} -- Player achievement progress

-- Achievement definitions
local ACHIEVEMENTS = {
    -- Building achievements
    {
        id = "first_building",
        name = "First Steps",
        description = "Place your first building",
        category = "Building",
        icon = "🏗️",
        xpReward = 100,
        requirements = {
            type = "building_count",
            count = 1
        }
    },
    {
        id = "master_builder",
        name = "Master Builder",
        description = "Place 100 buildings",
        category = "Building",
        icon = "🏛️",
        xpReward = 1000,
        requirements = {
            type = "building_count",
            count = 100
        }
    },
    {
        id = "creative_architect",
        name = "Creative Architect",
        description = "Use 10 different building templates",
        category = "Building",
        icon = "🎨",
        xpReward = 500,
        requirements = {
            type = "template_usage",
            count = 10
        }
    },

    -- Collection achievements
    {
        id = "first_collection",
        name = "Collector's Start",
        description = "Collect your first item",
        category = "Collection",
        icon = "📦",
        xpReward = 100,
        requirements = {
            type = "collection_count",
            count = 1
        }
    },
    {
        id = "treasure_hunter",
        name = "Treasure Hunter",
        description = "Collect 50 items",
        category = "Collection",
        icon = "💎",
        xpReward = 500,
        requirements = {
            type = "collection_count",
            count = 50
        }
    },
    {
        id = "rare_collector",
        name = "Rare Collector",
        description = "Collect 10 rare items",
        category = "Collection",
        icon = "🌟",
        xpReward = 1000,
        requirements = {
            type = "rare_collection_count",
            count = 10
        }
    },

    -- Social achievements
    {
        id = "first_friend",
        name = "Making Friends",
        description = "Add your first friend",
        category = "Social",
        icon = "👋",
        xpReward = 100,
        requirements = {
            type = "friend_count",
            count = 1
        }
    },
    {
        id = "social_butterfly",
        name = "Social Butterfly",
        description = "Add 10 friends",
        category = "Social",
        icon = "🦋",
        xpReward = 500,
        requirements = {
            type = "friend_count",
            count = 10
        }
    },
    {
        id = "community_leader",
        name = "Community Leader",
        description = "Receive 100 likes on your buildings",
        category = "Social",
        icon = "👑",
        xpReward = 1000,
        requirements = {
            type = "building_likes",
            count = 100
        }
    }
}

-- Initialize achievement system
function AchievementManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getAchievementsEvent = Instance.new("RemoteEvent")
    getAchievementsEvent.Name = "GetAchievements"
    getAchievementsEvent.Parent = remotes
    
    local checkAchievementEvent = Instance.new("RemoteEvent")
    checkAchievementEvent.Name = "CheckAchievement"
    checkAchievementEvent.Parent = remotes
    
    -- Set up event handlers
    getAchievementsEvent.OnServerEvent:Connect(function(player)
        AchievementManager.getAchievements(player)
    end)
    
    checkAchievementEvent.OnServerEvent:Connect(function(player, achievementId)
        AchievementManager.checkAchievement(player, achievementId)
    end)
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        AchievementManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        AchievementManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function AchievementManager.handlePlayerJoin(player)
    -- Initialize player's achievement data
    local userId = player.UserId
    
    playerAchievements[userId] = playerAchievements[userId] or {
        unlocked = {},
        progress = {}
    }
    
    -- Initialize progress tracking for all achievements
    for _, achievement in ipairs(ACHIEVEMENTS) do
        if not playerAchievements[userId].progress[achievement.id] then
            playerAchievements[userId].progress[achievement.id] = 0
        end
    end
end

-- Handle player leaving
function AchievementManager.handlePlayerLeave(player)
    -- Clean up player's achievement data
    local userId = player.UserId
    playerAchievements[userId] = nil
end

-- Get player achievements
function AchievementManager.getAchievements(player)
    local userId = player.UserId
    local achievements = playerAchievements[userId]
    
    if not achievements then return false, "Player data not found" end
    
    return true, {
        unlocked = achievements.unlocked,
        progress = achievements.progress
    }
end

-- Update achievement progress
function AchievementManager.updateProgress(player, type, amount)
    local userId = player.UserId
    local achievements = playerAchievements[userId]
    
    if not achievements then return false, "Player data not found" end
    
    -- Update progress for relevant achievements
    for _, achievement in ipairs(ACHIEVEMENTS) do
        if achievement.requirements.type == type then
            achievements.progress[achievement.id] = achievements.progress[achievement.id] + amount
            
            -- Check if achievement is completed
            if achievements.progress[achievement.id] >= achievement.requirements.count then
                AchievementManager.unlockAchievement(player, achievement)
            end
        end
    end
    
    return true, "Progress updated successfully"
end

-- Unlock achievement
function AchievementManager.unlockAchievement(player, achievement)
    local userId = player.UserId
    local achievements = playerAchievements[userId]
    
    if not achievements then return false, "Player data not found" end
    
    -- Check if already unlocked
    if achievements.unlocked[achievement.id] then
        return false, "Achievement already unlocked"
    end
    
    -- Unlock achievement
    achievements.unlocked[achievement.id] = true
    
    -- Award XP
    local ProgressionManager = require(ReplicatedStorage.Shared.Modules.ProgressionManager)
    ProgressionManager.addXP(player, achievement.xpReward)
    
    -- Notify achievement unlock
    AchievementManager.notifyAchievementUnlock(player, achievement)
    
    return true, "Achievement unlocked successfully"
end

-- Check specific achievement
function AchievementManager.checkAchievement(player, achievementId)
    local userId = player.UserId
    local achievements = playerAchievements[userId]
    
    if not achievements then return false, "Player data not found" end
    
    -- Find achievement
    local achievement = nil
    for _, a in ipairs(ACHIEVEMENTS) do
        if a.id == achievementId then
            achievement = a
            break
        end
    end
    
    if not achievement then return false, "Achievement not found" end
    
    -- Check if already unlocked
    if achievements.unlocked[achievementId] then
        return false, "Achievement already unlocked"
    end
    
    -- Check progress
    if achievements.progress[achievementId] >= achievement.requirements.count then
        return AchievementManager.unlockAchievement(player, achievement)
    end
    
    return false, "Achievement requirements not met"
end

-- Notify achievement unlock
function AchievementManager.notifyAchievementUnlock(player, achievement)
    -- TODO: Implement achievement notification
    -- This could include:
    -- - In-game notification
    -- - UI update
    -- - Sound effect
    -- - Particle effect
end

return AchievementManager 