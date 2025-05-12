local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientStateManager = {}
ClientStateManager.__index = ClientStateManager

-- Private variables
local currentState = {
    coins = 0,
    level = 1,
    experience = 0,
    inventory = {},
    settings = {
        musicVolume = 0.5,
        sfxVolume = 0.5
    }
}

local stateListeners = {}

-- Initialize a new client state manager
function ClientStateManager.new()
    local self = setmetatable({}, ClientStateManager)
    self:Initialize()
    return self
end

-- Initialize the client state manager
function ClientStateManager:Initialize()
    -- Set up attribute change listeners
    LocalPlayer:GetAttributeChangedSignal("Level"):Connect(function()
        self:UpdateState("level", LocalPlayer:GetAttribute("Level"))
    end)
    
    LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
        self:UpdateState("coins", LocalPlayer:GetAttribute("Coins"))
    end)
    
    -- Initialize state from attributes
    self:UpdateState("level", LocalPlayer:GetAttribute("Level") or 1)
    self:UpdateState("coins", LocalPlayer:GetAttribute("Coins") or 0)
end

-- Update the state and notify listeners
function ClientStateManager:UpdateState(key, value)
    currentState[key] = value
    
    -- Notify listeners
    if stateListeners[key] then
        for _, listener in ipairs(stateListeners[key]) do
            task.spawn(listener, value)
        end
    end
end

-- Get current state
function ClientStateManager:GetState(key)
    return key and currentState[key] or currentState
end

-- Subscribe to state changes
function ClientStateManager:Subscribe(key, callback)
    if not stateListeners[key] then
        stateListeners[key] = {}
    end
    
    table.insert(stateListeners[key], callback)
    
    -- Return unsubscribe function
    return function()
        for i, listener in ipairs(stateListeners[key]) do
            if listener == callback then
                table.remove(stateListeners[key], i)
                break
            end
        end
    end
end

-- Update settings
function ClientStateManager:UpdateSettings(key, value)
    if not currentState.settings[key] then
        warn("Invalid setting key:", key)
        return false
    end
    
    currentState.settings[key] = value
    self:UpdateState("settings", currentState.settings)
    return true
end

-- Get settings
function ClientStateManager:GetSettings(key)
    return key and currentState.settings[key] or currentState.settings
end

return ClientStateManager 