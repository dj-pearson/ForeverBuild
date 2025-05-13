--[[
    Shared Module - ForeverBuild2
    
    This is the main entry point for all shared modules.
    When requiring this module, you'll get access to all sub-modules.
]]

local SharedModule = {}

-- Create references to all sub-modules in the core folder
SharedModule.Constants = require(script.core.Constants)
SharedModule.GameManager = require(script.core.GameManager)
SharedModule.CurrencyManager = require(script.core.economy.CurrencyManager)
SharedModule.InventoryManager = require(script.core.inventory.InventoryManager)
SharedModule.ItemManager = require(script.core.inventory.ItemManager)
SharedModule.PlacementManager = require(script.core.placement.PlacementManager)

-- Core modules are in a subfolder
SharedModule.Core = {}
local coreModules = script.core:GetChildren()
for _, moduleScript in ipairs(coreModules) do
    if moduleScript:IsA("ModuleScript") then
        SharedModule.Core[moduleScript.Name] = require(moduleScript)
    end
end

-- Helper function to initialize all shared modules
function SharedModule.Init()
    print("Initializing SharedModule...")
    
    -- Initialize sub-modules that need initialization
    if SharedModule.GameManager.Init then SharedModule.GameManager.Init() end
    if SharedModule.CurrencyManager.Init then SharedModule.CurrencyManager.Init() end
    if SharedModule.InventoryManager.Init then SharedModule.InventoryManager.Init() end
    if SharedModule.ItemManager.Init then SharedModule.ItemManager.Init() end
    if SharedModule.PlacementManager.Init then SharedModule.PlacementManager.Init() end
    
    -- Initialize core modules
    for name, module in pairs(SharedModule.Core) do
        if module.Init then
            module.Init()
        elseif module.Initialize then
            -- Some modules use Initialize instead of Init
            module.Initialize()
        end
    end
    
    return true
end

return SharedModule
