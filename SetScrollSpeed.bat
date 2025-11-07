# 延遲設定滑鼠滾動速度的 PowerShell 腳本
# 等待 TrackballWorks 完成初始化後再設定

# 等待 10 秒（可根據需要調整）
Write-Host "等待系統完成啟動..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 設定登錄表中的滾動行數
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WheelScrollLines" -Value 5

# 如果 TrackballWorks 正在執行，嘗試重新啟動它
$trackballProcess = Get-Process -Name "TrackballWorks" -ErrorAction SilentlyContinue
if ($trackballProcess) {
    Write-Host "偵測到 TrackballWorks，嘗試重新啟動..." -ForegroundColor Yellow
    Stop-Process -Name "TrackballWorks" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # 嘗試重新啟動 TrackballWorks
    $trackballPath = "${env:ProgramFiles}\Kensington\TrackballWorks\TrackballWorks.exe"
    if (Test-Path $trackballPath) {
        Start-Process $trackballPath
    }
}

# 廣播設定變更訊息
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);
    }
"@

$HWND_BROADCAST = [IntPtr]0xffff
$WM_SETTINGCHANGE = 0x001A
$SMTO_ABORTIFHUNG = 0x0002
$timeout = 5000
$result = [IntPtr]::Zero

[Win32]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [IntPtr]::Zero, [IntPtr]::Zero, $SMTO_ABORTIFHUNG, $timeout, [ref]$result) | Out-Null

Write-Host "滑鼠滾動速度已設定為每次 5 行" -ForegroundColor Green

# 顯示目前的設定值
$currentValue = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WheelScrollLines" | Select-Object -ExpandProperty WheelScrollLines
Write-Host "目前的滾動行數設定: $currentValue" -ForegroundColor Cyan

# 持續監控並修正（選用）
Write-Host "`n按 Ctrl+C 結束監控，或關閉此視窗" -ForegroundColor Gray
while ($true) {
    Start-Sleep -Seconds 30
    $currentValue = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WheelScrollLines" | Select-Object -ExpandProperty WheelScrollLines
    if ($currentValue -ne 5) {
        Write-Host "偵測到設定被改變，重新設定..." -ForegroundColor Yellow
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WheelScrollLines" -Value 5
    }
}