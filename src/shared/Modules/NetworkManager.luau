local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Logger = require(script.Parent.Logger)
local PerformanceManager = require(script.Parent.PerformanceManager)
local StateManager = require(script.Parent.StateManager)

local NetworkManager = {}

-- Constants
local NETWORK_BATCH_SIZE = 50
local NETWORK_UPDATE_INTERVAL = 1/30 -- 30 times per second
local MAX_RETRY_ATTEMPTS = 3
local RETRY_DELAY = 0.5

-- Network storage
local remoteEvents = {}
local remoteFunctions = {}
local networkSubscribers = {}
local pendingRequests = {}
local requestId = 0

-- Utility: Generate unique request ID
local function generateRequestId()
    requestId = requestId + 1
    return requestId
end

-- Utility: Validate network data
local function validateNetworkData(data, schema)
    if not data or not schema then
        return false, "Invalid data or schema"
    end

    for field, expectedType in pairs(schema) do
        if data[field] ~= nil then
            local actualType = typeof(data[field])
            if actualType ~= expectedType then
                return false, string.format("Invalid type for %s: expected %s, got %s", 
                    field, expectedType, actualType)
            end
        end
    end

    return true
end

-- Utility: Handle network errors
local function handleNetworkError(error, context)
    Logger.error("Network error", {
        error = error,
        context = context
    })
    
    -- Notify subscribers of network error
    for _, callback in ipairs(networkSubscribers.errors or {}) do
        task.spawn(function()
            pcall(callback, error, context)
        end)
    end
end

-- Public API: Remote Event Management
function NetworkManager.createRemoteEvent(name, schema)
    if remoteEvents[name] then
        Logger.warn("Remote event already exists", { name = name })
        return remoteEvents[name]
    end

    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = ReplicatedStorage

    remoteEvents[name] = {
        event = event,
        schema = schema
    }

    return event
end

function NetworkManager.createRemoteFunction(name, schema)
    if remoteFunctions[name] then
        Logger.warn("Remote function already exists", { name = name })
        return remoteFunctions[name]
    end

    local func = Instance.new("RemoteFunction")
    func.Name = name
    func.Parent = ReplicatedStorage

    remoteFunctions[name] = {
        func = func,
        schema = schema
    }

    return func
end

-- Public API: Network Communication
function NetworkManager.fireServer(name, data)
    local remote = remoteEvents[name]
    if not remote then
        handleNetworkError("Remote event not found", { name = name })
        return false
    end

    if remote.schema then
        local isValid, error = validateNetworkData(data, remote.schema)
        if not isValid then
            handleNetworkError(error, { name = name, data = data })
            return false
        end
    end

    remote.event:FireServer(data)
    PerformanceManager.trackNetworkCall()
    return true
end

function NetworkManager.fireClient(player, name, data)
    local remote = remoteEvents[name]
    if not remote then
        handleNetworkError("Remote event not found", { name = name })
        return false
    end

    if remote.schema then
        local isValid, error = validateNetworkData(data, remote.schema)
        if not isValid then
            handleNetworkError(error, { name = name, data = data })
            return false
        end
    end

    remote.event:FireClient(player, data)
    PerformanceManager.trackNetworkCall()
    return true
end

function NetworkManager.invokeServer(name, data)
    local remote = remoteFunctions[name]
    if not remote then
        handleNetworkError("Remote function not found", { name = name })
        return nil
    end

    if remote.schema then
        local isValid, error = validateNetworkData(data, remote.schema)
        if not isValid then
            handleNetworkError(error, { name = name, data = data })
            return nil
        end
    end

    local requestId = generateRequestId()
    pendingRequests[requestId] = {
        startTime = os.time(),
        attempts = 0
    }

    local success, result
    repeat
        success, result = pcall(function()
            return remote.func:InvokeServer(data)
        end)
        
        if not success then
            pendingRequests[requestId].attempts = pendingRequests[requestId].attempts + 1
            if pendingRequests[requestId].attempts < MAX_RETRY_ATTEMPTS then
                task.wait(RETRY_DELAY)
            end
        end
    until success or pendingRequests[requestId].attempts >= MAX_RETRY_ATTEMPTS

    pendingRequests[requestId] = nil
    PerformanceManager.trackNetworkCall()

    if not success then
        handleNetworkError(result, { name = name, data = data })
        return nil
    end

    return result
end

function NetworkManager.invokeClient(player, name, data)
    local remote = remoteFunctions[name]
    if not remote then
        handleNetworkError("Remote function not found", { name = name })
        return nil
    end

    if remote.schema then
        local isValid, error = validateNetworkData(data, remote.schema)
        if not isValid then
            handleNetworkError(error, { name = name, data = data })
            return nil
        end
    end

    local requestId = generateRequestId()
    pendingRequests[requestId] = {
        startTime = os.time(),
        attempts = 0
    }

    local success, result
    repeat
        success, result = pcall(function()
            return remote.func:InvokeClient(player, data)
        end)
        
        if not success then
            pendingRequests[requestId].attempts = pendingRequests[requestId].attempts + 1
            if pendingRequests[requestId].attempts < MAX_RETRY_ATTEMPTS then
                task.wait(RETRY_DELAY)
            end
        end
    until success or pendingRequests[requestId].attempts >= MAX_RETRY_ATTEMPTS

    pendingRequests[requestId] = nil
    PerformanceManager.trackNetworkCall()

    if not success then
        handleNetworkError(result, { name = name, data = data })
        return nil
    end

    return result
end

-- Public API: Network Subscription
function NetworkManager.subscribe(eventName, callback)
    local remote = remoteEvents[eventName]
    if not remote then
        handleNetworkError("Remote event not found", { name = eventName })
        return nil
    end

    if not networkSubscribers[eventName] then
        networkSubscribers[eventName] = {}
    end

    table.insert(networkSubscribers[eventName], callback)
    return function()
        for i, cb in ipairs(networkSubscribers[eventName]) do
            if cb == callback then
                table.remove(networkSubscribers[eventName], i)
                break
            end
        end
    end
end

function NetworkManager.subscribeToErrors(callback)
    if not networkSubscribers.errors then
        networkSubscribers.errors = {}
    end
    table.insert(networkSubscribers.errors, callback)
    return function()
        for i, cb in ipairs(networkSubscribers.errors) do
            if cb == callback then
                table.remove(networkSubscribers.errors, i)
                break
            end
        end
    end
end

-- Public API: Network Monitoring
function NetworkManager.getPendingRequests()
    return pendingRequests
end

function NetworkManager.cleanup()
    -- Clean up old pending requests
    local currentTime = os.time()
    for id, request in pairs(pendingRequests) do
        if currentTime - request.startTime > 30 then -- 30 second timeout
            pendingRequests[id] = nil
        end
    end
end

-- Initialize the NetworkManager
function NetworkManager.init()
    Logger.info("Initializing NetworkManager")
    
    -- Set up periodic cleanup
    task.spawn(function()
        while true do
            task.wait(60) -- Every minute
            NetworkManager.cleanup()
        end
    end)
    
    Logger.info("NetworkManager initialized successfully")
end

return NetworkManager 