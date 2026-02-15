# System Changes Log

All system modifications (registry, settings, etc.) are recorded here for tracking and rollback.

> **規則：** 任何對作業系統有危險的操作（registry 修改、系統設定變更、服務啟停等）都必須：
> 1. 先記錄到此檔案
> 2. 提示使用者確認後才執行
> 3. 附上 rollback 指令

> **截圖參考：** 當使用者說「參考圖1-10」，代表去讀 `D:\snipaste\recent\1.jpg` ~ `10.jpg`

---

## 2025-02-08: Explorer - Open external folders in new tab

**Type:** Registry
**Path:** `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer`
**Value:** `OpenFolderInNewTab` = `1` (DWORD)
**Previous:** Not set (default = 0)
**Status:** ❌ 已移除（未生效，改用 AHK SetWinEventHook 方案替代）
**Purpose:** 從 115 等外部程式點資料夾圖示時，在已有 Explorer 視窗開新 tab，而非開新視窗
**Rollback:**
```powershell
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'OpenFolderInNewTab'
```

---

## 2025-02-08: AHK - Explorer 新視窗自動合併到已有視窗 tab

**Type:** AHK 腳本（SetWinEventHook）
**File:** `D:\mydotfile\ahk.ahk` Section 4 + Section 9
**Purpose:** 用系統級 EVENT_OBJECT_SHOW hook 偵測新 Explorer 視窗，自動關閉並在已有視窗開新 tab 導航
**Rollback:** 移除 ahk.ahk 中 `explorerHook` 相關程式碼和 `OnExplorerWindowShow`/`RedirectExplorerWindow` 函式

---

## 2025-02-08: Disable BitLocker prompt on fixed drives (Group Policy)

**Type:** Registry (Group Policy)
**Path:** `HKLM\SOFTWARE\Policies\Microsoft\FVE`
**Changes:**
- `FDVConfigureBDE` = `0` (DWORD) — 不設定固定磁碟加密
- `FDVAllowBDE` = `0` (DWORD) — 不允許固定磁碟 BitLocker
- `FDVDisableBDE` = `1` (DWORD) — 禁用固定磁碟 BitLocker
**Previous:** 只有 RDV（卸除式磁碟）的設定，無 FDV 設定
**Backup:** `D:\mydotfile\backup_FVE_policy.reg`
**Purpose:** 在 This PC 雙擊 C: 時不再跳出 BitLocker 加密提示，直接進入磁碟
**Rollback:**
```powershell
reg import 'D:\mydotfile\backup_FVE_policy.reg'
# 或手動移除:
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v FDVConfigureBDE /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v FDVAllowBDE /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v FDVDisableBDE /f
```
