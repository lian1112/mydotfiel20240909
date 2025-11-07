@echo off
SETLOCAL EnableDelayedExpansion
REM ================================================================
REM Total Commander System Integration - Emergency Restore Tool
REM ================================================================
REM 
REM This script restores settings from backup files
REM 
REM How to run: Right-click this file -> Run as administrator
REM ================================================================

echo.
echo ========================================
echo  Total Commander System Integration
echo  Emergency Restore (from backup)
echo ========================================
echo.

REM Check administrator rights
net session >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] Administrator rights required!
    echo.
    echo Please right-click this file and select
    echo "Run as administrator"
    echo.
    pause
    exit /b 1
)

REM Set backup directory
set "BACKUP_DIR=%~dp0Backups"

REM Check if backup directory exists
if not exist "!BACKUP_DIR!" (
    echo [ERROR] Backup folder not found!
    echo.
    echo Backup folder should be at: !BACKUP_DIR!
    echo.
    echo Please confirm:
    echo 1. Have you run 1_Backup_Current_Settings.bat?
    echo 2. Does the Backups folder exist?
    echo.
    pause
    exit /b 1
)

echo Searching for backup files...
echo.

REM Find latest backup files
for /f "delims=" %%f in ('dir /b /o-d "!BACKUP_DIR!\Directory_Shell_Backup_*.reg" 2^>nul') do (
    set "LATEST_DIR_BACKUP=%%f"
    goto :found_dir
)

:found_dir
for /f "delims=" %%f in ('dir /b /o-d "!BACKUP_DIR!\Drive_Shell_Backup_*.reg" 2^>nul') do (
    set "LATEST_DRV_BACKUP=%%f"
    goto :found_drv
)

:found_drv

if not defined LATEST_DIR_BACKUP (
    echo [ERROR] Folder settings backup file not found!
    echo.
    goto :error_exit
)

if not defined LATEST_DRV_BACKUP (
    echo [ERROR] Drive settings backup file not found!
    echo.
    goto :error_exit
)

echo Found the following backup files:
echo.
echo [1] !LATEST_DIR_BACKUP!
echo [2] !LATEST_DRV_BACKUP!
echo.
echo ========================================
echo  WARNING: Will restore to backup state
echo ========================================
echo.
set /p CONFIRM=Are you sure you want to restore? (Y/N): 

if /i not "!CONFIRM!"=="Y" (
    echo.
    echo Restore operation cancelled
    echo.
    pause
    exit /b 0
)

echo.
echo [1/2] Restoring folder opening settings...
reg import "!BACKUP_DIR!\!LATEST_DIR_BACKUP!" >nul 2>&1
if !errorLevel! equ 0 (
    echo       [SUCCESS] Folder settings restored
) else (
    echo       [FAILED] Restore failed, please manually import backup file
)

echo.
echo [2/2] Restoring drive opening settings...
reg import "!BACKUP_DIR!\!LATEST_DRV_BACKUP!" >nul 2>&1
if !errorLevel! equ 0 (
    echo       [SUCCESS] Drive settings restored
) else (
    echo       [FAILED] Restore failed, please manually import backup file
)

echo.
echo ========================================
echo  Restore Complete!
echo ========================================
echo.
echo IMPORTANT REMINDER:
echo 1. Please log out and log in again, or restart
echo 2. Settings will take full effect after restart
echo.
pause
exit /b 0

:error_exit
echo If you have manually backed up files, you can:
echo 1. Find your backup .reg files
echo 2. Double-click to import and restore
echo.
pause
exit /b 1
ENDLOCAL
