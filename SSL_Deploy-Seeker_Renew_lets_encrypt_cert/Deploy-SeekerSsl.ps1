# ===================================================================
# Seeker SSL 憑證部署腳本 (從 Samba 下載 Let's Encrypt 憑證)
# 用途: 從 Linux 伺服器的 Samba 共享下載憑證並部署到 Windows Seeker
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
    [string]$SambaSourcePath = "SSL_files\seeker_windows",
    
    [Parameter(Mandatory=$false)]
    [string]$SeekerCertPath = "C:\Seeker\data\server\conf\certs",
    
    [Parameter(Mandatory=$false)]
    [string]$SeekerNginxConf = "C:\Seeker\data\server\conf\nginx.conf",
    
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = "SeekerEnterpriseServer",
    
    [Parameter(Mandatory=$false)]
    [string]$SeekerUrl = "https://mydemo.idv.tw:8450",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipNginxConfig,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# ===================================================================
# 顏色輸出函數
# ===================================================================
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n[$(Get-Date -Format 'HH:mm:ss')] $Message" "Cyan"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "  ✓ $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "  ⚠ $Message" "Yellow"
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-ColorOutput "  ✗ $Message" "Red"
}

# ===================================================================
# 檢查管理員權限
# ===================================================================
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-ErrorMsg "此腳本需要管理員權限執行！"
    Write-ColorOutput "請以管理員身份執行 PowerShell" "Yellow"
    exit 1
}

# ===================================================================
# 顯示標題
# ===================================================================
Write-ColorOutput "`n=========================================" "Cyan"
Write-ColorOutput "    Seeker SSL 憑證部署腳本" "Cyan"
Write-ColorOutput "=========================================" "Cyan"
Write-ColorOutput "Samba 伺服器: \\$SambaServer\$SambaShare" "Yellow"
Write-ColorOutput "來源路徑: $SambaSourcePath" "Yellow"
Write-ColorOutput "目標路徑: $SeekerCertPath" "Yellow"
if ($DryRun) {
    Write-Warning "測試模式 (Dry Run) - 不會實際部署"
}
Write-ColorOutput ""

# ===================================================================
# 步驟 1: 連接到 Samba 共享
# ===================================================================
Write-Step "連接到 Samba 共享"

$sambaDrive = "Z:"
$sambaPath = "\\$SambaServer\$SambaShare"

# 檢查是否已經掛載
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
            throw "連接失敗: $result"
        }
    }
    catch {
        Write-ErrorMsg "無法連接到 Samba 共享: $_"
        Write-ColorOutput "`n請檢查:" "Yellow"
        Write-ColorOutput "  1. Samba 伺服器是否在線 (ping $SambaServer)" "White"
        Write-ColorOutput "  2. 使用者名稱和密碼是否正確" "White"
        Write-ColorOutput "  3. 網路防火牆設定" "White"
        exit 1
    }
}

# ===================================================================
# 步驟 2: 驗證來源憑證檔案
# ===================================================================
Write-Step "驗證來源憑證檔案"

$sourceFullchain = Join-Path $sambaDrive $SambaSourcePath "fullchain.pem"
$sourcePrivkey = Join-Path $sambaDrive $SambaSourcePath "privkey.pem"
$sourceReadme = Join-Path $sambaDrive $SambaSourcePath "README.txt"

# 檢查憑證檔案是否存在
if (-not (Test-Path $sourceFullchain)) {
    Write-ErrorMsg "找不到 fullchain.pem: $sourceFullchain"
    exit 1
}

if (-not (Test-Path $sourcePrivkey)) {
    Write-ErrorMsg "找不到 privkey.pem: $sourcePrivkey"
    exit 1
}

Write-Success "找到憑證檔案"
Write-ColorOutput "  - fullchain.pem: $((Get-Item $sourceFullchain).Length) bytes" "White"
Write-ColorOutput "  - privkey.pem: $((Get-Item $sourcePrivkey).Length) bytes" "White"

# 顯示 README 內容 (如果存在)
if (Test-Path $sourceReadme) {
    Write-ColorOutput "`n📄 README 內容:" "Cyan"
    Write-ColorOutput "$(('-' * 60))" "DarkGray"
    Get-Content $sourceReadme | Select-Object -First 20 | ForEach-Object {
        Write-ColorOutput "  $_" "Gray"
    }
    Write-ColorOutput "$(('-' * 60))" "DarkGray"
}

