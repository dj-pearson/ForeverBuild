--[[
    StarterGui Module - ForeverBuild2
    
    This is the main initialization script for the StarterGui.
    It handles loading and setting up all UI components.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get shared module
local SharedModule = require(ReplicatedStorage.shared)

-- Local references to commonly used modules
local Constants = SharedModule.Constants
local GameManager = SharedModule.GameManager
local CurrencyManager = SharedModule.CurrencyManager

local StarterGuiModule = {}

-- Wait for the player to be loaded fully
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Initialize the UI components based on what's available in the folder
local function InitializeUIComponents()
    -- Get all UI components in this folder
    local uiComponents = script:GetChildren()
    
    for _, component in ipairs(uiComponents) do
        -- Check if it's a UI component we can use
        if component:IsA("ScreenGui") or component:IsA("BillboardGui") or component:IsA("SurfaceGui") then
            -- Clone to PlayerGui if not already there
            if not playerGui:FindFirstChild(component.Name) then
                local clone = component:Clone()
                clone.Parent = playerGui
                print("UI Component loaded:", component.Name)
            end
        elseif component:IsA("ModuleScript") then
            -- If it's a module, require it and init if possible
            local module = require(component)
            if typeof(module) == "table" and module.Init then
                module.Init()
                print("UI Module initialized:", component.Name)
            end
        end
    end
end

function StarterGuiModule.Init()
    print("Initializing StarterGui...")
    
    -- Initialize all UI components
    InitializeUIComponents()
    
    -- Set up event connections for UI updates
    CurrencyManager.CurrencyChanged:Connect(function(newAmount)
        -- Update any currency displays
        print("Currency updated to:", newAmount)
        -- Implement UI update logic here
    end)
    
    return true
end

-- Auto-initialize
StarterGuiModule.Init()

return StarterGuiModule
