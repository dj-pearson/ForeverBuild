# Roblox Infinite Canvas

A continuously growing Roblox world inspired by the Million Dollar Homepage, allowing players to purchase and place objects on an infinite map.

## Project Overview

This game allows players to:

- Purchase predefined and mystery Roblox items
- Place objects on a permanent map
- Manage their inventory of purchased items
- Explore the world using various tools and vehicles

## Project Structure

```
src/
├── ServerScriptService/
│   ├── GameManager.server.lua
│   ├── DataStoreManager.server.lua
│   └── MarketplaceManager.server.lua
├── ReplicatedStorage/
│   ├── Shared/
│   │   ├── Constants.lua
│   │   └── Types.lua
│   └── Modules/
│       ├── InventoryManager.lua
│       └── ObjectManager.lua
├── StarterPlayer/
│   └── StarterPlayerScripts/
│       └── ClientManager.client.lua
└── StarterGui/
    └── MainUI/
        ├── InventoryUI.lua
        └── MarketplaceUI.lua
```

## Setup Instructions

1. Clone this repository
2. Open the project in Roblox Studio
3. Ensure all scripts are in their correct locations
4. Test the game in Studio before publishing

## Development Status

Currently in Phase 1: Planning & Design

- Core game mechanics being implemented
- Basic object placement system in development
- Inventory system being built

## Contributing

This is a private project. Please refer to the PRD.txt for detailed feature specifications and roadmap.
