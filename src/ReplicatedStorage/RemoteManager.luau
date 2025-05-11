local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = {}
RemoteManager.__index = RemoteManager

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

-- Initialize the RemoteManager
function RemoteManager.new()
    local self = setmetatable({}, RemoteManager)
    
    -- Ensure Remotes folder exists
    if not ReplicatedStorage:FindFirstChild("Remotes") then
        local remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end
    
    self.remotes = ReplicatedStorage:WaitForChild("Remotes")
    self.remoteEvents = {}
    self.remoteFunctions = {}
    return self
end

-- Create or get a RemoteEvent
function RemoteManager:getRemoteEvent(name)
    if not self.remoteEvents[name] then
        local remoteEvent = self.remotes:FindFirstChild(name)
        if not remoteEvent then
            remoteEvent = Instance.new("RemoteEvent")
            remoteEvent.Name = name
            remoteEvent.Parent = self.remotes
        end
        self.remoteEvents[name] = remoteEvent
    end
    return self.remoteEvents[name]
end

-- Create or get a RemoteFunction
function RemoteManager:getRemoteFunction(name)
    if not self.remoteFunctions[name] then
        local remoteFunction = self.remotes:FindFirstChild(name)
        if not remoteFunction then
            remoteFunction = Instance.new("RemoteFunction")
            remoteFunction.Name = name
            remoteFunction.Parent = self.remotes
        end
        self.remoteFunctions[name] = remoteFunction
    end
    return self.remoteFunctions[name]
end

-- Fire a RemoteEvent
function RemoteManager:fireRemote(name, ...)
    local remoteEvent = self:getRemoteEvent(name)
    remoteEvent:FireServer(...)
end

-- Fire a RemoteEvent to all clients
function RemoteManager:fireAllClients(name, ...)
    local remoteEvent = self:getRemoteEvent(name)
    remoteEvent:FireAllClients(...)
end

-- Fire a RemoteEvent to a specific client
function RemoteManager:fireClient(name, player, ...)
    local remoteEvent = self:getRemoteEvent(name)
    remoteEvent:FireClient(player, ...)
end

-- Invoke a RemoteFunction
function RemoteManager:invokeRemote(name, ...)
    local remoteFunction = self:getRemoteFunction(name)
    return remoteFunction:InvokeServer(...)
end

-- Invoke a RemoteFunction on a specific client
function RemoteManager:invokeClient(name, player, ...)
    local remoteFunction = self:getRemoteFunction(name)
    return remoteFunction:InvokeClient(player, ...)
end

-- Connect to a RemoteEvent
function RemoteManager:onRemoteEvent(name, callback)
    local remoteEvent = self:getRemoteEvent(name)
    return remoteEvent.OnClientEvent:Connect(callback)
end

-- Connect to a RemoteEvent on the server
function RemoteManager:onServerEvent(name, callback)
    local remoteEvent = self:getRemoteEvent(name)
    return remoteEvent.OnServerEvent:Connect(callback)
end

-- Set up a RemoteFunction callback on the server
function RemoteManager:setServerCallback(name, callback)
    local remoteFunction = self:getRemoteFunction(name)
    remoteFunction.OnServerInvoke = callback
end

-- Set up a RemoteFunction callback on the client
function RemoteManager:setClientCallback(name, callback)
    local remoteFunction = self:getRemoteFunction(name)
    remoteFunction.OnClientInvoke = callback
end

-- Get all remote events
function RemoteManager:getAllRemoteEvents()
    local events = {}
    for _, child in ipairs(self.remotes:GetChildren()) do
        if child:IsA("RemoteEvent") then
            events[child.Name] = child
        end
    end
    return events
end

-- Get all remote functions
function RemoteManager:getAllRemoteFunctions()
    local functions = {}
    for _, child in ipairs(self.remotes:GetChildren()) do
        if child:IsA("RemoteFunction") then
            functions[child.Name] = child
        end
    end
    return functions
end

return RemoteManager 