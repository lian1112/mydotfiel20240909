# Coverity SSL 自動更新系統

Windows 端自動從 Linux 伺服器同步 Let's Encrypt 憑證並部署到 Synopsys Coverity

---

## 📋 快速開始

### 系統架構

```
Linux 伺服器 (allenl-2404)
   ├─ Let's Encrypt 憑證 (每 90 天自動續約)
   ├─ 自動轉換為 JKS 格式
   ├─ 複製到 Samba 共享: /home/allenl/SSL_files/coverity_windows/
   │  ├── keystore.jks         # Java Keystore (主要檔案)
   │  ├── fullchain.crt        # 完整憑證鏈
   │  ├── private.key          # 私鑰
   │  └── README.txt           # 部署說明
   └─ Samba 共享: \\192.168.31.5\allenl_home

            ⬇ (透過 Samba)

Windows 機器 (192.168.31.6)
   ├─ 每月 1 號凌晨 4:00 自動執行 (在 Seeker 之後 1 小時)
   ├─ 從 Samba 下載 keystore.jks
   ├─ 停止 Coverity 服務
   ├─ 備份舊 keystore
   ├─ 部署新 keystore
   └─ 重啟 Coverity 服務

Coverity Platform
   └─ HTTPS 服務: https://mydemo.idv.tw:8449
```

### Coverity Keystore 位置

```
C:\Program Files\Coverity\Coverity Platform\
├── bin\
│   └── cov-im-ctl.exe         # Coverity 控制程式
└── server\base\conf\
    ├── keystore.jks           # 當前 SSL keystore
    └── backup\                # 自動備份目錄
        └── keystore.jks.backup.YYYYMMDD_HHMMSS
```

---

## 🚀 一鍵設定

### 前置需求

✅ **Seeker SSL 自動更新已設定**
   - 需要使用 Seeker 的 `samba-config.ps1`
   - 路徑: `D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\samba-config.ps1`

✅ **Coverity 已安裝**
   - 安裝路徑: `C:\Program Files\Coverity\Coverity Platform\`

✅ **Windows 管理員權限**

### 設定步驟

**1. 準備檔案**

```
D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert\
├── Deploy-CoveritySsl.ps1           # 主腳本
└── Setup-Coverity-AutoRenew.ps1    # 一鍵設定腳本
```

**2. 執行設定**

以**管理員身分**執行 PowerShell:

```powershell
# 切換到腳本目錄
cd D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert

# 執行一鍵設定
.\Setup-Coverity-AutoRenew.ps1
```

**3. 驗證結果**

```
═══════════════════════════════════════════
  ✓ 設定完成！
═══════════════════════════════════════════

排程資訊:
  任務名稱: Coverity-SSL-Auto-Renew
  執行時間: 每月 1 號 4:00
  下次執行: 2025-11-01 04:00:00

✓ 測試執行成功
```

---

## 📁 檔案說明

### 核心檔案

#### 1. Deploy-CoveritySsl.ps1

**主要功能:**
- 從 Samba 下載 Let's Encrypt JKS
- 自動停止/啟動 Coverity 服務
- 備份舊 keystore
- 部署新 keystore
- 驗證部署結果

**關鍵參數:**

```powershell
param(
    [string]$SambaServer = "192.168.31.5",      # Samba 伺服器
    [string]$SambaShare = "allenl_home",        # 共享名稱
    [string]$SambaUser = "allenl",              # 使用者
    [string]$SambaPassword = "",                # 密碼 (從 Seeker 配置讀取)
    [string]$SambaSourcePath = "SSL_files\coverity_windows",  # 來源路徑
    [string]$CoverityPath = "C:\Program Files\Coverity\Coverity Platform",  # Coverity 安裝路徑
    [string]$KeystorePassword = "changeit",     # Keystore 密碼
    [string]$CoverityUrl = "https://mydemo.idv.tw:8449"  # Coverity URL
)
```

**執行流程:**

```
[1] 檢查 Coverity 安裝
[2] 連接 Samba 共享
[3] 下載並驗證 keystore
[4] 停止 Coverity 服務
[5] 備份現有 keystore
[6] 部署新 keystore
[7] 啟動 Coverity 服務
[8] 驗證部署
[9] 清理 Samba 連接
```

#### 2. Setup-Coverity-AutoRenew.ps1

**用途:** 一鍵設定自動更新系統

**功能:**
1. 檢查必要檔案 (包括 Seeker 的 samba-config.ps1)
2. 建立包裝腳本 (Deploy-CoveritySsl-Wrapper.ps1)
3. 建立 Windows 排程工作
4. 執行測試部署
5. 顯示結果和管理命令

### 共用配置

**使用 Seeker 的配置檔案:**
- 路徑: `D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\samba-config.ps1`
- 包含: Samba 伺服器、使用者、密碼
- 優點: 兩個系統共用一個配置,統一管理

---

## 🛠️ 維護和管理

### 常用管理命令

#### 手動執行更新

```powershell
# 方法 1: 觸發排程工作
Start-ScheduledTask -TaskName "Coverity-SSL-Auto-Renew"

