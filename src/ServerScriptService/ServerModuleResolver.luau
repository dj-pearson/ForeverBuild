local ServerScriptService = game:GetService("ServerScriptService")

local ServerModuleResolver = {}
ServerModuleResolver.__index = ServerModuleResolver

-- Initialize the resolver
function ServerModuleResolver.new()
    local self = setmetatable({}, ServerModuleResolver)
    self.serverFolder = ServerScriptService:WaitForChild("server")
    self.modulesFolder = self.serverFolder:WaitForChild("Modules")
    return self
end

-- Get a module from the Modules folder
function ServerModuleResolver:getModule(modulePath)
    -- Split the path into parts
    local parts = string.split(modulePath, ".")
    local currentFolder = self.modulesFolder
    
    -- Navigate through the folder structure
    for i = 1, #parts - 1 do
        currentFolder = currentFolder:FindFirstChild(parts[i])
        if not currentFolder then
            warn("ServerModuleResolver: Folder not found:", parts[i])
            return nil
        end
    end
    
    -- Get the final module
    local moduleName = parts[#parts]
    local module = currentFolder:FindFirstChild(moduleName)
    if not module then
        warn("ServerModuleResolver: Module not found:", moduleName)
        return nil
    end
    
    return require(module)
end

-- Get all modules in a specific folder
function ServerModuleResolver:getModulesInFolder(folderPath)
    local parts = string.split(folderPath, ".")
    local currentFolder = self.modulesFolder
    
    -- Navigate to the target folder
    for _, part in ipairs(parts) do
        currentFolder = currentFolder:FindFirstChild(part)
        if not currentFolder then
            warn("ServerModuleResolver: Folder not found:", part)
            return {}
        end
    end
    
    -- Get all modules in the folder
    local modules = {}
    for _, child in ipairs(currentFolder:GetChildren()) do
        if child:IsA("ModuleScript") then
            modules[child.Name] = require(child)
        end
    end
    
    return modules
end

return ServerModuleResolver 