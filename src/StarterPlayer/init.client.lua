local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Logger = require(ReplicatedStorage.Shared.Modules.Logger)
local ModuleManager = require(ReplicatedStorage.Shared.Modules.ModuleManager)

-- Create module manager instance
local moduleManager = ModuleManager.new()

-- Load client modules
local ClientManager = require(game.ServerScriptService.Modules.ClientManager)
local AdminCommandHandler = require(script.Parent.Modules.Admin.AdminCommandHandler)
local ReportUI = require(script.Parent.Modules.Admin.ReportUI)
local AdminReportUI = require(script.Parent.Modules.Admin.AdminReport)
local ReportContextMenu = require(script.Parent.Modules.Admin.ReportContextMenu)
local TutorialManager = require(game.ServerScriptService.Modules.TutorialManager)
local InventoryUI = require(script.Parent.Modules.UI.InventoryUI)
local MarketplaceUI = require(script.Parent.Modules.UI.MarketplaceUI)
local DailyRewardsUI = require(script.Parent.Modules.UI.DailyRewardsUI)
local ObjectInteractionManager = require(script.Parent.Modules.UI.ObjectInteractionManager)
local LeaderboardUI = require(script.Parent.Modules.UI.LeaderboardUI)
local AchievementUI = require(script.Parent.Modules.UI.AchievementUI)
local FriendsUI = require(script.Parent.Modules.UI.FriendsUI)
local SocialHubUI = require(script.Parent.Modules.UI.SocialHubUI)
local SocialInteractionUI = require(script.Parent.Modules.UI.SocialInteractionUI)
local PlayerProfileUI = require(script.Parent.Modules.UI.PlayerProfileUI)
local SocialMediaUI = require(script.Parent.Modules.UI.SocialMediaUI)
local BuildingToolsUI = require(script.Parent.Modules.UI.BuildingToolsUI)
local BuildingTemplateUI = require(script.Parent.Modules.UI.BuildingTemplateUI)
local BuildingChallengeUI = require(script.Parent.Modules.UI.BuildingChallengeUI)

-- Register modules with their dependencies
moduleManager:registerModule("ClientManager", ClientManager)
moduleManager:registerModule("AdminCommandHandler", AdminCommandHandler, { "ClientManager" })
moduleManager:registerModule("ReportUI", ReportUI, { "ClientManager" })
moduleManager:registerModule("AdminReportUI", AdminReportUI, { "ClientManager", "ReportUI" })
moduleManager:registerModule("ReportContextMenu", ReportContextMenu, { "ClientManager", "ReportUI" })
moduleManager:registerModule("TutorialManager", TutorialManager, { "ClientManager" })
moduleManager:registerModule("InventoryUI", InventoryUI, { "ClientManager" })
moduleManager:registerModule("MarketplaceUI", MarketplaceUI, { "ClientManager" })
moduleManager:registerModule("DailyRewardsUI", DailyRewardsUI, { "ClientManager" })
moduleManager:registerModule("ObjectInteractionManager", ObjectInteractionManager, { "ClientManager" })
moduleManager:registerModule("LeaderboardUI", LeaderboardUI, { "ClientManager" })
moduleManager:registerModule("AchievementUI", AchievementUI, { "ClientManager" })
moduleManager:registerModule("FriendsUI", FriendsUI, { "ClientManager" })
moduleManager:registerModule("SocialHubUI", SocialHubUI, { "ClientManager" })
moduleManager:registerModule("SocialInteractionUI", SocialInteractionUI, { "ClientManager" })
moduleManager:registerModule("PlayerProfileUI", PlayerProfileUI, { "ClientManager" })
moduleManager:registerModule("SocialMediaUI", SocialMediaUI, { "ClientManager" })
moduleManager:registerModule("BuildingToolsUI", BuildingToolsUI, { "ClientManager" })
moduleManager:registerModule("BuildingTemplateUI", BuildingTemplateUI, { "ClientManager" })
moduleManager:registerModule("BuildingChallengeUI", BuildingChallengeUI, { "ClientManager" })

-- Initialize all modules
local success = moduleManager:initializeAll()
if not success then
    local moduleStatuses = moduleManager:getAllModuleStatuses()
    local failedModules = {}
    
    for name, status in pairs(moduleStatuses) do
        if status.status == "ERROR" then
            table.insert(failedModules, {
                name = name,
                error = status.error
            })
        end
    end
    
    Logger.fatal("Client initialization failed", {
        failedModules = failedModules
    })
    error("Client initialization failed - check logs for details")
end

Logger.info("Client initialized successfully", {
    moduleStatuses = moduleManager:getAllModuleStatuses()
}) 