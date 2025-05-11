local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared system
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local ModuleManager = Shared.ModuleManager
local RemoteManager = Shared.RemoteManager

-- Initialize core modules
local function initializeCoreModules()
    local coreModules = {
        -- UI Systems
        InventoryUI = require(script.Parent.Modules.UI.InventoryUI),
        MarketplaceUI = require(script.Parent.Modules.UI.MarketplaceUI),
        DailyRewardsUI = require(script.Parent.Modules.UI.DailyRewardsUI),
        LeaderboardUI = require(script.Parent.Modules.UI.LeaderboardUI),
        AchievementUI = require(script.Parent.Modules.UI.AchievementUI),
        FriendsUI = require(script.Parent.Modules.UI.FriendsUI),
        SocialHubUI = require(script.Parent.Modules.UI.SocialHubUI),
        SocialInteractionUI = require(script.Parent.Modules.UI.SocialInteractionUI),
        PlayerProfileUI = require(script.Parent.Modules.UI.PlayerProfileUI),
        SocialMediaUI = require(script.Parent.Modules.UI.SocialMediaUI),
        BuildingToolsUI = require(script.Parent.Modules.UI.BuildingToolsUI),
        BuildingTemplateUI = require(script.Parent.Modules.UI.BuildingTemplateUI),
        BuildingChallengeUI = require(script.Parent.Modules.UI.BuildingChallengeUI),
        
        -- Admin Systems
        AdminCommandHandler = require(script.Parent.Modules.Admin.AdminCommandHandler),
        ReportUI = require(script.Parent.Modules.Admin.ReportUI),
        AdminReportUI = require(script.Parent.Modules.Admin.AdminReport),
        ReportContextMenu = require(script.Parent.Modules.Admin.ReportContextMenu),
        
        -- Game Systems
        ClientManager = require(script.Parent.Modules.ClientManager),
        TutorialManager = require(script.Parent.Modules.TutorialManager),
        ObjectInteractionManager = require(script.Parent.Modules.UI.ObjectInteractionManager)
    }
    
    -- Register modules with their dependencies
    ModuleManager.registerModule("ClientManager", coreModules.ClientManager, {})
    ModuleManager.registerModule("TutorialManager", coreModules.TutorialManager, { "ClientManager" })
    ModuleManager.registerModule("ObjectInteractionManager", coreModules.ObjectInteractionManager, { "ClientManager" })
    
    -- Register UI modules
    for name, module in pairs(coreModules) do
        if string.match(name, "UI$") then
            ModuleManager.registerModule(name, module, { "ClientManager" })
        end
    end
    
    -- Register admin modules
    ModuleManager.registerModule("AdminCommandHandler", coreModules.AdminCommandHandler, { "ClientManager" })
    ModuleManager.registerModule("ReportUI", coreModules.ReportUI, { "ClientManager" })
    ModuleManager.registerModule("AdminReportUI", coreModules.AdminReportUI, { "ClientManager" })
    ModuleManager.registerModule("ReportContextMenu", coreModules.ReportContextMenu, { "ClientManager" })
    
    return coreModules
end

-- Initialize the system
local function initialize()
    -- Initialize core modules
    local coreModules = initializeCoreModules()
    
    -- Initialize all modules in dependency order
    ModuleManager.initializeAll()
    
    -- Set up UI cleanup on player leaving
    Players.PlayerRemoving:Connect(function(player)
        if player == Players.LocalPlayer then
            for _, module in pairs(coreModules) do
                if module.cleanup then
                    module.cleanup()
                end
            end
        end
    end)
    
    print("Client: All systems initialized successfully")
end

-- Start initialization
initialize()

-- Return the initialized client system
return {
    Initialize = initialize,
    getModule = function(modulePath)
        return ModuleManager.getModule(modulePath)
    end
} 