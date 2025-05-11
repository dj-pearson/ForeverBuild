local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Logger = require(game.ServerScriptService.Logger)
local PerformanceManager = require(game.ServerScriptService.PerformanceManager)

local StateManager = {}

-- Constants
local STATE_UPDATE_INTERVAL = 1/30 -- 30 times per second
local MAX_STATE_HISTORY = 10
local STATE_CHANGE_THRESHOLD = 0.1

-- State storage
local gameState = {
    current = nil,
    previous = nil,
    history = {},
    lastUpdate = 0
}

local playerStates = {}
local stateSubscribers = {}

-- State validation schemas
local stateSchemas = {
    game = {
        required = { "phase", "time", "players" },
        types = {
            phase = "string",
            time = "number",
            players = "table"
        }
    },
    player = {
        required = { "id", "position", "health", "inventory" },
        types = {
            id = "string",
            position = "Vector3",
            health = "number",
            inventory = "table"
        }
    }
}

-- Utility: Validate state against schema
local function validateState(state, schema)
    if not state or not schema then
        return false, "Invalid state or schema"
    end

    -- Check required fields
    for _, field in ipairs(schema.required) do
        if state[field] == nil then
            return false, "Missing required field: " .. field
        end
    end

    -- Check field types
    for field, expectedType in pairs(schema.types) do
        if state[field] ~= nil then
            local actualType = typeof(state[field])
            if actualType ~= expectedType then
                return false, string.format("Invalid type for %s: expected %s, got %s", 
                    field, expectedType, actualType)
            end
        end
    end

    return true
end

-- Utility: Check if state has changed significantly
local function hasStateChanged(newState, oldState)
    if not oldState then return true end
    
    for key, value in pairs(newState) do
        if type(value) == "number" then
            if math.abs(value - (oldState[key] or 0)) > STATE_CHANGE_THRESHOLD then
                return true
            end
        elseif type(value) == "Vector3" then
            if (value - (oldState[key] or Vector3.new())).Magnitude > STATE_CHANGE_THRESHOLD then
                return true
            end
        elseif value ~= oldState[key] then
            return true
        end
    end
    
    return false
end

-- Utility: Notify subscribers of state change
local function notifySubscribers(stateType, newState, oldState)
    if not stateSubscribers[stateType] then return end
    
    for _, callback in ipairs(stateSubscribers[stateType]) do
        task.spawn(function()
            local success, err = pcall(callback, newState, oldState)
            if not success then
                Logger.error("State subscriber error", {
                    error = err,
                    stateType = stateType
                })
            end
        end)
    end
end

-- Public API: Game state management
function StateManager.setState(newState)
    local isValid, error = validateState(newState, stateSchemas.game)
    if not isValid then
        Logger.error("Invalid game state", { error = error })
        return false
    end

    -- Check if state has changed significantly
    if not hasStateChanged(newState, gameState.current) then
        return false
    end

    -- Update state history
    gameState.previous = gameState.current
    gameState.current = newState
    table.insert(gameState.history, newState)
    
    -- Trim history if too long
    while #gameState.history > MAX_STATE_HISTORY do
        table.remove(gameState.history, 1)
    end

    gameState.lastUpdate = os.time()
    
    -- Notify subscribers
    notifySubscribers("game", newState, gameState.previous)
    
    -- Cache the state
    PerformanceManager.setCached("gameState", newState)
    
    return true
end

function StateManager.getState()
    return gameState.current
end

function StateManager.getPreviousState()
    return gameState.previous
end

function StateManager.getStateHistory()
    return gameState.history
end

-- Public API: Player state management
function StateManager.setPlayerState(playerId, newState)
    local isValid, error = validateState(newState, stateSchemas.player)
    if not isValid then
        Logger.error("Invalid player state", { 
            error = error,
            playerId = playerId
        })
        return false
    end

    local oldState = playerStates[playerId]
    
    -- Check if state has changed significantly
    if not hasStateChanged(newState, oldState) then
        return false
    end

    playerStates[playerId] = newState
    
    -- Notify subscribers
    notifySubscribers("player", newState, oldState)
    
    -- Cache the state
    PerformanceManager.setCached("playerState_" .. playerId, newState)
    
    return true
end

function StateManager.getPlayerState(playerId)
    return playerStates[playerId]
end

function StateManager.removePlayerState(playerId)
    playerStates[playerId] = nil
    PerformanceManager.setCached("playerState_" .. playerId, nil)
end

-- Public API: State subscription
function StateManager.subscribe(stateType, callback)
    if not stateSubscribers[stateType] then
        stateSubscribers[stateType] = {}
    end
    table.insert(stateSubscribers[stateType], callback)
    
    return function()
        for i, cb in ipairs(stateSubscribers[stateType]) do
            if cb == callback then
                table.remove(stateSubscribers[stateType], i)
                break
            end
        end
    end
end

-- Public API: State synchronization
function StateManager.syncState()
    local currentTime = os.time()
    if currentTime - gameState.lastUpdate < STATE_UPDATE_INTERVAL then
        return
    end

    -- Sync game state
    if gameState.current then
        -- Implementation will depend on your networking setup
        -- This is a placeholder for the actual sync logic
        Logger.debug("Syncing game state", {
            state = gameState.current
        })
    end

    -- Sync player states
    for playerId, state in pairs(playerStates) do
        -- Implementation will depend on your networking setup
        -- This is a placeholder for the actual sync logic
        Logger.debug("Syncing player state", {
            playerId = playerId,
            state = state
        })
    end
end

-- Initialize the StateManager
function StateManager.init()
    Logger.info("Initializing StateManager")
    
    -- Set up state synchronization
    task.spawn(function()
        while true do
            task.wait(STATE_UPDATE_INTERVAL)
            StateManager.syncState()
        end
    end)
    
    Logger.info("StateManager initialized successfully")
end

return StateManager 