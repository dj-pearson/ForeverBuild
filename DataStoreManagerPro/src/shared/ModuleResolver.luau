-- ModuleResolver.luau
-- Utility module for resolving module dependencies in both local and cloud environments

local ModuleResolver = {}
ModuleResolver.__index = ModuleResolver

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

-- Initialize the resolver
function ModuleResolver.new()
    local self = setmetatable({}, ModuleResolver)
    self.moduleCache = {}
    return self
end

-- Resolve a module from a specific directory
function ModuleResolver.resolveModule(moduleName, parent)
    -- Check if the module exists
    local module = parent:FindFirstChild(moduleName)
    if not module then
        warn("ModuleResolver: Module not found:", moduleName)
        return nil
    end
    
    -- Try to require the module
    local success, result = pcall(function()
        return require(module)
    end)
    
    if success then
        return result
    else
        warn("ModuleResolver: Failed to load module:", moduleName, "-", result)
        return nil
    end
end

-- Get all modules in a directory
function ModuleResolver.getAllModules(parent)
    local modules = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ModuleScript") then
            local success, result = pcall(function()
                return require(child)
            end)
            if success then
                modules[child.Name] = result
            else
                warn("ModuleResolver: Failed to load module:", child.Name, "-", result)
            end
        end
    end
    return modules
end

-- Get all modules in a directory recursively
function ModuleResolver.getAllModulesRecursive(parent)
    local modules = {}
    
    local function scanDirectory(directory)
        for _, child in ipairs(directory:GetChildren()) do
            if child:IsA("ModuleScript") then
                local success, result = pcall(function()
                    return require(child)
                end)
                if success then
                    modules[child.Name] = result
                else
                    warn("ModuleResolver: Failed to load module:", child.Name, "-", result)
                end
            elseif child:IsA("Folder") then
                scanDirectory(child)
            end
        end
    end
    
    scanDirectory(parent)
    return modules
end

return ModuleResolver
