--luau
-- DataStore Plugin/generateSchemaFromData.luau
-- This module defines a function to automatically generate a schema from existing data

-- Helper function to determine the type with more specificity than typeof
local function getDetailedType(value)
    -- Basic Lua types
    local baseType = typeof(value)
    
    -- Handle special cases
    if baseType == "table" then
        -- Check if it's an array (consecutive numeric indices)
        local isArray = true
        local count = 0
        
        for k, _ in pairs(value) do
            if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
                isArray = false
                break
            end
            count = count + 1
        end
        
        if isArray and count > 0 then
            return "array"
        else
            return "table"
        end
    end
    
    -- Return the base type for non-table values
    return baseType
end

-- Function to generate schema from data
local function generateSchemaFromData(data)
    if typeof(data) ~= "table" then
        return typeof(data)
    end
    
    local schema = {}
    
    for key, value in pairs(data) do
        local valueType = getDetailedType(value)
        
        if valueType == "table" or valueType == "array" then
            -- Recursively process nested tables
            schema[key] = generateSchemaFromData(value)
        else
            -- For primitive types, just store the type
            schema[key] = valueType
        end
    end
    
    -- If it's an array, we need to identify the element type
    if getDetailedType(data) == "array" then
        -- Find the most common type in the array
        local typeCount = {}
        local elementType = "any" -- Default to any if empty or mixed
        
        for _, value in ipairs(data) do
            local valType = getDetailedType(value)
            if valueType == "table" or valueType == "array" then
                valType = "object" -- Simplify for arrays
            end
            
            typeCount[valType] = (typeCount[valType] or 0) + 1
        end
        
        local maxCount = 0
        for typeName, count in pairs(typeCount) do
            if count > maxCount then
                maxCount = count
                elementType = typeName
            end
        end
        
        -- Create array schema structure with elementType
        schema.type = "array"
        schema.elementType = elementType
    end
    
    return schema
end

return generateSchemaFromData