# 方法 2: 直接執行腳本
.\Deploy-CoveritySsl.ps1
```

#### 查看排程工作狀態

```powershell
# 查看排程工作資訊
Get-ScheduledTask -TaskName "Coverity-SSL-Auto-Renew" | Format-List *

# 查看執行歷史
Get-ScheduledTaskInfo -TaskName "Coverity-SSL-Auto-Renew"

# 查看下次執行時間
$task = Get-ScheduledTaskInfo -TaskName "Coverity-SSL-Auto-Renew"
$task.NextRunTime
```

#### 查看日誌

```powershell
# 查看最新日誌
Get-ChildItem "D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert\logs" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1 | 
    Get-Content

# 打開日誌目錄
explorer "D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert\logs"
```

#### Coverity 服務管理

```powershell
# 查看 Coverity 狀態
cd "C:\Program Files\Coverity\Coverity Platform\bin"
.\cov-im-ctl.exe status

# 停止 Coverity
.\cov-im-ctl.exe stop

# 啟動 Coverity
.\cov-im-ctl.exe start
```

---

## 🔧 故障排除

### 1. Keystore 驗證失敗

**症狀:**
```
✗ Keystore 無效!
```

**排查步驟:**

```powershell
# 檢查 Samba 共享中的 keystore
Test-Path "\\192.168.31.5\allenl_home\SSL_files\coverity_windows\keystore.jks"

# 手動驗證 keystore
keytool -list -keystore "C:\temp\keystore.jks" -storepass changeit

# 檢查 Linux 端的轉換腳本
ssh allenl@114.34.97.78
cat /var/log/certbot-renewal.log
```

**解決方法:**

```bash
# Linux 端重新產生 JKS
sudo /etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh
```

---

### 2. Coverity 服務無法停止/啟動

**症狀:**
```
✗ 停止服務時發生錯誤
```

**排查步驟:**

```powershell
# 檢查 Coverity 狀態
cd "C:\Program Files\Coverity\Coverity Platform\bin"
.\cov-im-ctl.exe status

# 查看 Coverity 日誌
Get-ChildItem "C:\Program Files\Coverity\Coverity Platform\log\" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 3
```

**解決方法:**

```powershell
# 強制停止
.\cov-im-ctl.exe stop
Start-Sleep -Seconds 20

# 如果仍無法停止,檢查進程
Get-Process | Where-Object { $_.ProcessName -like "*coverity*" }

# 強制終止進程 (最後手段)
Stop-Process -Name "cov-*" -Force
```

---

### 3. 憑證部署後仍顯示舊憑證

**症狀:**
瀏覽器訪問 https://mydemo.idv.tw:8449 仍顯示舊的到期日

**排查步驟:**

```powershell
# 1. 檢查 keystore 檔案時間
Get-Item "C:\Program Files\Coverity\Coverity Platform\server\base\conf\keystore.jks" | 
    Select-Object LastWriteTime

# 2. 驗證 keystore 內容
keytool -list -keystore "C:\Program Files\Coverity\Coverity Platform\server\base\conf\keystore.jks" -storepass changeit

# 3. 檢查 Coverity 是否真的重啟了
cd "C:\Program Files\Coverity\Coverity Platform\bin"
.\cov-im-ctl.exe status

# 4. 檢查端口
Get-NetTCPConnection -LocalPort 8449
```

**解決方法:**

```powershell
# 強制重啟 Coverity
cd "C:\Program Files\Coverity\Coverity Platform\bin"
.\cov-im-ctl.exe stop
Start-Sleep -Seconds 20
.\cov-im-ctl.exe start