# ===================================================================
# 步驟 3: 停止 Seeker 服務
# ===================================================================
Write-Step "停止 Seeker 服務"

if ($DryRun) {
    Write-Warning "測試模式 - 跳過停止服務"
} else {
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        
        if ($service.Status -eq "Running") {
            Write-ColorOutput "  正在停止 $ServiceName..." "White"
            Stop-Service -Name $ServiceName -Force -ErrorAction Stop
            
            # 等待服務完全停止
            $timeout = 30
            $elapsed = 0
            while ((Get-Service -Name $ServiceName).Status -ne "Stopped" -and $elapsed -lt $timeout) {
                Start-Sleep -Seconds 1
                $elapsed++
            }
            
            if ((Get-Service -Name $ServiceName).Status -eq "Stopped") {
                Write-Success "服務已停止"
            } else {
                throw "服務停止超時"
            }
        } else {
            Write-Warning "服務已經是停止狀態"
        }
    }
    catch {
        Write-ErrorMsg "無法停止服務: $_"
        Write-ColorOutput "嘗試使用 taskkill 強制結束..." "Yellow"
        taskkill /F /FI "SERVICES eq $ServiceName" 2>$null
        Start-Sleep -Seconds 2
    }
}

# ===================================================================
# 步驟 4: 備份現有憑證
# ===================================================================
Write-Step "備份現有憑證"

$backupFolder = Join-Path $SeekerCertPath "backup"
$backupTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if (-not (Test-Path $SeekerCertPath)) {
    Write-Warning "憑證目錄不存在，將建立: $SeekerCertPath"
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $SeekerCertPath -Force | Out-Null
    }
}

if (-not (Test-Path $backupFolder)) {
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        Write-Success "建立備份目錄: $backupFolder"
    }
} else {
    Write-Success "備份目錄已存在"
}

# 備份現有憑證
$destFullchain = Join-Path $SeekerCertPath "fullchain.pem"
$destPrivkey = Join-Path $SeekerCertPath "privkey.pem"

if (Test-Path $destFullchain) {
    $backupFile = Join-Path $backupFolder "fullchain_$backupTimestamp.pem"
    if (-not $DryRun) {
        Copy-Item -Path $destFullchain -Destination $backupFile -Force
        Write-Success "已備份 fullchain.pem"
    } else {
        Write-Warning "測試模式 - 將備份 fullchain.pem 到 $backupFile"
    }
}

if (Test-Path $destPrivkey) {
    $backupFile = Join-Path $backupFolder "privkey_$backupTimestamp.pem"
    if (-not $DryRun) {
        Copy-Item -Path $destPrivkey -Destination $backupFile -Force
        Write-Success "已備份 privkey.pem"
    } else {
        Write-Warning "測試模式 - 將備份 privkey.pem 到 $backupFile"
    }
}

# ===================================================================
# 步驟 5: 部署新憑證
# ===================================================================
Write-Step "部署新憑證"

if ($DryRun) {
    Write-Warning "測試模式 - 跳過實際部署"
    Write-ColorOutput "  將複製:" "White"
    Write-ColorOutput "    $sourceFullchain" "Gray"
    Write-ColorOutput "    → $destFullchain" "Gray"
    Write-ColorOutput "    $sourcePrivkey" "Gray"
    Write-ColorOutput "    → $destPrivkey" "Gray"
} else {
    try {
        # 複製憑證檔案
        Copy-Item -Path $sourceFullchain -Destination $destFullchain -Force
        Copy-Item -Path $sourcePrivkey -Destination $destPrivkey -Force
        
        Write-Success "憑證檔案已部署"
        Write-ColorOutput "  - $destFullchain" "White"
        Write-ColorOutput "  - $destPrivkey" "White"
        
        # 設定檔案權限 (確保 Seeker 服務可以讀取)
        $acl = Get-Acl $destFullchain
        # 這裡可以添加特定的 ACL 設定,如果需要的話
        Write-Success "檔案權限已設定"
        
    }
    catch {
        Write-ErrorMsg "部署憑證失敗: $_"
        Write-ColorOutput "正在恢復備份..." "Yellow"
        
        # 嘗試恢復備份
        if (Test-Path (Join-Path $backupFolder "fullchain_$backupTimestamp.pem")) {
            Copy-Item -Path (Join-Path $backupFolder "fullchain_$backupTimestamp.pem") -Destination $destFullchain -Force
        }
        if (Test-Path (Join-Path $backupFolder "privkey_$backupTimestamp.pem")) {
            Copy-Item -Path (Join-Path $backupFolder "privkey_$backupTimestamp.pem") -Destination $destPrivkey -Force
        }
        
        exit 1
    }
}

