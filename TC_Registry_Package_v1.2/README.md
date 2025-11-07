# Total Commander 系統整合工具包

## 📋 內容說明

此工具包包含三個 Registry 腳本：

1. **1_Backup_Current_Settings.reg** - 備份當前設定
2. **2_Set_TotalCommander_Default.reg** - 設定 Total Commander 為預設
3. **3_Restore_Original_Settings.reg** - 還原原始設定

## ⚠️ 重要注意事項

### 執行前必讀

1. **必須以系統管理員身份執行**
2. **執行順序**：先執行 1（備份）→ 再執行 2（設定）
3. **如果有問題**：執行 3（還原）
4. **路徑確認**：請先確認 Total Commander 安裝路徑是否為 `C:\Program Files\totalcmd\TOTALCMD64.EXE`
   - 如果不是，請修改 `2_Set_TotalCommander_Default.reg` 中的路徑

### 安全性保證

✅ **只修改資料夾和磁碟機的開啟方式**
✅ **不影響 Windows Explorer 核心功能**
✅ **不修改桌面、工作列、控制台**
✅ **完全可逆，隨時可還原**

## 📝 使用步驟

### 第一步：備份（必須）

1. 找到 `1_Backup_Current_Settings.reg`
2. **右鍵 → 以系統管理員身份執行**
3. 確認「已成功匯入登錄」訊息
4. 備份檔案會建立在：
   - `C:\Windows\Temp\Directory_Shell_Backup.reg`
   - `C:\Windows\Temp\Drive_Shell_Backup.reg`

### 第二步：設定 Total Commander

1. **確認 TC 路徑正確**（預設：`C:\Program Files\totalcmd\TOTALCMD64.EXE`）
2. 如路徑不同，用記事本開啟 `2_Set_TotalCommander_Default.reg` 修改路徑
3. **右鍵 → 合併** 或 **雙擊執行**
4. 確認「已成功匯入登錄」訊息
5. **登出並重新登入** 或 **重新開機**

### 第三步：測試

測試以下操作是否開啟 Total Commander：

- [ ] 雙擊桌面上的資料夾
- [ ] 雙擊「本機」中的 C: 磁碟機
- [ ] 按 `Win+R` → 輸入 `C:\` → Enter
- [ ] 在 VS Code 中右鍵檔案 → Reveal in File Explorer

### 還原（如有問題）

1. 執行 `3_Restore_Original_Settings.reg`
2. 確認「已成功匯入登錄」訊息
3. **登出並重新登入** 或 **重新開機**

## 🔧 影響範圍

### ✅ 會替換為 Total Commander

- 雙擊資料夾
- 雙擊磁碟機（C:、D: 等）
- 右鍵選單「開啟」
- 執行視窗輸入路徑
- VS Code 的 "Reveal in File Explorer"
- 瀏覽器下載完成「開啟資料夾」
- 大多數應用程式的「瀏覽資料夾」

### ❌ 不會替換（保持原樣）

- `Win+E` 快捷鍵（仍開啟 Windows Explorer）
- 桌面和工作列
- 控制台
- 回收桶
- 網路芳鄰
- 「這台電腦」特殊資料夾

## 🛡️ 安全性說明

此修改：
- ✅ 不刪除或停用 `explorer.exe`
- ✅ 不影響 Windows 核心功能
- ✅ 不需要修改系統檔案
- ✅ 完全可還原
- ✅ 不會造成系統不穩定

## ❓ 常見問題

**Q: 如果 Total Commander 路徑不同怎麼辦？**
A: 用記事本開啟 `2_Set_TotalCommander_Default.reg`，搜尋 `C:\\Program Files\\totalcmd\\TOTALCMD64.EXE` 並替換成你的路徑（注意：路徑中的反斜線要寫兩次，如 `C:\\totalcmd\\TOTALCMD64.EXE`）

**Q: 修改後某些應用程式不相容怎麼辦？**
A: 立即執行 `3_Restore_Original_Settings.reg` 還原設定

**Q: Win+E 還是開啟 Windows Explorer？**
A: 這是正常的，`Win+E` 需要額外設定（使用 AutoHotkey 或 PowerToys）

**Q: 可以只替換資料夾，不替換磁碟機嗎？**
A: 可以，只需在 `2_Set_TotalCommander_Default.reg` 中刪除 `[HKEY_CLASSES_ROOT\Drive\shell...]` 相關的部分

**Q: 需要重新開機嗎？**
A: 建議登出再登入，或重新開機以確保生效

## 📞 如果遇到問題

如果遇到任何問題：
1. 立即執行 `3_Restore_Original_Settings.reg`
2. 重新開機
3. 檢查備份檔案是否存在於 `C:\Windows\Temp\`
4. 如果備份檔案存在，可以手動雙擊匯入

## 版本資訊

- 版本：1.0
- 適用系統：Windows 10/11
- Total Commander：支援 32-bit 和 64-bit 版本
- 更新日期：2025-11-08
