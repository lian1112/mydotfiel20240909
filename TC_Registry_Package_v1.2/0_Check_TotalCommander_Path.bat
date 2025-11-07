@echo off
SETLOCAL EnableDelayedExpansion
REM ================================================================
REM Total Commander Path Check Tool
REM ================================================================
REM 
REM This script checks if Total Commander is correctly installed
REM and displays the correct path for use in registry scripts
REM ================================================================

echo.
echo ========================================
echo  Total Commander Path Check Tool
echo ========================================
echo.

set "FOUND=0"

REM Check common installation paths
echo Searching for Total Commander...
echo.

REM Path 1: C:\Program Files\totalcmd\
if exist "C:\Program Files\totalcmd\TOTALCMD64.EXE" (
    echo [FOUND] C:\Program Files\totalcmd\TOTALCMD64.EXE
    set "TC_PATH=C:\Program Files\totalcmd\TOTALCMD64.EXE"
    set "TC_PATH_REG=C:\\Program Files\\totalcmd\\TOTALCMD64.EXE"
    set "FOUND=1"
)

if exist "C:\Program Files\totalcmd\TOTALCMD.EXE" (
    echo [FOUND] C:\Program Files\totalcmd\TOTALCMD.EXE (32-bit)
    if "!FOUND!" equ "0" (
        set "TC_PATH=C:\Program Files\totalcmd\TOTALCMD.EXE"
        set "TC_PATH_REG=C:\\Program Files\\totalcmd\\TOTALCMD.EXE"
        set "FOUND=1"
    )
)

REM Path 2: C:\Program Files (x86)\totalcmd\
if exist "C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE" (
    echo [FOUND] C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE
    if "!FOUND!" equ "0" (
        set "TC_PATH=C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE"
        set "TC_PATH_REG=C:\\Program Files (x86)\\totalcmd\\TOTALCMD64.EXE"
        set "FOUND=1"
    )
)

if exist "C:\Program Files (x86)\totalcmd\TOTALCMD.EXE" (
    echo [FOUND] C:\Program Files (x86)\totalcmd\TOTALCMD.EXE (32-bit)
    if "!FOUND!" equ "0" (
        set "TC_PATH=C:\Program Files (x86)\totalcmd\TOTALCMD.EXE"
        set "TC_PATH_REG=C:\\Program Files (x86)\\totalcmd\\TOTALCMD.EXE"
        set "FOUND=1"
    )
)

REM Path 3: C:\totalcmd\
if exist "C:\totalcmd\TOTALCMD64.EXE" (
    echo [FOUND] C:\totalcmd\TOTALCMD64.EXE
    if "!FOUND!" equ "0" (
        set "TC_PATH=C:\totalcmd\TOTALCMD64.EXE"
        set "TC_PATH_REG=C:\\totalcmd\\TOTALCMD64.EXE"
        set "FOUND=1"
    )
)

if exist "C:\totalcmd\TOTALCMD.EXE" (
    echo [FOUND] C:\totalcmd\TOTALCMD.EXE (32-bit)
    if "!FOUND!" equ "0" (
        set "TC_PATH=C:\totalcmd\TOTALCMD.EXE"
        set "TC_PATH_REG=C:\\totalcmd\\TOTALCMD.EXE"
        set "FOUND=1"
    )
)

echo.
echo ========================================

if "!FOUND!" equ "0" (
    echo  [ERROR] Total Commander not found!
    echo ========================================
    echo.
    echo Total Commander may be installed elsewhere
    echo.
    echo Please manually confirm the installation path,
    echo then modify the path in:
    echo 2_Set_TotalCommander_Default.reg
    echo.
    echo How to modify:
    echo 1. Open 2_Set_TotalCommander_Default.reg with Notepad
    echo 2. Search for "C:\\Program Files\\totalcmd\\TOTALCMD64.EXE"
    echo 3. Replace with correct path (backslashes must be doubled)
    echo.
    echo Example:
    echo   Actual path: D:\Tools\TotalCmd\TOTALCMD64.EXE
    echo   Registry:    D:\\Tools\\TotalCmd\\TOTALCMD64.EXE
    echo.
) else (
    echo  Check Result
    echo ========================================
    echo.
    echo Total Commander Location:
    echo   !TC_PATH!
    echo.
    echo Path to use in Registry script:
    echo   !TC_PATH_REG!
    echo.
    echo ----------------------------------------
    echo.
    
    REM Check if 2_Set_TotalCommander_Default.reg needs modification
    if exist "2_Set_TotalCommander_Default.reg" (
        findstr /C:"!TC_PATH_REG!" "2_Set_TotalCommander_Default.reg" >nul 2>&1
        if !errorLevel! equ 0 (
            echo [CHECK] 2_Set_TotalCommander_Default.reg
            echo         Path is correct, ready to use!
            echo.
            echo Next steps:
            echo   1. Run 1_Backup_Current_Settings.bat (Backup)
            echo   2. Run 2_Set_TotalCommander_Default.reg (Setup)
        ) else (
            echo [WARNING] 2_Set_TotalCommander_Default.reg
            echo           Path does not match, needs modification!
            echo.
            echo Please open the file with Notepad
            echo and replace with the correct path above
        )
    )
)

echo.
echo ========================================
echo.
pause
ENDLOCAL
