local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load core modules
local CurrencyUI = require(ReplicatedStorage.shared.core.ui.CurrencyUI)
local InteractionSystem = require(script.Parent.interaction.InteractionSystem)

-- Initialize UI
local currencyUI = CurrencyUI.new()
currencyUI:Initialize()

-- Initialize interaction system
local interactionSystem = InteractionSystem.new()
interactionSystem:Initialize()

print("Client initialized successfully")

-- ... existing code ... 