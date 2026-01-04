; 檢測連接的手柄/搖桿編號
; 此腳本可以幫助您確定連接設備的 JoystickNumber

#Requires AutoHotkey v2.0
Persistent

; 初始化
joystickCount := 0

; 檢測最多 16 個可能的手柄
Loop 16 {
    if GetKeyState(A_Index "JoyName") {
        joystickCount := A_Index
    }
}

; 顯示檢測到的手柄數量
if (joystickCount = 0) {
    MsgBox "未檢測到任何手柄或搖桿設備。請確保您的設備已正確連接。"
    ExitApp
} else {
    MsgBox "檢測到 " joystickCount " 個手柄/搖桿設備。`n`n按確定繼續查看各設備信息。"
}

; 創建 GUI 窗口
MyGui := Gui(, "手柄/搖桿檢測器")
MyGui.SetFont("s12")
MyGui.Add("Text", "w500", "已連接的手柄/搖桿設備：")
MyGui.Add("Text", "w500 h2 +0x10")  ; 水平分隔線

; 顯示每個檢測到的手柄的信息
Loop joystickCount {
    i := A_Index
    MyGui.Add("Text", "w500", "手柄 #" i ": " GetKeyState(i "JoyName"))
    MyGui.Add("Text", "w500", "按鈕數量: " GetKeyState(i "JoyButtons"))
    MyGui.Add("Text", "w500", "軸數量: " GetKeyState(i "JoyAxes"))
    MyGui.Add("Text", "w500", "是否有 POV 控制: " (GetKeyState(i "JoyPOV") != -1 ? "是" : "否"))
    
    ; 創建此手柄的狀態顯示
    MyGui.Add("Text", "w500 vJoy" i "Status", "請移動或按下此手柄的按鈕...")
    MyGui.Add("Text", "w500 h2 +0x10")  ; 水平分隔線
}

; 添加結束按鈕
MyGui.Add("Button", "w200 h40", "結束檢測").OnEvent("Click", (*) => ExitApp())

; 顯示窗口
MyGui.Show()

; 設置定時器來更新手柄狀態
SetTimer WatchJoysticks, 50

; 監視手柄狀態的函數
WatchJoysticks() {
    global joystickCount
    
    Loop joystickCount {
        i := A_Index
        ; 獲取手柄狀態
        joyX := GetKeyState(i "JoyX")
        joyY := GetKeyState(i "JoyY")
        joyZ := GetKeyState(i "JoyZ")
        joyR := GetKeyState(i "JoyR")
        joyU := GetKeyState(i "JoyU")
        joyV := GetKeyState(i "JoyV")
        joyPOV := GetKeyState(i "JoyPOV")
        
        ; 檢查按鈕
        buttonStates := []
        buttonCount := GetKeyState(i "JoyButtons")
        
        Loop buttonCount {
            b := A_Index
            if GetKeyState(i "Joy" b) {
                buttonStates.Push(b)
            }
        }
        
        ; 更新狀態文本
        statusText := "手柄 #" i " 狀態:`n"
        statusText .= "X軸: " Round(joyX) " | Y軸: " Round(joyY) " | Z軸: " Round(joyZ) "`n"
        statusText .= "R軸: " Round(joyR) " | U軸: " Round(joyU) " | V軸: " Round(joyV) "`n"
        statusText .= "POV: " joyPOV "`n"
        
        if (buttonStates.Length > 0) {
            statusText .= "按下的按鈕: " Join(buttonStates, ", ")
        } else {
            statusText .= "沒有按鈕被按下"
        }
        
        ; 更新 GUI
        MyGui["Joy" i "Status"].Value := statusText
    }
}

; 輔助函數：將陣列元素連接為字符串
Join(array, delimiter) {
    result := ""
    for index, value in array {
        if (index > 1)
            result .= delimiter
        result .= value
    }
    return result
}