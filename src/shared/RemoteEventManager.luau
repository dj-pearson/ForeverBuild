local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEventManager = {}
RemoteEventManager.__index = RemoteEventManager

-- Create the Remotes folder if it doesn't exist
local function ensureRemotesFolder()
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end
    return remotesFolder
end

-- Initialize the RemoteEventManager
function RemoteEventManager.new()
    local self = setmetatable({}, RemoteEventManager)
    self.remotesFolder = ensureRemotesFolder()
    self.remoteEvents = {}
    return self
end

-- Create or get a RemoteEvent
function RemoteEventManager:getRemoteEvent(name)
    if not self.remoteEvents[name] then
        local remoteEvent = self.remotesFolder:FindFirstChild(name)
        if not remoteEvent then
            remoteEvent = Instance.new("RemoteEvent")
            remoteEvent.Name = name
            remoteEvent.Parent = self.remotesFolder
        end
        self.remoteEvents[name] = remoteEvent
    end
    return self.remoteEvents[name]
end

-- Fire a RemoteEvent
function RemoteEventManager:fireRemote(name, ...)
    local remoteEvent = self:getRemoteEvent(name)
    remoteEvent:FireServer(...)
end

-- Fire a RemoteEvent to all clients
function RemoteEventManager:fireAllClients(name, ...)
    local remoteEvent = self:getRemoteEvent(name)
    remoteEvent:FireAllClients(...)
end

-- Fire a RemoteEvent to a specific client
function RemoteEventManager:fireClient(name, player, ...)
    local remoteEvent = self:getRemoteEvent(name)
    remoteEvent:FireClient(player, ...)
end

-- Connect to a RemoteEvent
function RemoteEventManager:onRemoteEvent(name, callback)
    local remoteEvent = self:getRemoteEvent(name)
    return remoteEvent.OnClientEvent:Connect(callback)
end

-- Connect to a RemoteEvent on the server
function RemoteEventManager:onServerEvent(name, callback)
    local remoteEvent = self:getRemoteEvent(name)
    return remoteEvent.OnServerEvent:Connect(callback)
end

return RemoteEventManager 