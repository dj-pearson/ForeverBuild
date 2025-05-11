# Final DataStore Plugin Setup Check
# This script checks the state of all critical components and reports status

Write-Host "DataStore Plugin: Final Setup Check" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host

$sourcePath = Join-Path $PSScriptRoot "src"
$allGood = $true

# 1. Check for Node.js and Argon
Write-Host "1. Checking Node.js installation..." -ForegroundColor Yellow
$nodeInstalled = $false
try {
    $nodeVersion = node -v
    Write-Host "   ✓ Node.js found: $nodeVersion" -ForegroundColor Green
    $nodeInstalled = $true
}
catch {
    Write-Host "   ✗ Node.js not found or not in PATH" -ForegroundColor Red
    $allGood = $false
}

if ($nodeInstalled) {
    Write-Host "   Checking npm installation..." -ForegroundColor Yellow
    try {
        $npmVersion = npm -v
        Write-Host "   ✓ npm found: $npmVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "   ✗ npm not found or not working properly" -ForegroundColor Red
        $allGood = $false
    }
    
    Write-Host "   Checking Argon installation..." -ForegroundColor Yellow
    try {
        $argonVersion = npx @argonlua/cli --version
        Write-Host "   ✓ Argon CLI found: $argonVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "   ✗ Argon CLI not found. Please run Setup-NodeJS-Argon.bat" -ForegroundColor Red
        $allGood = $false
    }
}

# 2. Check for circular dependencies in key modules
Write-Host "`n2. Checking for circular dependency fixes in key modules..." -ForegroundColor Yellow

$criticalPairs = @(
    @{Client = "DataStoreManager.luau"; Server = "DataStoreManager.server.luau" },
    @{Client = "MultiServerCoordination.luau"; Server = "MultiServerCoordination.server.luau" },
    @{Client = "DataExplorer.luau"; Server = "DataExplorer.server.luau" },
    @{Client = "SchemaManager.luau"; Server = "SchemaManager.server.luau" }
)

foreach ($pair in $criticalPairs) {
    $clientPath = Join-Path $sourcePath $pair.Client
    $serverPath = Join-Path $sourcePath $pair.Server
    
    # Check client module for lazy loading pattern
    $clientContent = Get-Content -Path $clientPath -Raw -ErrorAction SilentlyContinue
    if ($clientContent -match "lazy loading to prevent circular dependencies") {
        Write-Host "   ✓ $($pair.Client) uses lazy loading pattern" -ForegroundColor Green
    }
    else {
        Write-Host "   ✗ $($pair.Client) might need circular dependency fix" -ForegroundColor Red
        $allGood = $false
    }
    
    # Check server module for lazy references to potential circular dependencies
    $serverContent = Get-Content -Path $serverPath -Raw -ErrorAction SilentlyContinue
    if ($serverContent -match "_lazy_" -or $serverContent -match "_get_") {
        Write-Host "   ✓ $($pair.Server) uses lazy loading for dependencies" -ForegroundColor Green
    }
    else {
        $criticalDeps = @("DataStoreManager", "MultiServerCoordination", "DataExplorer", "SchemaManager")
        $needsFix = $false
        
        foreach ($dep in $criticalDeps) {
            if ($serverContent -match "local $dep = resolveModule\(['`"]$dep['`"]\)") {
                $needsFix = $true
                break
            }
        }
        
        if ($needsFix) {
            Write-Host "   ✗ $($pair.Server) has direct dependencies that might cause circular references" -ForegroundColor Red
            $allGood = $false
        }
        else {
            Write-Host "   ✓ $($pair.Server) does not have problematic direct dependencies" -ForegroundColor Green
        }
    }
}

# 3. Check Argon project file
Write-Host "`n3. Checking Argon project configuration..." -ForegroundColor Yellow
$argonProject = Join-Path $PSScriptRoot "default.project.json"

if (Test-Path $argonProject) {
    $projectContent = Get-Content -Path $argonProject -Raw
    
    try {
        $projectJson = ConvertFrom-Json $projectContent
        Write-Host "   ✓ Project file is valid JSON" -ForegroundColor Green
        
        if ($projectJson.name -eq "DataStorePlugin") {
            Write-Host "   ✓ Project is configured for DataStore Plugin" -ForegroundColor Green
        }
        else {
            Write-Host "   ✗ Project name is not set to DataStorePlugin" -ForegroundColor Red
            $allGood = $false
        }
    }
    catch {
        Write-Host "   ✗ Project file is not valid JSON: $_" -ForegroundColor Red
        $allGood = $false
    }
}
else {
    Write-Host "   ✗ Argon project file not found" -ForegroundColor Red
    $allGood = $false
}

# 4. Check helper scripts
Write-Host "`n4. Checking helper scripts..." -ForegroundColor Yellow
$watchScript = Join-Path $PSScriptRoot "Run-Argon-Watch.bat"
$buildScript = Join-Path $PSScriptRoot "Build-With-Argon.bat"

if (Test-Path $watchScript) {
    Write-Host "   ✓ Run-Argon-Watch.bat exists" -ForegroundColor Green
}
else {
    Write-Host "   ✗ Run-Argon-Watch.bat missing" -ForegroundColor Red
    $allGood = $false
}

if (Test-Path $buildScript) {
    Write-Host "   ✓ Build-With-Argon.bat exists" -ForegroundColor Green
}
else {
    Write-Host "   ✗ Build-With-Argon.bat missing" -ForegroundColor Red
    $allGood = $false
}

# Final Summary
Write-Host "`nFinal Status:" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "All checks passed! The DataStore Plugin should be ready to use with Argon." -ForegroundColor Green
    Write-Host "`nTo use the plugin:" -ForegroundColor Yellow
    Write-Host "1. Run 'Run-Argon-Watch.bat'" -ForegroundColor Yellow
    Write-Host "2. Open Roblox Studio" -ForegroundColor Yellow
    Write-Host "3. Test the plugin functionality" -ForegroundColor Yellow
}
else {
    Write-Host "Some issues were detected. Please fix them before using the plugin." -ForegroundColor Red
    Write-Host "`nTo fix the issues:" -ForegroundColor Yellow
    Write-Host "1. Run 'Setup-NodeJS-Argon.bat' to fix Node.js/Argon issues" -ForegroundColor Yellow
    Write-Host "2. Run 'Fix-CircularDependencies-DataStore.ps1' to fix circular dependencies" -ForegroundColor Yellow
}

Write-Host "`nSetup check complete." -ForegroundColor Cyan
