-- Re-export file with lazy loading to prevent circular dependencies
local lazyModule = nil
local function getModule()
    if not lazyModule then
        lazyModule = require(script.Parent:FindFirstChild("MultiServerCoordination.server"))
    end
    return lazyModule
end
return getModule()
