local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")

-- Create necessary folders if they don't exist
local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

-- Ensure required folders exist
local modulesFolder = ensureFolder(PlayerScripts, "Modules")
local sharedFolder = ensureFolder(ReplicatedStorage, "Shared")
local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")

-- Helper function to safely require modules
local function safeRequire(modulePath)
    if not modulePath then
        warn("Invalid module path provided to safeRequire")
        return nil
    end
    
    local success, result = pcall(function()
        return require(modulePath)
    end)
    
    if success then
        return result
    else
        warn("Failed to load module:", modulePath.Name, "-", result)
        return nil
    end
end

-- Initialize UI modules
local function initializeUIModules()
    local uiModules = {
        -- Core UI
        Gui = safeRequire(modulesFolder.UI.Gui),
        MenuUI = safeRequire(modulesFolder.UI.MenuUI),
        LoadingUI = safeRequire(modulesFolder.UI.LoadingUI),
        
        -- Game UI
        HealthUI = safeRequire(modulesFolder.UI.HealthUI),
        AmmoUI = safeRequire(modulesFolder.UI.AmmoUI),
        CrosshairUI = safeRequire(modulesFolder.UI.CrosshairUI),
        MinimapUI = safeRequire(modulesFolder.UI.MinimapUI),
        ScoreUI = safeRequire(modulesFolder.UI.ScoreUI),
        TeamScoreUI = safeRequire(modulesFolder.UI.TeamScoreUI),
        LeaderboardUI = safeRequire(modulesFolder.UI.LeaderboardUI),
        KillFeedUI = safeRequire(modulesFolder.UI.KillFeedUI),
        
        -- Social UI
        FriendsUI = safeRequire(modulesFolder.UI.FriendsUI),
        SocialHubUI = safeRequire(modulesFolder.UI.SocialHubUI),
        SocialInteractionUI = safeRequire(modulesFolder.UI.SocialInteractionUI),
        SocialMediaUI = safeRequire(modulesFolder.UI.SocialMediaUI),
        PlayerProfileUI = safeRequire(modulesFolder.UI.PlayerProfileUI),
        
        -- Game Systems UI
        InventoryUI = safeRequire(modulesFolder.UI.InventoryUI),
        ShopUI = safeRequire(modulesFolder.UI.ShopUI),
        MarketplaceUI = safeRequire(modulesFolder.UI.MarketplaceUI),
        AchievementUI = safeRequire(modulesFolder.UI.AchievementUI),
        ProgressionUI = safeRequire(modulesFolder.UI.ProgressionUI),
        
        -- Building UI
        BuildingToolsUI = safeRequire(modulesFolder.UI.BuildingToolsUI),
        BuildingTemplateUI = safeRequire(modulesFolder.UI.BuildingTemplateUI),
        BuildingChallengeUI = safeRequire(modulesFolder.UI.BuildingChallengeUI),
        
        -- Other UI
        ChatUI = safeRequire(modulesFolder.UI.ChatUI),
        SettingsUI = safeRequire(modulesFolder.UI.SettingsUI),
        HelpUI = safeRequire(modulesFolder.UI.HelpUI),
        PauseUI = safeRequire(modulesFolder.UI.PauseUI),
        RoundUI = safeRequire(modulesFolder.UI.RoundUI),
        EndUI = safeRequire(modulesFolder.UI.EndUI),
        ErrorUI = safeRequire(modulesFolder.UI.ErrorUI),
        NotificationUI = safeRequire(modulesFolder.UI.NotificationUI),
        ConfirmationUI = safeRequire(modulesFolder.UI.ConfirmationUI),
        InputUI = safeRequire(modulesFolder.UI.InputUI),
        SpectatorUI = safeRequire(modulesFolder.UI.SpectatorUI),
        TeamUI = safeRequire(modulesFolder.UI.TeamUI),
        WeaponUI = safeRequire(modulesFolder.UI.WeaponUI),
        DailyRewardsUI = safeRequire(modulesFolder.UI.DailyRewardsUI),
        ScoreboardUI = safeRequire(modulesFolder.UI.ScoreboardUI)
    }
    
    -- Initialize modules in dependency order
    for name, module in pairs(uiModules) do
        if module and module.Initialize then
            local success, result = pcall(function()
                return module:Initialize()
            end)
            if not success then
                warn("Failed to initialize UI module:", name, "-", result)
            end
        end
    end
    
    return uiModules
end

-- Initialize core modules
local function initializeCoreModules()
    local coreModules = {
        -- Core Systems
        TutorialManager = safeRequire(modulesFolder.Tutorial.TutorialManager),
        AdminCommandHandler = safeRequire(modulesFolder.Admin.AdminCommandHandler),
        AdminReport = safeRequire(modulesFolder.Admin.AdminReport),
        ReportUI = safeRequire(modulesFolder.UI.ReportUI),
        ReportContextMenu = safeRequire(modulesFolder.Admin.ReportContextMenu)
    }
    
    -- Initialize modules in dependency order
    for name, module in pairs(coreModules) do
        if module and module.Initialize then
            local success, result = pcall(function()
                return module:Initialize()
            end)
            if not success then
                warn("Failed to initialize core module:", name, "-", result)
            end
        end
    end
    
    return coreModules
end

-- Initialize the system
local function initialize()
    -- Wait for remote events to be created
    for _, remoteName in ipairs({"ReportObject", "AdminCommand", "CompleteTutorial", "GetTutorialStatus"}) do
        local remote = remotesFolder:WaitForChild(remoteName, 10)
        if not remote then
            warn("Failed to find remote event:", remoteName)
        end
    end
    
    local coreModules = initializeCoreModules()
    if not coreModules then
        warn("Failed to initialize core modules")
        return nil
    end
    
    local uiModules = initializeUIModules()
    if not uiModules then
        warn("Failed to initialize UI modules")
        return nil
    end
    
    print("Client modules initialized successfully")
    return {
        core = coreModules,
        ui = uiModules
    }
end

-- Start initialization
local modules = initialize()

-- Return the initialized client system
return {
    Initialize = initialize,
    getModule = function(moduleName)
        return modules and (modules.core[moduleName] or modules.ui[moduleName])
    end
} 