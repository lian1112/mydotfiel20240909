@echo off
setlocal EnableDelayedExpansion
REM 優化版事件觸發 - 只處理最新檔案，減少資源消耗

set "SNIPASTE_PATH=D:\snipaste"
set "RECENT_PATH=D:\snipaste\recent"

if not exist "%RECENT_PATH%" mkdir "%RECENT_PATH%"

REM 隱藏視窗
if "%1"=="HIDE" (
    goto MAIN
) else (
    start "" /min %0 HIDE
    exit
)

:MAIN
echo [%date% %time%] 啟動優化版事件觸發監控 >> "%SNIPASTE_PATH%\manager.log"

REM 初始更新
call :UPDATE_ONLY_LATEST

:OPTIMIZED_EVENT_LOOP
    REM 使用優化的 PowerShell FileSystemWatcher
    powershell -NoProfile -WindowStyle Hidden -Command "& { try { $w = New-Object System.IO.FileSystemWatcher '%SNIPASTE_PATH%', 'Snipaste_*.jpg'; $w.NotifyFilter = 'FileName'; $w.EnableRaisingEvents = $true; $r = $w.WaitForChanged('Created', 60000); $w.Dispose(); if (-not $r.TimedOut) { exit 1 } else { exit 0 } } catch { exit 0 } }" 2>nul
    
    if !errorlevel! equ 1 (
        REM 偵測到新檔案，只更新最新的那個
        echo [%date% %time%] 偵測到新檔案，只更新最新檔案 >> "%SNIPASTE_PATH%\manager.log"
        
        REM 短暫延遲確保檔案寫入完成
        timeout /t 1 /nobreak >nul
        
        REM 只處理最新檔案，不重新整理全部
        call :UPDATE_ONLY_LATEST
    )
    
goto OPTIMIZED_EVENT_LOOP

REM ==================== 只更新最新檔案 ====================
:UPDATE_ONLY_LATEST
    REM 只取得最新的檔案
    for /f "tokens=*" %%f in ('dir "%SNIPASTE_PATH%\Snipaste_*.jpg" /b /o:-d 2^>nul') do (
        REM 只處理第一個（最新的）檔案
        copy "%SNIPASTE_PATH%\%%f" "%RECENT_PATH%\1.jpg" >nul 2>&1
        echo [%date% %time%] 更新 1.jpg ^<-- %%f >> "%SNIPASTE_PATH%\manager.log"
        goto :UPDATE_OTHERS
    )
    
:UPDATE_OTHERS
    REM 如果需要，更新其他編號（2-10）
    set counter=2
    for /f "skip=1 tokens=*" %%f in ('dir "%SNIPASTE_PATH%\Snipaste_*.jpg" /b /o:-d 2^>nul') do (
        if !counter! leq 10 (
            copy "%SNIPASTE_PATH%\%%f" "%RECENT_PATH%\!counter!.jpg" >nul 2>&1
            set /a counter+=1
        )
    )
    
goto :EOF