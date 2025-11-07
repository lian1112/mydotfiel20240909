# Seeker SSL 自動更新系統

Windows 端自動從 Linux 伺服器同步 Let's Encrypt 憑證並部署到 Synopsys Seeker

---

## 📋 目錄

1. [系統架構](#系統架構)
2. [為什麼需要這個系統](#為什麼需要這個系統)
3. [自動化流程](#自動化流程)
4. [初次設定](#初次設定)
5. [檔案說明](#檔案說明)
6. [維護和管理](#維護和管理)
7. [故障排除](#故障排除)

---

## 系統架構

### 整體流程

```
Linux 伺服器 (allenl-2404)
   ├─ Let's Encrypt 憑證 (每 90 天自動續約)
   ├─ 自動複製到 Samba 共享: /home/allenl/SSL_files/seeker_windows/
   │  ├── fullchain.pem
   │  ├── privkey.pem
   │  └── README.txt
   └─ Samba 共享: \\192.168.31.5\allenl_home

            ⬇ (透過 Samba)

Windows 機器 (192.168.31.6)
   ├─ 每月 1 號凌晨 3:00 自動執行
   ├─ 從 Samba 下載憑證
   ├─ 停止 Seeker 服務
   ├─ 備份舊憑證
   ├─ 部署新憑證
   ├─ 更新 nginx.conf (如需要)
   └─ 重啟 Seeker 服務

Seeker Enterprise Server
   └─ HTTPS 服務: https://mydemo.idv.tw:8450
```

### Seeker 憑證位置

```
C:\Seeker\data\server\conf\
├── certs\
│   ├── fullchain.pem          # 完整憑證鏈 (網域 + 中繼 CA)
│   ├── privkey.pem            # 私鑰
│   └── backup\                # 自動備份目錄
│       ├── fullchain.pem.backup.20251029_134730
│       └── privkey.pem.backup.20251029_134730
└── nginx.conf                 # NGINX 配置
```

---

## 為什麼需要這個系統

### 問題

1. **Let's Encrypt 憑證 90 天到期** - 需要定期更新
2. **Seeker 在 Windows** - 無法直接使用 Linux 的 Certbot
3. **手動更新容易忘記** - 導致憑證過期服務中斷
4. **Seeker 使用 NGINX** - 需要 PEM 格式憑證 (不是 JKS)

### 解決方案

- ✅ **Linux 端**: Certbot 每天檢查,到期前 30 天自動續約
- ✅ **自動同步**: 憑證續約後自動複製到 Samba 共享
- ✅ **Windows 端**: 排程工作每月自動下載並部署
- ✅ **零停機部署**: 自動備份、停止服務、更新憑證、重啟服務

---

## 自動化流程

### 完整時間軸

```
Day 0: Linux 端 Let's Encrypt 憑證申請
   ↓
Day 60: Certbot 開始嘗試續約
   ↓
續約成功 (Linux 自動)
   ├─ 執行 hook 腳本: /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh
   ├─ 自動複製到 Samba 共享: /home/allenl/SSL_files/seeker_windows/
   └─ 更新 README.txt (含憑證有效期資訊)
   ↓
每月 1 號凌晨 3:00 (Windows 排程工作)
   ├─ 執行 Deploy-SeekerSsl-Wrapper.ps1
   ├─ 讀取 samba-config.ps1 (密碼)
   └─ 執行 Deploy-SeekerSsl.ps1 -SambaPassword "****"
       ├─ 連接 Samba 共享
       ├─ 下載最新憑證
       ├─ 停止 Seeker 服務
       ├─ 備份舊憑證
       ├─ 部署新憑證
       ├─ 檢查 nginx.conf 設定
       ├─ 重啟 Seeker 服務
       └─ 記錄日誌到 logs/deploy_YYYYMMDD_HHMMSS.log
   ↓
服務恢復正常
```

### 自動執行頻率

| 項目 | 頻率 | 說明 |
|------|------|------|
| Linux 憑證續約檢查 | 每天 2 次 | Certbot systemd timer |
| Linux 實際續約 | 到期前 30 天 | 約每 90 天一次 |
| Windows 同步更新 | 每月 1 號 3:00 | Windows 排程工作 |

---

## 初次設定

### 前置需求

1. ✅ **Linux 端已設定 Let's Encrypt**
   - 憑證路徑: `/etc/letsencrypt/live/mydemo.idv.tw/`
   - Hook 腳本已設定並複製到 Samba

2. ✅ **Samba 共享可訪問**
   - 路徑: `\\192.168.31.5\allenl_home\SSL_files\seeker_windows\`
   - 使用者: `allenl`
   - 密碼: 已知

3. ✅ **Windows 管理員權限**
   - 需要建立排程工作
   - 需要重啟 Seeker 服務

### 一鍵設定步驟

**1. 準備檔案**

確保這 3 個檔案在同一目錄:

```
D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\
├── Deploy-SeekerSsl.ps1       # 主腳本 (從 Linux 下載並部署)
├── samba-config.ps1           # Samba 認證配置
└── Setup-AutoRenew.ps1        # 一鍵設定腳本
```

**2. 設定 Samba 密碼**

編輯 `samba-config.ps1`:

```powershell
# ===================================================================
# Samba 認證配置
# ===================================================================

$SambaServer = "192.168.31.5"
$SambaShare = "allenl_home"
$SambaUser = "allenl"
$SambaPassword = "YOUR_PASSWORD_HERE"  # ← 修改這裡

$Global:SambaCredentials = @{
    Server = $SambaServer
    Share = $SambaShare
    User = $SambaUser
    Password = $SambaPassword
}
```

**3. 執行設定**

以**管理員身分**執行 PowerShell:

```powershell
# 切換到腳本目錄
cd D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert

# 執行一鍵設定
.\Setup-AutoRenew.ps1
```

**4. 驗證結果**

設定成功後會顯示:

```
═══════════════════════════════════════════
  ✓ 設定完成！
═══════════════════════════════════════════

排程資訊:
  任務名稱: Seeker-SSL-Auto-Renew
  執行時間: 每月 1 號 3:00
  下次執行: 2025-11-01 03:00:00

✓ 測試執行成功
```

---

## 檔案說明

### 核心檔案 (需要維護的)

#### 1. Deploy-SeekerSsl.ps1

**主要功能:**
- 從 Samba 下載 Let's Encrypt 憑證
- 自動停止/啟動 Seeker 服務
- 備份舊憑證
- 部署新憑證
- 更新 nginx.conf (如果路徑錯誤)
- 驗證部署結果

**關鍵參數:**

```powershell
param(
    [string]$SambaServer = "192.168.31.5",      # Samba 伺服器
    [string]$SambaShare = "allenl_home",        # 共享名稱
    [string]$SambaUser = "allenl",              # 使用者
    [string]$SambaPassword = "",                # 密碼 (從配置檔讀取)
    [string]$SambaSourcePath = "SSL_files\seeker_windows",  # 來源路徑
    [string]$SeekerCertPath = "C:\Seeker\data\server\conf\certs",  # 目標路徑
    [string]$ServiceName = "SeekerEnterpriseServer",  # 服務名稱
    [string]$SeekerUrl = "https://mydemo.idv.tw:8450"  # Seeker URL
)
```

**執行流程:**

```
[1] 連接 Samba 共享
[2] 驗證來源憑證
[3] 停止 Seeker 服務
[4] 備份現有憑證
[5] 部署新憑證
[6] 檢查 nginx.conf
[7] 啟動 Seeker 服務
[8] 驗證部署
[9] 清理 Samba 連接
```

#### 2. samba-config.ps1

**用途:** 儲存 Samba 認證資訊

**安全性:**
- 檔案權限已設定為只有 SYSTEM 和 Administrators 可讀取
- 包含明文密碼,請勿分享或提交到版本控制

**內容:**

```powershell
$SambaServer = "192.168.31.5"
$SambaShare = "allenl_home"
$SambaUser = "allenl"
$SambaPassword = "ffff"  # ← 實際密碼

$Global:SambaCredentials = @{
    Server = $SambaServer
    Share = $SambaShare
    User = $SambaUser
    Password = $SambaPassword
}
```

#### 3. Setup-AutoRenew.ps1

**用途:** 一鍵設定自動更新系統

**功能:**
1. 檢查必要檔案
2. 驗證 Deploy-SeekerSsl.ps1 支援密碼參數
3. 建立包裝腳本 (Deploy-SeekerSsl-Wrapper.ps1)
4. 建立 Windows 排程工作
5. 執行測試部署
6. 顯示結果和管理命令

### 自動生成檔案 (不需要維護)

#### Deploy-SeekerSsl-Wrapper.ps1

**用途:** 包裝腳本,由排程工作執行

**功能:**
- 自動讀取 samba-config.ps1
- 傳遞密碼給 Deploy-SeekerSsl.ps1
- 記錄完整執行日誌
- 處理錯誤和退出碼

**重要:** 此檔案由 Setup-AutoRenew.ps1 自動生成,不要手動編輯

#### 日誌檔案

**位置:** `logs\deploy_YYYYMMDD_HHMMSS.log`

**內容範例:**

```
====================================
Seeker SSL 自動部署
時間: 2025-10-29 13:47:30
====================================

✓ 已載入認證

[部署過程的完整輸出...]

====================================
✓ 部署成功
====================================
```

---

## 維護和管理

### 常用管理命令

#### 手動執行更新

```powershell
# 方法 1: 觸發排程工作
Start-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew"

# 方法 2: 直接執行腳本
.\Deploy-SeekerSsl.ps1
```

#### 查看排程工作狀態

```powershell
# 查看排程工作資訊
Get-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew" | Format-List *

# 查看執行歷史
Get-ScheduledTaskInfo -TaskName "Seeker-SSL-Auto-Renew"

# 查看下次執行時間
$task = Get-ScheduledTaskInfo -TaskName "Seeker-SSL-Auto-Renew"
$task.NextRunTime
```

#### 查看日誌

```powershell
# 查看最新日誌
Get-ChildItem "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\logs" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1 | 
    Get-Content

# 查看日誌最後 30 行
Get-ChildItem "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\logs" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1 | 
    Get-Content -Tail 30

# 打開日誌目錄
explorer "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\logs"
```

#### 停用/啟用排程工作

```powershell
# 停用
Disable-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew"

# 啟用
Enable-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew"
```

#### 刪除排程工作

```powershell
# 刪除
Unregister-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew" -Confirm:$false

# 重新建立
.\Setup-AutoRenew.ps1
```

### 修改執行時間

**重新執行設定腳本並指定參數:**

```powershell
# 每月 15 號凌晨 2:30 執行
.\Setup-AutoRenew.ps1 -DayOfMonth 15 -Hour 2 -Minute 30

# 每月 1 號中午 12:00 執行
.\Setup-AutoRenew.ps1 -DayOfMonth 1 -Hour 12 -Minute 0
```

### 修改 Samba 密碼

**如果 Samba 密碼變更:**

```powershell
# 1. 編輯配置檔
notepad "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\samba-config.ps1"

# 2. 修改 $SambaPassword

# 3. 重新建立排程工作 (會更新包裝腳本)
.\Setup-AutoRenew.ps1
```

---

## 故障排除

### 1. 排程工作執行失敗

**症狀:**
- 排程工作退出碼不是 0
- 沒有產生新的日誌檔案

**排查步驟:**

```powershell
# 1. 查看排程工作狀態
Get-ScheduledTaskInfo -TaskName "Seeker-SSL-Auto-Renew"

# 2. 手動執行包裝腳本
& "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\Deploy-SeekerSsl-Wrapper.ps1"

# 3. 查看日誌
Get-ChildItem "logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content

# 4. 測試 Samba 連線
Test-Path "\\192.168.31.5\allenl_home\SSL_files\seeker_windows\"
```

**常見問題:**

**問題 1: Samba 連線失敗**

```powershell
# 測試 SMB 連線
Test-NetConnection -ComputerName 192.168.31.5 -Port 445

# 手動連線測試
net use Z: \\192.168.31.5\allenl_home /user:allenl
```

**問題 2: 密碼錯誤**

```powershell
# 檢查配置檔
Get-Content "samba-config.ps1"

# 確認密碼正確後,重新設定
.\Setup-AutoRenew.ps1
```

**問題 3: Seeker 服務無法停止/啟動**

```powershell
# 檢查服務狀態
Get-Service SeekerEnterpriseServer

# 手動停止
Stop-Service SeekerEnterpriseServer -Force

# 手動啟動
Start-Service SeekerEnterpriseServer
```

---

### 2. 憑證部署後仍顯示舊憑證

**症狀:**
瀏覽器訪問 https://mydemo.idv.tw:8450 仍顯示舊的到期日

**排查步驟:**

```powershell
# 1. 檢查憑證檔案內容
openssl x509 -in "C:\Seeker\data\server\conf\certs\fullchain.pem" -text -noout | Select-String "Not After"

# 2. 檢查 nginx.conf 路徑
Select-String -Path "C:\Seeker\data\server\conf\nginx.conf" -Pattern "ssl_certificate"

# 3. 檢查 Seeker 服務是否真的重啟了
Get-Service SeekerEnterpriseServer | Select-Object Status,StartType

# 4. 檢查端口
Get-NetTCPConnection -LocalPort 8450
```

**解決方法:**

```powershell
# 強制重啟 Seeker
Stop-Service SeekerEnterpriseServer -Force
Start-Sleep -Seconds 10
Start-Service SeekerEnterpriseServer

# 清除瀏覽器快取並重新載入
Start-Process "https://mydemo.idv.tw:8450"
```

---

### 3. Linux 端憑證沒有更新到 Samba

**症狀:**
Samba 共享中的憑證日期過舊

**排查步驟 (Linux):**

```bash
# 1. 檢查 Let's Encrypt 憑證
sudo ls -lh /etc/letsencrypt/live/mydemo.idv.tw/

# 2. 檢查憑證到期日
sudo openssl x509 -in /etc/letsencrypt/live/mydemo.idv.tw/fullchain.pem -noout -dates

# 3. 檢查 Samba 共享中的憑證
ls -lh /home/allenl/SSL_files/seeker_windows/

# 4. 檢查 hook 腳本
ls -lh /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh

# 5. 手動執行 hook 腳本
sudo /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh

# 6. 查看日誌
cat /var/log/certbot-renewal.log
```

---

### 4. Seeker nginx.conf 路徑錯誤

**症狀:**
日誌顯示 "⚠ ssl_certificate 路徑需要更新"

**原因:**
nginx.conf 中的憑證路徑不是標準路徑

**解決方法:**

腳本會自動修正,但如果需要手動檢查:

```powershell
# 檢查當前設定
Select-String -Path "C:\Seeker\data\server\conf\nginx.conf" -Pattern "ssl_certificate" -Context 1

# 應該是:
# ssl_certificate "C:/Seeker/data/server/conf/certs/fullchain.pem";
# ssl_certificate_key "C:/Seeker/data/server/conf/certs/privkey.pem";
```

---

## 重要時程表

### 憑證續約週期

```
Let's Encrypt 憑證有效期: 90 天
自動續約時機: 到期前 30 天

申請日期: 2025-10-25
   ↓
第 60 天: 2025-12-24 (開始嘗試續約)
   ↓
續約完成: 2025-12-28 (預估,Linux 自動)
   ↓
複製到 Samba: 2025-12-28 (Linux 自動)
   ↓
Windows 同步: 2026-01-01 03:00 (每月 1 號自動)
   ↓
第 90 天: 2026-01-23 (舊憑證到期,但已更新)
   ↓
下次續約: 2026-03-28 (新憑證 60 天後)
```

### 執行時程

| 日期 | 事件 | 自動/手動 | 說明 |
|------|------|-----------|------|
| 2025-10-29 | 自動化系統設定完成 | ✅ 完成 | Windows 排程工作已建立 |
| **每月 1 號 3:00** | **Windows 自動同步** | 🤖 自動 | 從 Samba 下載並部署最新憑證 |
| **2025-12-28** | **Linux 憑證續約** | 🤖 自動 | Certbot 自動續約並複製到 Samba |
| 2026-01-01 3:00 | Windows 同步新憑證 | 🤖 自動 | 下載並部署續約後的新憑證 |
| 2026-01-23 | 舊憑證到期 | - | 不影響 (已更新) |

---

## 網域變更計畫 (2026-05)

### 背景

- **mydemo.idv.tw** 將於 **2026-05-xx** 到期
- 備用網域 **mydemo2.online** 已註冊 (到期日 2026-10-25)

### 變更流程

**1. 在 Linux 端申請新網域憑證**

```bash
# 申請新憑證
sudo certbot certonly --webroot -w /var/www/html -d mydemo2.online

# 修改 hook 腳本中的網域
sudo nano /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh
# 將 DOMAIN="mydemo.idv.tw" 改為 DOMAIN="mydemo2.online"
```

**2. 在 Windows 端更新配置**

```powershell
# 編輯 Deploy-SeekerSsl.ps1
notepad "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\Deploy-SeekerSsl.ps1"

# 修改參數
# $SeekerUrl = "https://mydemo2.online:8450"

# 重新設定排程工作
.\Setup-AutoRenew.ps1
```

**3. 測試部署**

```powershell
# 手動執行一次
.\Deploy-SeekerSsl.ps1

# 驗證
Start-Process "https://mydemo2.online:8450"
```

---

## 快速參考

### 🚨 緊急操作

**立即手動更新憑證:**

```powershell
# 執行部署
.\Deploy-SeekerSsl.ps1

# 或觸發排程工作
Start-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew"
```

**強制重啟 Seeker:**

```powershell
Stop-Service SeekerEnterpriseServer -Force
Start-Sleep -Seconds 10
Start-Service SeekerEnterpriseServer

# 驗證
Get-Service SeekerEnterpriseServer
Start-Process "https://mydemo.idv.tw:8450"
```

### 📝 Checklist: 憑證更新完成

- [ ] 日誌顯示 "✓ 部署成功"
- [ ] Seeker 服務狀態為 Running
- [ ] 瀏覽器可以訪問 https://mydemo.idv.tw:8450
- [ ] 憑證到期日正確 (應該是未來 90 天)
- [ ] 沒有憑證警告

### 🔗 相關路徑

**Windows:**
- 腳本目錄: `D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\`
- Seeker 憑證: `C:\Seeker\data\server\conf\certs\`
- 日誌目錄: `D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\logs\`

**Linux (透過 Samba):**
- Samba 路徑: `\\192.168.31.5\allenl_home\SSL_files\seeker_windows\`
- 來源憑證: `/etc/letsencrypt/live/mydemo.idv.tw/`

---

## 聯絡資訊

**管理員:** Allen Lin / Yulia  
**文件版本:** 1.0  
**最後更新:** 2025-10-29  
**相關文件:** 
- Linux SSL Management Guide (Black Duck, Coverity)
- Seeker Installation Guide

---

**🎉 自動化完成!憑證會自動更新,無需手動干預!**

### 系統優勢總結

✅ **完全自動化** - Linux 和 Windows 雙端自動執行  
✅ **零維護成本** - 設定一次,終身受用  
✅ **安全可靠** - 自動備份,失敗自動記錄  
✅ **簡單易懂** - 3 個檔案,一鍵設定  
✅ **詳細日誌** - 每次執行都有完整記錄  

---

## 附錄: Windows 排程工作詳細資訊

### 排程工作設定

- **名稱:** Seeker-SSL-Auto-Renew
- **執行身分:** SYSTEM (最高權限)
- **觸發器:** 每月特定日期 (預設 1 號)
- **執行時間:** 凌晨 3:00 (可自訂)
- **動作:** 執行 Deploy-SeekerSsl-Wrapper.ps1
- **日誌:** 自動記錄到 logs 目錄

### 排程工作管理

```powershell
# 查看完整設定
Get-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew" | Format-List *

# 匯出設定 (備份)
Export-ScheduledTask -TaskName "Seeker-SSL-Auto-Renew" -TaskPath "\" | 
    Out-File "Seeker-SSL-Auto-Renew.xml"

# 匯入設定 (還原)
Register-ScheduledTask -Xml (Get-Content "Seeker-SSL-Auto-Renew.xml" | Out-String) `
    -TaskName "Seeker-SSL-Auto-Renew"

# 開啟排程工作管理員
taskschd.msc
```

---

**結束 🚀**