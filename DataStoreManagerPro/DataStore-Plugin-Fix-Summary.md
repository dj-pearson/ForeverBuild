# DataStore Plugin: Fix Summary and Usage Guide

## Issues Fixed

1. **Circular Module Dependencies:**
   - Fixed circular dependencies between `DataStoreManager` and `MultiServerCoordination`
   - Implemented lazy loading pattern in key modules
   - Prevents stack overflow errors in Argon and Roblox Studio

2. **Node.js PATH Issues:**
   - Created a reliable Node.js detection and setup script
   - Ensures Argon can find and use Node.js properly
   - Creates helper scripts for running Argon

## How to Use the Fixed Plugin

### 1. Set Up Environment
Run `Setup-NodeJS-Argon.bat` to:
- Find or install Node.js
- Add Node.js to your PATH
- Install Argon CLI if needed
- Create helper scripts

### 2. Run the Plugin in Watch Mode
Run `Run-Argon-Watch.bat` to:
- Start Argon in watch mode
- Automatically sync changes to Roblox Studio
- Enable hot reloading

### 3. Build the Plugin for Distribution
Run `Build-With-Argon.bat` to:
- Build the plugin into an .rbxmx file
- Create a distributable version

## Key Files Modified

- **Re-export Modules Modified to Use Lazy Loading:**
  - `DataStoreManager.luau`
  - `MultiServerCoordination.luau`
  - Other circular dependency pairs

- **Server Modules Modified to Break Circular References:**
  - `DataStoreManager.server.luau`
  - `MultiServerCoordination.server.luau`

## Maintenance Guidelines

### When Adding New Modules:

1. **For normal modules:**
   ```lua
   local ModuleA = require(script.Parent:FindFirstChild("ModuleA"))
   ```

2. **For modules that might form circular dependencies:**
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

### Fix Scripts to Run When Issues Occur:

- `Fix-CircularDependencies-DataStore.ps1`: Fixes circular dependencies
- `Setup-NodeJS-Argon.bat`: Sets up Node.js and Argon
- `Fix-All-DataStore-Issues.bat`: Applies all fixes

## Troubleshooting

### If you get stack overflows:
- Run `Fix-CircularDependencies-DataStore.ps1` to fix circular dependencies
- Check for direct requires between module pairs that use each other

### If Argon fails with "node not recognized":
- Run `Setup-NodeJS-Argon.bat` again
- Restart your command prompt/terminal after running the setup

### If modules fail to load in Roblox Studio:
- Ensure both `.luau` and `.server.luau` files are properly synced
- Check that all modules use the `FindFirstChild` pattern
- Run the fix scripts if necessary
