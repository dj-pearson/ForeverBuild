local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataStoreManager = {}

-- DataStore instances
local playerDataStore = DataStoreService:GetDataStore("PlayerData")
local banDataStore = DataStoreService:GetDataStore("BanData")

-- Cache for player data
local playerDataCache = {}

-- Functions
function DataStoreManager.savePlayerData(player, data)
    local success, err = pcall(function()
        playerDataStore:SetAsync(player.UserId, data)
    end)
    
    if success then
        playerDataCache[player.UserId] = data
        return true
    else
        warn("Failed to save player data:", err)
        return false
    end
end

function DataStoreManager.loadPlayerData(player)
    local success, data = pcall(function()
        return playerDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        playerDataCache[player.UserId] = data
        return data
    else
        return nil
    end
end

function DataStoreManager.getCachedPlayerData(player)
    return playerDataCache[player.UserId]
end

function DataStoreManager.clearPlayerData(player)
    playerDataCache[player.UserId] = nil
end

-- Initialize
function DataStoreManager.init()
    -- Handle player leaving
    Players.PlayerRemoving:Connect(function(player)
        local data = DataStoreManager.getCachedPlayerData(player)
        if data then
            DataStoreManager.savePlayerData(player, data)
        end
    end)
    
    -- Handle player joining
    Players.PlayerAdded:Connect(function(player)
        local data = DataStoreManager.loadPlayerData(player)
        if not data then
            -- Create new player data
            data = {
                inventory = {},
                stats = {
                    level = 1,
                    experience = 0
                },
                settings = {
                    musicVolume = 1,
                    sfxVolume = 1
                }
            }
            DataStoreManager.savePlayerData(player, data)
        end
    end)
end

return DataStoreManager 