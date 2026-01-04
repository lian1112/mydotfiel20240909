# Total Commander 系統整合工具（精簡版）

## 🚀 使用方式（兩步驟）

### 步驟 1：設定 Total Commander
```
右鍵 → 以系統管理員身份執行：
1_Setup_TotalCommander.bat
```

這個腳本會自動：
- ✓ 檢查 Total Commander 安裝路徑
- ✓ 備份當前設定
- ✓ 套用 Total Commander 為預設

### 步驟 2：登出再登入
```
完成後登出並重新登入（或重新開機）
```

---

## 🔄 還原

如果想改回 Windows Explorer：
```
右鍵 → 以系統管理員身份執行：
2_Restore_Explorer.bat
```

還原腳本提供兩種方式：
1. **從備份還原**（推薦）- 還原到執行前的狀態
2. **Windows 預設設定** - 還原為乾淨的 Windows 預設值

---

## 📁 檔案說明

| 檔案 | 說明 |
|------|------|
| `1_Setup_TotalCommander.bat` | 一鍵設定 Total Commander |
| `2_Restore_Explorer.bat` | 還原為 Windows Explorer |
| `Backups\` | 備份資料夾（自動建立） |

---

## 🎯 執行後效果

### ✅ 會替換為 Total Commander
- 雙擊資料夾
- 雙擊磁碟機（C:、D: 等）
- Win+R 輸入路徑（例如 C:\）
- VS Code 的 "Reveal in File Explorer"
- 瀏覽器「開啟資料夾」
- 應用程式的「瀏覽」對話框

### ❌ 不會替換（保持 Explorer）
- Win+E 快捷鍵
- 桌面和工作列
- 控制台、回收桶、網路芳鄰

---

## 🛡️ 安全性保證

- ✅ 執行前自動備份
- ✅ 不刪除或停用 explorer.exe
- ✅ 不影響 Windows 核心功能
- ✅ 完全可還原
- ✅ 不會造成系統不穩定

---

## ❓ 常見問題

**Q: Total Commander 不在預設位置怎麼辦？**  
A: 腳本會自動偵測常見位置，如果找不到會提示你手動輸入路徑。

**Q: 執行後有問題怎麼辦？**  
A: 立即執行 `2_Restore_Explorer.bat` 選擇「從備份還原」。

**Q: Win+E 還是開啟 Windows Explorer？**  
A: 這是正常的，Win+E 需要額外設定（建議使用 PowerToys）。

**Q: 需要重新開機嗎？**  
A: 建議登出再登入即可，不一定要重新開機。

---

## 💡 Win+E 快捷鍵如何改？

### 方法 1：PowerToys（推薦）
1. 安裝 Microsoft PowerToys
2. 開啟 Keyboard Manager
3. Remap shortcuts → Win+E → 設定為執行 Total Commander

### 方法 2：AutoHotkey
```ahk
#e::Run, "C:\Program Files\totalcmd\TOTALCMD64.EXE"
```

---

## ✨ Total Commander 參數說明

如果你想自訂開啟行為，可以在腳本執行後，手動建立 Registry 檔案修改參數：

- `/O` - 使用現有視窗
- `/T` - 開新分頁
- `/S` - 在左側面板開啟
- `/R` 或 `/A` - 在右側面板開啟
- `/L` - 在左側面板開啟

目前預設值：`/O /T /S`（在現有視窗的新分頁左側開啟）

---

## 📞 如果遇到問題

1. 立即執行 `2_Restore_Explorer.bat`
2. 選擇「從備份還原」
3. 重新開機
4. 檢查 `Backups\` 資料夾中的備份檔案

---

**版本**：2.0（精簡版）  
**更新日期**：2025-11-08  
**測試環境**：Windows 10/11  
**Total Commander**：支援 32-bit 和 64-bit 版本
