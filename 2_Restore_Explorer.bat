@echo off
SETLOCAL EnableDelayedExpansion
REM ================================================================
REM 還原 Windows Explorer 預設設定
REM ================================================================

echo.
echo ========================================
echo  還原 Windows Explorer
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

REM 檢查是否有備份檔案
set "BACKUP_DIR=%~dp0Backups"
set "HAS_BACKUP=0"
set "LATEST_DIR_BACKUP="
set "LATEST_DRV_BACKUP="

if exist "!BACKUP_DIR!" (
    for /f "delims=" %%f in ('dir /b /o-d "!BACKUP_DIR!\Directory_Shell_Backup_*.reg" 2^>nul') do (
        set "LATEST_DIR_BACKUP=%%f"
        goto :found_dir
    )
)

:found_dir
if exist "!BACKUP_DIR!" (
    for /f "delims=" %%f in ('dir /b /o-d "!BACKUP_DIR!\Drive_Shell_Backup_*.reg" 2^>nul') do (
        set "LATEST_DRV_BACKUP=%%f"
        goto :check_backup
    )
)

:check_backup
if defined LATEST_DIR_BACKUP (
    if defined LATEST_DRV_BACKUP (
        set "HAS_BACKUP=1"
    )
)

echo 請選擇還原方式：
echo.
if "!HAS_BACKUP!" equ "1" (
    echo [1] 從備份還原（推薦）
    echo     還原時間: !LATEST_DIR_BACKUP:~24,8! !LATEST_DIR_BACKUP:~33,6!
    echo.
    echo [2] 還原為 Windows 預設設定
    echo.
    set /p CHOICE="請選擇 (1/2): "
) else (
    echo [提示] 找不到備份檔案
    echo.
    echo [1] 還原為 Windows 預設設定
    echo.
    set /p CHOICE="按 1 繼續，或按其他鍵取消: "
)

if "!HAS_BACKUP!" equ "1" (
    if "!CHOICE!" equ "1" goto :restore_from_backup
    if "!CHOICE!" equ "2" goto :restore_default
) else (
    if "!CHOICE!" equ "1" goto :restore_default
)

echo.
echo 還原操作已取消
echo.
pause
exit /b 0

REM ================================================================
REM 方式 1: 從備份還原
REM ================================================================
:restore_from_backup
echo.
echo ========================================
echo  從備份還原
echo ========================================
echo.

echo [1/2] 還原資料夾開啟設定...
reg import "!BACKUP_DIR!\!LATEST_DIR_BACKUP!" >nul 2>&1
if !errorLevel! equ 0 (
    echo         [成功] 資料夾設定已還原
) else (
    echo         [失敗] 還原失敗
)

echo.
echo [2/2] 還原磁碟機開啟設定...
reg import "!BACKUP_DIR!\!LATEST_DRV_BACKUP!" >nul 2>&1
if !errorLevel! equ 0 (
    echo         [成功] 磁碟機設定已還原
) else (
    echo         [失敗] 還原失敗
)

goto :done

REM ================================================================
REM 方式 2: 還原為 Windows 預設設定
REM ================================================================
:restore_default
echo.
echo ========================================
echo  還原為 Windows 預設設定
echo ========================================
echo.

REM 建立暫存 Registry 檔案 - Directory
set "TEMP_REG_DIR=%TEMP%\Restore_Explorer_Dir.reg"

(
echo Windows Registry Editor Version 5.00
echo.
echo ; ================================================================
echo ; 還原資料夾預設開啟方式為 Windows Explorer
echo ; ================================================================
echo.
echo [HKEY_CLASSES_ROOT\Directory\shell]
echo @=""
echo.
echo [HKEY_CLASSES_ROOT\Directory\shell\open]
echo.
echo [HKEY_CLASSES_ROOT\Directory\shell\open\command]
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
echo   00,5c,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,\
echo   65,00,00,00
echo "DelegateExecute"="{11dbb47c-a525-400b-9e80-a54615a090c0}"
) > "!TEMP_REG_DIR!"

REM 建立暫存 Registry 檔案 - Drive
set "TEMP_REG_DRV=%TEMP%\Restore_Explorer_Drv.reg"

(
echo Windows Registry Editor Version 5.00
echo.
echo ; ================================================================
echo ; 還原磁碟機預設開啟方式為 Windows Explorer
echo ; ================================================================
echo.
echo [HKEY_CLASSES_ROOT\Drive\shell]
echo @=""
echo.
echo [HKEY_CLASSES_ROOT\Drive\shell\open]
echo.
echo [HKEY_CLASSES_ROOT\Drive\shell\open\command]
echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
echo   00,5c,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,\
echo   65,00,00,00
echo "DelegateExecute"="{11dbb47c-a525-400b-9e80-a54615a090c0}"
) > "!TEMP_REG_DRV!"

echo [1/2] 還原資料夾開啟設定...
reg import "!TEMP_REG_DIR!" >nul 2>&1
if !errorLevel! equ 0 (
    echo         [成功] 資料夾設定已還原
    set "SUCCESS_COUNT=1"
) else (
    echo         [失敗] 還原失敗
    set "SUCCESS_COUNT=0"
)

echo.
echo [2/2] 還原磁碟機開啟設定...
reg import "!TEMP_REG_DRV!" >nul 2>&1
if !errorLevel! equ 0 (
    echo         [成功] 磁碟機設定已還原
) else (
    echo         [失敗] 還原失敗
)

REM 清理暫存檔案
del "!TEMP_REG_DIR!" >nul 2>&1
del "!TEMP_REG_DRV!" >nul 2>&1

goto :done

REM ================================================================
REM 完成
REM ================================================================
:done
echo.
echo ========================================
echo  還原完成！
echo ========================================
echo.
echo 重要提醒：
echo 1. 請登出後重新登入，或重新開機
echo 2. 設定將在重新登入後生效
echo.
echo 測試項目：
echo - 雙擊桌面上的資料夾 → 應該用 Windows Explorer 開啟
echo - 雙擊「本機」中的 C: 磁碟機 → 應該用 Windows Explorer 開啟
echo.
pause
ENDLOCAL
