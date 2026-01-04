@echo off
REM ================================================================
REM Total Commander Setup Launcher
REM ================================================================

echo Starting Total Commander Setup...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp01_Setup_TotalCommander_UTF8BOM.ps1"

pause
