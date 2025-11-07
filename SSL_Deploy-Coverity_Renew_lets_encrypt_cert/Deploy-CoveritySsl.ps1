# ===================================================================
# Coverity SSL 憑證部署腳本 (從 Samba 下載 Let's Encrypt 憑證)
# 用途: 從 Linux 伺服器的 Samba 共享下載 JKS 並部署到 Windows Coverity
# ===================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$SambaServer = "192.168.31.5",
    
    [Parameter(Mandatory=$false)]
    [string]$SambaShare = "allenl_home",
    
    [Parameter(Mandatory=$false)]
    [string]$SambaUser = "allenl",
    
    [Parameter(Mandatory=$false)]
    [string]$SambaPassword = "",  # 如果為空,會提示輸入;排程工作執行時必須提供
    
    [Parameter(Mandatory=$false)]
    [string]$SambaSourcePath = "SSL_files\coverity_windows",
    
    [Parameter(Mandatory=$false)]
    [string]$CoverityPath = "C:\Program Files\Coverity\Coverity Platform",
    
    [Parameter(Mandatory=$false)]
    [string]$KeystorePassword = "changeit",
    
    [Parameter(Mandatory=$false)]
    [string]$CoverityUrl = "https://mydemo.idv.tw:8449"
)

$ErrorActionPreference = "Stop"

# ===================================================================
# 輔助函數
# ===================================================================

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Step { param([string]$Message) Write-ColorOutput $Message "Cyan" }
function Write-Success { param([string]$Message) Write-ColorOutput "  ✓ $Message" "Green" }
function Write-Warning { param([string]$Message) Write-ColorOutput "  ⚠ $Message" "Yellow" }
function Write-Failure { param([string]$Message) Write-ColorOutput "  ✗ $Message" "Red" }

# ===================================================================
# 初始化
# ===================================================================

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "    Coverity SSL 憑證部署腳本" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Samba 伺服器: \\$SambaServer\$SambaShare" -ForegroundColor White
Write-Host "來源路徑: $SambaSourcePath" -ForegroundColor White
Write-Host "Coverity 路徑: $CoverityPath" -ForegroundColor White
Write-Host ""

$date = Get-Date -Format "yyyyMMdd_HHmmss"
$keystorePath = Join-Path $CoverityPath "server\base\conf\keystore.jks"
$covBin = Join-Path $CoverityPath "bin\cov-im-ctl.exe"
$tempKeystore = "C:\temp\keystore.jks"

# 確保臨時目錄存在
if (-not (Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp" -Force | Out-Null
}

# ===================================================================
# 步驟 1: 檢查 Coverity 安裝
# ===================================================================

Write-Step "檢查 Coverity 安裝"

if (-not (Test-Path $covBin)) {
    Write-Failure "找不到 Coverity: $covBin"
    exit 1
}

if (-not (Test-Path $keystorePath)) {
    Write-Failure "找不到現有 keystore: $keystorePath"
    exit 1
}

Write-Success "Coverity 安裝正常"

# ===================================================================
# 步驟 2: 連接到 Samba 共享
# ===================================================================

Write-Step "連接到 Samba 共享"

$sambaPath = "\\$SambaServer\$SambaShare"
$sambaDrive = "Z:"

# 檢查 Z: 是否已經掛載
if (Test-Path $sambaDrive) {
    Write-Success "Samba 磁碟機 $sambaDrive 已掛載"
} else {
    Write-ColorOutput "  正在連接到 $sambaPath..." "White"
    
    # 提示輸入密碼
    if (-not $SambaPassword) {
        $SecurePassword = Read-Host "請輸入 Samba 密碼 (使用者: $SambaUser)" -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
        $SambaPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }
    
    try {
        # 先移除可能存在的映射
        net use $sambaDrive /delete /y 2>$null | Out-Null
        
        # 建立新的映射
        $netUseCmd = "net use $sambaDrive $sambaPath /user:$SambaUser $SambaPassword"
        $result = cmd /c $netUseCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Samba 連接成功"
        } else {
            Write-Failure "Samba 連接失敗: $result"
            exit 1
        }
    }
    catch {
        Write-Failure "Samba 連接錯誤: $_"
        exit 1
    }
}

