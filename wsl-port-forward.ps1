# WSL2 Port Forwarding Script
# 需要以管理員權限運行

# 獲取 WSL2 的 IP 地址
$wslIP = (wsl hostname -I).Trim()
Write-Host "WSL2 IP: $wslIP"

# 要轉發的端口
$ports = @(23)

# 刪除現有的端口轉發規則
foreach ($port in $ports) {
    Write-Host "Removing existing port proxy for port $port..."
    netsh interface portproxy delete v4tov4 listenport=$port | Out-Null
}

# 添加新的端口轉發規則
foreach ($port in $ports) {
    Write-Host "Adding new port proxy for port $port..."
    netsh interface portproxy add v4tov4 listenport=$port connectaddress=$wslIP connectport=$port
}

# 添加防火牆規則
foreach ($port in $ports) {
    $ruleName = "WSL2_Port_$port"
    $ruleDisplayName = "WSL2 Port $port"
    
    # 檢查規則是否已存在
    $existingRule = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Updating existing firewall rule for port $port..."
        Set-NetFirewallRule -Name $ruleName -Enabled True
    } else {
        Write-Host "Creating new firewall rule for port $port..."
        New-NetFirewallRule -Name $ruleName -DisplayName $ruleDisplayName -Direction Inbound -LocalPort $port -Action Allow -Protocol TCP
    }
}

# 顯示所有端口轉發規則
Write-Host "`nCurrent port proxy rules:"
netsh interface portproxy show all

# 顯示防火牆規則
Write-Host "`nFirewall rules for WSL2 ports:"
foreach ($port in $ports) {
    Get-NetFirewallRule -Name "WSL2_Port_$port" | Select-Object Name, DisplayName, Enabled, Direction, Action
}
