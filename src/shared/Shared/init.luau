--init file for shared modules

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleLoader = require(script.Parent.ModuleLoader)

local Shared = {}

-- Debug logging
local function debugLog(message)
    print("[Shared] " .. message)
end

-- Retry logic for module loading
local function loadModuleWithRetry(loader, maxRetries)
    maxRetries = maxRetries or 3
    local retryCount = 0
    local lastError = nil
    
    while retryCount < maxRetries do
        local success, result = pcall(loader)
        if success then
            return result
        end
        lastError = result
        retryCount = retryCount + 1
        debugLog(string.format("Retry %d/%d loading module: %s", retryCount, maxRetries, lastError))
        task.wait(0.1) -- Small delay between retries
    end
    
    return nil, lastError
end

-- Lazy load modules with stack tracking and retry logic
function Shared.getTypes()
    debugLog("Loading Types module...")
    return loadModuleWithRetry(function()
        return ModuleLoader.getModule(script.Parent.Types)
    end)
end

function Shared.getConstants()
    debugLog("Loading Constants module...")
    return loadModuleWithRetry(function()
        return ModuleLoader.getModule(script.Parent.Constants)
    end)
end

function Shared.getStateManager()
    debugLog("Loading StateManager module...")
    return loadModuleWithRetry(function()
        return ModuleLoader.getModule(script.Parent.StateManager)
    end)
end

function Shared.getErrorBoundary()
    debugLog("Loading ErrorBoundary module...")
    return loadModuleWithRetry(function()
        return ModuleLoader.getModule(script.Parent.ErrorBoundary)
    end)
end

-- Initialize the Shared module with diagnostic information
function Shared.init()
    debugLog("Initializing Shared module...")
    
    -- Clear any existing module cache and history
    ModuleLoader.clearCache()
    
    -- Ensure required folders exist first
    local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")
    
    -- Create all required remotes before initializing managers
    local remotes = {
        ReportObject = createRemoteEvent("ReportObject"),
        AdminCommand = createRemoteEvent("AdminCommand"),
        CompleteTutorial = createRemoteEvent("CompleteTutorial"),
        ReportResponse = createRemoteEvent("ReportResponse"),
        GetTutorialStatus = createRemoteFunction("GetTutorialStatus")
    }
    
    -- Initialize RemoteManager with existing remotes
    local RemoteManager = {
        _remotes = remotes,
        _callbacks = {}
    }
    
    -- Set up RemoteManager methods
    for name, func in pairs(RemoteManagerMethods) do
        RemoteManager[name] = func
    end
    
    -- Configure Logger to show debug messages
    Logger.currentLevel = Logger.levels.DEBUG
    
    -- Try to load critical modules with diagnostic information
    local success, result = pcall(function()
        -- Preload critical modules in correct order with retry logic
        local Types, typesError = loadModuleWithRetry(Shared.getTypes)
        if not Types then
            error("Failed to load Types module: " .. tostring(typesError))
        end
        
        local Constants, constantsError = loadModuleWithRetry(Shared.getConstants)
        if not Constants then
            error("Failed to load Constants module: " .. tostring(constantsError))
        end
        
        return true
    end)
    
    if not success then
        debugLog("Module loading failed: " .. tostring(result))
        
        -- Get diagnostic information
        local history = ModuleLoader.getModuleLoadHistory()
        local analysis = ModuleLoader.analyzeDependencies()
        
        debugLog("Module Load History:")
        for i, entry in ipairs(history) do
            debugLog(string.format("%d: %s (depth: %d)", i, entry.path, entry.depth))
        end
        
        debugLog("Dependency Analysis:")
        debugLog("Max depth reached: " .. analysis.maxDepth)
        if #analysis.circularDeps > 0 then
            debugLog("Potential circular dependencies found:")
            for _, dep in ipairs(analysis.circularDeps) do
                debugLog(string.format("  %s -> %s", dep.start, dep.path))
            end
        end
        
        return false
    end
    
    debugLog("Shared module initialized successfully")
    return true
end

-- Create necessary folders
local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

-- Create remote events
local function createRemoteEvent(name)
    local remote = remotesFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remotesFolder
    end
    return remote
end

-- Create remote functions
local function createRemoteFunction(name)
    local remote = remotesFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = name
        remote.Parent = remotesFolder
    end
    return remote
end

-- RemoteManager methods
local RemoteManagerMethods = {
    onServerEvent = function(self, eventName, callback)
        local remote = self._remotes[eventName]
        if not remote then
            warn("Remote event not found:", eventName)
            return
        end
        return remote.OnServerEvent:Connect(callback)
    end,
    
    onClientEvent = function(self, eventName, callback)
        local remote = self._remotes[eventName]
        if not remote then
            warn("Remote event not found:", eventName)
            return
        end
        return remote.OnClientEvent:Connect(callback)
    end,
    
    fireServer = function(self, eventName, ...)
        local remote = self._remotes[eventName]
        if not remote then
            warn("Remote event not found:", eventName)
            return
        end
        remote:FireServer(...)
    end,
    
    fireClient = function(self, eventName, ...)
        local remote = self._remotes[eventName]
        if not remote then
            warn("Remote event not found:", eventName)
            return
        end
        remote:FireClient(...)
    end,
    
    setServerCallback = function(self, functionName, callback)
        local remote = self._remotes[functionName]
        if not remote then
            warn("Remote function not found:", functionName)
            return
        end
        self._callbacks[functionName] = callback
        remote.OnServerInvoke = callback
    end,
    
    invokeServer = function(self, functionName, ...)
        local remote = self._remotes[functionName]
        if not remote then
            warn("Remote function not found:", functionName)
            return nil
        end
        return remote:InvokeServer(...)
    end
}

-- Create Logger
local Logger = {
    levels = {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3
    },
    currentLevel = 0 -- Default to DEBUG
}

function Logger:setLevel(level)
    self.currentLevel = level
end

function Logger:log(level, message, data)
    if level < self.currentLevel then return end
    
    local prefix = ""
    if level == self.levels.DEBUG then prefix = "[DEBUG]"
    elseif level == self.levels.INFO then prefix = "[INFO]"
    elseif level == self.levels.WARN then prefix = "[WARN]"
    elseif level == self.levels.ERROR then prefix = "[ERROR]"
    end
    
    if data then
        print(prefix, message, data)
    else
        print(prefix, message)
    end
end

function Logger:debug(message, data)
    self:log(self.levels.DEBUG, message, data)
end

function Logger:info(message, data)
    self:log(self.levels.INFO, message, data)
end

function Logger:warn(message, data)
    self:log(self.levels.WARN, message, data)
end

function Logger:error(message, data)
    self:log(self.levels.ERROR, message, data)
end

-- Export shared modules with lazy loading
return {
    getTypes = Shared.getTypes,
    getConstants = Shared.getConstants,
    getStateManager = Shared.getStateManager,
    getErrorBoundary = Shared.getErrorBoundary,
    remotes = remotes,
    RemoteManager = RemoteManager,
    Logger = Logger,
    init = Shared.init
}