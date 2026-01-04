@echo off
REM ================================================================
REM Windows Explorer Restore Launcher
REM ================================================================

echo Starting Windows Explorer Restore...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp02_Restore_Explorer_UTF8BOM.ps1"

pause
