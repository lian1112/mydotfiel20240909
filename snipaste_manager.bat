@echo off
setlocal EnableDelayedExpansion
REM Snipaste Manager v3 - Optimized with smart sync

set "SNIPASTE_PATH=D:\snipaste"
set "RECENT_PATH=D:\snipaste\recent"
set "LINUX_PATH=Z:\snipaste\recent"
set "TIMEOUT_SEC=30"
set "MAX_RETRY=3"

if not exist "%RECENT_PATH%" mkdir "%RECENT_PATH%"

if "%1"=="HIDE" (
    goto MAIN
) else (
    start "" /min %0 HIDE
    exit
)

:MAIN
echo [%date% %time%] Started v3 optimized >> "%SNIPASTE_PATH%\manager.log"
call :UPDATE_LATEST

:EVENT_LOOP
    powershell -NoProfile -WindowStyle Hidden -Command "& { try { $w = New-Object System.IO.FileSystemWatcher '%SNIPASTE_PATH%', 'Snipaste_*.jpg'; $w.NotifyFilter = 'FileName'; $w.EnableRaisingEvents = $true; $r = $w.WaitForChanged('Created', %TIMEOUT_SEC%000); $w.Dispose(); if (-not $r.TimedOut) { exit 1 } else { exit 0 } } catch { exit 0 } }" 2>nul
    
    if !errorlevel! equ 1 (
        timeout /t 1 /nobreak >nul
        call :UPDATE_LATEST
    )
goto EVENT_LOOP

:UPDATE_LATEST
    set "LATEST_FILE="
    for /f "tokens=*" %%f in ('dir "%SNIPASTE_PATH%\Snipaste_*.jpg" /b /o:-d 2^>nul') do (
        set "LATEST_FILE=%%f"
        goto :GOT_LATEST
    )
:GOT_LATEST
    if "!LATEST_FILE!"=="" goto :EOF
    
    REM Check if file changed (compare size)
    set "SRC=%SNIPASTE_PATH%\!LATEST_FILE!"
    set "DST=%RECENT_PATH%\1.jpg"
    
    for %%A in ("!SRC!") do set "SRC_SIZE=%%~zA"
    for %%A in ("!DST!") do set "DST_SIZE=%%~zA"
    
    if "!SRC_SIZE!"=="!DST_SIZE!" (
        REM Same size, skip
        goto :SYNC_LINUX_SMART
    )
    
    copy /Y "!SRC!" "!DST!" >nul 2>&1
    echo [%date% %time%] 1.jpg updated from !LATEST_FILE! >> "%SNIPASTE_PATH%\manager.log"
    
    REM Update 2-10
    set counter=2
    for /f "skip=1 tokens=*" %%f in ('dir "%SNIPASTE_PATH%\Snipaste_*.jpg" /b /o:-d 2^>nul') do (
        if !counter! leq 10 (
            copy /Y "%SNIPASTE_PATH%\%%f" "%RECENT_PATH%\!counter!.jpg" >nul 2>&1
            set /a counter+=1
        )
    )

:SYNC_LINUX_SMART
    if not exist "Z:\" goto :EOF
    if not exist "%LINUX_PATH%" mkdir "%LINUX_PATH%" 2>nul
    
    REM Only sync files that changed
    for %%i in (1 2 3 4 5 6 7 8 9 10) do (
        if exist "%RECENT_PATH%\%%i.jpg" (
            set "W_FILE=%RECENT_PATH%\%%i.jpg"
            set "L_FILE=%LINUX_PATH%\%%i.jpg"
            
            for %%A in ("!W_FILE!") do set "W_SIZE=%%~zA"
            if exist "!L_FILE!" (
                for %%A in ("!L_FILE!") do set "L_SIZE=%%~zA"
            ) else (
                set "L_SIZE=0"
            )
            
            if not "!W_SIZE!"=="!L_SIZE!" (
                set "RETRY=0"
                :RETRY_COPY
                copy /Y "!W_FILE!" "!L_FILE!" >nul 2>&1
                if errorlevel 1 (
                    set /a RETRY+=1
                    if !RETRY! lss %MAX_RETRY% (
                        timeout /t 1 /nobreak >nul
                        goto :RETRY_COPY
                    )
                )
            )
        )
    )
    echo [%date% %time%] Linux sync done >> "%SNIPASTE_PATH%\manager.log"
goto :EOF
