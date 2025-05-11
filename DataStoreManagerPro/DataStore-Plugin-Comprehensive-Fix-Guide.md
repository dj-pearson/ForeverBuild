# DataStore Plugin - Comprehensive Fix Guide

## Overview

The DataStore Plugin encountered several critical issues that have been addressed with the fixes in this package:

1. **Node.js PATH Configuration:** Ensuring Node.js is properly detected and configured for Argon sync
2. **Circular Dependencies:** Breaking circular references that caused stack overflows
3. **Module Resolution:** Ensuring proper module resolution patterns work in Roblox Studio

## Fix Scripts

### 1. Setup-NodeJS-Argon.bat
This script handles all Node.js and Argon configuration:
- Searches multiple locations for Node.js installation
- Adds Node.js to the system PATH if needed
- Installs Argon CLI if not already installed
- Creates helper scripts for running Argon

### 2. Fix-CircularDependencies-DataStore.ps1
This script identifies and fixes circular module dependencies:
- Analyzes all module relationships
- Detects circular reference chains
- Replaces direct requires with lazy-loading patterns
- Fixes re-export files that contribute to circular dependencies

### 3. Fix-All-DataStore-Issues.bat
A master script that runs all fixes in the correct sequence.

## Common Issues Fixed

### 1. Circular Dependencies
In Lua/Luau, when modules reference each other in a circular pattern, it can cause stack overflows:
```
ModuleA → requires ModuleB → requires ModuleA
```

This has been fixed by implementing lazy loading patterns:
```lua
-- Instead of:
local ModuleB = require(script.Parent:FindFirstChild("ModuleB"))

-- We now use:
local _lazy_ModuleB = nil
local function _get_ModuleB()
    if not _lazy_ModuleB then
        _lazy_ModuleB = require(script.Parent:FindFirstChild("ModuleB"))
    end
    return _lazy_ModuleB
end
```

### 2. Re-export Files
Many files in the plugin used a simple re-export pattern:
```lua
-- In ModuleA.luau
return require(script.Parent:FindFirstChild("ModuleA.server"))
```

These were prime locations for circular dependencies to form and have been updated with lazy loading.

### 3. Node.js PATH Issues
Argon requires Node.js to be in the PATH, but this wasn't always set up correctly. The fix scripts properly:
- Detect Node.js installation
- Add it to PATH
- Verify Argon installation
- Create helper scripts to run Argon

## Best Practices for Maintaining This Plugin

### Module References
When adding new modules, follow these patterns:

1. **For normal requires:**
```lua
local ModuleA = require(script.Parent:FindFirstChild("ModuleA"))
```

2. **If you suspect potential circular dependencies:**
```lua
-- Lazy loading pattern
local _lazy_ModuleA = nil
local function _get_ModuleA()
    if not _lazy_ModuleA then
        _lazy_ModuleA = require(script.Parent:FindFirstChild("ModuleA"))
    end
    return _lazy_ModuleA
end
```

3. **For re-export files:**
```lua
-- Lazy loading re-export
local lazyModule = nil
local function getModule()
    if not lazyModule then
        lazyModule = require(script.Parent:FindFirstChild("ModuleName.server"))
    end
    return lazyModule
end
return getModule()
```

### Testing Changes
After making changes to the plugin:
1. Run the `Fix-CircularDependencies-DataStore.ps1` script to check for and fix any circular dependencies
2. Use `Run-Argon-Watch.bat` to start Argon sync
3. Test in Roblox Studio
4. Run `Build-With-Argon.bat` to create the final plugin

## Troubleshooting

### If you encounter "node is not recognized" errors:
Run `Setup-NodeJS-Argon.bat` to reconfigure Node.js

### If you get stack overflow errors:
1. Run `Fix-CircularDependencies-DataStore.ps1` to fix circular dependencies
2. If issues persist, manually review module dependencies to identify any circular patterns

### If modules fail to load in Roblox Studio:
1. Check if the module is using the correct require pattern with `FindFirstChild`
2. Ensure both the .luau and .server.luau files are properly synchronized
3. Check the output window for specific error messages

For persistent issues, run `Fix-All-DataStore-Issues.bat` to apply all fixes.
