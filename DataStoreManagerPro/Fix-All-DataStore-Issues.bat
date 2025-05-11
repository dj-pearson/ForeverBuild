@echo off
echo DataStore Plugin - Complete Fix Suite
echo ==================================
echo.

echo Step 1: Setting up Node.js and Argon...
call "%~dp0Setup-NodeJS-Argon.bat"
echo.

echo Step 2: Fixing module references and circular dependencies...
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