# 清除瀏覽器快取並重新載入
Start-Process "https://mydemo.idv.tw:8449"
```

---

## ⏰ 重要時程表

### 執行時程

| 時間 | 系統 | 動作 | 說明 |
|------|------|------|------|
| **每天** | Linux | 檢查憑證續約 | Certbot 自動 |
| **到期前 30 天** | Linux | 憑證續約 + 產生 JKS | 自動執行 |
| **每月 1 號 3:00** | Seeker | SSL 更新 | 自動執行 |
| **每月 1 號 4:00** | Coverity | SSL 更新 | 自動執行 (延遲 1 小時) |

### 為什麼 Coverity 延遲 1 小時?

**原因:**
1. ✅ **避免同時重啟服務** - Seeker 和 Coverity 不會同時停機
2. ✅ **減少網路壓力** - 不會同時從 Samba 下載檔案
3. ✅ **錯開維護窗口** - 如果一個失敗,不影響另一個

**時間安排:**
- 凌晨 3:00 - Seeker 更新 (預計 5 分鐘)
- 凌晨 4:00 - Coverity 更新 (預計 3 分鐘)
- 凌晨 4:05 - 所有服務恢復正常

---

## 🔗 與 Seeker 系統的關係

### 共用配置

**兩個系統共用同一個配置檔案:**

```
D:\mydotfile\
├── SSL_Deploy-Seeker_Renew_lets_encrypt_cert\
│   ├── Deploy-SeekerSsl.ps1
│   ├── samba-config.ps1          # ← 共用配置
│   └── Setup-AutoRenew.ps1
│
└── SSL_Deploy-Coverity_Renew_lets_encrypt_cert\
    ├── Deploy-CoveritySsl.ps1    # ← 讀取 Seeker 的配置
    └── Setup-Coverity-AutoRenew.ps1
```

### Linux 端處理

**同一個 hook 腳本產生兩種格式:**

```bash
/etc/letsencrypt/renewal-hooks/deploy/copy-certs.sh
   ├─ 產生 Seeker 用的 PEM 檔案
   │  └─ /home/allenl/SSL_files/seeker_windows/
   │      ├── fullchain.pem
   │      └── privkey.pem
   │
   └─ 產生 Coverity 用的 JKS 檔案
      └─ /home/allenl/SSL_files/coverity_windows/
          └── keystore.jks
```

### 統一管理

**修改 Samba 密碼只需要一個地方:**

```powershell
# 1. 編輯配置檔
notepad "D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\samba-config.ps1"

# 2. 重新設定兩個系統
cd D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert
.\Setup-AutoRenew.ps1

cd D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert
.\Setup-Coverity-AutoRenew.ps1
```

---

## 📝 快速參考

### 🚨 緊急操作

**立即手動更新憑證:**

```powershell
cd D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert
.\Deploy-CoveritySsl.ps1
```

**強制重啟 Coverity:**

```powershell
cd "C:\Program Files\Coverity\Coverity Platform\bin"
.\cov-im-ctl.exe stop
Start-Sleep -Seconds 20
.\cov-im-ctl.exe start

# 驗證
.\cov-im-ctl.exe status
Start-Process "https://mydemo.idv.tw:8449"
```

### ✅ Checklist: 憑證更新完成

- [ ] 日誌顯示 "✓ 部署成功"
- [ ] Coverity 服務狀態正常
- [ ] 瀏覽器可以訪問 https://mydemo.idv.tw:8449
- [ ] 憑證到期日正確 (未來 90 天)
- [ ] 沒有憑證警告

### 📍 重要路徑

**Windows:**
- 腳本目錄: `D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert\`
- Coverity Keystore: `C:\Program Files\Coverity\Coverity Platform\server\base\conf\keystore.jks`
- 日誌目錄: `D:\mydotfile\SSL_Deploy-Coverity_Renew_lets_encrypt_cert\logs\`
- 共用配置: `D:\mydotfile\SSL_Deploy-Seeker_Renew_lets_encrypt_cert\samba-config.ps1`

**Linux (透過 Samba):**
- Samba 路徑: `\\192.168.31.5\allenl_home\SSL_files\coverity_windows\`
- 來源憑證: `/etc/letsencrypt/live/mydemo.idv.tw/`

---

## 聯絡資訊

**管理員:** Allen Lin / Yulia  
**文件版本:** 1.0  
**最後更新:** 2025-10-29  
**相關文件:** 
- Seeker SSL 自動更新系統 README
- Linux SSL Management Guide

---

**🎉 自動化完成!Coverity 憑證會自動更新!**

### 系統優勢總結

✅ **完全自動化** - Linux 和 Windows 雙端自動執行  
✅ **與 Seeker 統一管理** - 共用配置,一次設定  
✅ **錯開維護時間** - 避免服務同時停機  
✅ **自動備份** - 每次更新都自動備份舊 keystore  
✅ **詳細日誌** - 每次執行都有完整記錄  

---

**結束 🚀**