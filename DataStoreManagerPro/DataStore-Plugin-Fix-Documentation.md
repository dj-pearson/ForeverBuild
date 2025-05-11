# DataStore Plugin Fix Documentation

## Module Organization in Roblox Studio

When the DataStore Plugin is loaded into Roblox Studio, there are important differences in how modules are organized compared to the filesystem:

1. The .server.luau extension gets converted to just .server
2. Modules are directly accessed by name rather than path
3. Some common module resolution patterns don't work in Roblox Studio's environment

### Proper Module Reference Patterns

When referencing other modules in your code, use these patterns:

\\\lua
-- CORRECT: Use FindFirstChild to reference server modules
local SomeModule = require(script.Parent:FindFirstChild("SomeModule.server"))

-- CORRECT: For re-export files (.luau that export .server.luau modules)
return require(script.Parent:FindFirstChild("ModuleName.server"))
\\\

### Incorrect Patterns to Avoid

\\\lua
-- INCORRECT: Direct .server access doesn't work 
local SomeModule = require(script.Parent.SomeModule.server)

-- INCORRECT: This pattern causes circular reference issues
return require(script.server)
\\\

## How to Maintain This Plugin

1. Always use the FindFirstChild pattern for module references
2. Create proper re-export files that follow the pattern above
3. Test in both local environment and Roblox Studio
4. When adding new modules, make sure to update both .server.luau and .luau files
5. Use the included fix scripts when issues arise

## Common Issues and Solutions

### Module Not Found Errors
- Check that you're using FindFirstChild pattern
- Ensure both .server.luau and .luau files exist
- Verify file names match exactly

### Circular References
- Never use return require(script.server) pattern
- Always use return require(script.Parent:FindFirstChild("ModuleName.server"))

### Multiple Values Returned
- Make sure your module only returns one value at the end
- Check for syntax errors that might cause multiple returns
\\\

