local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreManager = require(ServerScriptService.Server.Modules.Data.DataStoreManager)
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types

local TutorialHandler = {}

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getTutorialStatusEvent = Instance.new("RemoteFunction")
getTutorialStatusEvent.Name = "GetTutorialStatus"
getTutorialStatusEvent.Parent = remotes

local completeTutorialEvent = Instance.new("RemoteEvent")
completeTutorialEvent.Name = "CompleteTutorial"
completeTutorialEvent.Parent = remotes

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
    getTutorialStatusEvent.OnServerInvoke = function(player)
        return TutorialHandler.getTutorialStatus(player)
    end
    
    completeTutorialEvent.OnServerEvent:Connect(function(player)
        TutorialHandler.completeTutorial(player)
    end)
end

return TutorialHandler 