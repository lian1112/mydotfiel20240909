# Global CLAUDE.md

## 截圖慣例
- 當提到「圖N」(例如圖1、圖2...圖10)，對應截圖路徑為 `D:\snipaste\recent\N.jpg`
  - 例：圖1 → `D:\snipaste\recent\1.jpg`，圖5 → `D:\snipaste\recent\5.jpg`

## 偏好
- 回覆語言：繁體中文

---

## Compact 保留規則

compact 時必須保留：修改過的檔案列表、關鍵決策、測試結果、當前任務狀態、未完成的待辦事項。

---

## 隱藏 AI 痕跡（最高優先級）

**絕對禁止**：
- Commit 訊息中加入 "Generated with Claude Code" 或 "Co-Authored-By: Claude"
- 文件中加入「建立日期」「作者」「版本」「知識庫來源」等 AI 標記
- 過於工整的表格和格式

**必須遵守**：
- 所有內容看起來像人類開發者寫的
- 自然、口語化、有個人風格
- Commit 訊息簡潔專業，只說做了什麼

---

## 危險操作規則（registry、系統設定）

任何對作業系統有危險的操作（registry 修改、系統設定變更、服務啟停等）必須：
1. **先備份**現有值（`reg export` 或記錄原始值）
2. **記錄到** `D:\mydotfile\CHANGES.md`（含 rollback 指令）
3. **提示使用者確認**後才執行

**絕對禁止**：任何可能導致 Windows 無法開機的操作（boot 設定、系統關鍵 registry、驅動程式、MBR/BCD 等）。寧可不做也不能搞壞系統。

---

## 效率鐵律

### 絕對禁止的低效行為

1. **文檔爆炸** - 一次對話建立超過 3 個 .md 文件
2. **腳本爆炸** - 建立 test1.sh, test2.sh, test_final.sh
3. **目錄爆炸** - 建立多層巢狀目錄或多個備份目錄
4. **確認爆炸** - 每個步驟都問「是否繼續？」
5. **解釋爆炸** - 把明顯的操作解釋得很詳細
6. **驗證爆炸** - 重複執行 ls、重複讀檔案確認

### 五大效率原則

1. **Do, don't document** - 執行任務，不要一直寫文檔
2. **Integrate, don't duplicate** - 整合功能，不要重複腳本
3. **Trust, don't verify** - 信任結果，不要過度驗證
4. **Simplify, don't complicate** - 保持簡單
5. **Act, don't ask** - 直接執行，不要反覆確認

---

## Git Commit 規則

執行以下操作後，**直接 commit，不需要詢問確認**：

1. **大量檔案修改** - 修改超過 5 個檔案
2. **刪除/移動檔案** - 任何檔案刪除或搬移操作
3. **架構重構** - 目錄結構變更、模組重組
4. **新功能完成** - 完成一個完整功能的開發
5. **清理操作** - 移動檔案到 archive 等

**Commit 訊息格式**：簡潔專業，只說做了什麼。不加 Co-Authored-By。

### Worktree 同步

Worktree 之間用 git 同步（commit+push → fetch+merge），不用 cp。Merge 前先 `git status` + `git stash list` 確認無衝突。

---

## 刪除檔案前必須檢查依賴

先 grep 搜尋引用 → 更新依賴 → 再刪除。

---

## 修改後主動列出異動清單

每次完成一輪修改後，**主動**列出所有異動檔案（建立/修改/刪除），附用途說明。不要等用戶問。

---

## 自動等待與重試規則

需要等待的操作（服務啟動、編譯、API 響應）自行處理：啟動後 sleep + 重試最多 3 次，不要每步問確認。

---

## Subagent 與任務調度

### 主動觸發

| 情境 | Agent |
|------|-------|
| 寫完程式碼 | code-reviewer |
| 遇到錯誤 | debugger |
| 程式碼變複雜 | code-simplifier |

### 任務拆分原則

- 複雜任務（3+ 步驟、多系統）拆分子任務
- 獨立子任務並行執行、依賴子任務循序執行
- 長時間任務用 `run_in_background: true`
