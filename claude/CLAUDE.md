# Global CLAUDE.md

## 截圖慣例
- 當提到「圖N」(例如圖1、圖2...圖10)，對應截圖路徑為 `D:\snipaste\recent\N.jpg`
  - 例：圖1 → `D:\snipaste\recent\1.jpg`，圖5 → `D:\snipaste\recent\5.jpg`

## 偏好
- 回覆語言：繁體中文
- AHK 主腳本：`D:\mydotfile\ahk.ahk`，測試腳本在 `D:\mydotfile\tests\`

## Secrets
- 密碼與 API Token 存放於 `C:\Users\yulia\.claude\secrets.env`
- 需要時直接讀取該檔案取得對應的環境變數值
- **絕對禁止**將 secrets.env 的內容 commit 到任何 git repo

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

**盡量避免**：修改 registry key 的 ACL/權限（Deny rule、regini 改權限等）。這類操作難以還原，且可能導致系統元件異常。優先用「定期清除」或「啟動時重設」等軟性方案替代。

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

## 參考文件索引

遇到相關主題時，先讀取 Linux 上的參考檔再回答（透過 Z: Samba 共享）：

| 觸發關鍵字 | 參考檔 |
|-----------|--------|
| Black Duck / Detect / BDBA | `Z:\.claude\reference\test_environments.md` |
| Coverity / cov-commit / analyze | `Z:\.claude\reference\test_environments.md` |
| Defensics / DUT / pcap | `Z:\.claude\reference\test_environments.md` |
| Polaris / Bridge CLI | `Z:\.claude\reference\test_environments.md` |
| GitLab | `Z:\.claude\reference\test_environments.md` |
| SSL / 憑證 / Let's Encrypt | `Z:\.claude\reference\infrastructure.md` |
| Cloudflare / Tunnel / kumolab | `Z:\.claude\reference\infrastructure.md` |
| Router / Port Forward / 114.34 | `Z:\.claude\reference\infrastructure.md` |
| 服務清單 / Port 對照 | `Z:\.claude\reference\infrastructure.md` |

### 常用測試環境快速參考

| 服務 | URL | secrets.env 變數 |
|------|-----|------------------|
| Black Duck | https://mydemo.idv.tw:7443 | `BLACKDUCK_*` |
| Coverity Connect | https://mydemo.idv.tw:8449 | `COVERITY_*` |
| BDBA | https://mydemo.idv.tw:31443 | `BDBA_API_KEY` |
| GitLab CE | http://192.168.31.5:8929 | `GITLAB_*` |
| Polaris POC | https://poc.polaris.blackduck.com | token 在對話目錄 `.env.local` |

### Linux 主機

| 項目 | 值 |
|------|-----|
| 內網 IP | 192.168.31.5 |
| 外網 IP | 114.34.97.78 |
| SSH | `ssh -p 22 allenl@192.168.31.5` |
| Samba | Z:\ (映射 /home/allenl) |
| 知識庫 | `Z:\claude_project\kb\` |

### 常用目錄（透過 Z:）

| 用途 | 路徑 |
|------|------|
| 知識庫搜尋 | `Z:\claude_project\kb\*\*_kb\markdown\` |
| 對話筆記 | `Z:\claude_project\claude_對話_產生的md\` |
| 測試環境 | `Z:\claude_project\cases\test_env\` |

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
