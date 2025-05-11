# Script to Detect and Fix Circular Dependencies in DataStore Plugin
# This script will analyze modules to find circular dependencies and apply fixes

Write-Host "DataStore Plugin: Circular Dependency Checker and Fixer"
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

$sourceDir = Join-Path $PSScriptRoot "src"
Write-Host "Checking modules in: $sourceDir" -ForegroundColor Yellow

# Function to extract required modules from a Lua file
function Get-RequiredModules {
    param (
        [string]$FilePath
    )
    
    $content = Get-Content -Path $FilePath -Raw
    $requires = @()
    
    # Match different require patterns
    $patterns = @(
        'require\(script\.Parent:FindFirstChild\("([^"]+)"\)\)',
        'require\(script\.Parent\.([^\)]+)\)',
        'require\(script\.([^\)]+)\)',
        'resolveModule\(''([^'']+)''\)',
        'resolveModule\("([^"]+)"\)'
    )
    'require\(script\.Parent:FindFirstChild\("([^"]+)"\)\)',
    'require\(script\.Parent\.([^\)]+)\)',
    'require\(script\.([^\)]+)\)'
)
    
foreach ($pattern in $patterns) {
    $matches = [regex]::Matches($content, $pattern)
    foreach ($match in $matches) {
        if ($match.Groups.Count -gt 1) {
            $requires += $match.Groups[1].Value
        }
    }
}
    
return $requires
}

# Create a dependency graph
$modules = @{}
$files = Get-ChildItem -Path $sourceDir -Filter "*.luau" -Recurse

Write-Host "Building dependency graph..." -ForegroundColor Green

foreach ($file in $files) {
    $moduleName = $file.BaseName
    $requires = Get-RequiredModules -FilePath $file.FullName
    $modules[$moduleName] = @{
        Path     = $file.FullName
        Requires = $requires
        FileName = $file.Name
    }
}

# Function to detect circular dependencies
function Find-CircularDependencies {
    param (
        [string]$StartModule,
        [string]$CurrentModule,
        [array]$Path = @(),
        [hashtable]$Visited = @{}
    )
    
    if ($Visited.ContainsKey($CurrentModule)) {
        return $null
    }
    
    $newPath = $Path + $CurrentModule
    $Visited[$CurrentModule] = $true
    
    if (-not $modules.ContainsKey($CurrentModule)) {
        return $null
    }
    
    foreach ($required in $modules[$CurrentModule].Requires) {
        $cleanRequired = $required -replace "\.server$|\.client$", ""
        
        if ($cleanRequired -eq $StartModule) {
            return $newPath + $StartModule
        }
        
        $result = Find-CircularDependencies -StartModule $StartModule -CurrentModule $cleanRequired -Path $newPath -Visited $Visited.Clone()
        if ($result) {
            return $result
        }
    }
    
    return $null
}

# Find all circular dependencies
$circularDependencies = @()

foreach ($moduleName in $modules.Keys) {
    $circular = Find-CircularDependencies -StartModule $moduleName -CurrentModule $moduleName
    if ($circular) {
        $circularDependencies += @{
            Module = $moduleName
            Path   = $circular
        }
    }
}

# Report circular dependencies
if ($circularDependencies.Count -gt 0) {
    Write-Host "Found $($circularDependencies.Count) circular dependencies:" -ForegroundColor Red
    
    foreach ($circular in $circularDependencies) {
        Write-Host "  Circular dependency in module: $($circular.Module)" -ForegroundColor Red
        Write-Host "  Dependency path: $($circular.Path -join ' -> ')" -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Fix circular dependencies
    Write-Host "Applying fixes to circular dependencies..." -ForegroundColor Green
    
    foreach ($circular in $circularDependencies) {
        $cyclePath = $circular.Path
        
        # Find the best module to break the cycle
        # Usually the re-export file or the one with fewest dependencies
        $moduleToFix = $cyclePath[-2] # The module right before the cycle completes
        
        $filePath = $modules[$moduleToFix].Path
        $fileName = $modules[$moduleToFix].FileName
        
        Write-Host "  Fixing module: $moduleToFix ($fileName)" -ForegroundColor Cyan
        
        # Create backup
        $backupPath = "$filePath.bak"
        Copy-Item -Path $filePath -Destination $backupPath -Force
        
        # Read the content
        $content = Get-Content -Path $filePath -Raw
        
        # Determine if this is a re-export file (single line with "return require...")
        $isReExport = $content -match "^\s*return\s+require\(" -and ($content.Split("`n").Count -le 3)
        
        if ($isReExport) {
            # Fix re-export pattern
            $targetModule = $cyclePath[-1]
            $pattern = "return\s+require\(script\.server\)"
            $replacement = "return require(script.Parent:FindFirstChild('$targetModule.server'))"
            
            $newContent = $content -replace $pattern, $replacement
            
            if ($newContent -ne $content) {
                Set-Content -Path $filePath -Value $newContent
                Write-Host "    Fixed re-export pattern in $fileName" -ForegroundColor Green
            }
        }
        else {
            # Find the require statement causing the circular dependency
            $targetModule = $cyclePath[-1]
            $requirePattern = "(?:local\s+\w+\s*=\s*)?require\(script(?:\.Parent)?(?:\:FindFirstChild\(\"$targetModule(?:\.server)?\"\)|(?:\.|\[)$targetModule(?:\.server)?\]?)\)"
            
            $requireMatches = [regex]::Matches($content, $requirePattern)
            
            if ($requireMatches.Count -gt 0) {
                # Replace direct require with lazy loading
                $match = $requireMatches[0].Value
                $lazyLoadCode = @"
-- Lazy load $targetModule to avoid circular dependency
local $targetModule = nil
local function get$targetModule()
    if not $targetModule then
        $targetModule = require(script.Parent:FindFirstChild("$targetModule.server") or script.Parent:FindFirstChild("$targetModule"))
    end
    return $targetModule
end
"@
                
                $newContent = $content -replace [regex]::Escape($match), $lazyLoadCode
                
                # Also replace any direct references to the module with get$targetModule()
                $newContent = $newContent -replace "(?<!\w)$targetModule\.(\w+)", "get$targetModule().$1"
                
                Set-Content -Path $filePath -Value $newContent
                Write-Host "    Applied lazy loading pattern in $fileName" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "Completed fixes for circular dependencies" -ForegroundColor Green
}
else {
    Write-Host "No circular dependencies found." -ForegroundColor Green
}

Write-Host "Done." -ForegroundColor Yellow