# ===================================================================
# 步驟 3: 下載並驗證 keystore
# ===================================================================

Write-Step "下載並驗證 keystore"

$sourceKeystore = Join-Path "${sambaDrive}\" "$SambaSourcePath\keystore.jks"

if (-not (Test-Path $sourceKeystore)) {
    Write-Failure "找不到來源 keystore: $sourceKeystore"
    net use $sambaDrive /delete /y 2>$null | Out-Null
    exit 1
}

# 複製到臨時目錄
try {
    Copy-Item $sourceKeystore $tempKeystore -Force
    Write-Success "已下載 keystore"
}
catch {
    Write-Failure "下載失敗: $_"
    net use $sambaDrive /delete /y 2>$null | Out-Null
    exit 1
}

# 驗證 keystore
Write-ColorOutput "  驗證 keystore..." "White"
$verify = keytool -list -keystore $tempKeystore -storepass $KeystorePassword 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "Keystore 有效"
    
    # 顯示憑證資訊
    $certInfo = $verify | Select-String "Valid from|Alias name|Certificate fingerprints"
    if ($certInfo) {
        Write-ColorOutput "`n  憑證資訊:" "Yellow"
        $certInfo | ForEach-Object {
            Write-ColorOutput "    $($_.Line.Trim())" "Gray"
        }
    }
} else {
    Write-Failure "Keystore 無效!"
    Write-Failure $verify
    Remove-Item $tempKeystore -Force -ErrorAction SilentlyContinue
    net use $sambaDrive /delete /y 2>$null | Out-Null
    exit 1
}

# 檢查 README
$readmePath = Join-Path "${sambaDrive}\" "$SambaSourcePath\README.txt"
if (Test-Path $readmePath) {
    $readme = Get-Content $readmePath -Raw
    if ($readme -match "Valid To:\s+(.+)") {
        Write-ColorOutput "`n  📄 README 內容:" "Cyan"
        Write-ColorOutput "------------------------------------------------------------" "DarkGray"
        Get-Content $readmePath | ForEach-Object {
            Write-ColorOutput "  $_" "Gray"
        }
        Write-ColorOutput "------------------------------------------------------------" "DarkGray"
    }
}

# ===================================================================
# 步驟 4: 停止 Coverity 服務
# ===================================================================

Write-Step "停止 Coverity 服務"

Write-ColorOutput "  正在停止 Coverity..." "White"

try {
    $stopOutput = & $covBin stop 2>&1
    Start-Sleep -Seconds 10
    
    # 檢查是否真的停止了
    $statusOutput = & $covBin status 2>&1
    if ($statusOutput -match "not running|stopped") {
        Write-Success "服務已停止"
    } else {
        Write-Warning "服務可能仍在運行,等待額外 10 秒..."
        Start-Sleep -Seconds 10
    }
}
catch {
    Write-Failure "停止服務時發生錯誤: $_"
    exit 1
}

# ===================================================================
# 步驟 5: 備份現有 keystore
# ===================================================================

Write-Step "備份現有 keystore"

$backupDir = Join-Path $CoverityPath "server\base\conf\backup"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Success "備份目錄已建立"
} else {
    Write-Success "備份目錄已存在"
}

$backupPath = Join-Path $backupDir "keystore.jks.backup.$date"

try {
    Copy-Item $keystorePath $backupPath -Force
    Write-Success "已備份到: $backupPath"
}
catch {
    Write-Warning "備份失敗: $_"
}

# ===================================================================
# 步驟 6: 部署新 keystore
# ===================================================================

Write-Step "部署新 keystore"

try {
    Copy-Item $tempKeystore $keystorePath -Force
    Write-Success "Keystore 已部署"
    
    # 設定檔案權限
    $acl = Get-Acl $keystorePath
    Write-Success "檔案權限已設定"
}
catch {
    Write-Failure "部署失敗: $_"
    
    # 嘗試還原備份
    if (Test-Path $backupPath) {
        Write-Warning "嘗試還原備份..."
        Copy-Item $backupPath $keystorePath -Force
    }
    
    exit 1
}

