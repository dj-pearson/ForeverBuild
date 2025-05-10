local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local ProgressionManager = {}

-- Local state
local playerLevels = {} -- Player level data
local playerSkills = {} -- Player skill tree progress
local playerPrestige = {} -- Player prestige data

-- Experience thresholds for levels
local LEVEL_THRESHOLDS = {
    base = 100, -- Base XP needed for level 1
    multiplier = 1.5 -- XP multiplier per level
}

-- Skill trees
local SKILL_TREES = {
    Building = {
        name = "Building",
        description = "Enhance your building capabilities",
        skills = {
            {
                id = "building_speed",
                name = "Building Speed",
                description = "Build objects faster",
                maxLevel = 5,
                xpCost = 100,
                effects = {
                    {level = 1, value = 0.1}, -- 10% faster
                    {level = 2, value = 0.2}, -- 20% faster
                    {level = 3, value = 0.3}, -- 30% faster
                    {level = 4, value = 0.4}, -- 40% faster
                    {level = 5, value = 0.5}  -- 50% faster
                }
            },
            {
                id = "precision",
                name = "Precision",
                description = "More precise object placement",
                maxLevel = 5,
                xpCost = 100,
                effects = {
                    {level = 1, value = 0.05}, -- 5% more precise
                    {level = 2, value = 0.1},  -- 10% more precise
                    {level = 3, value = 0.15}, -- 15% more precise
                    {level = 4, value = 0.2},  -- 20% more precise
                    {level = 5, value = 0.25}  -- 25% more precise
                }
            },
            {
                id = "creativity",
                name = "Creativity",
                description = "Unlock more building options",
                maxLevel = 5,
                xpCost = 150,
                effects = {
                    {level = 1, value = "basic_variants"},
                    {level = 2, value = "advanced_variants"},
                    {level = 3, value = "special_effects"},
                    {level = 4, value = "custom_materials"},
                    {level = 5, value = "unique_objects"}
                }
            }
        }
    },
    Collection = {
        name = "Collection",
        description = "Improve your collection abilities",
        skills = {
            {
                id = "collection_range",
                name = "Collection Range",
                description = "Collect objects from further away",
                maxLevel = 5,
                xpCost = 100,
                effects = {
                    {level = 1, value = 2},  -- +2 studs
                    {level = 2, value = 4},  -- +4 studs
                    {level = 3, value = 6},  -- +6 studs
                    {level = 4, value = 8},  -- +8 studs
                    {level = 5, value = 10}  -- +10 studs
                }
            },
            {
                id = "collection_speed",
                name = "Collection Speed",
                description = "Collect objects faster",
                maxLevel = 5,
                xpCost = 100,
                effects = {
                    {level = 1, value = 0.1}, -- 10% faster
                    {level = 2, value = 0.2}, -- 20% faster
                    {level = 3, value = 0.3}, -- 30% faster
                    {level = 4, value = 0.4}, -- 40% faster
                    {level = 5, value = 0.5}  -- 50% faster
                }
            },
            {
                id = "rare_finder",
                name = "Rare Finder",
                description = "Increased chance of finding rare objects",
                maxLevel = 5,
                xpCost = 150,
                effects = {
                    {level = 1, value = 0.05}, -- 5% increased chance
                    {level = 2, value = 0.1},  -- 10% increased chance
                    {level = 3, value = 0.15}, -- 15% increased chance
                    {level = 4, value = 0.2},  -- 20% increased chance
                    {level = 5, value = 0.25}  -- 25% increased chance
                }
            }
        }
    },
    Social = {
        name = "Social",
        description = "Enhance your social interactions",
        skills = {
            {
                id = "friend_capacity",
                name = "Friend Capacity",
                description = "Increase maximum friend limit",
                maxLevel = 5,
                xpCost = 100,
                effects = {
                    {level = 1, value = 5},  -- +5 friends
                    {level = 2, value = 10}, -- +10 friends
                    {level = 3, value = 15}, -- +15 friends
                    {level = 4, value = 20}, -- +20 friends
                    {level = 5, value = 25}  -- +25 friends
                }
            },
            {
                id = "social_rewards",
                name = "Social Rewards",
                description = "Get more rewards from social interactions",
                maxLevel = 5,
                xpCost = 100,
                effects = {
                    {level = 1, value = 0.1}, -- 10% more rewards
                    {level = 2, value = 0.2}, -- 20% more rewards
                    {level = 3, value = 0.3}, -- 30% more rewards
                    {level = 4, value = 0.4}, -- 40% more rewards
                    {level = 5, value = 0.5}  -- 50% more rewards
                }
            },
            {
                id = "community_impact",
                name = "Community Impact",
                description = "Your actions have more impact on the community",
                maxLevel = 5,
                xpCost = 150,
                effects = {
                    {level = 1, value = 0.1}, -- 10% more impact
                    {level = 2, value = 0.2}, -- 20% more impact
                    {level = 3, value = 0.3}, -- 30% more impact
                    {level = 4, value = 0.4}, -- 40% more impact
                    {level = 5, value = 0.5}  -- 50% more impact
                }
            }
        }
    }
}

