@echo off
:: 設定滾動速度為 5 行的批次檔
:: 將此檔案放到啟動資料夾即可開機自動執行

:: 等待 15 秒讓 TrackballWorks 完成載入
timeout /t 15 /nobreak > nul

:: 使用 PowerShell 設定滾動速度
powershell -ExecutionPolicy Bypass -Command ^
"Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'WheelScrollLines' -Value 5; ^
$HWND_BROADCAST = [IntPtr]0xffff; ^
$WM_SETTINGCHANGE = 0x001A; ^
Add-Type @' ^
using System; ^
using System.Runtime.InteropServices; ^
public class Win32 { ^
[DllImport(\"user32.dll\")] ^
public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam); ^
} ^
'@; ^
[Win32]::SendMessage($HWND_BROADCAST, $WM_SETTINGCHANGE, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null"

:: 顯示完成訊息（可選，會閃現一個命令視窗）
:: echo 滑鼠滾動速度已設定為 5 行
:: timeout /t 2 > nul