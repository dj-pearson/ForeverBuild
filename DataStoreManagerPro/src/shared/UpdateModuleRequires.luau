-- UpdateModuleRequires.luau
-- Helper script to update require statements in all plugin modules
-- This script doesn't need to be included in the final plugin, it's just a one-time fix

local function processScript(script)
    -- Skip non-script objects
    if not script:IsA("ModuleScript") and not script:IsA("Script") then
        return 0
    end
    
    local source = script.Source
    local changes = 0
    
    -- Don't modify this script itself
    if script.Name == "UpdateModuleRequires" then
        return 0
    end
    
    -- Check if we need to process this script
    if not source:match("require%(script%.Parent%.") then
        return 0
    end
    
    -- Copy original source for comparison
    local originalSource = source
    
    -- Add module resolver import if needed
    if not source:match("resolveModule") and not source:match("moduleCache") then
        local resolved = false
        
        -- Try to add resolver at the beginning after any initial comments
        local newSource = source:gsub("^(.-\n[^-])", function(header)
            resolved = true
            return header .. "\n-- Module resolver for cloud compatibility\nlocal resolveModule = script.Parent.resolveModule or function(name) return require(script.Parent:FindFirstChild(name)) end\n"
        end)
        
        if resolved then
            source = newSource
            changes = changes + 1
        end
    end
    
    -- Replace direct requires with resolver
    local newSource = source:gsub(
        "require%(script%.Parent%.([%w_]+)%)",
        "resolveModule('%1')"
    )
    
    if newSource ~= source then
        source = newSource
        changes = changes + 1
    end
    
    -- If changes were made, update the script
    if source ~= originalSource then
        script.Source = source
        print("Updated module requires in: " .. script:GetFullName())
    end
    
    return changes
end

-- Process all scripts in the plugin
local function processAllScripts(parent)
    local totalChanges = 0
    
    for _, child in ipairs(parent:GetChildren()) do
        totalChanges = totalChanges + processScript(child)
        totalChanges = totalChanges + processAllScripts(child)
    end
    
    return totalChanges
end

-- Export the processor function
return {
    processAllScripts = processAllScripts
}
