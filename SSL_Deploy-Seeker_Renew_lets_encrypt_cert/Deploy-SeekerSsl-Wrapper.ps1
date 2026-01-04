# Seeker SSL 自動部署包裝腳本
$ErrorActionPreference = "Continue"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\logs\deploy_$timestamp.log"

# 記錄開始
"====================================" | Out-File $logFile -Encoding UTF8
"Seeker SSL 自動部署" | Out-File $logFile -Append -Encoding UTF8
"時間: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $logFile -Append -Encoding UTF8
"====================================" | Out-File $logFile -Append -Encoding UTF8
"" | Out-File $logFile -Append -Encoding UTF8

try {
    Set-Location "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert"
    
    # 讀取密碼
    . "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\samba-config.ps1"
    $password = $Global:SambaCredentials.Password
    
    if ($password) {
        "✓ 已載入認證" | Out-File $logFile -Append -Encoding UTF8
        $output = & "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\Deploy-SeekerSsl.ps1" -SambaPassword $password 2>&1
    } else {
        "✗ 找不到密碼" | Out-File $logFile -Append -Encoding UTF8
        exit 1
    }
    
    $output | Out-File $logFile -Append -Encoding UTF8
    
    "" | Out-File $logFile -Append -Encoding UTF8
    "====================================" | Out-File $logFile -Append -Encoding UTF8
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        "✓ 部署成功" | Out-File $logFile -Append -Encoding UTF8
        exit 0
    } else {
        "✗ 部署失敗 (代碼: $LASTEXITCODE)" | Out-File $logFile -Append -Encoding UTF8
        exit $LASTEXITCODE
    }
}
catch {
    "" | Out-File $logFile -Append -Encoding UTF8
    "✗ 錯誤: $_" | Out-File $logFile -Append -Encoding UTF8
    exit 1
}
