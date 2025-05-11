@echo off
setlocal enabledelayedexpansion

echo DataStore Plugin: Node.js and Argon Setup Utility
echo ================================================
echo.

REM Check for Node.js in PATH
echo Checking for Node.js installation...
where node 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('where node') do (
        set "NODE_EXE=%%i"
        echo Found Node.js at: !NODE_EXE!
        
        REM Extract directory
        for %%j in ("!NODE_EXE!") do set "NODE_PATH=%%~dpj"
        set "NODE_PATH=!NODE_PATH:~0,-1!"
        
        echo Node.js directory: !NODE_PATH!
        goto :node_found
    )
) else (
    echo Node.js not found in PATH.
    echo Checking common installation locations...
    
    REM Check common installation locations
    if exist "C:\Program Files\nodejs\node.exe" (
        set "NODE_PATH=C:\Program Files\nodejs"
        echo Found Node.js at: !NODE_PATH!
        goto :node_found
    )
    
    if exist "C:\Program Files (x86)\nodejs\node.exe" (
        set "NODE_PATH=C:\Program Files (x86)\nodejs"
        echo Found Node.js at: !NODE_PATH!
        goto :node_found
    )
    
    if exist "%LOCALAPPDATA%\Programs\nodejs\node.exe" (
        set "NODE_PATH=%LOCALAPPDATA%\Programs\nodejs"
        echo Found Node.js at: !NODE_PATH!
        goto :node_found
    )
    
    REM Not found, offer to install
    echo ERROR: Node.js not found.
    echo.
    echo Node.js is required for Argon to work properly.
    echo Would you like to open the Node.js download page?
    choice /c YN /m "Open Node.js download page (Y/N)? "
    if !ERRORLEVEL! equ 1 (
        start https://nodejs.org/en/download/
        echo Please run this script again after installing Node.js.
        goto :end
    ) else (
        echo Please install Node.js manually and run this script again.
        goto :end
    )
)

:node_found
echo.
set "NODE_CMD=!NODE_PATH!\node.exe"
set "NPM_CMD=!NODE_PATH!\npm.cmd"

REM Test Node.js and npm
echo Testing Node.js installation...
"!NODE_CMD!" -v
if %ERRORLEVEL% neq 0 (
    echo ERROR: Node.js installation appears broken.
    echo Please reinstall Node.js and try again.
    goto :end
)

echo.
echo Testing npm installation...
"!NPM_CMD!" -v
if %ERRORLEVEL% neq 0 (
    echo ERROR: npm installation appears broken.
    echo Please reinstall Node.js and try again.
    goto :end
)

REM Permanently add Node.js to PATH if not already there
echo !PATH! | find "!NODE_PATH!" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo Node.js is already in your system PATH.
) else (
    echo Adding Node.js to system PATH...
    setx PATH "!NODE_PATH!;%PATH%" /M
    echo Node.js has been added to your system PATH.
    echo Please restart any open command prompts for changes to take effect.
    
    REM Update current session's PATH as well
    set "PATH=!NODE_PATH!;%PATH%"
)

REM Check if Argon is installed
echo.
echo Checking for Argon CLI installation...
"!NPM_CMD!" list -g @argonlua/cli >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Argon CLI not found. Installing...
    "!NPM_CMD!" install -g @argonlua/cli
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Failed to install Argon CLI.
        echo Please run this command manually: npm install -g @argonlua/cli
        goto :end
    ) else (
        echo Argon CLI installed successfully!
    )
) else (
    echo Argon CLI is already installed.
)

REM Create Argon watch scripts
echo.
echo Creating Argon helper scripts...

REM Create Watch script
(
echo @echo off
echo echo Starting Argon in watch mode...
echo cd "%~dp0"
echo set "PATH=!NODE_PATH!;%%PATH%%"
echo npx @argonlua/cli watch
echo pause
) > "%~dp0Run-Argon-Watch.bat"

REM Create Build script
(
echo @echo off
echo echo Building plugin with Argon...
echo cd "%~dp0"
echo set "PATH=!NODE_PATH!;%%PATH%%"
echo npx @argonlua/cli build
echo echo Build complete!
echo pause
) > "%~dp0Build-With-Argon.bat"

echo.
echo Node.js and Argon setup complete!
echo.
echo To use Argon with your DataStore Plugin:
echo 1. Make sure Roblox Studio is closed
echo 2. Run "Run-Argon-Watch.bat" to start Argon in watch mode
echo 3. Open Roblox Studio and your plugin will auto-sync
echo.
echo To build your plugin into an .rbxmx file:
echo 1. Run "Build-With-Argon.bat"
echo.

:end
pause
