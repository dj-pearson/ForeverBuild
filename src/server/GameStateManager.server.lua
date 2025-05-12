local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreManager = require(ServerScriptService.DataStoreManager)

local GameStateManager = {}
GameStateManager.__index = GameStateManager

-- Constants
local SAVE_INTERVAL = 300 -- 5 minutes
local MAX_PLAYER_DATA_SIZE = 1000000 -- 1MB

-- Private variables
local activeSessions = {}
local saveQueue = {}

-- Initialize a new game state manager
function GameStateManager.new()
    local self = setmetatable({}, GameStateManager)
    self:Initialize()
    return self
end

-- Initialize the game state manager
function GameStateManager:Initialize()
    -- Set up player handling
    Players.PlayerAdded:Connect(function(player)
        self:HandlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:HandlePlayerLeave(player)
    end)
    
    -- Start save loop
    task.spawn(function()
        while true do
            task.wait(SAVE_INTERVAL)
            self:SaveAllPlayerData()
        end
    end)
end

-- Handle player joining
function GameStateManager:HandlePlayerJoin(player)
    local success, playerData = pcall(function()
        return DataStoreManager:GetPlayerData(player.UserId)
    end)
    
    if not success then
        warn("Failed to load data for player:", player.Name)
        playerData = self:CreateDefaultPlayerData()
    end
    
    activeSessions[player.UserId] = {
        data = playerData,
        lastSave = os.time()
    }
    
    -- Initialize player state
    self:InitializePlayerState(player)
end

-- Handle player leaving
function GameStateManager:HandlePlayerLeave(player)
    local session = activeSessions[player.UserId]
    if session then
        self:SavePlayerData(player)
        activeSessions[player.UserId] = nil
    end
end

-- Create default player data
function GameStateManager:CreateDefaultPlayerData()
    return {
        coins = 0,
        level = 1,
        experience = 0,
        inventory = {},
        settings = {
            musicVolume = 0.5,
            sfxVolume = 0.5
        },
        lastLogin = os.time()
    }
end

-- Initialize player state
function GameStateManager:InitializePlayerState(player)
    local session = activeSessions[player.UserId]
    if not session then return end
    
    -- Set up player properties
    player:SetAttribute("Level", session.data.level)
    player:SetAttribute("Coins", session.data.coins)
    
    -- Fire client events to sync state
    -- Note: You'll need to set up RemoteEvents for this
end

-- Save player data
function GameStateManager:SavePlayerData(player)
    local session = activeSessions[player.UserId]
    if not session then return end
    
    -- Update last save time
    session.lastSave = os.time()
    
    -- Queue save operation
    saveQueue[player.UserId] = session.data
end

-- Save all player data
function GameStateManager:SaveAllPlayerData()
    for userId, data in pairs(saveQueue) do
        local success, err = pcall(function()
            DataStoreManager:SavePlayerData(userId, data)
        end)
        
        if not success then
            warn("Failed to save data for user:", userId, "Error:", err)
        end
    end
    
    -- Clear save queue
    saveQueue = {}
end

-- Get player data
function GameStateManager:GetPlayerData(player)
    local session = activeSessions[player.UserId]
    return session and session.data or nil
end

-- Update player data
function GameStateManager:UpdatePlayerData(player, key, value)
    local session = activeSessions[player.UserId]
    if not session then return false end
    
    session.data[key] = value
    return true
end

return GameStateManager 