-- Prestige rewards
local PRESTIGE_REWARDS = {
    {
        level = 1,
        rewards = {
            {type = "currency", amount = 1000},
            {type = "title", value = "Prestige I"},
            {type = "badge", value = "prestige_1"}
        }
    },
    {
        level = 2,
        rewards = {
            {type = "currency", amount = 2000},
            {type = "title", value = "Prestige II"},
            {type = "badge", value = "prestige_2"},
            {type = "special_item", value = "prestige_2_exclusive"}
        }
    },
    {
        level = 3,
        rewards = {
            {type = "currency", amount = 3000},
            {type = "title", value = "Prestige III"},
            {type = "badge", value = "prestige_3"},
            {type = "special_item", value = "prestige_3_exclusive"},
            {type = "unique_effect", value = "prestige_3_aura"}
        }
    }
}

-- Initialize progression system
function ProgressionManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local getLevelEvent = Instance.new("RemoteEvent")
    getLevelEvent.Name = "GetLevel"
    getLevelEvent.Parent = remotes
    
    local getSkillsEvent = Instance.new("RemoteEvent")
    getSkillsEvent.Name = "GetSkills"
    getSkillsEvent.Parent = remotes
    
    local getPrestigeEvent = Instance.new("RemoteEvent")
    getPrestigeEvent.Name = "GetPrestige"
    getPrestigeEvent.Parent = remotes
    
    local addXPEvent = Instance.new("RemoteEvent")
    addXPEvent.Name = "AddXP"
    addXPEvent.Parent = remotes
    
    local upgradeSkillEvent = Instance.new("RemoteEvent")
    upgradeSkillEvent.Name = "UpgradeSkill"
    upgradeSkillEvent.Parent = remotes
    
    local prestigeEvent = Instance.new("RemoteEvent")
    prestigeEvent.Name = "Prestige"
    prestigeEvent.Parent = remotes
    
    -- Set up event handlers
    getLevelEvent.OnServerEvent:Connect(function(player)
        ProgressionManager.getLevel(player)
    end)
    
    getSkillsEvent.OnServerEvent:Connect(function(player)
        ProgressionManager.getSkills(player)
    end)
    
    getPrestigeEvent.OnServerEvent:Connect(function(player)
        ProgressionManager.getPrestige(player)
    end)
    
    addXPEvent.OnServerEvent:Connect(function(player, amount)
        ProgressionManager.addXP(player, amount)
    end)
    
    upgradeSkillEvent.OnServerEvent:Connect(function(player, skillId)
        ProgressionManager.upgradeSkill(player, skillId)
    end)
    
    prestigeEvent.OnServerEvent:Connect(function(player)
        ProgressionManager.prestige(player)
    end)
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        ProgressionManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        ProgressionManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function ProgressionManager.handlePlayerJoin(player)
    -- Initialize player's progression data
    local userId = player.UserId
    
    playerLevels[userId] = playerLevels[userId] or {
        level = 1,
        xp = 0
    }
    
    playerSkills[userId] = playerSkills[userId] or {
        Building = {},
        Collection = {},
        Social = {}
    }
    
    playerPrestige[userId] = playerPrestige[userId] or {
        level = 0,
        totalPrestige = 0
    }
end

-- Handle player leaving
function ProgressionManager.handlePlayerLeave(player)
    -- Clean up player's progression data
    local userId = player.UserId
    
    playerLevels[userId] = nil
    playerSkills[userId] = nil
    playerPrestige[userId] = nil
end

-- Calculate XP needed for next level
function ProgressionManager.getXPForNextLevel(currentLevel)
    return math.floor(LEVEL_THRESHOLDS.base * (LEVEL_THRESHOLDS.multiplier ^ (currentLevel - 1)))
end

-- Add XP to player
function ProgressionManager.addXP(player, amount)
    local userId = player.UserId
    local levelData = playerLevels[userId]
    
    if not levelData then return false, "Player data not found" end
    
    -- Add XP
    levelData.xp = levelData.xp + amount
    
    -- Check for level up
    local xpNeeded = ProgressionManager.getXPForNextLevel(levelData.level)
    while levelData.xp >= xpNeeded do
        levelData.xp = levelData.xp - xpNeeded
        levelData.level = levelData.level + 1
        xpNeeded = ProgressionManager.getXPForNextLevel(levelData.level)
        
        -- Notify level up
        ProgressionManager.notifyLevelUp(player, levelData.level)
    end
    
    return true, "XP added successfully"
