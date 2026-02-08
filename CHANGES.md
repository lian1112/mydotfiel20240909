# System Changes Log

All system modifications (registry, settings, etc.) are recorded here for tracking and rollback.

---

## 2025-02-08: Explorer - Open external folders in new tab

**Type:** Registry
**Path:** `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer`
**Value:** `OpenFolderInNewTab` = `1` (DWORD)
**Previous:** Not set (default = 0)
**Purpose:** 從 115 等外部程式點資料夾圖示時，在已有 Explorer 視窗開新 tab，而非開新視窗
**Rollback:**
```powershell
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'OpenFolderInNewTab'
```
