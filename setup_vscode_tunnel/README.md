# VS Code Tunnel 設定說明與故障排除

## 目錄
- [系統資訊](#系統資訊)
- [Ubuntu 管理](#ubuntu-管理)
- [Windows 管理](#windows-管理)
- [常見問題排除](#常見問題排除)
- [重新安裝指南](#重新安裝指南)

---

## 系統資訊

### Ubuntu Server
- **機器名稱**: `allenl-2404`
- **Tunnel URL**: `https://vscode.dev/tunnel/allenl-2404`
- **安裝位置**: `/home/allenl/vscode_remote_tunnel/`
- **服務方式**: systemd service

### Windows
- **機器名稱**: `allenl-windows`
- **Tunnel URL**: `https://vscode.dev/tunnel/allenl-windows`
- **安裝位置**: `D:\vscode_tunnel\`
- **服務方式**: NSSM (使用者帳號: `LIAN1112\yulia`)

---

## Ubuntu 管理

### 基本指令

```bash
# 查看服務狀態
sudo systemctl status code-tunnel

# 啟動服務
sudo systemctl start code-tunnel

# 停止服務
sudo systemctl stop code-tunnel

# 重啟服務
sudo systemctl restart code-tunnel

# 查看日誌 (最近 50 行)
sudo journalctl -u code-tunnel -n 50

# 查看即時日誌
sudo journalctl -u code-tunnel -f

# 停用開機自動啟動
sudo systemctl disable code-tunnel

# 啟用開機自動啟動
sudo systemctl enable code-tunnel
```

### 常見問題

#### 問題 1: 服務無法啟動

```bash
# 1. 檢查服務狀態
sudo systemctl status code-tunnel

# 2. 查看詳細日誌
sudo journalctl -u code-tunnel -n 100

# 3. 手動測試
cd /home/allenl/vscode_remote_tunnel
./code tunnel --name allenl-2404 --accept-server-license-terms

# 4. 如果手動正常,重啟服務
sudo systemctl restart code-tunnel
```

#### 問題 2: 認證過期

```bash
# 1. 停止服務
sudo systemctl stop code-tunnel

# 2. 刪除舊認證
rm -rf ~/.vscode/cli

# 3. 手動執行重新認證
cd /home/allenl/vscode_remote_tunnel
./code tunnel --name allenl-2404 --accept-server-license-terms
# 完成 GitHub 認證後按 Ctrl+C

# 4. 重啟服務
sudo systemctl start code-tunnel
```

#### 問題 3: 網路連接問題

```bash
# 測試網路連接
ping -c 3 vscode.dev
curl -I https://vscode.dev

# 檢查 DNS
nslookup vscode.dev

# 重啟網路服務
sudo systemctl restart NetworkManager
```

---

## Windows 管理

### 基本指令

```powershell
# 查看服務狀態
nssm status VSCodeTunnel

# 啟動服務
nssm start VSCodeTunnel

# 停止服務
nssm stop VSCodeTunnel

# 重啟服務
nssm restart VSCodeTunnel

# 查看日誌
Get-Content "D:\vscode_tunnel\stdout.log" -Tail 50

# 即時監控日誌
Get-Content "D:\vscode_tunnel\stdout.log" -Wait

# 檢查進程
Get-Process -Name "code" -ErrorAction SilentlyContinue

# 開啟 GUI 設定
nssm edit VSCodeTunnel
```

### 常見問題

#### 問題 1: 服務無法啟動

```powershell
# 1. 檢查服務狀態
nssm status VSCodeTunnel
Get-Service VSCodeTunnel

# 2. 查看日誌
Get-Content "D:\vscode_tunnel\stdout.log" -Tail 30
Get-Content "D:\vscode_tunnel\stderr.log" -Tail 30

# 3. 手動測試
Stop-Process -Name "code" -Force -ErrorAction SilentlyContinue
cd D:\vscode_tunnel
.\code.exe tunnel --name allenl-windows --accept-server-license-terms

# 4. 如果手動正常,重啟服務
nssm restart VSCodeTunnel
```

#### 問題 2: 登入失敗 (Logon Failure)

```powershell
# 密碼可能錯誤或過期,重新設定

# 方法 1: 用 GUI 設定 (最簡單)
nssm edit VSCodeTunnel
# 在 "Log on" 標籤重新輸入密碼

# 方法 2: 用指令設定
$username = "LIAN1112\yulia"
$password = Read-Host -AsSecureString "請輸入密碼"
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
nssm set VSCodeTunnel ObjectName "$username" "$passwordPlain"
nssm restart VSCodeTunnel
```

#### 問題 3: 認證過期

```powershell
# 1. 停止服務
nssm stop VSCodeTunnel

# 2. 刪除舊認證
Remove-Item -Path "$env:USERPROFILE\.vscode\cli" -Recurse -Force

# 3. 手動執行重新認證
cd D:\vscode_tunnel
.\code.exe tunnel --name allenl-windows --accept-server-license-terms
# 完成 GitHub 認證後按 Ctrl+C

# 4. 重啟服務
nssm start VSCodeTunnel
```

#### 問題 4: 開機後無法自動啟動

```powershell
# 1. 檢查服務啟動類型
Get-Service VSCodeTunnel | Select-Object Name, Status, StartType

# 2. 確認是延遲啟動
nssm set VSCodeTunnel Start SERVICE_DELAYED_AUTO_START

# 3. 檢查帳號權限
# 開啟 GUI 確認 Log on 設定
nssm edit VSCodeTunnel

# 4. 查看 Windows 事件日誌
Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Service Control Manager'} -MaxEvents 10 | Where-Object {$_.Message -like "*VSCodeTunnel*"}
```

#### 問題 5: 網路連接問題

```powershell
# 測試網路連接
Test-NetConnection -ComputerName vscode.dev -Port 443
Test-NetConnection -ComputerName global.rel.tunnels.api.visualstudio.com -Port 443

# 檢查防火牆規則
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*VS Code*"}

# 重新新增防火牆規則
New-NetFirewallRule -DisplayName "VS Code Tunnel" -Direction Inbound -Program "D:\vscode_tunnel\code.exe" -Action Allow -Force
New-NetFirewallRule -DisplayName "VS Code Tunnel" -Direction Outbound -Program "D:\vscode_tunnel\code.exe" -Action Allow -Force
```

---

## 常見問題排除

### 問題: 無法連接到 Tunnel

#### 症狀
- 瀏覽器顯示 "Fatal Error"
- 本地 VS Code 無法連接

#### 診斷步驟

**Ubuntu**:
```bash
# 1. 確認服務運行
sudo systemctl status code-tunnel

# 2. 檢查網路
ping -c 3 vscode.dev

# 3. 手動測試
cd /home/allenl/vscode_remote_tunnel
./code tunnel --name allenl-2404 --accept-server-license-terms
```

**Windows**:
```powershell
# 1. 確認服務運行
nssm status VSCodeTunnel
Get-Process -Name "code" -ErrorAction SilentlyContinue

# 2. 檢查網路
Test-NetConnection -ComputerName vscode.dev -Port 443

# 3. 手動測試
cd D:\vscode_tunnel
.\code.exe tunnel --name allenl-windows --accept-server-license-terms
```

#### 解決方案

1. **服務未運行** → 啟動服務
2. **網路問題** → 檢查防火牆/路由器設定
3. **認證過期** → 重新認證 (見上方認證過期處理)
4. **VS Code Server 未下載完成** → 手動執行等待下載完成

---

### 問題: GitHub 認證失效

#### 症狀
- 手動執行要求重新登入
- 服務啟動但無法連接

#### 解決方案

**通用步驟**:
1. 停止服務
2. 刪除認證目錄 (`~/.vscode/cli`)
3. 手動執行 Tunnel 完成認證
4. 重啟服務

**何時需要重新認證**:
- Token 過期 (通常幾個月後)
- 在 GitHub 撤銷授權
- 清除系統檔案時誤刪
- 更改 GitHub 密碼

**管理 GitHub 授權**:
訪問 https://github.com/settings/applications 查看和管理授權

---

### 問題: 重開機後服務未啟動

#### Windows 特有問題

**原因 1: 網路未就緒**
```powershell
# 增加啟動延遲
nssm set VSCodeTunnel Start SERVICE_DELAYED_AUTO_START
```

**原因 2: 密碼錯誤**
```powershell
# 重新設定密碼
nssm edit VSCodeTunnel
# 在 GUI 中更新密碼
```

**原因 3: 使用者設定檔未載入**
```powershell
# 確認環境變數設定
nssm set VSCodeTunnel AppEnvironmentExtra "HOME=$env:USERPROFILE" "USERPROFILE=$env:USERPROFILE" "LOCALAPPDATA=$env:LOCALAPPDATA"
```

#### Ubuntu 特有問題

**原因: 網路服務未就緒**
```bash
# 編輯服務檔案
sudo nano /etc/systemd/system/code-tunnel.service

# 修改 [Unit] 區段
[Unit]
Description=VS Code Tunnel
After=network-online.target
Wants=network-online.target

# 重新載入並重啟
sudo systemctl daemon-reload
sudo systemctl restart code-tunnel
```

---

## 重新安裝指南

### Ubuntu 完整重新安裝

```bash
# 1. 停止並移除舊服務
sudo systemctl stop code-tunnel
sudo systemctl disable code-tunnel
sudo rm /etc/systemd/system/code-tunnel.service
sudo systemctl daemon-reload

# 2. 清除舊檔案
rm -rf ~/vscode_remote_tunnel
rm -rf ~/.vscode/cli

# 3. 下載並安裝
mkdir -p ~/vscode_remote_tunnel
cd ~/vscode_remote_tunnel
wget https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-x64 -O vscode_cli.tar.gz
tar -xzf vscode_cli.tar.gz
rm vscode_cli.tar.gz

# 4. 首次認證
./code tunnel --name allenl-2404 --accept-server-license-terms
# 完成認證後按 Ctrl+C

# 5. 建立服務檔案
sudo nano /etc/systemd/system/code-tunnel.service
```

貼上以下內容:
```ini
[Unit]
Description=VS Code Tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=allenl
ExecStart=/home/allenl/vscode_remote_tunnel/code tunnel --name allenl-2404 --accept-server-license-terms
Restart=always
RestartSec=10
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
```

```bash
# 6. 啟用並啟動服務
sudo systemctl daemon-reload
sudo systemctl enable code-tunnel
sudo systemctl start code-tunnel

# 7. 驗證
sudo systemctl status code-tunnel
```

### Windows 完整重新安裝

```powershell
# 以系統管理員執行 PowerShell

# 1. 停止並移除舊服務
nssm stop VSCodeTunnel 2>$null
nssm remove VSCodeTunnel confirm 2>$null

# 2. 清除舊檔案
Remove-Item -Path "D:\vscode_tunnel" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\.vscode\cli" -Recurse -Force -ErrorAction SilentlyContinue

# 3. 下載並安裝
New-Item -ItemType Directory -Path "D:\vscode_tunnel" -Force
$url = "https://code.visualstudio.com/sha/download?build=stable&os=cli-win32-x64"
Invoke-WebRequest -Uri $url -OutFile "D:\vscode_tunnel\vscode_cli.zip" -UseBasicParsing
Expand-Archive -Path "D:\vscode_tunnel\vscode_cli.zip" -DestinationPath "D:\vscode_tunnel" -Force
Remove-Item "D:\vscode_tunnel\vscode_cli.zip"

# 4. 確認 NSSM 已安裝
if (-not (Test-Path "C:\Windows\System32\nssm.exe")) {
    Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile "$env:TEMP\nssm.zip" -UseBasicParsing
    Expand-Archive -Path "$env:TEMP\nssm.zip" -DestinationPath "$env:TEMP" -Force
    Copy-Item "$env:TEMP\nssm-2.24\win64\nssm.exe" "C:\Windows\System32\" -Force
}

# 5. 首次認證
cd D:\vscode_tunnel
.\code.exe tunnel --name allenl-windows --accept-server-license-terms
# 完成認證後按 Ctrl+C

# 6. 安裝 NSSM 服務
nssm install VSCodeTunnel "D:\vscode_tunnel\code.exe" "tunnel --name allenl-windows --accept-server-license-terms"
nssm set VSCodeTunnel Description "VS Code Remote Tunnel Service"
nssm set VSCodeTunnel AppDirectory "D:\vscode_tunnel"
nssm set VSCodeTunnel Start SERVICE_DELAYED_AUTO_START
nssm set VSCodeTunnel AppExit Default Restart
nssm set VSCodeTunnel AppEnvironmentExtra "HOME=$env:USERPROFILE" "USERPROFILE=$env:USERPROFILE" "LOCALAPPDATA=$env:LOCALAPPDATA"
nssm set VSCodeTunnel AppStdout "D:\vscode_tunnel\stdout.log"
nssm set VSCodeTunnel AppStderr "D:\vscode_tunnel\stderr.log"

# 7. 設定帳號密碼
$username = "LIAN1112\yulia"
Write-Host "請輸入 Windows 登入密碼:" -ForegroundColor Yellow
$password = Read-Host -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
nssm set VSCodeTunnel ObjectName "$username" "$passwordPlain"

# 8. 啟動服務
nssm start VSCodeTunnel
Start-Sleep -Seconds 20

# 9. 驗證
nssm status VSCodeTunnel
Get-Process -Name "code" -ErrorAction SilentlyContinue
```

---

## 測試連接

### 瀏覽器測試
- Ubuntu: `https://vscode.dev/tunnel/allenl-2404`
- Windows: `https://vscode.dev/tunnel/allenl-windows`

### 本地 VS Code 測試
1. 點擊左下角綠色 `><` 按鈕
2. 選擇 "Connect to Tunnel..."
3. 用 GitHub 帳號登入 (如果需要)
4. 選擇 `allenl-2404` 或 `allenl-windows`

---

## 日誌位置

### Ubuntu
```bash
# systemd 日誌
sudo journalctl -u code-tunnel

# VS Code Server 日誌
~/.vscode/cli/servers/Stable-*/log.txt
```

### Windows
```
D:\vscode_tunnel\stdout.log    # 標準輸出
D:\vscode_tunnel\stderr.log    # 錯誤輸出
```

---

## 檔案位置

### Ubuntu
```
/home/allenl/vscode_remote_tunnel/code    # VS Code CLI
/home/allenl/.vscode/cli/                  # 認證和快取
/etc/systemd/system/code-tunnel.service   # 服務檔案
```

### Windows
```
D:\vscode_tunnel\code.exe                  # VS Code CLI
C:\Users\yulia\.vscode\cli\                # 認證和快取
C:\Windows\System32\nssm.exe               # NSSM 工具
```

---

## 效能監控

### Ubuntu
```bash
# 查看資源使用
ps aux | grep code
top -p $(pgrep code)

# 查看網路連接
ss -tunlp | grep code
```

### Windows
```powershell
# 查看資源使用
Get-Process -Name "code" | Format-Table Id, CPU, WorkingSet

# 查看網路連接
Get-NetTCPConnection | Where-Object {$_.OwningProcess -eq (Get-Process -Name "code").Id}
```

---

## 安全注意事項

1. **GitHub Token 管理**
   - 定期檢查授權: https://github.com/settings/applications
   - 撤銷不需要的授權

2. **密碼安全 (Windows)**
   - 使用強密碼
   - 定期更新密碼
   - 密碼變更後記得更新服務設定

3. **防火牆設定**
   - 只開放必要的連接
   - 定期檢查防火牆規則

4. **日誌檢查**
   - 定期檢查日誌是否有異常連接
   - 監控資源使用情況

---

## 聯絡資訊

- VS Code Tunnel 文件: https://code.visualstudio.com/docs/remote/tunnels
- Anthropic 文件: https://docs.anthropic.com
- GitHub Support: https://support.github.com

---

**文件版本**: 1.0
**最後更新**: 2025-10-30
**作者**: Allen