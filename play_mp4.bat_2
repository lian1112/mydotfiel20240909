@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set "player=C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"

echo 正在处理以下参数:
echo %*
echo.

if "%~1"=="" (
    echo 错误：没有收到参数。请检查 Total Commander 的命令设置。
    goto :end
)

set "found_mp4=0"
for %%a in (%*) do (
    if "%%~a"=="%%" (
        echo 警告: 检测到未替换的百分号参数。请检查 Total Commander 的命令设置。
    ) else if exist "%%~a\" (
        echo 正在处理文件夹: %%~a
        for %%f in ("%%~a\*.mp4") do (
            echo 找到 MP4 文件: %%~f
            start "" "!player!" "%%~f"
            set "found_mp4=1"
        )
    ) else (
        echo 警告: %%~a 不是有效的文件夹路径
    )
)

if %found_mp4%==0 (
    echo 未找到任何 MP4 文件。请确保选择的文件夹中包含 MP4 文件。
) else (
    echo 处理完成。MP4 文件已添加到 PotPlayer 播放列表。
)

:end
echo.
echo 处理结束。请按任意键关闭此窗口。
pause > nul