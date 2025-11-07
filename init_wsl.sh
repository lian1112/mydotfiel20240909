#!/bin/bash

# 捕獲中斷信號
trap 'echo "腳本執行被中斷"; exit 1' INT

# 設置日誌輸出
log_file="/tmp/wsl_setup_$(date +%Y%m%d%H%M%S).log"
exec > >(tee -a "$log_file") 2>&1
echo "開始安裝 $(date)"
echo "日誌將保存到: $log_file"

# 檢查腳本是否以root權限運行
if [ "$EUID" -ne 0 ]; then
  echo "請以root權限運行此腳本 (sudo ./腳本名稱.sh)"
  exit 1
fi

# 設置目標用戶
TARGET_USER="allenl"
TARGET_PASS="ffff"

# 檢查目標用戶是否存在
if id "$TARGET_USER" &>/dev/null; then
  echo "用戶 $TARGET_USER 已存在，跳過創建步驟"
else
  echo "創建用戶 $TARGET_USER..."
  useradd -m -s /bin/bash "$TARGET_USER"
  echo "$TARGET_USER:$TARGET_PASS" | chpasswd
  usermod -aG sudo "$TARGET_USER"
  echo "用戶 $TARGET_USER 已創建，密碼設置為 $TARGET_PASS"
fi

# 安裝必要的程序包
echo "安裝必要的程序包..."
apt update -y

# 檢查並安裝必要的程序包
packages=("zsh" "git" "curl" "wget" "vim" "dos2unix")
for package in "${packages[@]}"; do
  if dpkg -l | grep -q "^ii  $package "; then
    echo "$package 已安裝"
  else
    echo "安裝 $package..."
    apt install -y "$package"
  fi
done

# 設置Zsh和Vim配置的函數
setup_user_configs() {
  local user=$1
  local user_home=$(eval echo ~$user)
  echo "為用戶 $user 設置 Zsh 和 Vim 環境..."
  
  # 檢查 Oh My Zsh 是否已安裝
  if [ -d "$user_home/.oh-my-zsh" ]; then
    echo "Oh My Zsh 已安裝於 $user_home/.oh-my-zsh"
  else
    echo "安裝 Oh My Zsh..."
    sudo -u $user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  
  # 安裝 Zsh 插件
  ZSH_CUSTOM="$user_home/.oh-my-zsh/custom"
  
  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "安裝 zsh-autosuggestions 插件..."
    sudo -u $user git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  else
    echo "zsh-autosuggestions 插件已安裝"
  fi
  
  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "安裝 zsh-syntax-highlighting 插件..."
    sudo -u $user git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
  else
    echo "zsh-syntax-highlighting 插件已安裝"
  fi
  
  # history-substring-search
  if [ ! -d "$ZSH_CUSTOM/plugins/history-substring-search" ]; then
    echo "安裝 history-substring-search 插件..."
    sudo -u $user git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM}/plugins/history-substring-search
  else
    echo "history-substring-search 插件已安裝"
  fi
  
  # 備份現有的.zshrc文件
  ZSHRC="$user_home/.zshrc"
  if [ -f "$ZSHRC" ]; then
    BACKUP_ZSHRC="${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    echo "備份現有的 .zshrc 文件至 $BACKUP_ZSHRC"
    cp "$ZSHRC" "$BACKUP_ZSHRC"
    chown $user:$user "$BACKUP_ZSHRC"
  fi
  
  # 創建新的.zshrc文件
  echo "創建新的 .zshrc 文件..."
  cat > "$ZSHRC" << 'EOL'
# 禁用zrecompile以避免WSL路徑問題
skip_global_compinit=1
ZSH_DISABLE_COMPFIX=true

# Oh My Zsh 路徑
export ZSH="$HOME/.oh-my-zsh"

# 設置主題
ZSH_THEME="half-life"

# 插件列表 - 移除fzf插件
plugins=(
  git 
  history-substring-search 
  zsh-autosuggestions 
  vi-mode 
  zsh-syntax-highlighting
)

# 載入 Oh My Zsh
source $ZSH/oh-my-zsh.sh

# 別名設定
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias h='history'
alias update='sudo apt update && sudo apt upgrade -y'
alias ws='cd /mnt/d'
alias wc='cd /mnt/c'

