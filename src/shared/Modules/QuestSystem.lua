local QuestSystem = {}
QuestSystem.__index = QuestSystem

-- Constants
local QUEST_TYPES = {
    KILL = "Kill",
    COLLECT = "Collect",
    EXPLORE = "Explore",
    TALK = "Talk"
}

local QUEST_STATES = {
    NOT_STARTED = "NotStarted",
    IN_PROGRESS = "InProgress",
    COMPLETED = "Completed",
    FAILED = "Failed"
}

-- Quest templates (this would typically be loaded from a data store)
local QUEST_TEMPLATES = {
    ["quest_1"] = {
        id = "quest_1",
        title = "First Steps",
        description = "Defeat 5 basic enemies",
        type = QUEST_TYPES.KILL,
        requirements = {
            target = "basic_enemy",
            count = 5
        },
        rewards = {
            experience = 100,
            coins = 50,
            items = {
                {id = "sword_1", quantity = 1}
            }
        },
        levelRequirement = 1
    },
    ["quest_2"] = {
        id = "quest_2",
        title = "Gather Resources",
        description = "Collect 10 wood logs",
        type = QUEST_TYPES.COLLECT,
        requirements = {
            target = "wood_log",
            count = 10
        },
        rewards = {
            experience = 75,
            coins = 25,
            items = {
                {id = "health_potion", quantity = 2}
            }
        },
        levelRequirement = 1
    }
}

-- Initialize a new quest system
function QuestSystem.new()
    local self = setmetatable({}, QuestSystem)
    return self
end

-- Create a new quest log
function QuestSystem:CreateQuestLog()
    return {
        activeQuests = {},
        completedQuests = {},
        failedQuests = {}
    }
end

-- Start a quest
function QuestSystem:StartQuest(questLog, questId)
    -- Check if quest exists
    local questTemplate = QUEST_TEMPLATES[questId]
    if not questTemplate then
        return false, "Quest not found"
    end
    
    -- Check if quest is already active
    if self:IsQuestActive(questLog, questId) then
        return false, "Quest already active"
    end
    
    -- Check if quest is already completed
    if self:IsQuestCompleted(questLog, questId) then
        return false, "Quest already completed"
    end
    
    -- Create quest instance
    local quest = {
        id = questId,
        template = questTemplate,
        state = QUEST_STATES.IN_PROGRESS,
        progress = 0,
        startTime = os.time()
    }
    
    -- Add to active quests
    questLog.activeQuests[questId] = quest
    return true, "Quest started successfully"
end

-- Update quest progress
function QuestSystem:UpdateQuestProgress(questLog, questId, progress)
    local quest = questLog.activeQuests[questId]
    if not quest then
        return false, "Quest not found"
    end
    
    quest.progress = progress
    
    -- Check if quest is complete
    if progress >= quest.template.requirements.count then
        return self:CompleteQuest(questLog, questId)
    end
    
    return true, "Quest progress updated"
end

-- Complete a quest
function QuestSystem:CompleteQuest(questLog, questId)
    local quest = questLog.activeQuests[questId]
    if not quest then
        return false, "Quest not found"
    end
    
    -- Update quest state
    quest.state = QUEST_STATES.COMPLETED
    quest.completionTime = os.time()
    
    -- Move to completed quests
    questLog.completedQuests[questId] = quest
    questLog.activeQuests[questId] = nil
    
    -- Return rewards
    return true, "Quest completed", quest.template.rewards
end

-- Fail a quest
function QuestSystem:FailQuest(questLog, questId)
    local quest = questLog.activeQuests[questId]
    if not quest then
        return false, "Quest not found"
    end
    
    -- Update quest state
    quest.state = QUEST_STATES.FAILED
    quest.failureTime = os.time()
    
    -- Move to failed quests
    questLog.failedQuests[questId] = quest
    questLog.activeQuests[questId] = nil
    
    return true, "Quest failed"
end

-- Check if quest is active
function QuestSystem:IsQuestActive(questLog, questId)
    return questLog.activeQuests[questId] ~= nil
end

-- Check if quest is completed
function QuestSystem:IsQuestCompleted(questLog, questId)
    return questLog.completedQuests[questId] ~= nil
end

-- Check if quest is failed
function QuestSystem:IsQuestFailed(questLog, questId)
    return questLog.failedQuests[questId] ~= nil
end

-- Get quest progress
function QuestSystem:GetQuestProgress(questLog, questId)
    local quest = questLog.activeQuests[questId]
    if not quest then
        return nil
    end
    
    return {
        progress = quest.progress,
        required = quest.template.requirements.count,
        percentage = (quest.progress / quest.template.requirements.count) * 100
    }
end

-- Get available quests for player level
function QuestSystem:GetAvailableQuests(playerLevel)
    local availableQuests = {}
    
    for questId, questTemplate in pairs(QUEST_TEMPLATES) do
        if questTemplate.levelRequirement <= playerLevel then
            table.insert(availableQuests, questTemplate)
        end
    end
    
    return availableQuests
end

-- Get active quests
function QuestSystem:GetActiveQuests(questLog)
    return questLog.activeQuests
end

-- Get completed quests
function QuestSystem:GetCompletedQuests(questLog)
    return questLog.completedQuests
end

-- Get failed quests
function QuestSystem:GetFailedQuests(questLog)
    return questLog.failedQuests
end

-- Get quest template
function QuestSystem:GetQuestTemplate(questId)
    return QUEST_TEMPLATES[questId]
end

-- Check quest requirements
function QuestSystem:CheckQuestRequirements(quest, target, count)
    if quest.template.requirements.target ~= target then
        return false
    end
    
    return count >= quest.template.requirements.count
end

return QuestSystem 