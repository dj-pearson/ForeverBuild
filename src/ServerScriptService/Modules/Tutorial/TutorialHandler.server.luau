local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Get the server module resolver
local Server = require(ServerScriptService.server)
local DataStoreManager = Server.getModule("Data.DataStoreManager")
local remoteManager = Server.Remotes

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.getType("Constants")
local Types = Shared.getType("Types")

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
    remoteManager:setServerCallback("GetTutorialStatus", function(player)
        return TutorialHandler.getTutorialStatus(player)
    end)
    
    remoteManager:onServerEvent("CompleteTutorial", function(player)
        TutorialHandler.completeTutorial(player)
    end)
end

return TutorialHandler 