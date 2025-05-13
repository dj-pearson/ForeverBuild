local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load core modules
local SharedModule = require(ReplicatedStorage.shared)
local InteractionSystem = require(script.Parent.interaction.InteractionSystem)
local StarterGui = require(script.Parent.StarterGui)

-- Initialize UI
local starterGui = StarterGui.new()
starterGui:Init()

-- Initialize interaction system
local interactionSystem = InteractionSystem.new()
interactionSystem:Initialize()

print("Client initialized successfully") 