@echo off
setlocal enabledelayedexpansion

set "source=%~1"
set "destination=%~dp1"

REM 獲取不帶擴展名的檔案名
for %%I in ("%source%") do set "filename=%%~nI"

REM 創建新的解壓目錄
set "extract_dir=%destination%%filename%"
if not exist "%extract_dir%" mkdir "%extract_dir%"

REM 將壓縮檔解壓到新目錄
"C:\Program Files\7-Zip\7z.exe" x "%source%" -o"%extract_dir%"

REM 檢查解壓是否成功
if %errorlevel% equ 0 (
    echo 解壓成功完成，檔案位於：%extract_dir%
) else (
    echo 解壓失敗，錯誤代碼：%errorlevel%
)

endlocal