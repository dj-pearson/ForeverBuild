-- ModuleResolver.luau
-- Utility module for resolving module dependencies in both local and cloud environments

local ModuleResolver = {}

-- Try to get the resolver from init script, otherwise define our own
local function getResolver()
    if script.Parent and script.Parent:FindFirstChild("resolveModule") then
        return script.Parent.resolveModule
    end
    
    -- Define our own resolver
    return function(moduleName, fromModule)
        local sourceModule = fromModule or script.Parent
        local success, result
        
        -- Try direct requiring from parent
        success, result = pcall(function()
            return require(sourceModule:FindFirstChild(moduleName))
        end)
        
        if success and result then
            return result
        end
        
        -- Try finding in parent's parent
        if sourceModule.Parent then
            success, result = pcall(function()
                return require(sourceModule.Parent:FindFirstChild(moduleName))
            end)
            
            if success and result then
                return result
            end
        end
        
        -- Try direct string require (works in some cloud environments)
        success, result = pcall(function()
            return require(moduleName)
        end)
        
        if success and result then
            return result
        end
        
        -- Create a dummy module to prevent errors
        warn("ModuleResolver: Failed to resolve module: " .. moduleName)
        return {
            initialize = function() 
                warn("Using dummy implementation of " .. moduleName .. ".initialize()") 
                return true 
            end,
            createUI = function() 
                warn("Using dummy implementation of " .. moduleName .. ".createUI()") 
                return Instance.new("Frame") 
            end
        }
    end
end

-- Export the resolve function
ModuleResolver.resolveModule = getResolver()

return ModuleResolver
