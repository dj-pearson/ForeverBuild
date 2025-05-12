# ForeverBuild - Build & Development Instructions

This document explains how to work with the ForeverBuild codebase, specifically the relationship between files in the development environment and how they appear in Roblox Studio.

## File Structure and Naming Conventions

### Local Development vs. Roblox Studio

When working with this project, it's important to understand that file naming in your local environment differs from how files appear in Roblox Studio:

| Local Filename | Roblox Studio Representation |
|----------------|------------------------------|
| `script.server.lua` | Server Script named `script` |
| `script.server.luau` | Server Script named `script` |
| `script.client.lua` | Local Script named `script` |
| `script.client.luau` | Local Script named `script` |
| `script.lua` | Module Script named `script` |
| `script.luau` | Module Script named `script` |
| `init.server.lua` | Server Script (parent folder becomes the script) |
| `init.client.lua` | Local Script (parent folder becomes the script) |
| `init.lua` | Module Script (parent folder becomes the script) |

### Example:

- `DataStoreManager.server.lua` in your local environment will appear as a Server Script named `DataStoreManager` in Roblox Studio
- The file extension `.luau` is equivalent to `.lua` for Rojo syncing purposes, but `.luau` is recommended for better LSP support

## Project Structure

The project uses the following structure:

- `src/`
  - `ReplicatedStorage/` - Shared code accessible by both server and client
  - `ServerScriptService/` - Server-side code
  - `StarterGui/` - UI code and client scripts for the UI
  - `StarterPlayer/` - Client scripts

## Referencing Scripts and Modules

### Server-to-Server References

When referencing a server script from another server script, use:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreManager = require(ServerScriptService.ForeverBuild.DataStoreManager)
```

### Server-to-Shared References

When referencing a shared module from a server script:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModule = require(ReplicatedStorage.ForeverBuild.Modules.SharedModule)
```

### Client-to-Shared References

When referencing a shared module from a client script:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedModule = require(ReplicatedStorage.ForeverBuild.Modules.SharedModule)
```

### Important Notes for References

1. Always use the service path for module references, not relative paths
2. Remember that `DataStoreManager.server.lua` will be referenced as just `DataStoreManager` in your code

## Init Files

Special behavior applies to `init` files:

1. When a folder contains an `init.server.lua` file, the folder itself becomes a Server Script
2. When a folder contains an `init.client.lua` file, the folder itself becomes a Local Script
3. When a folder contains an `init.lua` file, the folder itself becomes a Module Script

This means you would reference the parent folder name, not "init", in your require statements.

## Working with Rojo and Argon

### Rojo Sync

Rojo transforms files as follows:
- Any file ending in `.server.lua` becomes a Server Script instance
- Any file ending in `.client.lua` becomes a Local Script instance
- Any other `.lua` file becomes a Module Script instance

The project uses Rojo for syncing files between your local environment and Roblox Studio.

### Argon Configuration

For additional tooling, Argon can be configured for this project:

- Create an `argon.toml` file in the project root to configure workspace-specific settings
- Set `lua_extension = true` if you prefer using `.luau` extension

## Development Workflow

1. Make changes to your local files
2. Rojo will sync these changes to Roblox Studio
3. When adding new scripts, ensure you use the correct file extension:
   - `.server.lua` for server scripts
   - `.client.lua` for client scripts
   - `.lua` for module scripts
   - Alternatively, use `.luau` instead of `.lua` for better LSP support

## Troubleshooting

### Common Issues

- **Script not appearing in Roblox Studio**: Ensure the file has the correct extension (`.server.lua`, `.client.lua`, or `.lua`)
- **Can't require a module**: Double-check the path in the require statement; remember to use the service path and that file extensions are not included

### Script Instance Types

In Roblox, scripts have different contexts:

- **Server Scripts**: Run on the server only
- **Local Scripts**: Run on the client only
- **Module Scripts**: Can run anywhere they're required from

## Best Practices

1. Organize code logically within the appropriate services
2. Use descriptive file and folder names
3. Avoid circular dependencies
4. When working with DataStoreManager, ensure all references use the correct path in ServerScriptService

Remember that while your local file is named `DataStoreManager.server.lua`, you'll reference it in code as `DataStoreManager`.
