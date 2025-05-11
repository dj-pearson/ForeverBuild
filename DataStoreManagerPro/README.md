# DataStore Manager Pro Plugin

## Installation Instructions

### Using Argon
1. Open Roblox Studio
2. Install the Argon plugin if you haven't already
3. In Argon:
   - Select "Open Project"
   - Navigate to the RobloxProject directory
   - Select the `DataStore-plugin.project.json` file (not the default.project.json)
   - Click "Open"
4. The plugin should now sync to your Roblox Studio Plugin folder
5. If prompted to overwrite files, choose "Yes"

### Quick Setup (Windows)
1. Double-click the `SyncWithArgon.bat` file in the RobloxProject folder
2. This will attempt to automatically open Roblox Studio with the Argon plugin
3. Follow any on-screen prompts to complete the synchronization

### Important Notes
- This plugin contains files close to the 100KB limit (DataExplorer.server.luau: 97.32KB, BulkOperationsUI.server.luau: 94.48KB)
- Large image files have been moved to the Backups folder to prevent sync issues
- The main entry point is `init.server.luau`
- We're using the server version of DataExplorer (DataExplorer.server.luau) instead of the non-server version
- JSON files must not contain comments (lines starting with //) to be compatible with Argon

### Utility Scripts
Several utility scripts are available in the RobloxProject directory to help manage this plugin:

### Utility Scripts
Several utility scripts are available in the RobloxProject directory to help manage this plugin:

1. **SyncWithArgon.bat** - Automatically opens Roblox Studio with the Argon plugin to sync the DataStore plugin
2. **ValidateDataStorePlugin.ps1** - PowerShell script to check for common issues with the plugin files
3. **Analyze-LuauFile.ps1** - PowerShell script to analyze large Luau scripts and suggest optimizations

To use the file analyzer:
```powershell
# Example: Analyze DataExplorer.server.luau
powershell -ExecutionPolicy Bypass -File .\Analyze-LuauFile.ps1 -FilePath ".\DataStore Plugin\DataExplorer.server.luau"
```

### Troubleshooting
- If the plugin doesn't appear in Roblox Studio after syncing, check the Output window for any errors
- If you see messages about file size limits, verify that all large files (>100KB) have been properly excluded in the project file
- The asset ID for the toolbar button is set to "rbxassetid://7634658388" - if the button has no icon, you may need to use a different asset ID
- If you see JSON parsing errors, make sure your JSON files don't contain comments (lines starting with //)
- Run the ValidateDataStorePlugin.ps1 script to check for common issues:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\ValidateDataStorePlugin.ps1
  ```

### Common Errors and Solutions

#### "Failed to parse project" error
If you see an error like: `ERROR: Failed to parse project at [...] invalid type: sequence, expected struct ProjectNode`
1. Check if the JSON file contains comments (lines starting with //)
2. Run the ValidateDataStorePlugin.ps1 script which can detect and fix this issue
3. Or run the Fix-JsonComments function from the script:
   ```powershell
   # Load the function
   . .\ValidateDataStorePlugin.ps1
   # Fix the file
   Fix-JsonComments -FilePath ".\DataStore-plugin.project.json"
   ```

#### "Project already exists" error
If you see: `ERROR: Project [...] already exists!`
1. Close all instances of Roblox Studio
2. Restart Roblox Studio and try again
3. If that doesn't work, try manually deleting the project from Argon plugin in Studio and then re-adding it
