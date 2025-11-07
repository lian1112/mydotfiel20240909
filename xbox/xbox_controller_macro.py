"""
Xbox 控制器宏腳本 - 用於 Diablo 4
按 B 按鈕時觸發 QWERFG 按鍵的連續按下，每 500ms 一次
要求：
- inputs 庫 (用於讀取實際控制器): pip install inputs
- pynput 庫 (用於模擬鍵盤輸入): pip install pynput
"""

import time
import threading
import json
from inputs import get_gamepad
from pynput.keyboard import Key, Controller as KeyboardController

# 初始化控制器
keyboard = KeyboardController()

# 全局變數
auto_mode = False  # 自動連按模式狀態
keys_to_press = ['q', 'w', 'e', 'r', 'f', 'g']  # 要連續按的按鍵
press_interval = 0.5  # 按鍵間隔 (秒)

# 按鍵映射
button_mapping = {
    'BTN_SOUTH': 'A',       # A 按鈕
    'BTN_EAST': 'B',        # B 按鈕
    'BTN_WEST': 'X',        # X 按鈕
    'BTN_NORTH': 'Y',       # Y 按鈕
    'BTN_TL': 'LB',         # LB 按鈕
    'BTN_TR': 'RB'          # RB 按鈕
}

# 監控 Xbox 控制器輸入的線程
def monitor_controller():
    global auto_mode
    
    print("開始監控 Xbox 控制器...")
    
    try:
        while True:
            events = get_gamepad()
            for event in events:
                # 只處理按鈕按下事件
                if event.ev_type == 'Key' and event.code == 'BTN_EAST' and event.state == 1:
                    # B 按鈕被按下，切換自動連按模式
                    auto_mode = not auto_mode
                    if auto_mode:
                        print("自動連按模式開啟 - 開始連續按 QWERFG 鍵")
                    else:
                        print("自動連按模式關閉 - 停止連續按鍵")
    except Exception as e:
        print(f"控制器監控錯誤: {e}")
        print("請確保 Xbox 控制器已正確連接")

# 自動連按線程
def auto_press_keys():
    global auto_mode
    
    # 記錄上次按鍵時間
    last_press_times = {}
    for key in keys_to_press:
        last_press_times[key] = 0
    
    try:
        while True:
            if auto_mode:
                current_time = time.time()
                
                # 遍歷所有需要連按的按鍵
                for key in keys_to_press:
                    # 檢查是否需要按下
                    if current_time - last_press_times[key] >= press_interval:
                        # 按下按鍵
                        try:
                            keyboard.press(key)
                            time.sleep(0.05)  # 短暫延遲
                            keyboard.release(key)
                            
                            # 更新上次按鍵時間
                            last_press_times[key] = current_time
                            
                            # 按鍵按下提示 (調試用)
                            # print(f"按下 {key} 鍵")
                        except Exception as e:
                            print(f"按鍵 {key} 執行錯誤: {e}")
            
            # 短暫睡眠，避免 CPU 過載
            time.sleep(0.01)
    except Exception as e:
        print(f"自動連按錯誤: {e}")

# 主函數
def main():
    print("Xbox 控制器 Diablo 4 宏腳本啟動中...")
    print("按 B 按鈕切換自動連按模式，自動連按 QWERFG 鍵")
    
    # 啟動監控線程
    monitor_thread = threading.Thread(target=monitor_controller)
    monitor_thread.daemon = True
    monitor_thread.start()
    
    # 啟動自動連按線程
    auto_press_thread = threading.Thread(target=auto_press_keys)
    auto_press_thread.daemon = True
    auto_press_thread.start()
    
    print("腳本已啟動! 按 Ctrl+C 退出")
    
    try:
        # 保持主線程運行
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("腳本已停止")

# 啟動腳本
if __name__ == "__main__":
    main()