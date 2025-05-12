local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Types = Shared.Types
local StateManager = Shared.StateManager
local ModuleDependencyManager = Shared.ModuleDependencyManager
local ErrorBoundary = Shared.ErrorBoundary

-- Load UI modules
local UIComponents = {
    AchievementUI = require(script.Parent.AchievementUI),
    ProgressionUI = require(script.Parent.ProgressionUI),
    BuildingChallengeUI = require(script.Parent.BuildingChallengeUI),
    BuildingTemplateUI = require(script.Parent.BuildingTemplateUI),
    BuildingToolsUI = require(script.Parent.BuildingToolsUI),
    SocialMediaUI = require(script.Parent.SocialMediaUI),
    PlayerProfileUI = require(script.Parent.PlayerProfileUI),
    SocialInteractionUI = require(script.Parent.SocialInteractionUI),
    SocialHubUI = require(script.Parent.SocialHubUI),
    FriendsUI = require(script.Parent.FriendsUI),
    Marketplace = require(script.Parent.Marketplace),
    DailyRewardsUI = require(script.Parent.DailyRewardsUI),
}

-- Register module dependencies
ModuleDependencyManager:registerModule("PlayerProfileUI", {"SocialHubUI"})
ModuleDependencyManager:registerModule("SocialInteractionUI", {"SocialHubUI"})
ModuleDependencyManager:registerModule("FriendsUI", {"SocialHubUI"})
ModuleDependencyManager:registerModule("BuildingChallengeUI", {"BuildingToolsUI"})
ModuleDependencyManager:registerModule("BuildingTemplateUI", {"BuildingToolsUI"})

-- Create error boundaries for UI components
local ErrorBoundaries = {}
for name, component in UIComponents do
    -- Create a simple fallback UI for each component
    local fallbackUI = {
        init = function() end,
        show = function() end,
        hide = function() end,
        update = function() end,
        destroy = function() end,
    }
    
    ErrorBoundaries[name] = ErrorBoundary.new(component, fallbackUI)
end

-- Initialize UI state
StateManager:setState("UI", {
    activeComponents = {},
    visibleComponents = {},
})

-- Initialize all UI components
local function initializeUI()
    -- Create initialization functions for each component
    local initFunctions = {}
    for name, boundary in ErrorBoundaries do
        initFunctions[name] = function()
            boundary:init()
            -- Subscribe to state changes
            StateManager:subscribe("UI", function(newState)
                boundary:update(newState)
            end)
        end
    end
    
    -- Initialize all components in the correct order
    local success = ModuleDependencyManager:initializeAll(initFunctions)
    if not success then
        warn("Failed to initialize all UI components")
        return false
    end
    
    return true
end

-- Main initialization
local success, result = pcall(function()
    if not initializeUI() then
        error("Failed to initialize UI")
    end
end)

if not success then
    warn("UI initialization failed:", result)
else
    print("UI initialized successfully")
end

return {
    Initialize = initializeUI,
    GetComponent = function(name: string)
        return ErrorBoundaries[name]
    end,
    ShowComponent = function(name: string)
        local boundary = ErrorBoundaries[name]
        if boundary then
            boundary:show()
            local state = StateManager:getState("UI")
            state.visibleComponents[name] = true
            StateManager:setState("UI", state)
        end
    end,
    HideComponent = function(name: string)
        local boundary = ErrorBoundaries[name]
        if boundary then
            boundary:hide()
            local state = StateManager:getState("UI")
            state.visibleComponents[name] = false
            StateManager:setState("UI", state)
        end
    end,
} 