local MockEnvironment = {}

-- Mock Roblox Services
local Services = {
    DataStoreService = {
        GetDataStore = function(self, name)
            return {
                GetAsync = function(self, key)
                    return self.data[key]
                end,
                SetAsync = function(self, key, value)
                    self.data[key] = value
                end,
                data = {}
            }
        end
    },
    Players = {
        GetPlayers = function(self)
            return self.players
        end,
        PlayerAdded = {
            Connect = function(self, callback)
                table.insert(self.callbacks, callback)
            end,
            callbacks = {}
        },
        PlayerRemoving = {
            Connect = function(self, callback)
                table.insert(self.callbacks, callback)
            end,
            callbacks = {}
        },
        players = {}
    },
    ServerScriptService = {},
    ReplicatedStorage = {},
    workspace = {
        GetChildren = function(self)
            return self.children
        end,
        children = {}
    }
}

-- Mock game object
local game = {
    GetService = function(self, serviceName)
        return Services[serviceName]
    end,
    BindToClose = function(self, callback)
        self.shutdownCallback = callback
    end
}

-- Mock task
local task = {
    spawn = function(callback)
        callback()
    end,
    wait = function(seconds)
        -- Simulate waiting
    end
}

-- Mock Instance
local Instance = {
    new = function(className)
        return {
            Name = "",
            Parent = nil,
            GetChildren = function(self)
                return {}
            end,
            IsA = function(self, className)
                return className == "Model"
            end,
            GetPrimaryPartCFrame = function(self)
                return {
                    Position = Vector3.new(0, 0, 0)
                }
            end,
            PivotTo = function(self, cframe)
                -- Simulate pivoting
            end
        }
    end
}

-- Mock Vector3
local Vector3 = {
    new = function(x, y, z)
        return {x = x, y = y, z = z}
    end
}

-- Mock CFrame
local CFrame = {
    new = function(x, y, z)
        return {
            Position = Vector3.new(x, y, z)
        }
    end
}

-- Create a mock player
function MockEnvironment.createMockPlayer(userId, name)
    return {
        UserId = userId,
        Name = name,
        PlayerGui = {
            WaitForChild = function(self, name)
                return {}
            end
        }
    }
end

-- Add a player to the mock environment
function MockEnvironment.addPlayer(player)
    table.insert(Services.Players.players, player)
end

-- Remove a player from the mock environment
function MockEnvironment.removePlayer(player)
    for i, p in ipairs(Services.Players.players) do
        if p.UserId == player.UserId then
            table.remove(Services.Players.players, i)
            break
        end
    end
end

-- Trigger player added event
function MockEnvironment.triggerPlayerAdded(player)
    for _, callback in ipairs(Services.Players.PlayerAdded.callbacks) do
        callback(player)
    end
end

-- Trigger player removing event
function MockEnvironment.triggerPlayerRemoving(player)
    for _, callback in ipairs(Services.Players.PlayerRemoving.callbacks) do
        callback(player)
    end
end

-- Trigger server shutdown
function MockEnvironment.triggerShutdown()
    if game.shutdownCallback then
        game.shutdownCallback()
    end
end

-- Clear all data
function MockEnvironment.clearData()
    Services.DataStoreService.GetDataStore("PlayerData").data = {}
    Services.DataStoreService.GetDataStore("WorldObjects").data = {}
    Services.Players.players = {}
    Services.workspace.children = {}
end

-- Export mock environment
MockEnvironment.Services = Services
MockEnvironment.game = game
MockEnvironment.task = task
MockEnvironment.Instance = Instance
MockEnvironment.Vector3 = Vector3
MockEnvironment.CFrame = CFrame

return MockEnvironment 