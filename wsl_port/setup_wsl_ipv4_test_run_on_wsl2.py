#!/usr/bin/env python3

import subprocess
import sys
import os
import re

def get_wsl_ip():
    """獲取WSL的IP地址"""
    try:
        result = subprocess.run("ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1",
                               shell=True, capture_output=True, text=True, check=True)
        ip = result.stdout.strip()
        if not ip:
            raise Exception("無法獲取WSL IP地址")
        return ip
    except Exception as e:
        print(f"錯誤: {str(e)}")
        sys.exit(1)

def setup_wsl_firewall(port):
    """設置WSL防火牆規則"""
    try:
        print(f"正在設置WSL防火牆規則，允許端口 {port}...")
        # 允許TCP流量
        subprocess.run(f"sudo iptables -A INPUT -p tcp --dport {port} -j ACCEPT", 
                      shell=True, check=True)
        # 允許UDP流量
        subprocess.run(f"sudo iptables -A INPUT -p udp --dport {port} -j ACCEPT", 
                      shell=True, check=True)
        # 允許ICMP流量
        subprocess.run(f"sudo iptables -A INPUT -p icmp -j ACCEPT", 
                      shell=True, check=True)
        print("WSL防火牆規則設置成功")
    except subprocess.CalledProcessError:
        print("設置WSL防火牆規則失敗，請確認您有sudo權限")
        sys.exit(1)

def add_test_ip(test_ip):
    """添加測試IP地址"""
    try:
        print(f"正在添加測試IP地址: {test_ip}...")
        subprocess.run(f"sudo ip addr add {test_ip}/24 dev eth0", 
                      shell=True, check=True)
        print(f"測試IP地址添加成功: {test_ip}")
        return True
    except subprocess.CalledProcessError:
        print(f"添加測試IP地址失敗: {test_ip}")
        return False

def generate_windows_script(wsl_ip, port):
    """生成Windows端執行的PowerShell腳本"""
    windows_script = f"""
# 此腳本需要在Windows PowerShell中以管理員身份運行
# 首先移除可能存在的舊規則
netsh interface portproxy delete v4tov4 listenport={port} listenaddress=0.0.0.0 2>$null

# 添加新的端口轉發規則
netsh interface portproxy add v4tov4 listenport={port} listenaddress=0.0.0.0 connectport={port} connectaddress={wsl_ip}

# 添加防火牆規則
New-NetFirewallRule -DisplayName "WSL IPv4 Test Suite Port {port}" -Direction Inbound -LocalPort {port} -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

# 顯示當前端口轉發設置
Write-Host "端口轉發設置:"
netsh interface portproxy show v4tov4

Write-Host "`n設置完成!"
Write-Host "現在您可以在Windows上的Defensics Monitor中使用以下設置:"
Write-Host "地址: localhost 或 127.0.0.1"
Write-Host "端口: {port}"
"""
    
    # 將腳本寫入文件
    script_path = os.path.join(os.path.expanduser("~"), "setup_port_forward.ps1")
    with open(script_path, "w") as f:
        f.write(windows_script)
    
    print(f"Windows端口轉發腳本已生成: {script_path}")
    print("請在Windows中以管理員身份運行此PowerShell腳本")
    
    # 顯示Windows中文件的預期路徑
    windows_path = subprocess.run("wslpath -w " + script_path, 
                                 shell=True, capture_output=True, text=True).stdout.strip()
    print(f"Windows路徑: {windows_path}")
    
    return script_path

def start_network_monitoring():
    """啟動網絡監控"""
    try:
        print("正在啟動網絡監控 (tcpdump)...")
        subprocess.Popen(["sudo", "tcpdump", "-i", "eth0", "-n", "ip"])
        print("網絡監控已啟動，按 Ctrl+C 停止")
        return True
    except:
        print("啟動網絡監控失敗")
        return False

def setup_ipv4_test_environment(port, add_ip=False, test_ip="192.168.100.50", start_monitor=False, auto_run_windows=True):
    """設置IPv4測試環境"""
    # 配置WSL網絡
    print("正在配置WSL網絡設置...")
    
    # 獲取當前WSL IP
    current_ip = get_wsl_ip()
    print(f"當前WSL IP地址: {current_ip}")
    
    # 如果需要，添加測試IP
    if add_ip:
        ip_added = add_test_ip(test_ip)
        # 如果成功添加測試IP，使用它進行端口轉發
        if ip_added:
            wsl_ip = test_ip
        else:
            wsl_ip = current_ip
    else:
        wsl_ip = current_ip
    
    # 設置WSL防火牆
    setup_wsl_firewall(port)
    
    # 生成Windows腳本
    windows_script = generate_windows_script(wsl_ip, port)
    
    # 如果需要，自動在Windows中運行腳本
    if auto_run_windows:
        try:
            print("\n嘗試自動執行Windows腳本...")
            subprocess.run(f"powershell.exe -Command \"Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File {windows_script}' -Verb RunAs\"", 
                          shell=True)
            print("Windows腳本啟動成功，請在Windows中查看彈出的PowerShell窗口")
        except:
            print("無法自動執行Windows腳本，請手動運行該腳本")
    
    # 如果需要，啟動網絡監控
    if start_monitor:
        start_network_monitoring()
    
    print("\nWSL環境設置已完成")
    print(f"要在Defensics中使用此環境，請使用以下設置:")
    print(f"協議: IPv4")
    print(f"地址: localhost 或 127.0.0.1")
    print(f"端口: {port}")

def main():
    if len(sys.argv) < 2:
        print("用法: python3 setup_ipv4_env.py <端口> [添加測試IP?] [測試IP地址] [啟動網絡監控?] [自動運行Windows腳本?]")
        print("參數:")
        print("  <端口> - 必須，用於測試的端口號")
        print("  [添加測試IP?] - 可選，是否添加測試IP (y/n)，默認為n")
        print("  [測試IP地址] - 可選，測試IP地址，默認為192.168.100.50")
        print("  [啟動網絡監控?] - 可選，是否啟動網絡監控 (y/n)，默認為n")
        print("  [自動運行Windows腳本?] - 可選，是否嘗試自動在Windows中運行腳本 (y/n)，默認為y")
        print("\n例如: python3 setup_ipv4_env.py 8091")
        print("例如: python3 setup_ipv4_env.py 8091 y 192.168.100.50 y n")
        sys.exit(1)
    
    try:
        port = int(sys.argv[1])
    except ValueError:
        print("錯誤: 端口必須是數字")
        sys.exit(1)
    
    # 解析可選參數
    add_ip = False
    test_ip = "192.168.100.50"
    start_monitor = False
    auto_run_windows = True
    
    if len(sys.argv) >= 3:
        add_ip = sys.argv[2].lower() == 'y'
    
    if len(sys.argv) >= 4:
        test_ip = sys.argv[3]
    
    if len(sys.argv) >= 5:
        start_monitor = sys.argv[4].lower() == 'y'
    
    if len(sys.argv) >= 6:
        auto_run_windows = sys.argv[5].lower() == 'y'
    
    # 設置IPv4測試環境
    setup_ipv4_test_environment(port, add_ip, test_ip, start_monitor, auto_run_windows)

if __name__ == "__main__":
    main()