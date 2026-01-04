# ===================================================================
# Samba 認證配置
# 此檔案包含敏感資訊,請確保檔案權限設定正確
# ===================================================================

# Samba 伺服器資訊
$SambaServer = "192.168.31.5"
$SambaShare = "allenl_home"
$SambaUser = "allenl"

# Samba 密碼
# 注意: 此檔案包含明文密碼,請確保只有管理員可以讀取
$SambaPassword = "ffff"

# 匯出變數供其他腳本使用
$Global:SambaCredentials = @{
    Server = $SambaServer
    Share = $SambaShare
    User = $SambaUser
    Password = $SambaPassword
}