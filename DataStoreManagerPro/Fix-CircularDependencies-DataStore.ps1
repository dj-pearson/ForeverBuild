# Fix-CircularDependencies-DataStore.ps1
# This script detects and fixes circular dependencies in the DataStore Plugin
# It focuses on transforming direct require statements into lazy loading patterns

Write-Host "DataStore Plugin: Circular Dependency Detector and Fixer" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host

$sourcePath = Join-Path $PSScriptRoot "src"
Write-Host "Analyzing modules in: $sourcePath" -ForegroundColor Yellow

# Get all Luau files
$luauFiles = Get-ChildItem -Path $sourcePath -Filter "*.luau" -Recurse

# 1. First pass: Catalog all modules and their relationships
$modules = @{}
$serverModules = @{}
$reexportModules = @{}

Write-Host "Building module relationship map..." -ForegroundColor Green

foreach ($file in $luauFiles) {
    $moduleName = $file.BaseName
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check if this is a server module
    if ($moduleName -like "*.server") {
        $baseModuleName = $moduleName -replace "\.server$", ""
        $serverModules[$baseModuleName] = $file.FullName
    }
    
    # Check if this is a re-export module (very short file that just returns require)
    if (($content -split "`n").Count -le 7 -and $content -match "return require") {
        $reexportModules[$moduleName] = $file.FullName
    }
    
    # Add to the main module catalog
    $modules[$moduleName] = @{
        Path = $file.FullName
        Content = $content
        RequiresModules = @()
        IsReexport = ($content -split "`n").Count -le 7 -and $content -match "return require"
    }
    
    # Extract module dependencies
    if ($content -match "resolveModule\(['""]([^'""]+)['""]") {
        foreach ($match in ([regex]::Matches($content, "resolveModule\(['""]([^'""]+)['""]"))) {
            $modules[$moduleName].RequiresModules += $match.Groups[1].Value
        }
    }
    
    if ($content -match "require\(script\.Parent:FindFirstChild\(['""]([^'""]+)['""]") {
        foreach ($match in ([regex]::Matches($content, "require\(script\.Parent:FindFirstChild\(['""]([^'""]+)['""]"))) {
            $modules[$moduleName].RequiresModules += $match.Groups[1].Value
        }
    }
}

# 2. Detect potential circular dependencies
Write-Host "Checking for circular dependencies..." -ForegroundColor Green

$circularDependencies = @()

function Test-CircularDependency($startModule, $currentModule, $visited = @{}, $path = @()) {
    if ($visited.ContainsKey($currentModule)) {
        return $null
    }
    
    $visited[$currentModule] = $true
    $newPath = $path + $currentModule
    
    if (-not $modules.ContainsKey($currentModule)) {
        return $null
    }
    
    foreach ($dependency in $modules[$currentModule].RequiresModules) {
        if ($dependency -eq $startModule) {
            return $newPath + $startModule
        }
        
        $result = Test-CircularDependency -startModule $startModule -currentModule $dependency -visited ($visited.Clone()) -path $newPath
        if ($result) {
            return $result
        }
    }
    
    return $null
}

foreach ($moduleName in $modules.Keys) {
    $circularPath = Test-CircularDependency -startModule $moduleName -currentModule $moduleName
    
    if ($circularPath) {
        $circularDependencies += @{
            Module = $moduleName
            Path = $circularPath
        }
    }
}

