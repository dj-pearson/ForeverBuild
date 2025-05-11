local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

-- Load server modules
local DataStoreManager = require(ServerScriptService.Modules.Data.DataStoreManager)

local TutorialHandler = {}

-- Get tutorial status for a player
function TutorialHandler.getTutorialStatus(player)
    local data = DataStoreManager.GetPlayerData(player)
    return not data.tutorialComplete
end

-- Mark tutorial as completed for a player
function TutorialHandler.completeTutorial(player)
    local data = DataStoreManager.GetPlayerData(player)
    data.tutorialComplete = true
    DataStoreManager.SetPlayerData(player, data, true)
end

-- Initialize
function TutorialHandler.init()
    -- Set up remote event handlers
    RemoteManager:onServerEvent(Constants.RemoteEvents.CompleteTutorial, function(player)
        TutorialHandler.completeTutorial(player)
    end)
    
    RemoteManager:setServerCallback(Constants.RemoteFunctions.GetTutorialStatus, function(player)
        return TutorialHandler.getTutorialStatus(player)
    end)
end

return TutorialHandler 