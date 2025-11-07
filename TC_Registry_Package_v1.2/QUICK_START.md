# Total Commander 系統整合工具 - 快速指南

## 🚀 快速開始（3 步驟）

### 步驟 0：檢查路徑（推薦先執行）
```
右鍵 → 以系統管理員身份執行：
0_Check_TotalCommander_Path.bat
```
這會檢查 Total Commander 是否正確安裝，並顯示正確的路徑。

### 步驟 1：備份當前設定（必須）
```
右鍵 → 以系統管理員身份執行：
1_Backup_Current_Settings.bat
```
備份檔案會儲存在 `Backups` 資料夾中。

### 步驟 2：設定 Total Commander 為預設
```
雙擊執行：
2_Set_TotalCommander_Default.reg
```
確認匯入後，登出再登入（或重新開機）。

### 步驟 3：測試
- 雙擊桌面上的資料夾 → 應該用 Total Commander 開啟
- 按 Win+R，輸入 `C:\` → 應該用 Total Commander 開啟
- 在 VS Code 右鍵檔案 → Reveal in File Explorer → 用 Total Commander 開啟

---

## 📁 檔案說明

| 檔案 | 說明 | 執行方式 |
|------|------|----------|
| `0_Check_TotalCommander_Path.bat` | 檢查 TC 路徑是否正確 | 右鍵以系統管理員執行 |
| `1_Backup_Current_Settings.bat` | 備份當前設定 | 右鍵以系統管理員執行 |
| `2_Set_TotalCommander_Default.reg` | 設定 TC 為預設 | 雙擊執行 |
| `3_Restore_Original_Settings.reg` | 還原為 Windows Explorer | 雙擊執行 |
| `4_Emergency_Restore_From_Backup.bat` | 從備份檔案緊急還原 | 右鍵以系統管理員執行 |
| `README.md` | 完整說明文件 | - |
| `QUICK_START.md` | 本檔案 | - |

---

## ⚠️ 重要提醒

### ✅ 安全保證
- 不會刪除或停用 explorer.exe
- 不會影響桌面和工作列
- 完全可還原
- 不會造成系統不穩定

### ⚡ 如果遇到問題
1. 立即執行 `3_Restore_Original_Settings.reg`
2. 或執行 `4_Emergency_Restore_From_Backup.bat`
3. 重新開機

### 📝 路徑修改
如果 Total Commander 不是安裝在預設位置：
1. 先執行 `0_Check_TotalCommander_Path.bat` 查看正確路徑
2. 用記事本開啟 `2_Set_TotalCommander_Default.reg`
3. 搜尋 `C:\\Program Files\\totalcmd\\TOTALCMD64.EXE`
4. 替換為正確路徑（注意：反斜線要寫兩次）

---

## 🎯 執行後效果

### ✅ 會替換為 Total Commander
- 雙擊資料夾
- 雙擊磁碟機（C:、D: 等）
- Win+R 輸入路徑
- VS Code 的 "Reveal in File Explorer"
- 瀏覽器「開啟資料夾」
- 應用程式的「瀏覽」對話框

### ❌ 不會替換（保持 Explorer）
- Win+E 快捷鍵
- 桌面和工作列
- 控制台
- 回收桶、網路芳鄰

---

## 💡 補充說明

### Win+E 快捷鍵如何改？
需要使用 AutoHotkey 或 PowerToys：

**PowerToys 方式**（推薦）：
1. 下載安裝 Microsoft PowerToys
2. 開啟 Keyboard Manager
3. Remap shortcuts → Win+E → 執行 Total Commander

**AutoHotkey 方式**：
```ahk
#e::Run, "C:\Program Files\totalcmd\TOTALCMD64.EXE"
```

---

## 📞 支援

如果有任何問題：
1. 先執行 `3_Restore_Original_Settings.reg` 還原
2. 檢查 `Backups` 資料夾中的備份檔案
3. 查看 `README.md` 完整說明

---

## ✨ 小技巧

### Total Commander 參數
修改 `2_Set_TotalCommander_Default.reg` 中的參數可自訂行為：

- `/O` - 使用現有視窗
- `/T` - 開新分頁
- `/S` - 在左側面板開啟
- `/A` - 在右側面板開啟
- `/R` - 在右側面板開啟（替代 /A）
- `/L` - 在左側面板開啟（替代 /S）

範例：
```
原始："%1" /O /T /S "%1"
改為："%1" /O /T /A "%1"  （改為在右側面板開啟）
```

---

**版本**：1.0  
**日期**：2025-11-08  
**測試環境**：Windows 10/11
