local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local DailyRewardsManager = {}

-- Daily reward configurations
local DAILY_REWARDS = {
    {
        day = 1,
        reward = {
            type = "coins",
            amount = 100,
        },
    },
    {
        day = 2,
        reward = {
            type = "coins",
            amount = 150,
        },
    },
    {
        day = 3,
        reward = {
            type = "coins",
            amount = 200,
        },
    },
    {
        day = 4,
        reward = {
            type = "coins",
            amount = 250,
        },
    },
    {
        day = 5,
        reward = {
            type = "coins",
            amount = 300,
        },
    },
    {
        day = 6,
        reward = {
            type = "coins",
            amount = 350,
        },
    },
    {
        day = 7,
        reward = {
            type = "coins",
            amount = 500,
        },
    },
}

-- Get reward for a specific day
function DailyRewardsManager.getReward(day)
    for _, rewardConfig in ipairs(DAILY_REWARDS) do
        if rewardConfig.day == day then
            return rewardConfig.reward
        end
    end
    return nil
end

-- Check if player can claim daily reward
function DailyRewardsManager.canClaimReward(playerData)
    if not playerData.lastRewardClaim then
        return true
    end
    
    local currentTime = os.time()
    local lastClaimTime = playerData.lastRewardClaim
    local timeSinceLastClaim = currentTime - lastClaimTime
    
    -- Check if 24 hours have passed since last claim
    return timeSinceLastClaim >= 24 * 60 * 60
end

-- Get next reward day
function DailyRewardsManager.getNextRewardDay(playerData)
    if not playerData.lastRewardClaim then
        return 1
    end
    
    local currentStreak = playerData.rewardStreak or 0
    local nextDay = (currentStreak % 7) + 1
    return nextDay
end

-- Claim daily reward
function DailyRewardsManager.claimReward(playerData)
    if not DailyRewardsManager.canClaimReward(playerData) then
        return false, "Must wait 24 hours between claims"
    end
    
    local nextDay = DailyRewardsManager.getNextRewardDay(playerData)
    local reward = DailyRewardsManager.getReward(nextDay)
    
    if not reward then
        return false, "Invalid reward day"
    end
    
    -- Update player data
    playerData.lastRewardClaim = os.time()
    playerData.rewardStreak = (playerData.rewardStreak or 0) + 1
    
    -- Apply reward
    if reward.type == "coins" then
        playerData.coins = (playerData.coins or 0) + reward.amount
    end
    
    return true, reward
end

-- Get all available rewards
function DailyRewardsManager.getAllRewards()
    return DAILY_REWARDS
end

return DailyRewardsManager 