#!/bin/bash

# WSL Ubuntu 開發環境自動化設置腳本
# 此腳本會安裝 Docker, Zsh, 開發工具等

# 設置顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 錯誤處理
set -e
trap 'echo -e "${RED}錯誤發生在第 $LINENO 行${NC}"' ERR

# 顯示開始訊息
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}WSL Ubuntu 開發環境安裝腳本${NC}"
echo -e "${GREEN}========================================${NC}"

# 更新系統
echo -e "\n${YELLOW}[1/10] 更新系統套件...${NC}"
sudo apt update && sudo apt upgrade -y

# 安裝基本工具
echo -e "\n${YELLOW}[2/10] 安裝基本工具...${NC}"
sudo apt install -y \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    build-essential \
    make \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    unzip \
    zip \
    net-tools \
    dnsutils \
    telnet \
    postgresql-client \
    mysql-client \
    redis-tools \
    xclip \
    xsel

# 安裝 Docker
echo -e "\n${YELLOW}[3/10] 安裝 Docker...${NC}"

# 移除舊版本
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# 添加 Docker 官方 GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 添加 Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安裝 Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 將當前用戶添加到 docker 組
sudo usermod -aG docker $USER

# 配置 Docker 在 WSL 中正常運行
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "hosts": ["unix:///var/run/docker.sock"],
  "iptables": false
}
EOF

# 啟動 Docker 服務
sudo service docker start || true

# 安裝 Java 17 和 21
echo -e "\n${YELLOW}[4/10] 安裝 Java 17 和 21...${NC}"
sudo apt install -y openjdk-17-jdk openjdk-21-jdk

# 安裝 Node.js 和 npm (使用 NodeSource repository)
echo -e "\n${YELLOW}[5/10] 安裝 Node.js 和 npm...${NC}"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# 驗證 npm 安裝
npm --version || sudo apt install -y npm

# 安裝 Python 和 pip
echo -e "\n${YELLOW}[6/10] 安裝 Python 和 pip...${NC}"
sudo apt install -y python3 python3-pip python3-venv python3-dev
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# 安裝 Zsh
echo -e "\n${YELLOW}[7/10] 安裝 Zsh...${NC}"
sudo apt install -y zsh

# 安裝 Oh My Zsh
echo -e "\n${YELLOW}[8/10] 安裝 Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    export RUNZSH=no
    export CHSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh 已安裝"
fi

# 安裝 Zsh 插件
echo -e "\n${YELLOW}[9/10] 安裝 Zsh 插件...${NC}"

# 設置 ZSH_CUSTOM 變量
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# history-substring-search
if [ ! -d "$ZSH_CUSTOM/plugins/history-substring-search" ]; then
    echo "安裝 history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/history-substring-search"
else
    echo "history-substring-search 已安裝"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "安裝 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions 已安裝"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "安裝 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting 已安裝"
fi

# 配置 .zshrc
echo -e "\n${YELLOW}[10/10] 配置 Zsh...${NC}"

# 備份原始 .zshrc
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# 確保 .zshrc 存在
if [ ! -f ~/.zshrc ]; then
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
fi

# 更新插件列表
sed -i 's/^plugins=.*/plugins=(git history-substring-search zsh-autosuggestions vi-mode zsh-syntax-highlighting)/' ~/.zshrc

# 檢查是否已經添加過自定義配置
if ! grep -q "========== 自定義配置 ==========" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOL'

# ========== 自定義配置 ==========

# Java 環境變量
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Java 版本切換函數
jdk() {
    version=$1
    case "$version" in
        17)
            export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
            ;;
        21)
            export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
            ;;
        *)
            echo "Usage: jdk [17|21]"
            echo "Current JAVA_HOME: $JAVA_HOME"
            return 1
            ;;
    esac
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Switched to Java $version"
    java -version
}

# Docker 別名
alias dc='docker compose'
alias dcp='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'

# Git 別名
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpu='git pull'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'

# 其他有用的別名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias reload='source ~/.zshrc'
alias zshconfig='vim ~/.zshrc'
alias ports='netstat -tulanp'

# Python 別名
alias py='python'
alias py3='python3'
alias pip3='pip'
alias venv='python -m venv'
alias activate='source venv/bin/activate'

# 自動啟動 Docker 服務（如果尚未啟動）
if [ -z "$(service docker status 2>&1 | grep 'Docker is running')" ]; then
    echo "啟動 Docker 服務..."
    sudo service docker start 2>/dev/null || true
