local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create necessary folders if they don't exist
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
local sharedFolder = ensureFolder(ReplicatedStorage, "Shared")

-- Initialize ModuleResolver
local ModuleResolver = require(script.Parent.Parent.shared.ModuleResolver)
local resolveModule = ModuleResolver.resolveModule

-- Initialize RemoteEventManager
local RemoteEventManager = require(script.Parent.Parent.shared.RemoteEventManager)
local remoteManager = RemoteEventManager.new()

-- Initialize client modules
local DataExplorer = resolveModule("DataExplorer", script.Parent)
local SchemaVersionViewer = resolveModule("SchemaVersionViewer", script.Parent)
local DataVisualization = resolveModule("DataVisualization", script.Parent)

-- Initialize the client system
local function initialize()
    -- Initialize client modules
    DataExplorer:Initialize()
    SchemaVersionViewer:Initialize()
    DataVisualization:Initialize()
    
    -- Set up remote event connections
    remoteManager:onRemoteEvent("DataUpdate", function(data)
        -- Handle data updates from server
        DataExplorer:UpdateData(data)
    end)
    
    remoteManager:onRemoteEvent("SchemaUpdate", function(schema)
        -- Handle schema updates from server
        SchemaVersionViewer:UpdateSchema(schema)
    end)
    
    print("DataStoreManagerPro Client: All systems initialized successfully")
end

-- Return the initialized client system
return {
    Initialize = initialize,
    DataExplorer = DataExplorer,
    SchemaVersionViewer = SchemaVersionViewer,
    DataVisualization = DataVisualization,
    RemoteManager = remoteManager,
    resolveModule = resolveModule
}