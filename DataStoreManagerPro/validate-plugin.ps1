# Validation script for DataStore Manager Pro Plugin
Write-Host "Validating plugin structure..."

# Check if the rbxmx file exists
if (!(Test-Path "DataStoreManagerPro.rbxmx")) {
    Write-Host "Error: DataStoreManagerPro.rbxmx not found"
    exit 1
}

# Check if all required directories exist
$requiredDirs = @(
    "src/shared",
    "src/server",
    "src/clientScripts"
)

foreach ($dir in $requiredDirs) {
    if (!(Test-Path $dir)) {
        Write-Host "Error: Required directory not found: $dir"
        exit 1
    }
}

# Check if critical files exist
$criticalFiles = @(
    "plugin.luau",
    "src/server/init.server.luau",
    "src/server/DataStoreManager.server.luau",
    "src/server/DataExplorer.server.luau"
)

foreach ($file in $criticalFiles) {
    if (!(Test-Path $file)) {
        Write-Host "Error: Critical file not found: $file"
        exit 1
    }
}

# Try to parse the rbxmx file as XML
try {
    [xml]$pluginXml = Get-Content "DataStoreManagerPro.rbxmx"
    
    # Check for Plugin class
    $pluginNodes = $pluginXml.SelectNodes("//Item[@class='Plugin']")
    if ($pluginNodes.Count -eq 0) {
        Write-Host "Error: No Plugin class found in rbxmx"
        exit 1
    }
    
    # Check for Main script in Plugin
    $mainScript = $pluginXml.SelectNodes("//Item[@class='Plugin']/Item[@class='ModuleScript' and @Name='Main']")
    if ($mainScript.Count -eq 0) {
        Write-Host "Error: No Main ModuleScript found in Plugin"
        exit 1
    }
    
    # Check for required services
    $requiredServices = @("ServerStorage", "StarterPlayer")
    foreach ($service in $requiredServices) {
        $serviceNode = $pluginXml.SelectNodes("//Item[@class='$service']")
        if ($serviceNode.Count -eq 0) {
            Write-Host "Error: Required service not found: $service"
            exit 1
        }
    }
    
    # Check for Packages
    $packagesNode = $pluginXml.SelectNodes("//Item[@Name='Packages']")
    if ($packagesNode.Count -eq 0) {
        Write-Host "Error: Packages folder not found"
        exit 1
    }
    
    # Validate plugin.luau content
    $pluginContent = Get-Content "plugin.luau" -Raw
    if ($pluginContent -notmatch "local plugin = script:GetProperty\(""Plugin""\)") {
        Write-Host "Error: plugin.luau missing Plugin property check"
        exit 1
    }
    if ($pluginContent -notmatch "CreateToolbar") {
        Write-Host "Error: plugin.luau missing toolbar creation"
        exit 1
    }
    if ($pluginContent -notmatch "CreateDockWidgetPluginGui") {
        Write-Host "Error: plugin.luau missing widget creation"
        exit 1
    }
    
    Write-Host "Plugin structure validation passed!"
    Write-Host "Found Plugin class with Main script"
    Write-Host "Found required services: $($requiredServices -join ', ')"
    Write-Host "Found Packages folder"
    Write-Host "plugin.luau contains required components"
} catch {
    Write-Host "Error: Failed to parse rbxmx file as XML"
    Write-Host $_.Exception.Message
    exit 1
} 