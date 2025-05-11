--luau
-- DataStore Plugin/SchemaVersioning.luau
-- Module to handle schema versioning

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

-- Get module resolver from init script or define a local one
local resolver = script.Parent:FindFirstChild("ModuleResolver")
local resolveModule = resolver and require(resolver).resolveModule or function(name)
    local success, result = pcall(function()
        return require(script.Parent:FindFirstChild(name))
    end)
    
    if success and result then
        return result
    end
    
    warn("Failed to resolve module: " .. name)
    return {
        initialize = function() return true end,
        createUI = function() return Instance.new("Frame") end
    }
end

local SchemaVersioning = {}

local SCHEMA_VERSION_STORE = "PluginSchemaVersions"

-- Helper function to get the schema version datastore
local function getVersionStore()
    return DataStoreService:GetDataStore(SCHEMA_VERSION_STORE)
end

-- Create a new version of a schema
function SchemaVersioning.createVersion(dataStoreName, keyName, schema)
    if typeof(schema) ~= "table" then
        warn("Cannot version a non-table schema")
        return false
    end
    
    local versionStore = getVersionStore()
    local schemaKey = string.format("SchemaVersions_%s_%s", dataStoreName, keyName)
    
    -- Get existing versions
    local success, versions = pcall(function()
        return versionStore:GetAsync(schemaKey) or {}
    end)
    
    if not success then
        warn("Failed to get existing schema versions:", versions)
        return false
    end
    
    -- Create a new version
    local newVersion = {
        id = HttpService:GenerateGUID(),
        timestamp = os.time(),
        schema = schema,
        description = "Schema version created on " .. os.date("%Y-%m-%d %H:%M:%S")
    }
    
    -- Add to versions list
    table.insert(versions, newVersion)
    
    -- Save updated versions
    local saveSuccess, saveError = pcall(function()
        versionStore:SetAsync(schemaKey, versions)
    end)
    
    if not saveSuccess then
        warn("Failed to save schema version:", saveError)
        return false
    end
    
    return true, newVersion.id
end

-- Get all versions of a schema
function SchemaVersioning.getVersions(dataStoreName, keyName)
    local versionStore = getVersionStore()
    local schemaKey = string.format("SchemaVersions_%s_%s", dataStoreName, keyName)
    
    local success, versions = pcall(function()
        return versionStore:GetAsync(schemaKey) or {}
    end)
    
    if not success then
        warn("Failed to get schema versions:", versions)
        return {}
    end
    
    return versions
end

-- Get a specific version of a schema
function SchemaVersioning.getVersion(dataStoreName, keyName, versionId)
    local versions = SchemaVersioning.getVersions(dataStoreName, keyName)
    
    for _, version in ipairs(versions) do
        if version.id == versionId then
            return version
        end
    end
    
    return nil
end

-- Update the description of a schema version
function SchemaVersioning.updateVersionDescription(dataStoreName, keyName, versionId, description)
    local versionStore = getVersionStore()
    local schemaKey = string.format("SchemaVersions_%s_%s", dataStoreName, keyName)
    
    local versions = SchemaVersioning.getVersions(dataStoreName, keyName)
    local updated = false
    
    for i, version in ipairs(versions) do
        if version.id == versionId then
            versions[i].description = description
            updated = true
            break
        end
    end
    
    if updated then
        local success, result = pcall(function()
            versionStore:SetAsync(schemaKey, versions)
        end)
        
        return success
    end
    
    return false
end

return SchemaVersioning
