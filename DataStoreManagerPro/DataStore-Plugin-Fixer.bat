@echo off
echo DataStore Plugin - Comprehensive Fix Script
echo =========================================
echo.

:menu
echo Please select an option:
echo 1. Setup Node.js and Argon
echo 2. Fix circular dependencies
echo 3. Apply all fixes (recommended)
echo 4. Exit
echo.
set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" goto setup_nodejs
if "%choice%"=="2" goto fix_circular
if "%choice%"=="3" goto apply_all
if "%choice%"=="4" goto end

echo Invalid choice. Please try again.
echo.
goto menu

:setup_nodejs
echo.
echo Setting up Node.js and Argon...
call "%~dp0Setup-NodeJS-Argon.bat"
echo.
echo Node.js and Argon setup complete!
echo.
pause
goto menu

:fix_circular
echo.
echo Fixing circular dependencies...
powershell -ExecutionPolicy Bypass -File "%~dp0Fix-CircularDependencies-DataStore.ps1"
echo.
echo Circular dependency fixes applied!
echo.
pause
goto menu

:apply_all
echo.
echo Applying all fixes...
echo.
echo Step 1: Setting up Node.js and Argon...
call "%~dp0Setup-NodeJS-Argon.bat"
echo.
echo Step 2: Fixing circular dependencies...
powershell -ExecutionPolicy Bypass -File "%~dp0Fix-CircularDependencies-DataStore.ps1"
echo.
echo All fixes have been applied!
echo.
echo Next steps:
echo 1. Use Run-Argon-Watch.bat to start the Argon sync process
echo 2. Open Roblox Studio to test the plugin
echo 3. Use Build-With-Argon.bat to build the plugin for distribution
echo.
pause
goto menu

:end
echo Exiting...
exit
