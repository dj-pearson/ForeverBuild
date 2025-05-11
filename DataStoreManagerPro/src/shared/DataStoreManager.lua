-- Re-export file with lazy loading to prevent circular dependencies
local lazyModule = nil
local function getModule()
    if not lazyModule then
        lazyModule = require(script.Parent:FindFirstChild("DataStoreManager.server"))
    end
    return lazyModule
end

-- DataStoreManager.lua
local DataStoreManager = {}

function DataStoreManager.initialize()
    print("DataStoreManager initialized")
end

function DataStoreManager.getData(key)
    -- Implementation
end

function DataStoreManager.setData(key, value)
    -- Implementation
end

function DataStoreManager.updateData(key, updateFunction)
    -- Implementation
end

function DataStoreManager.removeData(key)
    -- Implementation
end

function DataStoreManager.listKeys()
    -- Implementation
end

return DataStoreManager
