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
local function createMockPlayer(userId, name)
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

local MockEnvironment = require(script.Parent.MockEnvironment)
local TestRunner = require(script.Parent.TestRunner)

-- Test DataStoreManager
local function testDataStoreManager()
    -- Clear any existing data
    MockEnvironment.clearData()
    
    -- Create mock players
    local player1 = MockEnvironment.createMockPlayer(1, "Player1")
    local player2 = MockEnvironment.createMockPlayer(2, "Player2")
    
    -- Add players to the mock environment
    MockEnvironment.addPlayer(player1)
    MockEnvironment.addPlayer(player2)
    
    -- Load DataStoreManager
    local DataStoreManager = require(script.Parent.Parent.server.Modules.Data.DataStoreManager)
    
    -- Test 1: Load player data
    local player1Data = DataStoreManager.LoadPlayerData(player1)
    TestRunner.addResult(player1Data.coins == 0, "Default coins should be 0")
    TestRunner.addResult(type(player1Data.inventory) == "table", "Inventory should be a table")
    TestRunner.addResult(player1Data.tutorialComplete == false, "Tutorial should not be completed by default")
    
    -- Test 2: Save and load player data
    player1Data.coins = 100
    player1Data.inventory = {"item1", "item2"}
    DataStoreManager.SetPlayerData(player1, player1Data, true)
    
    local loadedData = DataStoreManager.LoadPlayerData(player1)
    TestRunner.addResult(loadedData.coins == 100, "Coins should be 100")
    TestRunner.addResult(#loadedData.inventory == 2, "Inventory should have 2 items")
    
    -- Test 3: World objects
    local worldObjects = {
        {type = "Tree", position = MockEnvironment.Vector3.new(0, 0, 0)},
        {type = "Rock", position = MockEnvironment.Vector3.new(10, 0, 10)}
    }
    DataStoreManager.SetWorldObjects(worldObjects, true)
    
    local loadedWorldObjects = DataStoreManager.LoadWorldObjects()
    TestRunner.addResult(#loadedWorldObjects == 2, "Should have 2 world objects")
    
    -- Test 4: Player leaving
    MockEnvironment.triggerPlayerRemoving(player1)
    local player1DataAfterLeave = DataStoreManager.GetPlayerData(player1)
    TestRunner.addResult(player1DataAfterLeave.coins == 100, "Player data should persist after leaving")
    
    -- Test 5: Server shutdown
    MockEnvironment.triggerShutdown()
    local worldObjectsAfterShutdown = DataStoreManager.LoadWorldObjects()
    TestRunner.addResult(#worldObjectsAfterShutdown == 2, "World objects should persist after shutdown")
    
    -- Test 6: Multiple players
    local player2Data = DataStoreManager.LoadPlayerData(player2)
    TestRunner.addResult(player2Data.coins == 0, "Second player should have default coins")
    
    -- Test 7: Data isolation
    TestRunner.addResult(player1Data.coins ~= player2Data.coins, "Player data should be isolated")
    
    -- Test 8: Error handling
    local invalidPlayer = {UserId = "invalid"}
    local success, result = pcall(function()
        return DataStoreManager.LoadPlayerData(invalidPlayer)
    end)
    TestRunner.addResult(not success, "Should handle invalid player data")
end

-- Run tests
testDataStoreManager() 