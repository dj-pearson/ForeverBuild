local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Constants)

local RemoteManager = {}
RemoteManager.__index = RemoteManager

-- Initialize the RemoteManager
function RemoteManager.new()
    local self = setmetatable({}, RemoteManager)
    self.remotes = {}
    self.remoteFunctions = {}
    self.connections = {}
    return self
end

-- Get a remote event by name
function RemoteManager:getRemote(name)
    if self.remotes[name] then
        return self.remotes[name]
    end
    
    local shared = ReplicatedStorage:WaitForChild("Shared", 10)
    if not shared then
        warn(Constants.ErrorMessages.RemoteNotFound:format(name))
        return nil
    end
    
    local remotes = shared:WaitForChild("Remotes", 10)
    if not remotes then
        warn(Constants.ErrorMessages.RemoteNotFound:format(name))
        return nil
    end
    
    local remote = remotes:WaitForChild(name, 10)
    if not remote then
        warn(Constants.ErrorMessages.RemoteNotFound:format(name))
        return nil
    end
    
    self.remotes[name] = remote
    return remote
end

-- Fire a remote event
function RemoteManager:fireRemote(name, ...)
    local remote = self:getRemote(name)
    if remote then
        remote:FireServer(...)
    end
end

-- Fire a remote event to all clients
function RemoteManager:fireRemoteToAll(name, ...)
    local remote = self:getRemote(name)
    if remote then
        remote:FireAllClients(...)
    end
end

-- Fire a remote event to specific players
function RemoteManager:fireRemoteToPlayers(name, players, ...)
    local remote = self:getRemote(name)
    if remote then
        remote:FireClient(players, ...)
    end
end

-- Connect to a remote event
function RemoteManager:onRemote(name, callback)
    local remote = self:getRemote(name)
    if remote then
        local connection = remote.OnClientEvent:Connect(callback)
        self.connections[name] = connection
        return connection
    end
    return nil
end

-- Disconnect from a remote event
function RemoteManager:disconnectRemote(name)
    if self.connections[name] then
        self.connections[name]:Disconnect()
        self.connections[name] = nil
    end
end

-- Clean up all connections
function RemoteManager:cleanup()
    for name, connection in pairs(self.connections) do
        connection:Disconnect()
        self.connections[name] = nil
    end
end

return RemoteManager 