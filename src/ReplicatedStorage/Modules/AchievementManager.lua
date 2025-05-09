local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local AchievementManager = {}

-- Achievement definitions
local ACHIEVEMENTS = {
    FIRST_PURCHASE = {
        id = "first_purchase",
        name = "First Purchase",
        description = "Purchase your first object",
        reward = 50,
        icon = "rbxassetid://1234567890", -- Replace with actual asset ID
    },
    COLLECTOR = {
        id = "collector",
        name = "Collector",
        description = "Place 10 different types of objects",
        reward = 100,
        icon = "rbxassetid://1234567891",
    },
    MASTER_BUILDER = {
        id = "master_builder",
        name = "Master Builder",
        description = "Place 50 objects in total",
        reward = 200,
        icon = "rbxassetid://1234567892",
    },
    DAILY_CHAMPION = {
        id = "daily_champion",
        name = "Daily Champion",
        description = "Maintain a 7-day streak",
        reward = 150,
        icon = "rbxassetid://1234567893",
    },
    COIN_COLLECTOR = {
        id = "coin_collector",
        name = "Coin Collector",
        description = "Accumulate 1000 coins",
        reward = 300,
        icon = "rbxassetid://1234567894",
    },
    SOCIAL_BUTTERFLY = {
        id = "social_butterfly",
        name = "Social Butterfly",
        description = "Share your creation with 5 different players",
        reward = 100,
        icon = "rbxassetid://1234567895",
    }
}

-- Local state
local playerAchievements = {}

-- Initialize achievement system
function AchievementManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getAchievementsEvent = Instance.new("RemoteFunction")
    getAchievementsEvent.Name = "GetAchievements"
    getAchievementsEvent.Parent = remotes
    
    local unlockAchievementEvent = Instance.new("RemoteEvent")
    unlockAchievementEvent.Name = "UnlockAchievement"
    unlockAchievementEvent.Parent = remotes
    
    -- Set up event handlers
    getAchievementsEvent.OnServerInvoke = function(player)
        return AchievementManager.getPlayerAchievements(player)
    end
    
    unlockAchievementEvent.OnServerEvent:Connect(function(player, achievementId)
        AchievementManager.unlockAchievement(player, achievementId)
    end)
end

-- Check and unlock achievements
function AchievementManager.checkAchievements(player, data)
    local userId = player.UserId
    if not playerAchievements[userId] then
        playerAchievements[userId] = {}
    end
    
    -- Check first purchase
    if data.totalPurchases == 1 then
        AchievementManager.unlockAchievement(player, "first_purchase")
    end
    
    -- Check collector
    if data.uniqueObjectsPlaced >= 10 then
        AchievementManager.unlockAchievement(player, "collector")
    end
    
    -- Check master builder
    if data.totalObjectsPlaced >= 50 then
        AchievementManager.unlockAchievement(player, "master_builder")
    end
    
    -- Check daily champion
    if data.dailyStreak >= 7 then
        AchievementManager.unlockAchievement(player, "daily_champion")
    end
    
    -- Check coin collector
    if data.totalCoinsEarned >= 1000 then
        AchievementManager.unlockAchievement(player, "coin_collector")
    end
    
    -- Check social butterfly
    if data.uniqueShares >= 5 then
        AchievementManager.unlockAchievement(player, "social_butterfly")
    end
end

-- Unlock achievement
function AchievementManager.unlockAchievement(player, achievementId)
    local userId = player.UserId
    if not playerAchievements[userId] then
        playerAchievements[userId] = {}
    end
    
    -- Check if already unlocked
    if playerAchievements[userId][achievementId] then
        return
    end
    
    -- Get achievement data
    local achievement = ACHIEVEMENTS[achievementId]
    if not achievement then return end
    
    -- Unlock achievement
    playerAchievements[userId][achievementId] = {
        unlockedAt = os.time(),
        reward = achievement.reward
    }
    
    -- Give reward
    local data = playerData[userId]
    if data then
        data.coins = data.coins + achievement.reward
    end
    
    -- Notify client
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local unlockEvent = remotes:WaitForChild("UnlockAchievement")
    unlockEvent:FireClient(player, achievement)
end

-- Get player achievements
function AchievementManager.getPlayerAchievements(player)
    local userId = player.UserId
    if not playerAchievements[userId] then
        return {}
    end
    
    local achievements = {}
    for id, data in pairs(playerAchievements[userId]) do
        local achievement = ACHIEVEMENTS[id]
        if achievement then
            table.insert(achievements, {
                id = id,
                name = achievement.name,
                description = achievement.description,
                reward = achievement.reward,
                icon = achievement.icon,
                unlockedAt = data.unlockedAt
            })
        end
    end
    
    return achievements
end

-- Get all achievements
function AchievementManager.getAllAchievements()
    local achievements = {}
    for id, data in pairs(ACHIEVEMENTS) do
        table.insert(achievements, {
            id = id,
            name = data.name,
            description = data.description,
            reward = data.reward,
            icon = data.icon
        })
    end
    return achievements
end

return AchievementManager 