# ===================================================================
# 步驟 6: 更新 NGINX 配置 (自動修正)
# ===================================================================
if (-not $SkipNginxConfig) {
    Write-Step "檢查並更新 NGINX 配置"
    
    if (-not (Test-Path $SeekerNginxConf)) {
        Write-Warning "找不到 nginx.conf: $SeekerNginxConf"
        Write-ColorOutput "  如果這是首次設定,請手動配置 nginx.conf" "Yellow"
    } else {
        # 讀取配置檔案
        $nginxContent = Get-Content $SeekerNginxConf -Raw
        $originalContent = $nginxContent
        $needUpdate = $false
        $changes = @()
        
        # 檢查 SSL 憑證路徑
        $expectedCertPath = ($destFullchain -replace '\\', '/').Replace('C:', 'C:')
        $expectedKeyPath = ($destPrivkey -replace '\\', '/').Replace('C:', 'C:')
        
        # 檢查 listen 端口 (只檢查,不修改)
        if ($nginxContent -match 'listen\s+(\d+)\s+ssl') {
            $currentPort = $matches[1]
            Write-ColorOutput "  目前端口: $currentPort" "White"
        }
        
        # 檢查並修正 ssl_certificate
        if ($nginxContent -match 'ssl_certificate\s+"?([^;"]+)"?;') {
            $currentCertPath = $matches[1]
            if ($currentCertPath -ne $expectedCertPath) {
                Write-Warning "檢測到憑證路徑需要更新"
                $changes += "憑證路徑: $currentCertPath → $expectedCertPath"
                $needUpdate = $true
            } else {
                Write-Success "ssl_certificate 路徑正確"
            }
        }
        
        # 檢查並修正 ssl_certificate_key
        if ($nginxContent -match 'ssl_certificate_key\s+"?([^;"]+)"?;') {
            $currentKeyPath = $matches[1]
            if ($currentKeyPath -ne $expectedKeyPath) {
                Write-Warning "檢測到私鑰路徑需要更新"
                $changes += "私鑰路徑: $currentKeyPath → $expectedKeyPath"
                $needUpdate = $true
            } else {
                Write-Success "ssl_certificate_key 路徑正確"
            }
        }
        
        # 如果需要更新配置
        if ($needUpdate -and -not $DryRun) {
            Write-ColorOutput "`n  將進行以下修改:" "Yellow"
            foreach ($change in $changes) {
                Write-ColorOutput "    - $change" "White"
            }
            
            # 備份 nginx.conf
            $nginxBackup = "$SeekerNginxConf.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item -Path $SeekerNginxConf -Destination $nginxBackup
            Write-ColorOutput "  已備份 nginx.conf 到: $nginxBackup" "Gray"
            
            # 修改配置 (只修改憑證路徑,不修改端口)
            $nginxContent = $nginxContent -replace 'ssl_certificate\s+"?[^;"]+\.pem"?;', "ssl_certificate `"$expectedCertPath`";"
            $nginxContent = $nginxContent -replace 'ssl_certificate_key\s+"?[^;"]+\.(pem|key)"?;', "ssl_certificate_key `"$expectedKeyPath`";"
            
            # 註解掉 ssl_password_file (Let's Encrypt 不需要密碼)
            $nginxContent = $nginxContent -replace '(?m)^\s*(ssl_password_file.*)$', '# $1'
            
            try {
                Set-Content -Path $SeekerNginxConf -Value $nginxContent -Encoding UTF8 -NoNewline
                Write-Success "nginx.conf 已更新"
                
                # 驗證 NGINX 配置語法
                $nginxExe = "C:\Seeker\install\nginx\nginx.exe"
                if (Test-Path $nginxExe) {
                    Write-ColorOutput "  驗證 NGINX 配置語法..." "White"
                    
                    # 切換到 NGINX 目錄執行測試,避免路徑問題
                    $originalPath = Get-Location
                    Set-Location (Split-Path $nginxExe)
                    
                    $testResult = & $nginxExe -t -c $SeekerNginxConf 2>&1 | Out-String
                    $testExitCode = $LASTEXITCODE
                    
                    Set-Location $originalPath
                    
                    # 檢查是否有真正的錯誤 (忽略 logs 目錄警告)
                    $hasError = $testResult -match '\[emerg\]' -and $testResult -notmatch 'logs/(error\.log|nginx\.pid)'
                    
                    if ($testExitCode -eq 0 -or ($testResult -match 'syntax is ok' -and -not $hasError)) {
                        Write-Success "NGINX 配置語法正確"
                    } else {
                        Write-ErrorMsg "NGINX 配置語法錯誤!"
                        Write-ColorOutput "  $testResult" "Red"
                        Write-ColorOutput "  正在恢復備份..." "Yellow"
                        Copy-Item -Path $nginxBackup -Destination $SeekerNginxConf -Force
                        throw "NGINX 配置驗證失敗"
                    }
                }
            }
            catch {
                Write-ErrorMsg "更新 nginx.conf 失敗: $_"
                exit 1
            }
        } elseif ($needUpdate -and $DryRun) {
            Write-Warning "測試模式 - 檢測到需要修改但未實際修改:"
            foreach ($change in $changes) {
                Write-ColorOutput "    - $change" "White"
            }
        } else {
            Write-Success "nginx.conf 配置正確,無需修改"
        }
    }
}

