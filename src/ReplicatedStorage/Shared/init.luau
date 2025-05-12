local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

-- Ensure required folders exist
local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")

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

-- Create all required remotes
local remotes = {
    ReportObject = createRemoteEvent("ReportObject"),
    AdminCommand = createRemoteEvent("AdminCommand"),
    CompleteTutorial = createRemoteEvent("CompleteTutorial"),
    ReportResponse = createRemoteEvent("ReportResponse"),
    GetTutorialStatus = createRemoteFunction("GetTutorialStatus")
}

-- Load shared modules
local Types = require(script.Types)
local Constants = require(script.Constants)

-- Create RemoteManager
local RemoteManager = {
    _remotes = remotes,
    _callbacks = {}
}

function RemoteManager:onServerEvent(eventName, callback)
    local remote = self._remotes[eventName]
    if not remote then
        warn("Remote event not found:", eventName)
        return
    end
    remote.OnServerEvent:Connect(callback)
end

function RemoteManager:onClientEvent(eventName, callback)
    local remote = self._remotes[eventName]
    if not remote then
        warn("Remote event not found:", eventName)
        return
    end
    remote.OnClientEvent:Connect(callback)
end

function RemoteManager:fireServer(eventName, ...)
    local remote = self._remotes[eventName]
    if not remote then
        warn("Remote event not found:", eventName)
        return
    end
    remote:FireServer(...)
end

function RemoteManager:fireClient(eventName, ...)
    local remote = self._remotes[eventName]
    if not remote then
        warn("Remote event not found:", eventName)
        return
    end
    remote:FireClient(...)
end

function RemoteManager:setServerCallback(functionName, callback)
    local remote = self._remotes[functionName]
    if not remote then
        warn("Remote function not found:", functionName)
        return
    end
    self._callbacks[functionName] = callback
    remote.OnServerInvoke = callback
end

function RemoteManager:invokeServer(functionName, ...)
    local remote = self._remotes[functionName]
    if not remote then
        warn("Remote function not found:", functionName)
        return nil
    end
    return remote:InvokeServer(...)
end

-- Create Logger
local Logger = {
    levels = {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3
    },
    currentLevel = 1 -- Default to INFO
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

-- Export shared modules
return {
    Types = Types,
    Constants = Constants,
    RemoteManager = RemoteManager,
    Logger = Logger
}