# 3. Fix circular dependencies
if ($circularDependencies.Count -gt 0) {
    Write-Host "Found $($circularDependencies.Count) circular dependencies:" -ForegroundColor Red
    
    foreach ($circular in $circularDependencies) {
        $cyclePath = $circular.Path -join " -> "
        Write-Host "  Circular dependency detected: $cyclePath" -ForegroundColor Yellow
    }
    
    Write-Host "Applying fixes..." -ForegroundColor Green
    
    # Keep track of modules we've fixed
    $fixedModules = @{}
    
    # Fix re-export pattern first
    foreach ($moduleName in $reexportModules.Keys) {
        $filePath = $reexportModules[$moduleName]
        $content = Get-Content -Path $filePath -Raw
        
        if ($content -match "return require\(script\.Parent:FindFirstChild\(['""]([^'""]+)['""]") {
            $requiredModule = $matches[1]
            
            # Check if this forms part of a circular dependency
            $isPartOfCircular = $false
            foreach ($circular in $circularDependencies) {
                if ($circular.Path -contains $moduleName) {
                    $isPartOfCircular = $true
                    break
                }
            }
            
            if ($isPartOfCircular) {
                Write-Host "  Fixing re-export in $moduleName..." -ForegroundColor Cyan
                
                # Create a new pattern with lazy loading
                $lazyLoadPattern = @"
-- Re-export file with lazy loading to prevent circular dependencies
local lazyModule = nil
local function getModule()
    if not lazyModule then
        lazyModule = require(script.Parent:FindFirstChild("$requiredModule"))
    end
    return lazyModule
end
return getModule()
"@
                
                # Save backup
                Copy-Item -Path $filePath -Destination "$filePath.bak" -Force
                
                # Update the file
                Set-Content -Path $filePath -Value $lazyLoadPattern
                
                $fixedModules[$moduleName] = $true
            }
        }
    }
    
    # Fix server modules with direct requires
    foreach ($moduleName in $modules.Keys) {
        if ($fixedModules.ContainsKey($moduleName)) {
            continue
        }
        
        # Check if this module is part of a circular dependency
        $isPartOfCircular = $false
        foreach ($circular in $circularDependencies) {
            if ($circular.Path -contains $moduleName) {
                $isPartOfCircular = $true
                break
            }
        }
        
        if ($isPartOfCircular) {
            $filePath = $modules[$moduleName].Path
            $content = $modules[$moduleName].Content
            
            # Replace direct requires with lazy-loaded versions
            foreach ($dependency in $modules[$moduleName].RequiresModules) {
                if ($circular.Path -contains $dependency) {
                    Write-Host "  Replacing direct require of $dependency in $moduleName with lazy loading..." -ForegroundColor Cyan
                    
                    # Match pattern for resolveModule and direct require
                    $resolvePattern = "resolveModule\(['""]$dependency['""]"
                    $requirePattern = "require\(script\.Parent:FindFirstChild\(['""]$dependency['""]"
                    
                    if ($content -match $resolvePattern) {
                        $lazyPattern = @"
-- Lazy load $dependency to avoid circular dependency
local _lazy_$dependency = nil
local function _get_$dependency()
    if not _lazy_$dependency then
        _lazy_$dependency = resolveModule("$dependency")
    end
    return _lazy_$dependency
end
"@
                        
                        # Replace all instances of the module being used
                        $varPattern = "local $dependency = resolveModule\(['""]$dependency['""]"
                        $newContent = $content -replace $varPattern, $lazyPattern
                        
                        # Also replace any direct uses of the module
                        $usePattern = "(?<!\w)$dependency\."
                        $newContent = $newContent -replace $usePattern, "_get_$dependency()."
                        
                        if ($newContent -ne $content) {
                            # Save backup
                            Copy-Item -Path $filePath -Destination "$filePath.bak" -Force
                            
                            # Update the file
                            Set-Content -Path $filePath -Value $newContent
                            
                            $fixedModules[$moduleName] = $true
                            $content = $newContent  # Update for subsequent replacements
                        }
                    }
                    
                    if ($content -match $requirePattern) {
                        $lazyPattern = @"
-- Lazy load $dependency to avoid circular dependency
local _lazy_$dependency = nil
local function _get_$dependency()
    if not _lazy_$dependency then
        _lazy_$dependency = require(script.Parent:FindFirstChild("$dependency"))
    end
    return _lazy_$dependency
end
"@
                        
                        # Replace all instances of the module being used
                        $varPattern = "local $dependency = require\(script\.Parent:FindFirstChild\(['""]$dependency['""]"
                        $newContent = $content -replace $varPattern, $lazyPattern
                        
                        # Also replace any direct uses of the module
                        $usePattern = "(?<!\w)$dependency\."
                        $newContent = $newContent -replace $usePattern, "_get_$dependency()."
                        
                        if ($newContent -ne $content) {
                            # Save backup
                            Copy-Item -Path $filePath -Destination "$filePath.bak" -Force
                            
                            # Update the file
                            Set-Content -Path $filePath -Value $newContent
                            
                            $fixedModules[$moduleName] = $true
                        }
                    }
                }
            }
        }
    }
    
    Write-Host "Fixed circular dependencies in $($fixedModules.Count) modules" -ForegroundColor Green
} else {
    Write-Host "No circular dependencies found." -ForegroundColor Green
}

Write-Host "Circular dependency check complete." -ForegroundColor Cyan
