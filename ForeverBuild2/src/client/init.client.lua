local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Add debug print to confirm script is running
print("Client script starting...")

-- Load core modules
local SharedModule = require(ReplicatedStorage.shared)
SharedModule.Init() -- Ensure all shared systems are initialized

local UI = require(ReplicatedStorage.shared.core.ui)
UI.InventoryUI.Initialize(Players.LocalPlayer.PlayerGui)
UI.PurchaseDialog.Initialize(Players.LocalPlayer.PlayerGui)
local currencyUI = UI.CurrencyUI.new()
currencyUI:Initialize()
UI.PlacedItemDialog.Initialize(Players.LocalPlayer.PlayerGui)

-- The interaction module is a child of this script
local InteractionSystem = require(script.interaction.InteractionSystem)
-- Get StarterGui service
local StarterGui = game:GetService("StarterGui")

-- Initialize UI
-- StarterGui should already have UI elements from Roblox Studio
-- We don't need to explicitly initialize it here as those scripts will run automatically

-- Initialize interaction system
local interactionSystem = InteractionSystem.new()
interactionSystem:Initialize()

print("Client initialized successfully")

-- ... existing code ... 