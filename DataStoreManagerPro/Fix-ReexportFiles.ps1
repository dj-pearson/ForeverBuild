# Fix-ReexportFiles.ps1
# This script updates all re-export files to use a compatible approach

$srcFolder = "c:\Users\pears\OneDrive\Documents\RobloxProject\DataStore Plugin\src"
$files = @(
    "AccessControlIntegration.luau",
    "BulkOperationsManager.luau",
    "BulkOperationsUI.luau",
    "DataMigrationTools.luau",
    "DataMigrationUI.luau",
    "DataVisualization.luau",
    "MonitoringDashboard.luau",
    "PerformanceMonitor.luau",
    "SchemaBuilder.luau",
    "SchemaBuilderUI.luau",
    "SchemaEditor.luau", 
    "SchemaManager.luau",
    "SchemaValidator.luau",
    "SchemaVersionViewer.luau",
    "SessionManagementUI.luau"
)

foreach ($file in $files) {
    $filePath = Join-Path $srcFolder $file
    $content = Get-Content $filePath -Raw
    
    if ($content -match "return require\(script\.server\)") {
        $moduleName = $file -replace '\.luau$', ''
        $newContent = $content -replace "return require\(script\.server\)", "-- Use direct reference to the server script instead of script.server`nreturn require(script.Parent:FindFirstChild(`"$moduleName.server`"))"
        Set-Content $filePath $newContent -NoNewline
        Write-Host "Updated $file to use direct server reference"
    }
    else {
        Write-Host "Skipped $file - pattern not found"
    }
}

Write-Host "`nCompleted updating re-export files" -ForegroundColor Green