# 條件別名 - 只有當命令存在時才設置
if command -v exa &> /dev/null; then
  alias ls='exa'
  alias ll='exa -l'
  alias la='exa -la'
  alias lt='exa -T'
  alias lg='exa -l --git'
fi

if command -v bat &> /dev/null; then
  alias cat='bat --style=plain'
fi

if command -v rg &> /dev/null; then
  alias grep='rg'
fi

if command -v fd &> /dev/null || command -v fdfind &> /dev/null; then
  if command -v fdfind &> /dev/null; then
    alias find='fdfind'
  else
    alias find='fd'
  fi
fi

# 歷史記錄設定
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# Vi-mode 配置
bindkey -v
export KEYTIMEOUT=1

# 添加模式指示器到提示符
function zle-line-init zle-keymap-select {
    if [ "$KEYMAP" = "vicmd" ]; then
        echo -ne '\e[1 q'
    else
        echo -ne '\e[5 q'
    fi
}
zle -N zle-line-init
zle -N zle-keymap-select

# History Substring Search 配置
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Zsh-autosuggestions 配置
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8e908c"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
bindkey '^ ' autosuggest-accept

# 高亮設定
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'

# 自動CD 到目錄
setopt AUTO_CD

# 啟用命令修正
setopt CORRECT

# 定義cw指令 - 將Windows路徑轉換為WSL路徑並切換到該目錄
cw() {
  if [ "$#" -eq 0 ]; then
    # 檢查路徑是否存在，避免報錯
    if [ -d "/mnt/c/Users" ]; then
      cd /mnt/c/Users
    else
      echo "Windows用戶目錄不可訪問，改為切換到/mnt/d (如果存在)"
      [ -d "/mnt/d" ] && cd /mnt/d
    fi
  else
    # 獲取參數並處理路徑
    local winpath="$1"
    
    # 移除引號(如果有)
    winpath=${winpath//\'/}
    winpath=${winpath//\"/}
    
    # 轉換路徑格式
    # 替換驅動器號和反斜線
    local wslpath=$(echo "$winpath" | sed -E 's/^([A-Za-z]):/\/mnt\/\L\1/' | sed 's/\\/\//g')
    
    # 切換到轉換後的目錄
    cd "$wslpath" 2>/dev/null || echo "無法切換到目錄: $wslpath"
  fi
}
EOL
  
  # 設置正確的擁有者
  chown $user:$user "$ZSHRC"
  
  # 備份現有的.vimrc文件
  VIMRC="$user_home/.vimrc"
  if [ -f "$VIMRC" ]; then
    BACKUP_VIMRC="${VIMRC}.backup.$(date +%Y%m%d%H%M%S)"
    echo "備份現有的 .vimrc 文件至 $BACKUP_VIMRC"
    cp "$VIMRC" "$BACKUP_VIMRC"
    chown $user:$user "$BACKUP_VIMRC"
  fi
  
  # 創建新的.vimrc文件 (簡化版)
  echo "創建新的 .vimrc 文件..."
  cat > "$VIMRC" << 'EOL'
" 基本設置
syntax on                     " 語法高亮
set number                    " 顯示行號
set autoindent                " 自動縮排
set tabstop=4                 " Tab寬度
set shiftwidth=4              " 縮排寬度
set expandtab                 " 使用空格而非Tab
set hlsearch                  " 高亮搜索結果
set incsearch                 " 增量搜索
set ignorecase                " 搜索時忽略大小寫
set backspace=indent,eol,start " 退格鍵行為
set encoding=utf-8            " 使用UTF-8編碼

" 設置剪貼板共享
set clipboard=unnamed,unnamedplus

" 粘貼模式快捷鍵
set pastetoggle=<F2>

" WSL專用設置 - 啟用Windows剪貼板集成
if system('uname -r') =~ "microsoft"
  " 複製到Windows剪貼板
  vnoremap <leader>y :w !clip.exe<CR><CR>
  
  " 從Windows剪貼板粘貼（修正原有的問題行）
  nnoremap <leader>p :r !powershell.exe -Command "Get-Clipboard"<CR>
endif
EOL
  
  # 設置正確的擁有者
  chown $user:$user "$VIMRC"
  
  # 設置Zsh為默認shell
  echo "設置用戶 $user 的默認shell為Zsh..."
  chsh -s $(which zsh) $user
}

# 分別為root和allenl用戶設置配置
echo "為root用戶設置配置..."
setup_user_configs "root"

echo "為allenl用戶設置配置..."
setup_user_configs "allenl"

# 創建/更新 WSL 配置文件
echo "創建/更新 WSL 配置文件..."
cat > /etc/wsl.conf << EOL
[user]
default=$TARGET_USER

[boot]
systemd=true

[interop]
appendWindowsPath=true
enabled=true
EOL

# 修復Oh-My-Zsh中的zrecompile問題
echo "修復Oh-My-Zsh中的zrecompile問題..."
for user_home in /root /home/$TARGET_USER; do
  if [ -f "$user_home/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "更新 $user_home/.oh-my-zsh/oh-my-zsh.sh"
    # 備份原始文件
    cp "$user_home/.oh-my-zsh/oh-my-zsh.sh" "$user_home/.oh-my-zsh/oh-my-zsh.sh.bak"
    # 替換或注釋掉zrecompile行
    sed -i 's/zrecompile -q -p "$ZSH_COMPDUMP"/# zrecompile -q -p "$ZSH_COMPDUMP" # 已被WSL設置腳本禁用/' "$user_home/.oh-my-zsh/oh-my-zsh.sh"
    # 修改文件擁有者
    if [ "$user_home" = "/home/$TARGET_USER" ]; then
      chown $TARGET_USER:$TARGET_USER "$user_home/.oh-my-zsh/oh-my-zsh.sh"
      chown $TARGET_USER:$TARGET_USER "$user_home/.oh-my-zsh/oh-my-zsh.sh.bak"
    fi
  fi
done

# 禁用fzf插件
echo "禁用fzf插件..."
for user_home in /root /home/$TARGET_USER; do
  FZF_PLUGIN="$user_home/.oh-my-zsh/plugins/fzf/fzf.plugin.zsh"
  if [ -f "$FZF_PLUGIN" ]; then
    echo "備份並修改 $FZF_PLUGIN"
    # 備份原始文件
    cp "$FZF_PLUGIN" "$FZF_PLUGIN.bak"
    # 註釋掉eval "$(fzf --zsh)"行
    sed -i 's/eval "$(fzf --zsh)"/# eval "$(fzf --zsh)" # 已被WSL設置腳本禁用/' "$FZF_PLUGIN"
    # 修改文件擁有者
    if [ "$user_home" = "/home/$TARGET_USER" ]; then
      chown $TARGET_USER:$TARGET_USER "$FZF_PLUGIN"
      chown $TARGET_USER:$TARGET_USER "$FZF_PLUGIN.bak"
    fi
  fi
done

echo "===================================================="
echo "安裝完成！"
echo "root和$TARGET_USER用戶的Zsh環境和Vim配置已設置完成"
echo "已設置剪貼板共享功能，可以在Vim和Windows之間複製粘貼"
echo "===================================================="
echo "增強功能包括："
echo "- 已修復zrecompile在WSL中的路徑問題"
echo "- 已禁用fzf插件以避免--zsh選項錯誤"
echo "- Vim與Windows的剪貼板共享"
echo "- 新增cw命令用於快速轉換Windows路徑並切換到該目錄"
echo "- Vi 模式與視覺指示器"
echo "- 歷史子字符串搜索（使用上下箭頭鍵）"
echo "- 智能自動建議（Ctrl+空格接受建議）"
echo "- 語法高亮顯示"
echo "- 改進的工具別名（如果已安裝相應工具）"
echo "===================================================="
echo "Vim剪貼板使用方法："
echo "- 使用 yy, p 等常用命令直接與系統剪貼板共享"
echo "- 複製到Windows剪貼板：選擇文本後使用 <leader>y"
echo "- 從Windows剪貼板粘貼：使用 <leader>p"
echo "  (<leader>鍵默認為 \\ 反斜線)"
echo "- 使用F2切換粘貼模式來避免格式問題"
echo "===================================================="
echo "cw命令使用方法："
echo "- cw 'D:\\mydotfile\\cursor_vscode_setting'  # 轉換並切換到/mnt/d/mydotfile/cursor_vscode_setting"
echo "- cw                                         # 不帶參數時切換到Windows用戶主目錄"
echo "===================================================="
echo "安裝日誌位於: $log_file"
echo "===================================================="
