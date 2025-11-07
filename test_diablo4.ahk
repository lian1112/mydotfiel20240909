#SingleInstance Force
#Warn
SetWorkingDir A_ScriptDir

; 顯示當前視窗的執行檔名稱和標題
F2::DisplayCurrentWindowInfo()

; 顯示當前活動窗口的信息
DisplayCurrentWindowInfo() {
    activeProcess := WinGetProcessName("A")
    activeTitle := WinGetTitle("A")
    activeClass := WinGetClass("A")
    activeID := WinGetID("A")
    
    infoText := "當前視窗信息：`n"
             . "------------------------------`n"
             . "進程名稱: " . activeProcess . "`n"
             . "視窗標題: " . activeTitle . "`n"
             . "視窗類別: " . activeClass . "`n"
             . "視窗ID: " . activeID . "`n`n"
             . "視窗檢測測試：`n"
             . "Diablo IV.exe: " . (WinActive("ahk_exe Diablo IV.exe") ? "匹配" : "不匹配") . "`n"
             . "DiabloIV.exe: " . (WinActive("ahk_exe DiabloIV.exe") ? "匹配" : "不匹配") . "`n"
             . "Diablo4.exe: " . (WinActive("ahk_exe Diablo4.exe") ? "匹配" : "不匹配") . "`n"
    
    ; 創建 GUI 窗口顯示信息
    testGui := Gui()
    testGui.SetFont("s10", "Consolas")
    testGui.Add("Text",, infoText)
    testGui.Add("Button", "Default w120", "關閉").OnEvent("Click", (*) => testGui.Destroy())
    testGui.Title := "Diablo 4 視窗測試"
    testGui.Show()
}

; 測試 Diablo 4 的簡單自動連按功能 (僅作為測試用)
F3::TestAutoClick()

; 測試自動連按功能
TestAutoClick() {
    static isActive := false
    
    isActive := !isActive
    
    if (isActive) {
        MsgBox("自動連按測試已啟動`n按 F3 停止`n`n注意：這只是一個測試功能", "測試", "T2")
        SetTimer SendTestKeys, 1000
    } else {
        SetTimer SendTestKeys, 0
        MsgBox("自動連按測試已停止", "測試", "T2")
    }
}

; 測試自動按鍵功能
SendTestKeys() {
    activeProcess := WinGetProcessName("A")
    
    ; 顯示當前進程名稱
    ToolTip("當前進程: " . activeProcess . "`n自動連按測試中...", 100, 100)
    
    ; 假裝按鍵 (實際上不會發送按鍵，只是顯示)
    ; 實際使用時移除註釋
    ; Send "q"
    ; Sleep 100
    ; Send "w"
}

; 顯示啟動消息
MsgBox("Diablo 4 視窗測試腳本已啟動`n`n按 F2 檢測當前窗口信息`n按 F3 測試自動連按功能", "測試腳本", "T3")
