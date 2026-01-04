### 整合後的功能包括：

1. **端口轉發設置**：設置從Windows到WSL的端口轉發
2. **防火牆規則配置**：在WSL中配置iptables防火牆規則，允許TCP、UDP和ICMP流量
3. **可選的測試IP添加**：可以選擇添加專用的測試IP地址
4. **自動生成Windows腳本**：生成PowerShell腳本用於在Windows中設置端口轉發
5. **可選的自動執行Windows腳本**：嘗試自動在Windows中運行生成的PowerShell腳本
6. **可選的網絡監控**：可以選擇啟動tcpdump進行網絡監控
7. **詳細的命令行選項**：提供多個命令行選項來控制腳本行為

### 使用方法：

```bash
python3 setup_ipv4_env.py <端口> [添加測試IP?] [測試IP地址] [啟動網絡監控?] [自動運行Windows腳本?]
```

例如：
```bash
# 基本用法，只設置端口轉發
python3 setup_ipv4_env.py 8091

# 設置端口轉發，添加測試IP，啟動網絡監控，但不自動運行Windows腳本
python3 setup_ipv4_env.py 8091 y 192.168.100.50 y n

# 設置端口轉發，不添加測試IP，啟動網絡監控
python3 setup_ipv4_env.py 8091 n - y
```

這個整合後的腳本結合了兩個原始腳本的所有功能，並提供了更多的選項和更好的用戶體驗。