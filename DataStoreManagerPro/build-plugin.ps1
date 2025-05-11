# Build the DataStore Manager Pro Plugin
Write-Host "Building DataStore Manager Pro Plugin..."

# Check if Rojo is installed
if (!(Get-Command rojo -ErrorAction SilentlyContinue)) {
    Write-Host "Rojo is not installed. Please install it first:"
    Write-Host "https://github.com/rojo-rbx/rojo"
    exit 1
}

# Build the plugin
Write-Host "Building plugin..."
rojo build default.project.json --output DataStoreManagerPro.rbxmx

if ($LASTEXITCODE -eq 0) {
    Write-Host "Plugin built successfully: DataStoreManagerPro.rbxmx"
    
    # Run validation
    Write-Host "Running plugin validation..."
    .\validate-plugin.ps1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Plugin validation failed!"
        exit 1
    }
    
    # Create Plugins directory if it doesn't exist
    $pluginsDir = "$env:LOCALAPPDATA\Roblox\Plugins"
    if (!(Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Force -Path $pluginsDir
    }
    
    # Copy to Roblox Plugins folder
    Write-Host "Copying plugin to Roblox Plugins folder..."
    Copy-Item -Force -Path "DataStoreManagerPro.rbxmx" -Destination "$pluginsDir\DataStoreManagerPro.rbxmx"
    
    if ($?) {
        Write-Host "Plugin successfully copied to Roblox Plugins folder"
        Write-Host "Please restart Roblox Studio for changes to take effect"
    } else {
        Write-Host "Failed to copy plugin to Roblox Plugins folder"
        exit 1
    }
} else {
    Write-Host "Failed to build plugin"
    exit 1
} 