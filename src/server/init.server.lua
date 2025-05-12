--init file for server modules

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModuleLoader = require(ReplicatedStorage.Shared.ModuleLoader)

-- Initialize core modules
local Shared = ModuleLoader.getModule(ReplicatedStorage.Shared)
Shared.init()

-- Initialize server modules
local DataStoreManager = ModuleLoader.getModule(script.Parent.DataStoreManager)

-- Initialize the server
local function initialize()
    -- Initialize DataStoreManager
    if DataStoreManager.init then
        DataStoreManager.init()
    end
    
    print("Server initialized successfully")
end

initialize() 