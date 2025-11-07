@echo off
setlocal enabledelayedexpansion

rem 創建一個臨時檔案來存儲檔案名稱
set "temp_file=%temp%\selected_files.txt"

rem 清空臨時檔案如果已存在
type nul > "%temp_file%"

rem 列出所需的檔案名稱並儲存到臨時檔案
for %%i in (
    git
    .gitignore
    Aqua_Sonatype_enriched_report.json
    checkov_report.json
    combined_report.xml
    sonarqube_report.json
    srm_combined_report.xml
) do (
    if exist "%%i" (
        echo %%i>> "%temp_file%"
    )
)

rem 將臨時檔案內容複製到剪貼簿
type "%temp_file%" | clip

rem 顯示已複製的檔案
echo 已複製以下檔案名稱到剪貼簿：
type "%temp_file%"

rem 刪除臨時檔案
del "%temp_file%"

pause