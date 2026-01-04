# ===================================================================
# Seeker SSL 自動更新 - 一鍵設定腳本
# 用途: 設定每月 1 號自動更新 SSL 憑證
# ===================================================================

param(
    [Parameter(Mandatory=$false)]
    [int]$DayOfMonth = 1,
    
    [Parameter(Mandatory=$false)]
    [int]$Hour = 3,
    
    [Parameter(Mandatory=$false)]
    [int]$Minute = 0
)

$ErrorActionPreference = "Stop"

# 檢查管理員權限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "✗ 需要管理員權限!" -ForegroundColor Red
    Write-Host "請以管理員身分執行 PowerShell" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Seeker SSL 自動更新 - 一鍵設定" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 設定路徑
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path $scriptDir "Deploy-SeekerSsl.ps1"
$configFile = Join-Path $scriptDir "samba-config.ps1"
$taskName = "Seeker-SSL-Auto-Renew"

# ===================================================================
# 步驟 1: 檢查必要檔案
# ===================================================================
Write-Host "[1/4] 檢查必要檔案..." -ForegroundColor Yellow

if (-not (Test-Path $mainScript)) {
    Write-Host "✗ 找不到 Deploy-SeekerSsl.ps1" -ForegroundColor Red
    exit 1
}

# 檢查是否有 SambaPassword 參數
$hasPasswordParam = Select-String -Path $mainScript -Pattern 'SambaPassword\s*=' -Quiet
if (-not $hasPasswordParam) {
    Write-Host "✗ Deploy-SeekerSsl.ps1 缺少 SambaPassword 參數" -ForegroundColor Red
    Write-Host "  請使用最新版本的腳本" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $configFile)) {
    Write-Host "✗ 找不到 samba-config.ps1" -ForegroundColor Red
    Write-Host "  請先建立配置檔案" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ 所有檔案就緒" -ForegroundColor Green

# ===================================================================
# 步驟 2: 建立包裝腳本
# ===================================================================
Write-Host "`n[2/4] 建立包裝腳本..." -ForegroundColor Yellow

$wrapperScript = Join-Path $scriptDir "Deploy-SeekerSsl-Wrapper.ps1"
$logDir = Join-Path $scriptDir "logs"

# 確保日誌目錄存在
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# 生成包裝腳本
$wrapperContent = @"
# Seeker SSL 自動部署包裝腳本
`$ErrorActionPreference = "Continue"
`$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
`$logFile = "$logDir\deploy_`$timestamp.log"

# 記錄開始
"====================================" | Out-File `$logFile -Encoding UTF8
"Seeker SSL 自動部署" | Out-File `$logFile -Append -Encoding UTF8
"時間: `$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File `$logFile -Append -Encoding UTF8
"====================================" | Out-File `$logFile -Append -Encoding UTF8
"" | Out-File `$logFile -Append -Encoding UTF8

try {
    Set-Location "$scriptDir"
    
    # 讀取密碼
    . "$configFile"
    `$password = `$Global:SambaCredentials.Password
    
    if (`$password) {
        "✓ 已載入認證" | Out-File `$logFile -Append -Encoding UTF8
        `$output = & "$mainScript" -SambaPassword `$password 2>&1
    } else {
        "✗ 找不到密碼" | Out-File `$logFile -Append -Encoding UTF8
        exit 1
    }
    
    `$output | Out-File `$logFile -Append -Encoding UTF8
    
    "" | Out-File `$logFile -Append -Encoding UTF8
    "====================================" | Out-File `$logFile -Append -Encoding UTF8
    if (`$LASTEXITCODE -eq 0 -or `$null -eq `$LASTEXITCODE) {
        "✓ 部署成功" | Out-File `$logFile -Append -Encoding UTF8
        exit 0
    } else {
        "✗ 部署失敗 (代碼: `$LASTEXITCODE)" | Out-File `$logFile -Append -Encoding UTF8
        exit `$LASTEXITCODE
    }
}
catch {
    "" | Out-File `$logFile -Append -Encoding UTF8
    "✗ 錯誤: `$_" | Out-File `$logFile -Append -Encoding UTF8
    exit 1
}
"@

Set-Content -Path $wrapperScript -Value $wrapperContent -Encoding UTF8
Write-Host "✓ 包裝腳本已建立" -ForegroundColor Green

# ===================================================================
# 步驟 3: 建立排程工作
# ===================================================================
Write-Host "`n[3/4] 建立排程工作..." -ForegroundColor Yellow

# 刪除舊的
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# 建立新的
$startTime = "{0:D2}:{1:D2}" -f $Hour, $Minute
$command = "PowerShell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$wrapperScript`""

$result = cmd /c "schtasks /Create /TN `"$taskName`" /TR `"$command`" /SC MONTHLY /D $DayOfMonth /ST $startTime /RU SYSTEM /RL HIGHEST /F" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 排程工作已建立" -ForegroundColor Green
} else {
    Write-Host "✗ 建立失敗: $result" -ForegroundColor Red
    exit 1
}

# ===================================================================
# 步驟 4: 測試執行
# ===================================================================
Write-Host "`n[4/4] 測試執行..." -ForegroundColor Yellow

# 手動執行一次測試
Write-Host "正在執行測試..." -ForegroundColor White
& $wrapperScript

Start-Sleep -Seconds 2

# 檢查日誌
$latestLog = Get-ChildItem $logDir -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($latestLog -and ((Get-Date) - $latestLog.LastWriteTime).TotalMinutes -lt 1) {
    Write-Host "✓ 測試執行成功" -ForegroundColor Green
    Write-Host "`n最新日誌 (最後 10 行):" -ForegroundColor Cyan
    Get-Content $latestLog.FullName -Tail 10 -Encoding UTF8 | ForEach-Object {
        if ($_ -match "✓|成功") {
            Write-Host "  $_" -ForegroundColor Green
        } elseif ($_ -match "✗|失敗|錯誤") {
            Write-Host "  $_" -ForegroundColor Red
        } else {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "⚠ 找不到測試日誌" -ForegroundColor Yellow
}

# ===================================================================
# 完成
# ===================================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ 設定完成！" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "排程資訊:" -ForegroundColor Yellow
Write-Host "  任務名稱: $taskName" -ForegroundColor White
Write-Host "  執行時間: 每月 $DayOfMonth 號 $Hour`:$('{0:D2}' -f $Minute)" -ForegroundColor White
Write-Host "  下次執行: " -NoNewline -ForegroundColor White
$taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
Write-Host "$($taskInfo.NextRunTime)" -ForegroundColor Cyan
Write-Host ""
Write-Host "管理命令:" -ForegroundColor Yellow
Write-Host "  # 手動執行" -ForegroundColor Cyan
Write-Host "  Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor Gray
Write-Host ""
Write-Host "  # 查看日誌" -ForegroundColor Cyan  
Write-Host "  Get-ChildItem '$logDir' | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content" -ForegroundColor Gray
Write-Host ""
Write-Host "  # 刪除排程" -ForegroundColor Cyan
Write-Host "  Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false" -ForegroundColor Gray
Write-Host ""