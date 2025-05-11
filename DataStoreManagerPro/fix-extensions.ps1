# Fix file extensions in clientScripts directory
Get-ChildItem -Path "src\clientScripts\*.client" | ForEach-Object {
    $newName = $_.BaseName + ".client.luau"
    Rename-Item -Path $_.FullName -NewName $newName
}

# Remove UI files from server directory that should be in clientScripts
Get-ChildItem -Path "src\server\*UI.server.luau" | ForEach-Object {
    $clientName = $_.BaseName -replace '\.server$', ''
    if (Test-Path "src\clientScripts\$clientName.client.luau") {
        Remove-Item $_.FullName
    }
} 