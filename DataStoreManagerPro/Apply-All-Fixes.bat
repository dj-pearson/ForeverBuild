@echo off
echo DataStore Plugin - Complete Fix Utility
echo =====================================
echo.

echo Step 1: Setting up Node.js and Argon...
call "%~dp0..\Argon-Setup-Improved.bat"
echo.
echo.

echo Step 2: Fixing module references...
powershell -ExecutionPolicy Bypass -File "%~dp0Fix-ServerModules.ps1"
echo.
echo.

echo Step 3: Detecting and fixing circular dependencies...
powershell -ExecutionPolicy Bypass -File "%~dp0Fix-CircularDependencies.ps1"
echo.
echo.

echo Step 4: Building plugin with Argon...
echo This will build the plugin for use in Roblox Studio
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0SimplePluginBuild.ps1"
echo.
echo.

echo All fixes complete!
echo Please test the plugin in Roblox Studio.
echo.
pause
