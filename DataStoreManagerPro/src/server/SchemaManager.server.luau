--luau
-- DataStore Plugin/SchemaManager.luau

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

local SchemaVersioning = resolveModule('SchemaVersioning')
local SchemaManager = {}

local SCHEMA_DATA_STORE_NAME = "PluginSchemas" -- Separate DataStore for schemas

-- Basic structure for a schema:
-- {
--     KeyName1 = "string",
--     KeyName2 = "number",
--     KeyName3 = "boolean",
--     KeyName4 = { -- Example of a nested table schema
--         NestedKey1 = "string",
--         NestedKey2 = "number"
--     },
--     KeyName5 = "table" -- Simple check for any table
-- }

local function getPluginDataStore()
	return DataStoreService:GetDataStore(SCHEMA_DATA_STORE_NAME)
end

function SchemaManager.saveSchema(schema, dataStoreName, keyName)
	if typeof(schema) ~= "table" then
		warn("saveSchema called with invalid schema type")
		return
	end
	
	local pluginDataStore = getPluginDataStore()
	local schemaKey = string.format("Schema_%s_%s", dataStoreName, keyName)

	local success, result = pcall(function()
		pluginDataStore:SetAsync(schemaKey, schema)
	end)

	if not success then
		warn("Error saving schema:", result)
		return false
	end
	
	-- Create a version record for this schema
	SchemaVersioning.createVersion(dataStoreName, keyName, schema)
	
	return true
end

function SchemaManager.loadSchema(dataStoreName, keyName)
	local pluginDataStore = getPluginDataStore()
	local schemaKey = string.format("Schema_%s_%s", dataStoreName, keyName)

	local schema = pluginDataStore:GetAsync(schemaKey)
	return schema
end

function SchemaManager.validateData(data, schema)
    if typeof(data) ~= "table" then
        return false, "Data is not a table."
    end

    if typeof(schema) ~= "table" then
        return false, "Schema is not a table."
    end

    for key, expectedType in pairs(schema) do
        local dataValue = data[key]
        local dataType = typeof(dataValue)

        if expectedType == "table" then
            -- If the schema expects a table, just check if the data value is a table (and not nil)
            if dataType ~= "table" then
                return false, string.format("Expected table for key '%s', but got %s.", key, dataType)
            end
        elseif typeof(expectedType) == "table" then
            -- If the schema defines a nested table structure, recursively validate
            local success, errorMessage = SchemaManager.validateData(dataValue, expectedType)
            if not success then
                return false, string.format("Validation failed for nested key '%s': %s", key, errorMessage)
            end
        else
            -- For other types, check if the key exists and the type matches
            if dataValue == nil then
                return false, string.format("Missing required key '%s'.", key)
            end
            if dataType ~= expectedType then
                return false, string.format("Expected type '%s' for key '%s', but got '%s'.", expectedType, key, dataType)
            end
        end
    end

    -- Optional: Check for unexpected keys in data not defined in schema
    -- This might be too strict depending on the use case, so leaving it out for now.
    --[[
    for key, value in pairs(data) do
        if schema[key] == nil and typeof(schema) == "table" then
            -- Check if it's an expected nested table key
            local isNestedKey = false
            for schemaKey, schemaValue in pairs(schema) do
                if typeof(schemaValue) == "table" and schemaValue[key] ~= nil then
                    isNestedKey = true
                    break
                end
            end
            if not isNestedKey then
                 -- Consider if this should be an error or a warning
                 -- return false, string.format("Unexpected key '%s' found in data.", key)
            end
        end
    end
    ]]

    return true, "Validation successful."
end

return SchemaManager