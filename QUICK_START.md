# Total Commander 系統整合 - 快速指南

## ⚡ 超快速開始

### 設定
```batch
1. 右鍵「1_Setup_TotalCommander.bat」→ 以系統管理員身份執行
2. 登出再登入（或重開機）
3. 完成！
```

### 還原
```batch
右鍵「2_Restore_Explorer.bat」→ 以系統管理員身份執行
```

---

## 📋 詳細步驟

### 一、設定 Total Commander

1. **執行設定腳本**
   ```
   右鍵 → 1_Setup_TotalCommander.bat → 以系統管理員身份執行
   ```

2. **腳本會自動完成：**
   - ✓ 偵測 Total Commander 路徑
   - ✓ 備份當前設定到 Backups 資料夾
   - ✓ 套用 Total Commander 為預設檔案管理器

3. **登出再登入**
   - 按 `Win+L` 鎖定螢幕後登入
   - 或重新開機

### 二、測試是否生效

開啟以下任一項目，應該會用 Total Commander 開啟：
- [ ] 雙擊桌面上的資料夾
- [ ] 雙擊「本機」中的 C: 磁碟機
- [ ] 按 `Win+R`，輸入 `C:\`，按 Enter
- [ ] 在 VS Code 中右鍵檔案 → Reveal in File Explorer

### 三、還原（如需要）

1. **執行還原腳本**
   ```
   右鍵 → 2_Restore_Explorer.bat → 以系統管理員身份執行
   ```

2. **選擇還原方式**
   - **選項 1**：從備份還原（推薦）
   - **選項 2**：還原為 Windows 預設設定

3. **登出再登入**

---

## 🔍 路徑偵測

腳本會自動檢查以下位置：
- `C:\Program Files\totalcmd\TOTALCMD64.EXE`
- `C:\Program Files\totalcmd\TOTALCMD.EXE`
- `C:\Program Files (x86)\totalcmd\TOTALCMD64.EXE`
- `C:\Program Files (x86)\totalcmd\TOTALCMD.EXE`
- `C:\totalcmd\TOTALCMD64.EXE`
- `C:\totalcmd\TOTALCMD.EXE`

如果 Total Commander 不在這些位置，腳本會提示你手動輸入路徑。

---

## ⚠️ 注意事項

### ✅ 安全保證
- 執行前會自動備份當前設定
- 完全可還原
- 不影響系統穩定性

### ❌ 不會影響
- Win+E 快捷鍵（仍然是 Windows Explorer）
- 桌面和工作列
- 控制台、回收桶

### 💡 Win+E 快捷鍵
如果想讓 Win+E 也開啟 Total Commander：
- 推薦使用 **Microsoft PowerToys** 的 Keyboard Manager 功能
- 或使用 **AutoHotkey** 腳本

---

## 🛟 緊急還原

如果設定後系統有問題：

1. **方法 1：使用還原腳本**
   ```
   執行 2_Restore_Explorer.bat → 選擇「從備份還原」
   ```

2. **方法 2：手動匯入備份**
   ```
   開啟 Backups 資料夾
   雙擊最新的 .reg 檔案
   重新開機
   ```

---

## 📂 檔案結構

```
Total Commander 整合工具/
├── 1_Setup_TotalCommander.bat      ← 一鍵設定
├── 2_Restore_Explorer.bat          ← 一鍵還原
├── README.md                       ← 完整說明
├── QUICK_START.md                  ← 本檔案
└── Backups/                        ← 備份資料夾（自動建立）
    ├── Directory_Shell_Backup_*.reg
    └── Drive_Shell_Backup_*.reg
```

---

## ✨ 進階使用

### 修改開啟參數

如果想修改 Total Commander 的開啟行為，在設定完成後：

1. 按 `Win+R`，輸入 `regedit`
2. 前往：`HKEY_CLASSES_ROOT\Directory\shell\open\command`
3. 修改預設值（目前是：`"...\TOTALCMD64.EXE" /O /T /S "%1"`）

**常用參數：**
- `/O` - 使用現有視窗
- `/T` - 開新分頁
- `/S` - 左側面板
- `/R` - 右側面板
- `/L` - 左側面板（同 /S）

---

**版本**：2.0（精簡版）  
**日期**：2025-11-08
