@echo off
echo Building DataStore Manager Pro Plugin...

:: Check if Rojo is installed
where rojo >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Rojo is not installed. Please install it first:
    echo https://github.com/rojo-rbx/rojo
    exit /b 1
)

:: Build the plugin
rojo build plugin.project.json -o DataStoreManagerPro.rbxmx

if %ERRORLEVEL% equ 0 (
    echo Plugin built successfully: DataStoreManagerPro.rbxmx
    
    :: Copy to Roblox Plugins folder
    echo Copying plugin to Roblox Plugins folder...
    copy /Y DataStoreManagerPro.rbxmx "%LOCALAPPDATA%\Roblox\Plugins\DataStoreManagerPro.rbxmx"
    if %ERRORLEVEL% equ 0 (
        echo Plugin successfully copied to Roblox Plugins folder
    ) else (
        echo Failed to copy plugin to Roblox Plugins folder
        exit /b 1
    )
) else (
    echo Failed to build plugin
    exit /b 1
) 