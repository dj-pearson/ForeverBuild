@echo off
echo Running DataStore Plugin Setup Check...
powershell -ExecutionPolicy Bypass -File "%~dp0Check-DataStore-Setup.ps1"
pause