# ===================================================================
# 步驟 7: 啟動 Seeker 服務
# ===================================================================
Write-Step "啟動 Seeker 服務"

if ($DryRun) {
    Write-Warning "測試模式 - 跳過啟動服務"
} else {
    try {
        Write-ColorOutput "  正在啟動 $ServiceName..." "White"
        Start-Service -Name $ServiceName -ErrorAction Stop
        
        # 等待服務啟動
        $timeout = 60
        $elapsed = 0
        while ((Get-Service -Name $ServiceName).Status -ne "Running" -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
            if ($elapsed % 10 -eq 0) {
                Write-ColorOutput "  等待服務啟動... ($elapsed 秒)" "Gray"
            }
        }
        
        $service = Get-Service -Name $ServiceName
        if ($service.Status -eq "Running") {
            Write-Success "服務已啟動"
        } else {
            throw "服務啟動超時或失敗 (狀態: $($service.Status))"
        }
        
    }
    catch {
        Write-ErrorMsg "啟動服務失敗: $_"
        Write-ColorOutput "`n請檢查:" "Yellow"
        Write-ColorOutput "  1. Seeker 日誌檔案" "White"
        Write-ColorOutput "  2. nginx.conf 語法是否正確" "White"
        Write-ColorOutput "  3. 憑證檔案是否有效" "White"
        Write-ColorOutput "`n可以使用以下命令檢查日誌:" "Yellow"
        Write-ColorOutput "  Get-EventLog -LogName Application -Source Seeker -Newest 20" "Cyan"
        exit 1
    }
}

# ===================================================================
# 步驟 8: 驗證部署
# ===================================================================
Write-Step "驗證部署"

if ($DryRun) {
    Write-Warning "測試模式 - 跳過驗證"
} else {
    # 檢查服務狀態
    $service = Get-Service -Name $ServiceName
    Write-ColorOutput "  服務狀態: $($service.Status)" "White"
    
    # 檢查端口監聽
    Start-Sleep -Seconds 3
    $port = 8445
    $listening = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    
    if ($listening) {
        Write-Success "端口 $port 正在監聽"
    } else {
        Write-Warning "端口 $port 未檢測到監聽"
        Write-ColorOutput "  服務可能還在啟動中,請稍後再試" "Yellow"
    }
    
    # 驗證憑證有效期
    Write-ColorOutput "`n  憑證資訊:" "Cyan"
    try {
        # 使用 OpenSSL 檢查憑證 (如果有安裝)
        $opensslPath = "C:\Program Files\Git\usr\bin\openssl.exe"
        if (Test-Path $opensslPath) {
            $certInfo = & $opensslPath x509 -in $destFullchain -noout -dates 2>$null
            if ($certInfo) {
                $certInfo | ForEach-Object {
                    Write-ColorOutput "    $_" "White"
                }
            }
        } else {
            # 簡單顯示檔案資訊
            $fileInfo = Get-Item $destFullchain
            Write-ColorOutput "    最後修改時間: $($fileInfo.LastWriteTime)" "White"
            Write-ColorOutput "    檔案大小: $($fileInfo.Length) bytes" "White"
        }
    }
    catch {
        Write-ColorOutput "    無法檢查憑證詳細資訊" "Gray"
    }
}

# ===================================================================
# 步驟 9: 清理 (中斷 Samba 連接)
# ===================================================================
Write-Step "清理"

