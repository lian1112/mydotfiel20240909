@echo off
SETLOCAL EnableDelayedExpansion
REM ================================================================
REM Total Commander System Integration - Backup Current Settings
REM ================================================================
REM 
REM This script backs up current folder and drive opening settings
REM 
REM How to run: Right-click this file -> Run as administrator
REM Backup location: Current directory
REM ================================================================

echo.
echo ========================================
echo  Total Commander System Integration
echo  Step 1/3: Backup Current Settings
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

REM Set backup file path (current directory)
set "BACKUP_DIR=%~dp0Backups"
if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!"

set BACKUP_TIME=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_TIME=%BACKUP_TIME: =0%

set "BACKUP_DIR_FILE=!BACKUP_DIR!\Directory_Shell_Backup_!BACKUP_TIME!.reg"
set "BACKUP_DRV_FILE=!BACKUP_DIR!\Drive_Shell_Backup_!BACKUP_TIME!.reg"

echo [1/2] Backing up folder opening settings...
reg export "HKEY_CLASSES_ROOT\Directory\shell" "!BACKUP_DIR_FILE!" /y >nul 2>&1
if !errorLevel! equ 0 (
    echo       [SUCCESS] Backed up to: !BACKUP_DIR_FILE!
) else (
    echo       [FAILED] Backup failed, please check permissions
)

echo.
echo [2/2] Backing up drive opening settings...
reg export "HKEY_CLASSES_ROOT\Drive\shell" "!BACKUP_DRV_FILE!" /y >nul 2>&1
if !errorLevel! equ 0 (
    echo       [SUCCESS] Backed up to: !BACKUP_DRV_FILE!
) else (
    echo       [FAILED] Backup failed, please check permissions
)

echo.
echo ========================================
echo  Backup Complete!
echo ========================================
echo.
echo Backup file location:
echo   !BACKUP_DIR!
echo.
echo Next step:
echo   Run 2_Set_TotalCommander_Default.reg
echo   to set Total Commander as default file manager
echo.
pause
ENDLOCAL