# ===================================================================
# 步驟 7: 啟動 Coverity 服務
# ===================================================================

Write-Step "啟動 Coverity 服務"

Write-ColorOutput "  正在啟動 Coverity..." "White"

try {
    $startOutput = & $covBin start 2>&1
    
    # 等待服務啟動
    $maxWait = 60
    $waited = 0
    $started = $false
    
    while ($waited -lt $maxWait) {
        Start-Sleep -Seconds 5
        $waited += 5
        
        $statusOutput = & $covBin status 2>&1
        if ($statusOutput -match "running|started") {
            $started = $true
            break
        }
        
        if ($waited % 15 -eq 0) {
            Write-ColorOutput "  等待中... ($waited 秒)" "Gray"
        }
    }
    
    if ($started) {
        Write-Success "服務已啟動"
    } else {
        Write-Warning "服務可能還在啟動中,請稍後驗證"
    }
}
catch {
    Write-Failure "啟動服務時發生錯誤: $_"
}

# ===================================================================
# 步驟 8: 驗證部署
# ===================================================================

Write-Step "驗證部署"

# 檢查服務狀態
$statusOutput = & $covBin status 2>&1
if ($statusOutput -match "running|started") {
    Write-Success "服務狀態: Running"
} else {
    Write-Warning "服務狀態異常"
    Write-ColorOutput "  $statusOutput" "Gray"
}

# 檢查端口
Start-Sleep -Seconds 3
$port = 8449
$portCheck = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue

if ($portCheck) {
    Write-Success "端口 $port 正在監聽"
} else {
    Write-Warning "端口 $port 未檢測到監聽"
    Write-ColorOutput "  服務可能還在啟動中,請稍後再試" "Gray"
}

# ===================================================================
# 步驟 9: 清理
# ===================================================================

Write-Step "清理"

# 刪除臨時檔案
if (Test-Path $tempKeystore) {
    Remove-Item $tempKeystore -Force
    Write-Success "已刪除臨時檔案"
}

# 中斷 Samba 連接
try {
    net use $sambaDrive /delete /y 2>$null | Out-Null
    Write-Success "已中斷 Samba 連接"
}
catch {
    # 忽略錯誤
}

# ===================================================================
# 完成
# ===================================================================

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "         部署完成！" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-ColorOutput "📊 部署摘要:" "Yellow"
Write-ColorOutput "  ✓ Keystore 已從 Samba 下載" "White"
Write-ColorOutput "  ✓ 舊 keystore 已備份" "White"
Write-ColorOutput "  ✓ 新 keystore 已部署到 $keystorePath" "White"
Write-ColorOutput "  ✓ Coverity 服務已重啟" "White"

Write-Host ""
Write-ColorOutput "🔍 驗證步驟:" "Yellow"
Write-ColorOutput "  1. 檢查端口 8449 是否在監聽:" "White"
Write-ColorOutput "     Get-NetTCPConnection -LocalPort 8449 -State Listen" "Gray"
Write-Host ""
Write-ColorOutput "  2. 測試本機連線:" "White"
Write-ColorOutput "     Test-NetConnection -ComputerName localhost -Port 8449" "Gray"
Write-Host ""
Write-ColorOutput "  3. 開啟瀏覽器訪問: $CoverityUrl" "White"
Write-ColorOutput "     Start-Process '$CoverityUrl'" "Gray"

Write-Host ""
Write-ColorOutput "📁 重要路徑:" "Yellow"
Write-ColorOutput "  Keystore: $keystorePath" "White"
Write-ColorOutput "  備份目錄: $backupDir" "White"

Write-Host ""
Write-ColorOutput "💡 提示:" "Yellow"
Write-ColorOutput "  - 憑證會在 Linux 伺服器上每天自動更新" "White"
Write-ColorOutput "  - 請定期執行此腳本以保持憑證最新" "White"
Write-ColorOutput "  - 可以將此腳本加入 Windows 排程工作自動執行" "White"

Write-Host ""