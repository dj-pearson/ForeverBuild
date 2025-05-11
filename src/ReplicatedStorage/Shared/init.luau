local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load shared modules
local Types = require(script.Types)
local Constants = require(script.Constants)

-- Create RemoteManager
local RemoteManager = {
    _remotes = {},
    _callbacks = {}
}

function RemoteManager:onServerEvent(eventName, callback)
    local remote = self._remotes[eventName]
    if not remote then
        remote = ReplicatedStorage.Remotes:WaitForChild(eventName, 10)
        if not remote then
            warn("Failed to find remote event:", eventName)
            return
        end
        self._remotes[eventName] = remote
    end
    remote.OnServerEvent:Connect(callback)
end

function RemoteManager:setServerCallback(functionName, callback)
    local remote = self._remotes[functionName]
    if not remote then
        remote = ReplicatedStorage.Remotes:WaitForChild(functionName, 10)
        if not remote then
            warn("Failed to find remote function:", functionName)
            return
        end
        self._remotes[functionName] = remote
    end
    self._callbacks[functionName] = callback
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
end 