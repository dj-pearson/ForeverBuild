local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ModuleManager = require(ReplicatedStorage.Shared.ModuleManager)
local BuildingToolsUI = require(script.Parent.Modules.UI.BuildingToolsUI)
local BuildingTemplateUI = require(script.Parent.Modules.UI.BuildingTemplateUI)
local BuildingChallengeUI = require(script.Parent.Modules.UI.BuildingChallengeUI)
local ProgressionUI = require(script.Parent.Modules.UI.ProgressionUI)
local AchievementUI = require(script.Parent.Modules.UI.AchievementUI)

-- Register modules
ModuleManager.registerModule("BuildingToolsUI", BuildingToolsUI, { "ClientManager" })
ModuleManager.registerModule("BuildingTemplateUI", BuildingTemplateUI, { "ClientManager" })
ModuleManager.registerModule("BuildingChallengeUI", BuildingChallengeUI, { "ClientManager" })
ModuleManager.registerModule("ProgressionUI", ProgressionUI, { "ClientManager" })
ModuleManager.registerModule("AchievementUI", AchievementUI, { "ClientManager" })

-- Initialize modules
BuildingToolsUI.init()
BuildingTemplateUI.init()
BuildingChallengeUI.init()
ProgressionUI.init()
AchievementUI.init() 