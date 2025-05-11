local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

-- Load UI modules
local AchievementUI = require(script.AchievementUI)
local ProgressionUI = require(script.ProgressionUI)
local BuildingChallengeUI = require(script.BuildingChallengeUI)
local BuildingTemplateUI = require(script.BuildingTemplateUI)
local BuildingToolsUI = require(script.BuildingToolsUI)
local SocialMediaUI = require(script.SocialMediaUI)
local PlayerProfileUI = require(script.PlayerProfileUI)
local SocialInteractionUI = require(script.SocialInteractionUI)
local SocialHubUI = require(script.SocialHubUI)
local FriendsUI = require(script.FriendsUI)
local Marketplace = require(script.Marketplace)
local DailyRewardsUI = require(script.DailyRewardsUI)

-- Initialize UI modules
local function init()
    AchievementUI.init()
    ProgressionUI.init()
    BuildingChallengeUI.init()
    BuildingTemplateUI.init()
    BuildingToolsUI.init()
    SocialMediaUI.init()
    PlayerProfileUI.init()
    SocialInteractionUI.init()
    SocialHubUI.init()
    FriendsUI.init()
    Marketplace.init()
    DailyRewardsUI.init()
end

init() 