local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameStateManager = require(ServerScriptService.GameStateManager)
local InventorySystem = require(ReplicatedStorage.Modules.InventorySystem)
local QuestSystem = require(ReplicatedStorage.Modules.QuestSystem)

local GameSystemsManager = {}
GameSystemsManager.__index = GameSystemsManager

-- Initialize a new game systems manager
function GameSystemsManager.new()
    local self = setmetatable({}, GameSystemsManager)
    self:Initialize()
    return self
end

-- Initialize the game systems manager
function GameSystemsManager:Initialize()
    -- Initialize systems
    self.gameState = GameStateManager.new()
    self.inventorySystem = InventorySystem.new()
    self.questSystem = QuestSystem.new()
    
    -- Set up player handling
    Players.PlayerAdded:Connect(function(player)
        self:HandlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:HandlePlayerLeave(player)
    end)
end

-- Handle player joining
function GameSystemsManager:HandlePlayerJoin(player)
    -- Get player data
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return end
    
    -- Initialize inventory if not exists
    if not playerData.inventory then
        playerData.inventory = self.inventorySystem:CreateInventory()
    end
    
    -- Initialize quest log if not exists
    if not playerData.questLog then
        playerData.questLog = self.questSystem:CreateQuestLog()
    end
    
    -- Set up player attributes
    self:UpdatePlayerAttributes(player, playerData)
end

-- Handle player leaving
function GameSystemsManager:HandlePlayerLeave(player)
    -- Save player data
    self.gameState:SavePlayerData(player)
end

-- Update player attributes
function GameSystemsManager:UpdatePlayerAttributes(player, playerData)
    player:SetAttribute("Level", playerData.level)
    player:SetAttribute("Coins", playerData.coins)
    player:SetAttribute("Experience", playerData.experience)
end

-- Add item to player inventory
function GameSystemsManager:AddItemToInventory(player, itemId, quantity)
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return false, "Player data not found" end
    
    local success, message = self.inventorySystem:AddItem(playerData.inventory, itemId, quantity)
    if success then
        self.gameState:SavePlayerData(player)
    end
    
    return success, message
end

-- Remove item from player inventory
function GameSystemsManager:RemoveItemFromInventory(player, itemId, quantity)
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return false, "Player data not found" end
    
    local success, message = self.inventorySystem:RemoveItem(playerData.inventory, itemId, quantity)
    if success then
        self.gameState:SavePlayerData(player)
    end
    
    return success, message
end

-- Start quest for player
function GameSystemsManager:StartQuest(player, questId)
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return false, "Player data not found" end
    
    local success, message = self.questSystem:StartQuest(playerData.questLog, questId)
    if success then
        self.gameState:SavePlayerData(player)
    end
    
    return success, message
end

-- Update quest progress
function GameSystemsManager:UpdateQuestProgress(player, questId, progress)
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return false, "Player data not found" end
    
    local success, message, rewards = self.questSystem:UpdateQuestProgress(playerData.questLog, questId, progress)
    if success then
        -- Handle rewards if quest completed
        if rewards then
            self:HandleQuestRewards(player, rewards)
        end
        self.gameState:SavePlayerData(player)
    end
    
    return success, message
end

-- Handle quest rewards
function GameSystemsManager:HandleQuestRewards(player, rewards)
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return end
    
    -- Add experience
    if rewards.experience then
        playerData.experience = playerData.experience + rewards.experience
        -- Check for level up
        self:CheckLevelUp(player, playerData)
    end
    
    -- Add coins
    if rewards.coins then
        playerData.coins = playerData.coins + rewards.coins
    end
    
    -- Add items
    if rewards.items then
        for _, item in ipairs(rewards.items) do
            self.inventorySystem:AddItem(playerData.inventory, item.id, item.quantity)
        end
    end
    
    -- Update attributes
    self:UpdatePlayerAttributes(player, playerData)
end

-- Check for level up
function GameSystemsManager:CheckLevelUp(player, playerData)
    local experienceNeeded = self:GetExperienceForLevel(playerData.level + 1)
    
    if playerData.experience >= experienceNeeded then
        playerData.level = playerData.level + 1
        playerData.experience = playerData.experience - experienceNeeded
        
        -- Update attributes
        self:UpdatePlayerAttributes(player, playerData)
        
        -- Fire level up event
        -- This would typically trigger UI updates and other effects
    end
end

-- Get experience needed for level
function GameSystemsManager:GetExperienceForLevel(level)
    -- Simple exponential formula
    return 100 * (level ^ 1.5)
end

-- Get player inventory
function GameSystemsManager:GetPlayerInventory(player)
    local playerData = self.gameState:GetPlayerData(player)
    return playerData and playerData.inventory or nil
end

-- Get player quest log
function GameSystemsManager:GetPlayerQuestLog(player)
    local playerData = self.gameState:GetPlayerData(player)
    return playerData and playerData.questLog or nil
end

-- Get available quests for player
function GameSystemsManager:GetAvailableQuests(player)
    local playerData = self.gameState:GetPlayerData(player)
    if not playerData then return {} end
    
    return self.questSystem:GetAvailableQuests(playerData.level)
end

return GameSystemsManager 