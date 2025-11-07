# Defensics IPv4 與 UDPv4 測試套件在 WSL 環境中的配置指南

本文檔提供了使用 Windows Subsystem for Linux (WSL) 設置 Synopsys Defensics 測試環境的完整步驟和腳本，重點關注 IPv4 Test Suite 和 UDPv4 Test Suite。

## 目錄

- [前提條件](#前提條件)
- [測試套件說明](#測試套件說明)
- [環境準備](#環境準備)
- [WSL 網絡配置](#wsl-網絡配置)
- [Windows 端口轉發設置](#windows-端口轉發設置)
- [Defensics 配置](#defensics-配置)
- [響應服務設置](#響應服務設置)
- [自動化腳本](#自動化腳本)
- [測試執行與監控](#測試執行與監控)
- [常見問題排解](#常見問題排解)
- [其他測試套件配置](#其他測試套件配置)

## 前提條件

- Windows 10/11 系統
- WSL 2 已安裝
- Ubuntu 或其他 Linux 發行版在 WSL 中運行
- Synopsys Defensics 已安裝在 Windows 上
- 管理員權限

## 測試套件說明

Defensics 包含多種網絡協議測試套件，本文檔主要關注：

### IPv4 Test Suite

- **測試目標**：測試 IP 協議本身的實現
- **測試內容**：IP 頭部處理、分片/重組、路由、選項處理等
- **測試方法**：向目標發送各種標準和非標準（故意構造的畸形）IP 封包
- **注意事項**：可能會使用各種協議（TCP、UDP、ICMP 等）作為載荷

### UDPv4 Test Suite

- **測試目標**：測試 UDP 協議的實現
- **測試內容**：UDP 頭部處理、校驗和、端口處理等
- **測試方法**：發送各種 UDP 封包，通常使用 SNMP 等應用層協議作為載荷
- **注意事項**：默認使用 SNMP 協議（端口 161）進行測試

## 環境準備

在 WSL 中安裝必要的網絡工具：

```bash
sudo apt update
sudo apt install net-tools iproute2 iputils-ping tcpdump python3
```

## WSL 網絡配置

### 1. 檢查 WSL 網絡接口

```bash
ip a
```

記錄 eth0 接口的 IP 地址（如 172.21.140.96）

### 2. 設置防火牆規則

在 WSL 中執行：

```bash
# 允許所有入站流量
sudo iptables -A INPUT -p all -j ACCEPT
# 允許所有轉發流量
sudo iptables -A FORWARD -p all -j ACCEPT
```

### 3. 添加虛擬 IP 地址

添加一個虛擬 IP 地址，用於 Defensics 作為測試流量的源地址：

```bash
# 獲取當前 IP 的子網掩碼
CIDR=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f2)
# 計算新的 IP（當前 IP 的最後一段加 1）
CURRENT_IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
IP_PARTS=(${CURRENT_IP//./ })
LAST_OCTET=$((${IP_PARTS[3]} + 1))
VIRTUAL_IP="${IP_PARTS[0]}.${IP_PARTS[1]}.${IP_PARTS[2]}.$LAST_OCTET"
# 添加虛擬 IP
sudo ip addr add $VIRTUAL_IP/$CIDR dev eth0
```

## Windows 端口轉發設置

要將 WSL 服務暴露給 Windows，需要設置端口轉發。在 PowerShell（管理員身份）中執行：

```powershell
# 獲取 WSL IP 地址（需要先在 WSL 中查看）
$wslIp = "172.21.140.96"  # 替換為您的 WSL IP

# 設置 SNMP 端口轉發（用於 UDPv4 Test Suite）
netsh interface portproxy add v4tov4 listenport=161 listenaddress=0.0.0.0 connectport=161 connectaddress=$wslIp

# 添加防火牆規則
New-NetFirewallRule -DisplayName "WSL SNMP Test" -Direction Inbound -LocalPort 161 -Protocol UDP -Action Allow

# 對於可能需要的其他端口（如自動選擇的端口）
# 您可以添加額外的端口轉發
netsh interface portproxy add v4tov4 listenport=8091 listenaddress=0.0.0.0 connectport=8091 connectaddress=$wslIp
New-NetFirewallRule -DisplayName "WSL Additional Test Port" -Direction Inbound -LocalPort 8091 -Protocol UDP -Action Allow
```

## Defensics 配置

在 Defensics 中進行測試套件配置：

### IPv4 Test Suite 配置

#### 1. 基本設置

- **Target IP address**：您的 WSL IP 地址（如 172.21.140.96）
  - 這是被測系統（SUT）的地址，即測試封包的目標地址
  - Defensics 將向此地址發送測試封包

- **Name of network device**：選擇您的網絡接口（如 ethernet_32777）
  - 這是 Defensics 用來發送測試封包的物理接口

#### 2. 虛擬地址設置

- **Virtual IP address**：虛擬 IP 地址（如 172.21.140.97）
  - 這是測試封包的源 IP 地址
  - Defensics 將使用此地址作為發送測試封包的來源

- **Virtual Ethernet MAC address**：虛擬 MAC 地址（如 0a:c0:de:3b:65:c2）
  - 這是測試封包的源 MAC 地址
  - Defensics 將使用此 MAC 地址構建乙太網幀

#### 3. 其他設置

- **ARP frequency**：100（或根據需要調整）
- **Pad Ethernet frames to 60 bytes**：勾選

### UDPv4 Test Suite 配置

#### 1. 基本設置

與 IPv4 Test Suite 相同：
- **Target IP address**：您的 WSL IP 地址
- **Name of network device**：選擇網絡接口

#### 2. UDP 負載設置

- **UDP payload type**：Built-in SNMP（默認設置）
- **UDP source port range**：1024-65535
- **UDP target port**：161（SNMP 標準端口）

## 響應服務設置

要使測試成功，需要在 WSL 中運行響應服務來回應 Defensics 的測試封包。下面提供了兩種不同的響應服務，分別針對不同的測試套件：

### 1. 通用響應服務

此服務可以響應各種協議的基本測試，適用於 IPv4 Test Suite：

```python
#!/usr/bin/env python3
import socket
import sys
import binascii
import struct
import threading

def start_ip_responder():
    """啟動一個回應各種 IP 協議的服務"""
    print("啟動通用 IP 協議響應服務...")
    
    # 創建原始套接字來捕獲所有 IP 封包
    try:
        sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ntohs(0x0003))
        print("原始套接字創建成功，等待數據...")
    except PermissionError:
        print("錯誤: 需要 root 權限運行此腳本")
        sys.exit(1)
    except Exception as e:
        print(f"創建套接字時出錯: {str(e)}")
        sys.exit(1)
    
    try:
        while True:
            # 接收數據包
            packet, addr = sock.recvfrom(65536)
            
            # 解析以太網頭部
            eth_header = packet[0:14]
            eth = struct.unpack("!6s6s2s", eth_header)
            
            # 檢查是否為 IP 封包 (0x0800)
            if eth[2] != b'\x08\x00':
                continue
            
            # 獲取源 MAC 和目的 MAC
            dst_mac = eth_header[0:6]
            src_mac = eth_header[6:12]
            
            # 解析 IP 頭部
            ip_header = packet[14:34]
            iph = struct.unpack('!BBHHHBBH4s4s', ip_header)
            
            version_ihl = iph[0]
            ihl = version_ihl & 0xF
            version = version_ihl >> 4
            
            protocol = iph[6]
            s_addr = iph[8]
            d_addr = iph[9]
            
            # 檢查是否發送到我們的地址
            my_ip = socket.inet_aton(socket.gethostbyname(socket.gethostname()))
            
            # 如果目標不是我們，或者是從我們發出的，則跳過
            if d_addr != my_ip or s_addr == my_ip:
                continue
            
            print(f"\n收到 IPv{version} 封包，協議: {protocol}")
            
            # 構建回應
            # 交換 MAC 地址
            response_eth_header = dst_mac + src_mac + eth[2]
            
            # 構建 IP 頭部（簡單交換源和目的地址）
            response_ip_header = struct.pack('!BBHHHBBH4s4s',
                                           version_ihl,
                                           0,  # ToS
                                           20 + 8,  # 總長度 (IP 頭部 + UDP 頭部)
                                           0,  # ID
                                           0,  # Flags/Fragment offset
                                           64,  # TTL
                                           protocol,  # Protocol
                                           0,  # 校驗和（暫時為 0）
                                           d_addr,  # 源地址（原目標）
                                           s_addr   # 目標地址（原源）
                                          )
            
            # 根據協議構建適當的回應
            if protocol == 1:  # ICMP
                print("響應 ICMP 封包")
                # ICMP Echo 回應
                icmp_header = packet[34:42]
                icmp_type = icmp_header[0]
                
                if icmp_type == 8:  # Echo 請求
                    # 將 type 改為 0 (Echo 回應)
                    response_icmp = b'\x00' + icmp_header[1:8]
                    payload = packet[42:]
                    response_payload = response_eth_header + response_ip_header + response_icmp + payload
                    sock.send(response_payload)
                
            elif protocol == 17:  # UDP
                print("響應 UDP 封包")
                udp_header = packet[34:42]
                src_port, dst_port, length, checksum = struct.unpack('!HHHH', udp_header)
                
                # 構建回應 UDP 頭部（交換端口）
                response_udp_header = struct.pack('!HHHH',
                                               dst_port,  # 源端口（原目標）
                                               src_port,  # 目標端口（原源）
                                               length,    # 長度
                                               0          # 校驗和（暫時為 0）
                                              )
                
                payload = packet[42:42 + length - 8]  # UDP 頭部長度為 8
                response_payload = response_eth_header + response_ip_header + response_udp_header + payload
                sock.send(response_payload)
                
                print(f"已回應到 UDP 端口 {src_port}")
            
            # 可以添加其他協議的處理（如 TCP 等）
            
    except KeyboardInterrupt:
        print("服務已停止")
    finally:
        sock.close()

def start_udp_service(port):
    """啟動特定端口的 UDP 服務"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', port))
    
    print(f"UDP 服務已啟動在端口 {port}")
    
    try:
        while True:
            data, addr = sock.recvfrom(4096)
            print(f"UDP 端口 {port} 收到來自 {addr} 的數據: {len(data)} 字節")
            
            # 發送回應
            sock.sendto(data, addr)
            print(f"已回應到 {addr}")
    except KeyboardInterrupt:
        pass
    finally:
        sock.close()

def start_snmp_service(port=161):
    """啟動 SNMP 服務"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    try:
        sock.bind(('0.0.0.0', port))
    except PermissionError:
        print(f"錯誤: 無法綁定到端口 {port}，需要 root 權限")
        return
    
    print(f"SNMP 服務已啟動在端口 {port}")
    
    try:
        while True:
            data, addr = sock.recvfrom(4096)
            print(f"SNMP 收到來自 {addr} 的數據: {len(data)} 字節")
            
            # SNMP 回應邏輯
            response = bytearray(data)
            
            # 如果這是 Get 請求，修改為 GetResponse
            if len(data) > 20 and data[18] == 0xa0:
                response[18] = 0xa2  # 將 Get(0xa0) 改為 GetResponse(0xa2)
            
            # 發送回應
            sock.sendto(response, addr)
            print(f"已回應 SNMP 請求到 {addr}")
    except KeyboardInterrupt:
        pass
    finally:
        sock.close()

if __name__ == "__main__":
    # 啟動多個服務
    print("啟動綜合響應服務...")
    
    # 啟動 SNMP 服務（端口 161，需要 root 權限）
    snmp_thread = threading.Thread(target=start_snmp_service)
    snmp_thread.daemon = True
    snmp_thread.start()
    
    # 啟動通用 UDP 服務（端口 8091）
    udp_thread = threading.Thread(target=start_udp_service, args=(8091,))
    udp_thread.daemon = True
    udp_thread.start()
    
    # 啟動 IP 響應服務（主服務）
    try:
        start_ip_responder()
    except KeyboardInterrupt:
        print("\n所有服務已停止")
```

將上述代碼保存為 `defensics_responder.py`，然後在 WSL 中以 root 權限運行：

```bash
sudo python3 defensics_responder.py
```

這個腳本會同時啟動多個服務：
1. 通用 IP 響應服務 - 響應各種 IP 協議
2. SNMP 服務（端口 161）- 專門響應 UDPv4 Test Suite 的 SNMP 測試
3. 通用 UDP 服務（端口 8091）- 響應其他 UDP 端口的測試

## 自動化腳本

以下是一個全面的自動化腳本，用於配置 WSL 環境以進行 Defensics 測試：

```python
#!/usr/bin/env python3

import subprocess
import sys
import os
import threading
import socket
import time
import binascii

def get_wsl_ip():
    """獲取 WSL 的 IP 地址"""
    try:
        result = subprocess.run("ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1",
                               shell=True, capture_output=True, text=True, check=True)
        ip = result.stdout.strip()
        if not ip:
            raise Exception("無法獲取 WSL IP 地址")
        return ip
    except Exception as e:
        print(f"錯誤: {str(e)}")
        sys.exit(1)

def setup_wsl_firewall():
    """設置 WSL 防火牆規則"""
    try:
        print("正在設置 WSL 防火牆規則...")
        # 允許所有進入的 IPv4 流量
        subprocess.run("sudo iptables -A INPUT -p all -j ACCEPT", shell=True, check=True)
        # 允許所有轉發的 IPv4 流量
        subprocess.run("sudo iptables -A FORWARD -p all -j ACCEPT", shell=True, check=True)
        print("WSL 防火牆規則設置成功")
    except subprocess.CalledProcessError:
        print("設置 WSL 防火牆規則失敗，請確認您有 sudo 權限")
        sys.exit(1)

def add_virtual_ip(current_ip, virtual_ip):
    """添加虛擬 IP 地址"""
    try:
        print(f"正在添加虛擬 IP 地址: {virtual_ip}...")
        # 提取子網掩碼
        result = subprocess.run("ip addr show eth0 | grep 'inet ' | awk '{print $2}'",
                               shell=True, capture_output=True, text=True, check=True)
        cidr = result.stdout.strip().split('/')[1]
        
        # 添加虛擬 IP
        subprocess.run(f"sudo ip addr add {virtual_ip}/{cidr} dev eth0", shell=True, check=True)
        print(f"虛擬 IP 地址添加成功: {virtual_ip}")
        return True
    except subprocess.CalledProcessError:
        print(f"添加虛擬 IP 地址失敗: {virtual_ip}")
        return False

def generate_windows_script(wsl_ip):
    """生成 Windows 端執行的 PowerShell 腳本"""
    windows_script = f"""
# 此腳本需要在 Windows PowerShell 中以管理員身份運行

# 設置 SNMP 端口轉發（用於 UDPv4 Test Suite）
netsh interface portproxy delete v4tov4 listenport=161 listenaddress=0.0.0.0 2>$null
netsh interface portproxy add v4tov4 listenport=161 listenaddress=0.0.0.0 connectport=161 connectaddress={wsl_ip}

# 添加 SNMP 防火牆規則
New-NetFirewallRule -DisplayName "WSL SNMP Test" -Direction Inbound -LocalPort 161 -Protocol UDP -Action Allow -ErrorAction SilentlyContinue

# 設置通用測試端口轉發
netsh interface portproxy delete v4tov4 listenport=8091 listenaddress=0.0.0.0 2>$null
netsh interface portproxy add v4tov4 listenport=8091 listenaddress=0.0.0.0 connectport=8091 connectaddress={wsl_ip}

# 添加通用測試端口防火牆規則
New-NetFirewallRule -DisplayName "WSL Generic Test Port" -Direction Inbound -LocalPort 8091 -Protocol UDP -Action Allow -ErrorAction SilentlyContinue

# 顯示當前端口轉發設置
Write-Host "端口轉發設置:"
netsh interface portproxy show v4tov4

Write-Host "`n設置完成!"
Write-Host "現在您可以在 Defensics 中使用以下設置:"
Write-Host "目標 IP 地址: localhost 或 127.0.0.1（使用端口轉發）"
Write-Host "或者直接使用 WSL IP 地址: {wsl_ip}"
"""
    
    # 將腳本寫入文件
    script_path = os.path.join(os.path.expanduser("~"), "setup_defensics_test.ps1")
    with open(script_path, "w") as f:
        f.write(windows_script)
    
    print(f"Windows 端口轉發腳本已生成: {script_path}")
    print("請在 Windows 中以管理員身份運行此 PowerShell 腳本")
    
    # 顯示 Windows 中文件的預期路徑
    windows_path = subprocess.run("wslpath -w " + script_path, 
                                 shell=True, capture_output=True, text=True).stdout.strip()
    print(f"Windows 路徑: {windows_path}")
    
    return script_path

def start_tcpdump_monitoring():
    """啟動 tcpdump 監控"""
    print("正在啟動網絡監控...")
    
    # 監控 SNMP 流量
    subprocess.Popen(["sudo", "tcpdump", "-i", "eth0", "-n", "udp port 161"])
    
    # 監控其他測試流量
    subprocess.Popen(["sudo", "tcpdump", "-i", "eth0", "-n", "udp port 8091"])
    
    print("網絡監控已啟動，在其他終端窗口中顯示")

def setup_defensics_test_environment(auto_run_windows=True, start_monitor=False):
    """設置 Defensics 測試環境"""
    # 獲取當前 WSL IP
    current_ip = get_wsl_ip()
    print(f"當前 WSL IP 地址: {current_ip}")
    
    # 計算虛擬 IP（當前 IP 的最後一段加 1）
    ip_parts = current_ip.split('.')
    last_octet = int(ip_parts[3]) + 1
    ip_parts[3] = str(last_octet)
    virtual_ip = '.'.join(ip_parts)
    
    # 添加虛擬 IP
    add_virtual_ip(current_ip, virtual_ip)
    
    # 設置 WSL 防火牆
    setup_wsl_firewall()
    
    # 生成 Windows 腳本
    windows_script = generate_windows_script(current_ip)
    
    # 如果需要，自動在 Windows 中運行腳本
    if auto_run_windows:
        try:
            print("\n嘗試自動執行 Windows 腳本...")
            subprocess.run(f"powershell.exe -Command \"Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File {windows_script}' -Verb RunAs\"", 
                          shell=True)
            print("Windows 腳本啟動成功，請在 Windows 中查看彈出的 PowerShell 窗口")
        except:
            print("無法自動執行 Windows 腳本，請手動運行該腳本")
    
    # 如果需要，啟動網絡監控
    if start_monitor:
        start_tcpdump_monitoring()
    
    print("\nDefensics 測試環境設置已完成")
    print(f"\nDefensics 配置指南:")
    print("\n1. IPv4 Test Suite 配置:")
    print(f"   - Target IP address: {current_ip}")
    print(f"   - Virtual IP address: {virtual_ip}")
    print("   - Virtual Ethernet MAC address: 0a:c0:de:3b:65:c2（或其他自定義值）")
    
    print("\n2. UDPv4 Test Suite 配置:")
    print(f"   - Target IP address: {current_ip}")
    print("   - UDP payload type: Built-in SNMP")
    print("   - UDP target port: 161")
    
    print("\n備註:")
    print("1. 請確保 'defensics_responder.py' 腳本正在運行")
    print("2. 如果使用端口轉發，也可以使用 localhost/127.0.0.1 作為目標 IP")
    
    print("\n現在，您可以啟動 Defensics 並開始測試。")

def main():
    print("Defensics 測試環境配置工具")
    print("--------------------------")
    
    auto_run = input("是否自動在 Windows 中運行端口轉發腳本? (y/n, 默認: y): ").lower() != 'n'
    monitor = input("是否啟動網絡監控? (y/n, 默認: n): ").lower() == 'y'
    
    setup_defensics_test_environment(auto_run, monitor)
    
    print("\n環境已配置完成。")
    print("請在另一個終端窗口運行響應服務:")
    print("sudo python3 defensics_responder.py")
    
    choice = input("是否顯示響應服務腳本的內容? (y/n, 默認: n): ").lower()
    if choice == 'y':
        # 這裡應該是響應服務腳本的內容，由於篇幅限制，實際使用時需要完整提供
        print("請參閱本文檔中的響應服務設置部分")

if __name__ == "__main__":
    main()
```

## 測試執行與監控

### 1. 環境設置

執行環境設置腳本：

```bash
python3 setup_defensics_environment.py
```

按照提示完成配置。

### 2. 啟動響應服務

在另一個 WSL 終端窗口中啟動響應服務：

```bash
sudo python3 defensics_responder.py
```

### 3. 在 Defensics 中開始測試

- 打開 Defensics
- 選擇適當的測試套件（IPv4 Test Suite 或 UDPv4 Test Suite）
- 按照前面提到的設置配置測試參數
- 開始測試

### 4. 監控測試過程

如果您啟用了網絡監控，可以在單獨的終端窗口中查看網絡流量：

```bash
# 監控 SNMP 流量
sudo tcpdump -i eth0 -n 'udp port 161'

# 監控其他測試流量
sudo tcpdump -i eth0 -n 'udp port 8091'
```

## 常見問題排解

### 1. 沒有收到測試封包

檢查：
1. 確認 Windows 端口轉發是否正確設置：
   ```powershell
   netsh interface portproxy show v4tov4
   ```
2. 確認 WSL 中的防火牆規則：
   ```bash
   sudo iptables -L
   ```
3. 使用 tcpdump 監控特定端口的流量：
   ```bash
   sudo tcpdump -i eth0 -n 'host 172.21.140.96'
   ```

### 2. 測試顯示"No response within the timeout"

可能原因：
1. 響應服務沒有正確響應
2. 響應未返回到 Defensics
3. 使用了錯誤的測試套件或配置

解決方案：
1. 確保響應服務正在運行並且有適當的權限
2. 檢查網絡監控輸出，查看是否有收到測試封包
3. 調整 Defensics 中的超時設置
4. 使用 Wireshark 在 Windows 端捕獲並分析封包

### 3. WSL IP 地址變化

每次重啟 WSL 後，IP 地址可能會變化。解決方法：
1. 重新運行設置腳本
2. 更新 Defensics 配置中的 IP 地址
3. 更新 Windows 端口轉發設置

## 其他測試套件配置

除了 IPv4 和 UDPv4 測試套件外，Defensics 還包含許多其他測試套件。配置方法類似，但可能需要：

1. **安裝特定的服務器軟件**：
   - HTTP/HTTPS 測試：安裝 Apache 或 Nginx
   - FTP 測試：安裝 vsftpd
   - SSH 測試：安裝 OpenSSH Server
   - SMTP 測試：安裝 Postfix

2. **調整響應服務**：
   - 針對特定協議擴展響應服務
   - 實現特定協議的回應邏輯

3. **修改端口轉發**：
   - 根據測試套件需要設置相應的端口轉發規則

### 可在 WSL 中模擬的其他測試套件

以下測試套件可以使用類似的方法在 WSL 中配置模擬環境：

1. **HTTP 相關測試套件**：
   ```bash
   # 安裝 Apache
   sudo apt install apache2
   ```

2. **TCP 相關測試套件**：
   - 使用 netcat 或自定義服務來響應 TCP 請求
   ```bash
   # 簡單的 TCP 服務器
   netcat -l -p 8080
   ```

3. **TLS/SSL 測試套件**：
   ```bash
   # 安裝 OpenSSL
   sudo apt install openssl
   
   # 生成自簽名證書
   openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
   ```

## 最佳實踐

1. **流程自動化**：
   - 使用腳本自動配置環境
   - 將常用配置保存為模板

2. **監控與分析**：
   - 始終使用網絡監控工具監視測試流量
   - 保存測試日誌以便後續分析

3. **安全考慮**：
   - 在隔離的環境中進行測試
   - 避免在生產網絡中運行測試
   - 使用虛擬 IP 和 MAC 地址避免與實際網絡設備衝突

4. **故障排除**：
   - 分步驟調試問題
   - 從網絡層開始，逐步向上排查到應用層

## 結論

WSL 提供了一個方便的環境來配置和運行 Defensics 測試。通過適當的網絡配置和響應服務設置，您可以在 WSL 中模擬各種網絡服務，從而進行全面的協議測試。

本指南涵蓋了 IPv4 和 UDPv4 測試套件的配置，這些方法可以擴展應用到其他 Defensics 測試套件。通過自動化腳本和響應服務，您可以輕鬆建立測試環境並執行各種網絡協議測試。

---

## 附錄：測試套件與端口對照表

| 測試套件 | 主要使用端口 | 協議 | 備註 |
|---------|-------------|------|------|
| IPv4 Test Suite | 多個/不固定 | IP | 針對 IP 協議本身進行測試 |
| UDPv4 Test Suite | 161 | UDP/SNMP | 使用 SNMP 協議作為載荷 |
| TCP for IPv4 Client Test Suite | 多個/不固定 | TCP | 測試 TCP 客戶端實現 |
| TCP for IPv4 Server Test Suite | 多個/不固定 | TCP | 測試 TCP 服務器實現 |
| HTTP Server Test Suite | 80/443 | HTTP/HTTPS | 測試 HTTP 服務器實現 |
| SNMP Test Suite | 161 | SNMP | 測試 SNMP 實現 |
| TLS Test Suite | 443 | TLS/SSL | 測試 TLS 實現 |

## 附錄：常用腳本和命令

### 檢查 WSL IP 地址
```bash
ip addr show eth0 | grep 'inet '
```

### 監控特定端口
```bash
sudo tcpdump -i eth0 -n 'port 161'
```

### 檢查端口轉發
```powershell
netsh interface portproxy show v4tov4
```

### 添加虛擬 IP
```bash
sudo ip addr add 172.21.140.97/20 dev eth0
```

### 設置防火牆規則
```bash
sudo iptables -A INPUT -p all -j ACCEPT
```