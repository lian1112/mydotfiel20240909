#!/usr/bin/env python3
import socket
import sys

def start_udp_responder(port):
    """啟動一個簡單的UDP響應服務"""
    print(f"啟動UDP響應服務在端口 {port}...")
    
    # 創建UDP套接字
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', port))
    
    print(f"服務已啟動，等待數據...")
    
    try:
        while True:
            # 接收數據
            data, addr = sock.recvfrom(1024)
            print(f"收到來自 {addr} 的數據: {len(data)} 字節")
            
            # 發送回應
            sock.sendto(data, addr)
            print(f"已回應到 {addr}")
    except KeyboardInterrupt:
        print("服務已停止")
    finally:
        sock.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python3 udp_responder.py <端口>")
        sys.exit(1)
    
    try:
        port = int(sys.argv[1])
    except ValueError:
        print("錯誤: 端口必須是數字")
        sys.exit(1)
    
    start_udp_responder(port)