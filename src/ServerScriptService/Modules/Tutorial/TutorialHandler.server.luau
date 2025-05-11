local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

-- Load dependencies
local DataStoreManager = require(ServerScriptService.Modules.Data.DataStoreManager)

local TutorialHandler = {}
TutorialHandler.__index = TutorialHandler

-- Tutorial states
local TUTORIAL_STATES = {
    NOT_STARTED = "not_started",
    IN_PROGRESS = "in_progress",
    COMPLETED = "completed"
}

-- Get tutorial status for a player
function TutorialHandler.GetTutorialStatus(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    return playerData.tutorialComplete and TUTORIAL_STATES.COMPLETED or TUTORIAL_STATES.NOT_STARTED
end

-- Complete tutorial for a player
function TutorialHandler.CompleteTutorial(player)
    local playerData = DataStoreManager.GetPlayerData(player)
    playerData.tutorialComplete = true
    DataStoreManager.SavePlayerData(player)
    Logger:info("Tutorial completed", { playerId = player.UserId })
    return true
end

-- Initialize
function TutorialHandler.Initialize()
    -- Set up remote event handlers
    RemoteManager:onServerEvent(Constants.RemoteEvents.CompleteTutorial, function(player)
        TutorialHandler.CompleteTutorial(player)
    end)
    
    RemoteManager:setServerCallback(Constants.RemoteFunctions.GetTutorialStatus, function(player)
        return TutorialHandler.GetTutorialStatus(player)
    end)
    
    Logger:info("TutorialHandler initialized successfully")
    return true
end

return TutorialHandler 