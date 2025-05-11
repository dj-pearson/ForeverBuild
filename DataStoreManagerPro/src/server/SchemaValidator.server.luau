--luau
-- DataStore Plugin/SchemaValidator.luau

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

local SchemaValidator = {}

-- Validates a value against a schema definition
-- Schema format:
-- {
--    type = "string" | "number" | "boolean" | "table" | "array",
--    required = true | false,
--    default = any value,
--    minLength = number, -- for strings or arrays
--    maxLength = number, -- for strings or arrays
--    minValue = number, -- for numbers
--    maxValue = number, -- for numbers
--    pattern = string, -- for strings (regex pattern)
--    enum = {value1, value2, ...}, -- list of allowed values
--    properties = { -- for type "table"
--        propertyName = {schema definition},
--        ...
--    },
--    items = {schema definition} -- for type "array"
-- }

function SchemaValidator.validate(value, schema)
    if schema == nil then
        return true, nil -- No schema means validation always passes
    end
    
    -- Check if the value is nil and handle required/default
    if value == nil then
        if schema.required == true then
            return false, "Value is required but was nil"
        elseif schema.default ~= nil then
            return true, schema.default
        else
            return true, nil
        end
    end
    
    -- Check type
    if schema.type then
        local valueType = type(value)
        
        -- Special handling for table vs array
        if schema.type == "array" then
            if valueType ~= "table" then
                return false, string.format("Expected type 'array', got '%s'", valueType)
            end
            
            -- Check if it's an array-like table
            local isArray = true
            local count = 0
            for _, _ in pairs(value) do
                count += 1
            end
            
            for i = 1, count do
                if value[i] == nil then
                    isArray = false
                    break
                end
            end
            
            if not isArray then
                return false, "Expected an array but got a table with non-sequential indices"
            end
        elseif schema.type ~= valueType and not (schema.type == "table" and valueType == "table") then
            return false, string.format("Expected type '%s', got '%s'", schema.type, valueType)
        end
        
        -- Type-specific validations
        if schema.type == "string" then
            -- String length constraints
            if schema.minLength and #value < schema.minLength then
                return false, string.format("String must be at least %d characters long", schema.minLength)
            end
            
            if schema.maxLength and #value > schema.maxLength then
                return false, string.format("String cannot be longer than %d characters", schema.maxLength)
            end
            
            -- Pattern matching
            if schema.pattern and not string.match(value, schema.pattern) then
                return false, string.format("String does not match pattern '%s'", schema.pattern)
            end
        elseif schema.type == "number" then
            -- Numeric constraints
            if schema.minValue and value < schema.minValue then
                return false, string.format("Number must be at least %f", schema.minValue)
            end
            
            if schema.maxValue and value > schema.maxValue then
                return false, string.format("Number cannot be greater than %f", schema.maxValue)
            end
        elseif schema.type == "table" and schema.properties then
            -- Validate table properties
            for propName, propSchema in pairs(schema.properties) do
                local propValue = value[propName]
                local propValid, propResult = SchemaValidator.validate(propValue, propSchema)
                
                if not propValid then
                    return false, string.format("Property '%s': %s", propName, propResult)
                end
                
                -- If the property was validated to a default value, update the original value
                if propValue == nil and propResult ~= nil then
                    value[propName] = propResult
                end
            end
            
            -- Check for extra properties not in the schema if strictProperties is true
            if schema.strictProperties == true then
                for propName, _ in pairs(value) do
                    if schema.properties[propName] == nil then
                        return false, string.format("Property '%s' is not defined in the schema", propName)
                    end
                end
            end
        elseif schema.type == "array" and schema.items then
            -- Validate array items
            if schema.minLength and #value < schema.minLength then
                return false, string.format("Array must have at least %d items", schema.minLength)
            end
            
            if schema.maxLength and #value > schema.maxLength then
                return false, string.format("Array cannot have more than %d items", schema.maxLength)
            end
            
            -- Validate each item against the schema
            for i, item in ipairs(value) do
                local itemValid, itemResult = SchemaValidator.validate(item, schema.items)
                
                if not itemValid then
                    return false, string.format("Item at index %d: %s", i, itemResult)
                end
                
                -- If the item was validated to a default value, update the original array
                if item == nil and itemResult ~= nil then
                    value[i] = itemResult
                end
            end
        end
    end
    
    -- Check enumeration constraints
    if schema.enum and not table.find(schema.enum, value) then
        return false, string.format("Value must be one of: %s", table.concat(schema.enum, ", "))
    end
    
    -- All validations passed
    return true, value
end

-- Generate a default value based on a schema
function SchemaValidator.generateDefault(schema)
    if not schema then
        return nil
    end
    
    if schema.default ~= nil then
        return schema.default
    end
    
    if schema.type == "string" then
        return ""
    elseif schema.type == "number" then
        return 0
    elseif schema.type == "boolean" then
        return false
    elseif schema.type == "table" and schema.properties then
        local result = {}
        for propName, propSchema in pairs(schema.properties) do
            if propSchema.required == true then
                result[propName] = SchemaValidator.generateDefault(propSchema)
            end
        end
        return result
    elseif schema.type == "array" and schema.items and schema.minLength and schema.minLength > 0 then
        local result = {}
        for i = 1, schema.minLength do
            table.insert(result, SchemaValidator.generateDefault(schema.items))
        end
        return result
    end
    
    return nil
end

-- Compare two schemas and determine if they are compatible (for migrations)
function SchemaValidator.areCompatible(oldSchema, newSchema)
    if not oldSchema or not newSchema then
        return true -- If either schema is nil, consider them compatible
    end
    
    -- Types must match
    if oldSchema.type ~= newSchema.type then
        return false
    end
    
    -- For tables, check property compatibility
    if oldSchema.type == "table" and oldSchema.properties and newSchema.properties then
        for propName, propSchema in pairs(oldSchema.properties) do
            -- If the old schema has a required property, it must still exist in the new schema
            if propSchema.required == true and not newSchema.properties[propName] then
                return false
            end
            
            -- If the property exists in both schemas, they must be compatible
            if newSchema.properties[propName] then
                local propsCompatible = SchemaValidator.areCompatible(propSchema, newSchema.properties[propName])
                if not propsCompatible then
                    return false
                end
            end
        end
    end
    
    -- For arrays, check item compatibility
    if oldSchema.type == "array" and oldSchema.items and newSchema.items then
        return SchemaValidator.areCompatible(oldSchema.items, newSchema.items)
    end
    
    return true
end

return SchemaValidator
