@echo off
SETLOCAL EnableDelayedExpansion
REM ================================================================
REM Total Commander 一鍵設定工具
REM ================================================================

echo.
echo ========================================
echo  Total Commander 一鍵設定工具
echo ========================================
echo.

REM 檢查系統管理員權限
net session >nul 2>&1
if !errorLevel! neq 0 (
    echo [錯誤] 需要系統管理員權限！
    echo.
    echo 請用滑鼠右鍵點選此檔案，選擇
    echo 「以系統管理員身份執行」
    echo.
    pause
    exit /b 1
)

REM ================================================================
REM 步驟 1/3: 檢查 Total Commander 路徑
REM ================================================================
echo [步驟 1/3] 檢查 Total Commander 安裝路徑...
echo.

set "FOUND=0"
set "TC_PATH="
set "TC_PATH_REG="

REM 檢查常見安裝路徑
if exist "C:\Program Files\totalcmd\TOTALCMD64.EXE" (
    set "TC_PATH=C:\Program Files\totalcmd\TOTALCMD64.EXE"
    set "TC_PATH_REG=C:\\Program Files\\totalcmd\\TOTALCMD64.EXE"
    set "FOUND=1"
    echo           已找到: C:\Program Files\totalcmd\TOTALCMD64.EXE
) else if exist "C:\Program Files\totalcmd\TOTALCMD.EXE" (
    set "TC_PATH=C:\Program Files\totalcmd\TOTALCMD.EXE"
    set "TC_PATH_REG=C:\\Program Files\\totalcmd\\TOTALCMD.EXE"
    set "FOUND=1"
    echo           已找到: C:\Program Files\totalcmd\TOTALCMD.EXE (32-bit)
) else if exist "C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE" (
    set "TC_PATH=C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE"
    set "TC_PATH_REG=C:\\Program Files (x86)\\totalcmd\\TOTALCMD64.EXE"
    set "FOUND=1"
    echo           已找到: C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE
) else if exist "C:\Program Files (x86)\totalcmd\TOTALCMD.EXE" (
    set "TC_PATH=C:\Program Files (x86)\totalcmd\TOTALCMD.EXE"
    set "TC_PATH_REG=C:\\Program Files (x86)\\totalcmd\\TOTALCMD.EXE"
    set "FOUND=1"
    echo           已找到: C:\Program Files (x86)\totalcmd\TOTALCMD.EXE (32-bit)
) else if exist "C:\totalcmd\TOTALCMD64.EXE" (
    set "TC_PATH=C:\totalcmd\TOTALCMD64.EXE"
    set "TC_PATH_REG=C:\\totalcmd\\TOTALCMD64.EXE"
    set "FOUND=1"
    echo           已找到: C:\totalcmd\TOTALCMD64.EXE
) else if exist "C:\totalcmd\TOTALCMD.EXE" (
    set "TC_PATH=C:\totalcmd\TOTALCMD.EXE"
    set "TC_PATH_REG=C:\\totalcmd\\TOTALCMD.EXE"
    set "FOUND=1"
    echo           已找到: C:\totalcmd\TOTALCMD.EXE (32-bit)
)

if "!FOUND!" equ "0" (
    echo           [錯誤] 找不到 Total Commander！
    echo.
    echo Total Commander 可能安裝在其他位置
    echo 請手動輸入完整路徑（例如: D:\Tools\totalcmd\TOTALCMD64.EXE）
    echo.
    set /p TC_PATH="請輸入路徑: "
    
    if not exist "!TC_PATH!" (
        echo.
        echo [錯誤] 找不到指定的檔案！
        echo.
        pause
        exit /b 1
    )
    
    REM 轉換路徑為 Registry 格式（反斜線加倍）
    set "TC_PATH_REG=!TC_PATH:\=\\!"
    echo.
    echo           已確認: !TC_PATH!
)

echo.

REM ================================================================
REM 步驟 2/3: 備份當前設定
REM ================================================================
echo [步驟 2/3] 備份當前設定...
echo.

