@echo off
REM Integrated cleanup tool batch file

REM Set UTF-8 code page
chcp 65001 >nul

REM Set window title
title Integrated Cleanup Tool

REM Check parameters
if "%1"=="" (
    echo Error: No path parameter provided
    echo Usage: %0 "path"
    pause
    exit /b 1
)

REM Check if PowerShell script exists
if not exist "d:\mydotfile\delete_file_smaller_200M\integrated_cleanup.ps1" (
    echo Error: PowerShell script not found
    echo Please ensure d:\mydotfile\delete_file_smaller_200M\integrated_cleanup.ps1 exists
    pause
    exit /b 1
)

REM Display operation description
echo =================================================================
echo                   Integrated Cleanup Tool
echo =================================================================
echo.
echo This tool will perform the following operations:
echo 1. Delete folders named "promotional files" and "2048" 
echo    in paths containing specific keywords
echo 2. Delete all files smaller than 200MB
echo.
echo Target path: %1
echo.

REM Execute PowerShell script
echo Target path: "%~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\mydotfile\delete_file_smaller_200M\integrated_cleanup.ps1" -CurrentPath "%~1"

REM Check execution result
if errorlevel 1 (
    echo.
    echo PowerShell execution failed
    pause
)