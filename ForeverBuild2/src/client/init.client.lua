local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load core modules
local CurrencyUI = require(ReplicatedStorage.shared.core.ui.CurrencyUI)

-- Initialize UI
local currencyUI = CurrencyUI.new()

print("Client initialized successfully")

-- ... existing code ... 