local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Logger = Shared.Logger

-- Helper function to safely require modules
local function safeRequire(module)
    local success, result = pcall(function()
        return require(module)
    end)
    
    if not success then
        Logger:error("Failed to load module", { module = module.Name, error = result })
        return nil
    end
    
    return result
end

-- Initialize client modules
local function initializeClientModules()
    -- Load UI module
    local uiModule = safeRequire(script.Modules.UI)
    if not uiModule then return false end
    
    -- Load Tutorial module
    local tutorialModule = safeRequire(script.Modules.Tutorial)
    if not tutorialModule then return false end
    
    -- Initialize modules
    if not uiModule.Initialize() then
        Logger:error("Failed to initialize UI module")
        return false
    end
    
    if not tutorialModule.Initialize() then
        Logger:error("Failed to initialize Tutorial module")
        return false
    end
    
    return true
end

-- Main initialization
local success, result = pcall(function()
    -- Create necessary folders
    if not script:FindFirstChild("Modules") then
        local modules = Instance.new("Folder")
        modules.Name = "Modules"
        modules.Parent = script
    end
    
    -- Initialize modules
    if not initializeClientModules() then
        error("Failed to initialize client modules")
    end
end)

if not success then
    Logger:error("Client initialization failed", { error = result })
else
    Logger:info("Client initialized successfully")
end

-- Initialize UI modules
local function initializeUIModules()
    local uiModules = {
        -- Core UI
        Gui = safeRequire(script.Modules.UI.Gui),
        MenuUI = safeRequire(script.Modules.UI.MenuUI),
        LoadingUI = safeRequire(script.Modules.UI.LoadingUI),
        
        -- Game UI
        HealthUI = safeRequire(script.Modules.UI.HealthUI),
        AmmoUI = safeRequire(script.Modules.UI.AmmoUI),
        CrosshairUI = safeRequire(script.Modules.UI.CrosshairUI),
        MinimapUI = safeRequire(script.Modules.UI.MinimapUI),
        ScoreUI = safeRequire(script.Modules.UI.ScoreUI),
        TeamScoreUI = safeRequire(script.Modules.UI.TeamScoreUI),
        LeaderboardUI = safeRequire(script.Modules.UI.LeaderboardUI),
        KillFeedUI = safeRequire(script.Modules.UI.KillFeedUI),
        
        -- Social UI
        FriendsUI = safeRequire(script.Modules.UI.FriendsUI),
        SocialHubUI = safeRequire(script.Modules.UI.SocialHubUI),
        SocialInteractionUI = safeRequire(script.Modules.UI.SocialInteractionUI),
        SocialMediaUI = safeRequire(script.Modules.UI.SocialMediaUI),
        PlayerProfileUI = safeRequire(script.Modules.UI.PlayerProfileUI),
        
        -- Game Systems UI
        InventoryUI = safeRequire(script.Modules.UI.InventoryUI),
        ShopUI = safeRequire(script.Modules.UI.ShopUI),
        MarketplaceUI = safeRequire(script.Modules.UI.MarketplaceUI),
        AchievementUI = safeRequire(script.Modules.UI.AchievementUI),
        ProgressionUI = safeRequire(script.Modules.UI.ProgressionUI),
        
        -- Building UI
        BuildingToolsUI = safeRequire(script.Modules.UI.BuildingToolsUI),
        BuildingTemplateUI = safeRequire(script.Modules.UI.BuildingTemplateUI),
        BuildingChallengeUI = safeRequire(script.Modules.UI.BuildingChallengeUI),
        
        -- Other UI
        ChatUI = safeRequire(script.Modules.UI.ChatUI),
        SettingsUI = safeRequire(script.Modules.UI.SettingsUI),
        HelpUI = safeRequire(script.Modules.UI.HelpUI),
        PauseUI = safeRequire(script.Modules.UI.PauseUI),
        RoundUI = safeRequire(script.Modules.UI.RoundUI),
        EndUI = safeRequire(script.Modules.UI.EndUI),
        ErrorUI = safeRequire(script.Modules.UI.ErrorUI),
        NotificationUI = safeRequire(script.Modules.UI.NotificationUI),
        ConfirmationUI = safeRequire(script.Modules.UI.ConfirmationUI),
        InputUI = safeRequire(script.Modules.UI.InputUI),
        SpectatorUI = safeRequire(script.Modules.UI.SpectatorUI),
        TeamUI = safeRequire(script.Modules.UI.TeamUI),
        WeaponUI = safeRequire(script.Modules.UI.WeaponUI),
        DailyRewardsUI = safeRequire(script.Modules.UI.DailyRewardsUI),
        ScoreboardUI = safeRequire(script.Modules.UI.ScoreboardUI)
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
        TutorialManager = safeRequire(script.Modules.Tutorial.TutorialManager),
        AdminCommandHandler = safeRequire(script.Modules.Admin.AdminCommandHandler),
        AdminReport = safeRequire(script.Modules.Admin.AdminReport),
        ReportUI = safeRequire(script.Modules.UI.ReportUI),
        ReportContextMenu = safeRequire(script.Modules.Admin.ReportContextMenu)
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