set "BACKUP_DIR=%~dp0Backups"
if not exist "!BACKUP_DIR!" mkdir "!BACKUP_DIR!"

set BACKUP_TIME=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_TIME=%BACKUP_TIME: =0%

set "BACKUP_DIR_FILE=!BACKUP_DIR!\Directory_Shell_Backup_!BACKUP_TIME!.reg"
set "BACKUP_DRV_FILE=!BACKUP_DIR!\Drive_Shell_Backup_!BACKUP_TIME!.reg"

reg export "HKEY_CLASSES_ROOT\Directory\shell" "!BACKUP_DIR_FILE!" /y >nul 2>&1
if !errorLevel! equ 0 (
    echo           [成功] 資料夾設定已備份
) else (
    echo           [失敗] 備份失敗，請檢查權限
    pause
    exit /b 1
)

reg export "HKEY_CLASSES_ROOT\Drive\shell" "!BACKUP_DRV_FILE!" /y >nul 2>&1
if !errorLevel! equ 0 (
    echo           [成功] 磁碟機設定已備份
) else (
    echo           [失敗] 備份失敗，請檢查權限
    pause
    exit /b 1
)

echo.
echo           備份位置: !BACKUP_DIR!
echo.

REM ================================================================
REM 步驟 3/3: 套用 Total Commander 設定
REM ================================================================
echo [步驟 3/3] 套用 Total Commander 設定...
echo.

REM 建立暫存 Registry 檔案
set "TEMP_REG=%TEMP%\TC_Setup.reg"

(
echo Windows Registry Editor Version 5.00
echo.
echo ; ================================================================
echo ; 設定資料夾預設開啟方式為 Total Commander
echo ; ================================================================
echo.
echo [HKEY_CLASSES_ROOT\Directory\shell]
echo @="none"
echo.
echo [HKEY_CLASSES_ROOT\Directory\shell\open]
echo @="使用 Total Commander 開啟(&O)"
echo "Icon"="\"!TC_PATH_REG!\",0"
echo.
echo [HKEY_CLASSES_ROOT\Directory\shell\open\command]
echo @="\"!TC_PATH_REG!\" /O /T /S \"%%1\""
echo.
echo ; ================================================================
echo ; 設定磁碟機預設開啟方式為 Total Commander
echo ; ================================================================
echo.
echo [HKEY_CLASSES_ROOT\Drive\shell]
echo @="none"
echo.
echo [HKEY_CLASSES_ROOT\Drive\shell\open]
echo @="使用 Total Commander 開啟(&O)"
echo "Icon"="\"!TC_PATH_REG!\",0"
echo.
echo [HKEY_CLASSES_ROOT\Drive\shell\open\command]
echo @="\"!TC_PATH_REG!\" /O /T /S \"%%1\""
) > "!TEMP_REG!"

REM 匯入 Registry
reg import "!TEMP_REG!" >nul 2>&1
if !errorLevel! equ 0 (
    echo           [成功] Total Commander 已設為預設
) else (
    echo           [失敗] 設定失敗
    del "!TEMP_REG!" >nul 2>&1
    pause
    exit /b 1
)

REM 清理暫存檔案
del "!TEMP_REG!" >nul 2>&1

echo.
echo ========================================
echo  設定完成！
echo ========================================
echo.
echo ✓ Total Commander 路徑: !TC_PATH!
echo ✓ 備份檔案位置: !BACKUP_DIR!
echo.
echo 重要提醒：
echo 1. 請登出後重新登入，或重新開機
echo 2. 設定將在重新登入後生效
echo.
echo 測試項目：
echo - 雙擊桌面上的資料夾
echo - 雙擊「本機」中的 C: 磁碟機
echo - Win+R 輸入 C:\ 按 Enter
echo - VS Code 右鍵 → Reveal in File Explorer
echo.
echo 如需還原，請執行：
echo   2_Restore_Explorer.bat
echo.
pause
ENDLOCAL
