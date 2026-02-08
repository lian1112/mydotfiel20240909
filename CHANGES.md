# System Changes Log

All system modifications (registry, settings, etc.) are recorded here for tracking and rollback.

> **規則：** 任何對作業系統有危險的操作（registry 修改、系統設定變更、服務啟停等）都必須：
> 1. 先記錄到此檔案
> 2. 提示使用者確認後才執行
> 3. 附上 rollback 指令

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