fi

# 顯示系統信息（只在互動式 shell 中顯示）
if [[ $- == *i* ]]; then
    echo "Welcome to WSL Ubuntu Development Environment!"
    echo "Docker: $(docker --version 2>/dev/null || echo 'Not running')"
    echo "Java: $(java -version 2>&1 | head -n 1 | cut -d'"' -f2 || echo 'Not available')"
    echo "Node: $(node --version 2>/dev/null || echo 'Not installed')"
    echo "Python: $(python --version 2>&1 || echo 'Not installed')"
fi

# 工作目錄快捷方式
export WORKSPACE="$HOME/workspace"
export PROJECTS="$HOME/projects"
alias ws='cd $WORKSPACE'
alias pj='cd $PROJECTS'

# 函數：創建並進入目錄
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 函數：快速創建 Python 虛擬環境
mkvenv() {
    python -m venv venv && source venv/bin/activate
}

# ========== 剪貼板工具函數 ==========

# 直接執行版本（支援長指令）
runclip_force() {
    # WSL 環境檢測
    if grep -qi microsoft /proc/version 2>/dev/null; then
        clipboard_content=$(powershell.exe -NoProfile -Command "
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            Get-Clipboard -Raw
        " 2>/dev/null | tr -d '\r')
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        clipboard_content=$(pbpaste)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xclip &> /dev/null; then
            clipboard_content=$(xclip -selection clipboard -o)
        elif command -v xsel &> /dev/null; then
            clipboard_content=$(xsel --clipboard --output)
        else
            echo "錯誤：請先安裝 xclip 或 xsel"
            return 1
        fi
    else
        echo "錯誤：不支援的作業系統"
        return 1
    fi

    if [[ -z "$clipboard_content" ]]; then
        echo "錯誤：剪貼板是空的"
        return 1
    fi

    line_count=$(echo "$clipboard_content" | wc -l | tr -d ' ')
    char_count=$(echo -n "$clipboard_content" | wc -c | tr -d ' ')

    echo "執行命令 ($line_count 行, $char_count 字元)..."

    # 使用臨時檔案執行
    temp_script=$(mktemp /tmp/runshell.XXXXXX)
    echo "$clipboard_content" > "$temp_script"
    chmod +x "$temp_script"

    zsh -c "source ~/.zshrc; source $temp_script"
    exit_code=$?

    rm -f "$temp_script"

    return $exit_code
}

# 只顯示剪貼板內容而不執行
showclip() {
    # WSL 環境檢測
    if grep -qi microsoft /proc/version 2>/dev/null; then
        clipboard_content=$(powershell.exe -NoProfile -Command "
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            Get-Clipboard -Raw
        " 2>/dev/null | tr -d '\r')
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        clipboard_content=$(pbpaste)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xclip &> /dev/null; then
            clipboard_content=$(xclip -selection clipboard -o)
        elif command -v xsel &> /dev/null; then
            clipboard_content=$(xsel --clipboard --output)
        else
            echo "錯誤：請先安裝 xclip 或 xsel"
            return 1
        fi
    else
        echo "錯誤：不支援的作業系統"
        return 1
    fi

    if [[ -z "$clipboard_content" ]]; then
        echo "剪貼板是空的"
        return 1
    fi

    line_count=$(echo "$clipboard_content" | wc -l | tr -d ' ')
    char_count=$(echo -n "$clipboard_content" | wc -c | tr -d ' ')

    echo "剪貼板內容 ($line_count 行, $char_count 字元)："
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$clipboard_content"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

saveclip() {
    local filename="${1:-clipboard_script.sh}"

    # WSL 環境 - 使用正確的編碼
    if grep -qi microsoft /proc/version 2>/dev/null; then
        # 設定 PowerShell 輸出編碼為 UTF-8
        clipboard_content=$(powershell.exe -NoProfile -Command "
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
            Get-Clipboard -Raw
        " 2>/dev/null | tr -d '\r')
    else
        # 原生 Linux
        if command -v xclip &> /dev/null; then
            clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)
        else
            echo "錯誤：請先安裝 xclip"
            return 1
        fi
    fi

    if [[ -z "$clipboard_content" ]]; then
        echo "錯誤：剪貼板是空的"
        return 1
    fi

    # 使用 printf 保存，確保 UTF-8 編碼
    printf '%s\n' "$clipboard_content" > "$filename"

    # 只對 .sh 檔案加執行權限
    [[ "$filename" == *.sh ]] && chmod +x "$filename"

    # 顯示檔案資訊
    line_count=$(wc -l < "$filename")
    echo "✅ 已將剪貼板內容儲存到: $filename"
    echo "   ($line_count 行)"

    if [[ "$filename" == *.py ]]; then
        echo "   執行方式: python3 $filename"
    elif [[ "$filename" == *.sh ]]; then
        echo "   執行方式: ./$filename"
    fi
}

# 複製檔案或管道內容到剪貼板
copytoclip() {
    # WSL 環境使用 clip.exe
    if grep -qi microsoft /proc/version 2>/dev/null; then
        # 如果沒有參數且有管道輸入
        if [[ $# -eq 0 ]]; then
            if [[ -p /dev/stdin ]]; then
                # 從管道讀取
                clip.exe
                echo "✓ 已將管道內容複製到剪貼板"
            else
                echo "用法："
                echo "  copytoclip <檔案名>    # 複製檔案內容"
                echo "  <指令> | copytoclip    # 複製指令輸出"
                return 1
            fi
        else
            # 處理檔案
            local file="$1"
            if [[ ! -f "$file" ]]; then
                echo "錯誤：檔案 '$file' 不存在"
                return 1
            fi
            # 複製檔案內容到剪貼板
            clip.exe < "$file"
            # 顯示成功訊息和檔案資訊
            local size=$(wc -c < "$file" | tr -d ' ')
            local lines=$(wc -l < "$file" | tr -d ' ')
            echo "✓ 已複製 '$file' 到剪貼板 (${lines} 行, ${size} 位元組)"
        fi
    else
        # 原生 Linux 使用 xclip
        if ! command -v xclip &> /dev/null; then
            echo "錯誤：xclip 未安裝。請先安裝 xclip"
            return 1
        fi

        # 如果沒有參數且有管道輸入
        if [[ $# -eq 0 ]]; then
            if [[ -p /dev/stdin ]]; then
                # 從管道讀取
                xclip -selection clipboard
                echo "✓ 已將管道內容複製到剪貼板"
            else
                echo "用法："
                echo "  copytoclip <檔案名>    # 複製檔案內容"
                echo "  <指令> | copytoclip    # 複製指令輸出"
                return 1
            fi
        else
            # 處理檔案
            local file="$1"

            if [[ ! -f "$file" ]]; then
                echo "錯誤：檔案 '$file' 不存在"
                return 1
            fi

            # 複製檔案內容到剪貼板
            xclip -selection clipboard < "$file"

            # 顯示成功訊息和檔案資訊
            local size=$(wc -c < "$file" | tr -d ' ')
            local lines=$(wc -l < "$file" | tr -d ' ')
            echo "✓ 已複製 '$file' 到剪貼板 (${lines} 行, ${size} 位元組)"
        fi
    fi
}

# 剪貼板工具別名
alias ctc='copytoclip'
alias clip='copytoclip'
alias stf='saveclip'

# 關閉嗶聲
unsetopt BEEP

# 自動 CD 到目錄（輸入目錄名稱即可切換）
setopt AUTO_CD

# 啟用命令修正（可選，有時會干擾）
# setopt CORRECT

# 定義 cw 指令 - 將 Windows 路徑轉換為 WSL 路徑並切換到該目錄
cw() {
  if [ "$#" -eq 0 ]; then
    # 檢查路徑是否存在，避免報錯
    if [ -d "/mnt/c/Users" ]; then
      cd /mnt/c/Users
    else
      echo "Windows 用戶目錄不可訪問，改為切換到 /mnt/d (如果存在)"
      [ -d "/mnt/d" ] && cd /mnt/d
    fi
  else
    # 獲取參數並處理路徑
    local winpath="$1"
    # 移除引號(如果有)
    winpath=${winpath//\'/}
    winpath=${winpath//\"/}
    # 檢查是否有 wslpath 命令
    if command -v wslpath &> /dev/null; then
      # 使用 wslpath 轉換
      local wslpath=$(wslpath -u "$winpath" 2>/dev/null)
    else
      # 手動轉換
      local drive_letter=$(echo "$winpath" | grep -o '^[A-Za-z]:' | tr '[:upper:]' '[:lower:]' | tr -d ':')
      local path_part=$(echo "$winpath" | sed 's/^[A-Za-z]://' | sed 's/\\/\//g')
      local wslpath="/mnt/${drive_letter}${path_part}"
    fi
    # 檢查路徑是否存在
    if [ -e "$wslpath" ]; then
      # 如果是文件，切換到其所在目錄
      if [ -f "$wslpath" ]; then
        local dir=$(dirname "$wslpath")
        echo "檢測到文件，切換到其所在目錄: $dir"
        cd "$dir"
      # 如果是目錄，直接切換
      elif [ -d "$wslpath" ]; then
        cd "$wslpath"
      fi
    else
      echo "路徑不存在: $wslpath"
      # 嘗試顯示可能的路徑供參考
      local base_dir=$(dirname "$wslpath")
      if [ -d "$base_dir" ]; then
        echo "但找到父目錄: $base_dir"
        echo "可用的內容："
        ls "$base_dir" 2>/dev/null | head -10
      fi
    fi
  fi
}

# 按鍵綁定設置
bindkey '^[[H' beginning-of-line     # Home
bindkey '^[[F' end-of-line           # End
bindkey '^[[2~' overwrite-mode       # Insert
bindkey '^[[3~' delete-char          # Delete
bindkey '^?' backward-delete-char    # Backspace

# ========== 自定義配置結束 ==========
EOL
else
    echo "自定義配置已存在，跳過添加"
fi

# 創建工作目錄
mkdir -p ~/workspace ~/projects

# 配置 Vim
echo -e "\n${BLUE}配置 Vim...${NC}"
cat > ~/.vimrc << 'EOL'
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
  " 從Windows剪貼板粘貼
  nnoremap <leader>p :r !powershell.exe -Command "Get-Clipboard"<CR>
endif
EOL

# 設置預設 shell 為 zsh
echo -e "\n${BLUE}設置預設 shell 為 Zsh...${NC}"
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh) $USER
    echo "預設 shell 已設為 Zsh"
else
    echo "Zsh 已經是預設 shell"
fi

# 安裝完成，顯示摘要
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}安裝完成！${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}已安裝的版本：${NC}"
echo -n "Docker: " && (docker --version 2>/dev/null || echo "需要重新登入以使用")
echo -n "Docker Compose: " && (docker compose version 2>/dev/null || echo "需要重新登入以使用")
echo -n "Git: " && git --version
echo -n "Make: " && make --version | head -n 1
echo -n "Node.js: " && node --version
echo -n "npm: " && npm --version
echo -n "Python: " && python --version 2>&1
echo -n "pip: " && pip --version
echo -n "Java 17: " && (/usr/lib/jvm/java-17-openjdk-amd64/bin/java -version 2>&1 | head -n 1)
echo -n "Java 21: " && (/usr/lib/jvm/java-21-openjdk-amd64/bin/java -version 2>&1 | head -n 1)
echo -n "Zsh: " && zsh --version
echo -n "xclip: " && (xclip -version 2>&1 | head -n 1 || echo "未安裝")

echo -e "\n${YELLOW}注意事項：${NC}"
echo "1. 請重新登入以使 Docker 群組權限和 Zsh 生效"
echo "2. 使用 'jdk 17' 或 'jdk 21' 切換 Java 版本"
echo "3. 預設 Java 版本設為 21"
echo "4. 使用 'reload' 重新載入 shell 配置"
echo "5. 工作目錄已創建：~/workspace 和 ~/projects"
echo "6. 剪貼板工具："
echo "   - showclip: 顯示剪貼板內容"
echo "   - runclip_force: 執行剪貼板中的命令"
echo "   - saveclip <filename>: 儲存剪貼板到檔案"
echo "   - copytoclip/ctc/clip: 複製檔案或輸出到剪貼板"
echo "7. Vim 已配置 WSL 剪貼板整合："
echo "   - Visual 模式: <leader>y 複製到 Windows 剪貼板"
echo "   - Normal 模式: <leader>p 從 Windows 剪貼板貼上"
echo "   - F2: 切換貼上模式"
echo "8. WSL 特殊功能："
echo "   - cw: 快速切換到 Windows 路徑 (例: cw 'C:\Users\Desktop')"
echo "   - cw 無參數: 切換到 /mnt/c/Users"
echo "   - AUTO_CD: 直接輸入目錄名即可切換"

echo -e "\n${GREEN}建議執行：${NC}"
echo "1. exit （退出當前 shell）"
echo "2. wsl --shutdown （在 Windows PowerShell 中執行）"
echo "3. 重新進入 WSL Ubuntu"

echo -e "\n${BLUE}Enjoy your development environment! 🚀${NC}"