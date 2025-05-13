--[[
    Shared Module - ForeverBuild2
    
    This is the main entry point for all shared modules.
    When requiring this module, you'll get access to all sub-modules.
]]

local SharedModule = {}

SharedModule.Constants = require(script.core.Constants)
SharedModule.GameManager = require(script.core.GameManager)
SharedModule.UI = require(script.core.ui)
SharedModule.Interaction = require(script.core.interaction)
SharedModule.Placement = require(script.core.placement)
SharedModule.Inventory = require(script.core.inventory)
SharedModule.Economy = require(script.core.economy)

function SharedModule.Init()
    print("Initializing SharedModule...")

    -- Initialize submodules if they have Init/Initialize
    for _, sub in pairs({
        SharedModule.GameManager,
        SharedModule.UI,
        SharedModule.Interaction,
        SharedModule.Placement,
        SharedModule.Inventory,
        SharedModule.Economy
    }) do
        if sub.Init then sub.Init() end
        if sub.Initialize then sub.Initialize() end
    end

    return true
end

return SharedModule