try {
    net use $sambaDrive /delete /y 2>$null | Out-Null
    Write-Success "已中斷 Samba 連接"
}
catch {
    Write-Warning "無法中斷 Samba 連接,可能已經斷開"
}

# ===================================================================
# 完成
# ===================================================================
Write-ColorOutput "`n=========================================" "Cyan"
Write-ColorOutput "         部署完成！" "Green"
Write-ColorOutput "=========================================" "Cyan"

if (-not $DryRun) {
    Write-ColorOutput "`n📋 部署摘要:" "Yellow"
    Write-ColorOutput "  ✓ 憑證已從 Samba 下載" "Green"
    Write-ColorOutput "  ✓ 舊憑證已備份" "Green"
    Write-ColorOutput "  ✓ 新憑證已部署到 $SeekerCertPath" "Green"
    Write-ColorOutput "  ✓ nginx.conf 已檢查並更新 (如有需要)" "Green"
    Write-ColorOutput "  ✓ Seeker 服務已重啟" "Green"
    
    # 取得實際的端口號
    $nginxContent = Get-Content $SeekerNginxConf -Raw
    if ($nginxContent -match 'listen\s+(\d+)\s+ssl') {
        $actualPort = $matches[1]
    } else {
        $actualPort = "8450"
    }
    
    Write-ColorOutput "`n🔍 驗證步驟:" "Yellow"
    Write-ColorOutput "  1. 檢查端口 $actualPort 是否在監聽:" "White"
    Write-ColorOutput "     Get-NetTCPConnection -LocalPort $actualPort -State Listen" "Cyan"
    
    Write-ColorOutput "`n  2. 測試本機連線:" "White"
    Write-ColorOutput "     Test-NetConnection -ComputerName localhost -Port $actualPort" "Cyan"
    
    Write-ColorOutput "`n  3. 開啟瀏覽器訪問: https://mydemo.idv.tw:$actualPort" "White"
    Write-ColorOutput "     Start-Process 'https://mydemo.idv.tw:$actualPort'" "Cyan"
    
    Write-ColorOutput "`n📁 重要路徑:" "Yellow"
    Write-ColorOutput "  憑證目錄: $SeekerCertPath" "White"
    Write-ColorOutput "  備份目錄: $backupFolder" "White"
    Write-ColorOutput "  NGINX 配置: $SeekerNginxConf" "White"
    
    Write-ColorOutput "`n⚙️  NGINX 配置重點:" "Yellow"
    Write-ColorOutput "  listen $actualPort ssl;" "Cyan"
    Write-ColorOutput "  ssl_certificate `"C:/Seeker/data/server/conf/certs/fullchain.pem`";" "Cyan"
    Write-ColorOutput "  ssl_certificate_key `"C:/Seeker/data/server/conf/certs/privkey.pem`";" "Cyan"
    
    Write-ColorOutput "`n⚠️  重要提醒:" "Yellow"
    Write-ColorOutput "  1. 確保路由器端口轉發設定為: $actualPort → 192.168.31.6:$actualPort" "White"
    Write-ColorOutput "  2. 在 Seeker Web UI 的 Settings > Server URL 更新為: https://mydemo.idv.tw:$actualPort" "White"
    Write-ColorOutput "  3. 確保防火牆允許端口 $actualPort" "White"
    
    Write-ColorOutput "`n🔧 快速診斷命令:" "Yellow"
    Write-ColorOutput "  # 檢查服務狀態" "Cyan"
    Write-ColorOutput "  Get-Service $ServiceName" "Gray"
    Write-ColorOutput "`n  # 檢查端口監聽" "Cyan"
    Write-ColorOutput "  Get-NetTCPConnection -LocalPort $actualPort" "Gray"
    Write-ColorOutput "`n  # 完整診斷" "Cyan"
    Write-ColorOutput "  .\Diagnose-Seeker.ps1 -Port $actualPort" "Gray"
    
} else {
    Write-ColorOutput "`n✓ 測試模式完成 - 所有檢查通過" "Green"
    Write-ColorOutput "  執行時不加 -DryRun 參數即可實際部署" "White"
}

Write-ColorOutput "`n💡 提示:" "Yellow"
Write-ColorOutput "  - 憑證會在 Linux 伺服器上每天自動更新" "White"
Write-ColorOutput "  - 請定期執行此腳本以保持憑證最新" "White"
Write-ColorOutput "  - 可以將此腳本加入 Windows 排程工作自動執行" "White"
Write-ColorOutput "`n"

# 返回成功代碼
exit 0