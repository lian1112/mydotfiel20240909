#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import sys
import os
import time

# 設置控制台輸出編碼
if sys.platform.startswith('win'):
    # Windows 平台下設置控制台編碼
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def get_wsl_ip():
    """Get the WSL IP address using Windows commands"""
    print("正在獲取WSL IP地址...")
    try:
        result = subprocess.run(
            ["wsl", "bash", "-c", "ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1"],
            capture_output=True, text=True, check=True, timeout=10
        )
        ip = result.stdout.strip()
        # 移除可能的"inet"前綴
        ip = ip.replace("inet ", "").strip()
        if not ip:
            raise Exception("無法獲取WSL IP地址")
        print(f"獲取到WSL IP地址: {ip}")
        return ip
    except subprocess.TimeoutExpired:
        print("獲取WSL IP地址超時。請確保WSL已經啟動。")
        sys.exit(1)
    except Exception as e:
        print(f"獲取WSL IP地址時出錯: {str(e)}")
        sys.exit(1)

def setup_port_forwarding(wsl_ip, port):
    """Setup port forwarding from Windows to WSL"""
    print(f"正在設置端口轉發 (Windows:{port} -> WSL:{port})...")
    try:
        # 執行netsh命令設置端口轉發，添加超時
        subprocess.run(
            ["netsh", "interface", "portproxy", "add", "v4tov4", 
             f"listenport={port}", "listenaddress=0.0.0.0", 
             f"connectport={port}", f"connectaddress={wsl_ip}"],
            check=True, capture_output=True, timeout=15
        )
        print(f"成功設置端口轉發")
        
        # 添加防火牆規則，添加超時
        print("正在添加防火牆規則...")
        subprocess.run(
            ["powershell", "-Command", 
             f"New-NetFirewallRule -DisplayName \"WSL IPv4 Test Suite Port {port}\" -Direction Inbound -LocalPort {port} -Protocol TCP -Action Allow"],
            check=True, capture_output=True, timeout=15
        )
        print(f"成功添加防火牆規則")
    except subprocess.TimeoutExpired:
        print("設置端口轉發超時。請確保您以管理員身份運行此腳本。")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"設置端口轉發時出錯: {e}")
        print(f"錯誤輸出: {e.stderr}")
        print("請確保您以管理員身份運行此腳本")
        sys.exit(1)

def setup_wsl_firewall(port):
    """Setup firewall rules in WSL without waiting for password prompt"""
    print(f"正在設置WSL防火牆規則...")
    try:
        # 使用-n選項讓sudo不等待密碼輸入，如果需要密碼則立即失敗
        subprocess.run(
            ["wsl", "sudo", "-n", "iptables", "-A", "INPUT", "-p", "tcp", "--dport", str(port), "-j", "ACCEPT"],
            check=True, capture_output=True, timeout=10
        )
        print(f"成功在WSL中配置防火牆規則")
    except subprocess.TimeoutExpired:
        print("在WSL中設置防火牆規則超時")
        print("您可能需要在WSL中手動運行以下命令:")
        print(f"sudo iptables -A INPUT -p tcp --dport {port} -j ACCEPT")
    except subprocess.CalledProcessError as e:
        print(f"在WSL中設置防火牆規則時出錯")
        print("您可能需要在WSL中手動運行以下命令:")
        print(f"sudo iptables -A INPUT -p tcp --dport {port} -j ACCEPT")

def main():
    if len(sys.argv) < 2:
        print("用法: python setup_wsl_port.py <端口>")
        sys.exit(1)
    
    try:
        port = int(sys.argv[1])
    except ValueError:
        print("錯誤: 端口必須是數字")
        sys.exit(1)
    
    print("正在啟動WSL端口轉發設置...")
    
    # 檢查WSL是否在運行
    try:
        subprocess.run(["wsl", "echo", "WSL is running"], check=True, timeout=5, capture_output=True)
    except:
        print("WSL似乎沒有運行。請先啟動WSL，然後再運行此腳本。")
        print("您可以通過在命令提示符中輸入 'wsl' 來啟動WSL。")
        sys.exit(1)
    
    wsl_ip = get_wsl_ip()
    setup_port_forwarding(wsl_ip, port)
    setup_wsl_firewall(port)
    
    print("\n設置完成!")
    print(f"現在您可以在Windows上的Defensics Monitor中使用以下設置:")
    print(f"地址: localhost 或 127.0.0.1")
    print(f"端口: {port}")
    print("\n如需驗證端口轉發是否成功，請運行:")
    print(f"netsh interface portproxy show v4tov4")

if __name__ == "__main__":
    main()