end

-- Get player level
function ProgressionManager.getLevel(player)
    local userId = player.UserId
    local levelData = playerLevels[userId]
    
    if not levelData then return false, "Player data not found" end
    
    return true, {
        level = levelData.level,
        xp = levelData.xp,
        xpNeeded = ProgressionManager.getXPForNextLevel(levelData.level)
    }
end

-- Get player skills
function ProgressionManager.getSkills(player)
    local userId = player.UserId
    local skillsData = playerSkills[userId]
    
    if not skillsData then return false, "Player data not found" end
    
    return true, skillsData
end

-- Upgrade skill
function ProgressionManager.upgradeSkill(player, skillId)
    local userId = player.UserId
    local skillsData = playerSkills[userId]
    
    if not skillsData then return false, "Player data not found" end
    
    -- Find skill in trees
    local skill = nil
    local treeName = nil
    
    for treeName, tree in pairs(SKILL_TREES) do
        for _, s in ipairs(tree.skills) do
            if s.id == skillId then
                skill = s
                treeName = treeName
                break
            end
        end
        if skill then break end
    end
    
    if not skill then return false, "Skill not found" end
    
    -- Check current level
    local currentLevel = skillsData[treeName][skillId] or 0
    if currentLevel >= skill.maxLevel then
        return false, "Skill already at maximum level"
    end
    
    -- Check if player has enough XP
    local levelData = playerLevels[userId]
    if levelData.xp < skill.xpCost then
        return false, "Not enough XP"
    end
    
    -- Upgrade skill
    levelData.xp = levelData.xp - skill.xpCost
    skillsData[treeName][skillId] = currentLevel + 1
    
    -- Apply skill effect
    ProgressionManager.applySkillEffect(player, skill, currentLevel + 1)
    
    return true, "Skill upgraded successfully"
end

-- Apply skill effect
function ProgressionManager.applySkillEffect(player, skill, level)
    local effect = skill.effects[level]
    if not effect then return end
    
    -- TODO: Implement skill effect application
    -- This could include:
    -- - Modifying player stats
    -- - Unlocking new abilities
    -- - Applying visual effects
end

-- Get player prestige
function ProgressionManager.getPrestige(player)
    local userId = player.UserId
    local prestigeData = playerPrestige[userId]
    
    if not prestigeData then return false, "Player data not found" end
    
    return true, prestigeData
end

-- Prestige player
function ProgressionManager.prestige(player)
    local userId = player.UserId
    local levelData = playerLevels[userId]
    local prestigeData = playerPrestige[userId]
    
    if not levelData or not prestigeData then return false, "Player data not found" end
    
    -- Check if player meets prestige requirements
    if levelData.level < 50 then
        return false, "Must reach level 50 to prestige"
    end
    
    -- Calculate prestige level
    local newPrestigeLevel = prestigeData.level + 1
    if newPrestigeLevel > #PRESTIGE_REWARDS then
        return false, "Maximum prestige level reached"
    end
    
    -- Reset player progress
    levelData.level = 1
    levelData.xp = 0
    
    -- Update prestige data
    prestigeData.level = newPrestigeLevel
    prestigeData.totalPrestige = prestigeData.totalPrestige + 1
    
    -- Award prestige rewards
    local rewards = PRESTIGE_REWARDS[newPrestigeLevel].rewards
    ProgressionManager.awardPrestigeRewards(player, rewards)
    
    -- Notify prestige
    ProgressionManager.notifyPrestige(player, newPrestigeLevel)
    
    return true, "Prestige successful"
end

-- Award prestige rewards
function ProgressionManager.awardPrestigeRewards(player, rewards)
    -- TODO: Implement reward distribution
    -- This could include:
    -- - Currency rewards
    -- - Title unlocks
    -- - Badge awards
    -- - Special items
    -- - Unique effects
end

-- Notify level up
function ProgressionManager.notifyLevelUp(player, newLevel)
    -- TODO: Implement level up notification
    -- This could include:
    -- - In-game notification
    -- - UI update
    -- - Sound effect
    -- - Particle effect
end

-- Notify prestige
function ProgressionManager.notifyPrestige(player, newPrestigeLevel)
    -- TODO: Implement prestige notification
    -- This could include:
    -- - In-game notification
    -- - UI update
    -- - Sound effect
    -- - Particle effect
    -- - Special animation
end

return ProgressionManager 