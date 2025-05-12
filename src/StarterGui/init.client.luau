local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

-- Load UI modules
local AchievementUI = require(script.Parent.AchievementUI)
local ProgressionUI = require(script.Parent.ProgressionUI)
local BuildingChallengeUI = require(script.Parent.BuildingChallengeUI)
local BuildingTemplateUI = require(script.Parent.BuildingTemplateUI)
local BuildingToolsUI = require(script.Parent.BuildingToolsUI)
local SocialMediaUI = require(script.Parent.SocialMediaUI)
local PlayerProfileUI = require(script.Parent.PlayerProfileUI)
local SocialInteractionUI = require(script.Parent.SocialInteractionUI)
local SocialHubUI = require(script.Parent.SocialHubUI)
local FriendsUI = require(script.Parent.FriendsUI)
local Marketplace = require(script.Parent.Marketplace)
local DailyRewardsUI = require(script.Parent.DailyRewardsUI)

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