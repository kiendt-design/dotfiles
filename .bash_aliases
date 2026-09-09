# Quản lý Agentic Awesome Skills On-Demand
agy-skill-add() {
    [ -z "$1" ] && echo "Usage: agy-skill-add <skill-name>" && return 1
    npx --yes agentic-awesome-skills --path "$HOME/.gemini/config/skills" --skills "$1"
}

agy-skill-rm() {
    [ -z "$1" ] && echo "Usage: agy-skill-rm <skill-name>" && return 1
    rm -rf "$HOME/.gemini/config/skills/$1"
    echo "Removed skill: $1"
}

agy-skill-local() {
    [ -z "$1" ] && echo "Usage: agy-skill-local <skill-name>" && return 1
    mkdir -p .agents/skills
    npx --yes agentic-awesome-skills --path .agents/skills --skills "$1"
    [ -d ".git" ] && grep -qxF ".agents/" .git/info/exclude 2>/dev/null || echo ".agents/" >> .git/info/exclude 2>/dev/null || true
}

# Hàm tìm vị trí thực tế của thư mục dotfiles trên Codespaces hoặc môi trường khác
_find_dotfiles_dir() {
    if [ -d "/workspaces/.codespaces/.persistedshare/dotfiles" ]; then
        echo "/workspaces/.codespaces/.persistedshare/dotfiles"
    elif [ -d "$HOME/dotfiles" ]; then
        echo "$HOME/dotfiles"
    elif [ -d "$HOME/.dotfiles" ]; then
        echo "$HOME/.dotfiles"
    fi
}

# 1-click sync và apply dotfiles tức thì vào Codespace đang chạy
dot-sync() {
    local DOT_DIR
    DOT_DIR=$(_find_dotfiles_dir)
    if [ -z "$DOT_DIR" ] || [ ! -d "$DOT_DIR" ]; then
        echo "❌ Không tìm thấy thư mục dotfiles trong /workspaces/.codespaces/.persistedshare/dotfiles hoặc ~/dotfiles"
        return 1
    fi
    echo "==> [Dotfiles] Found dotfiles at: $DOT_DIR"
    echo "==> [Dotfiles] Pulling latest changes from GitHub..."
    (cd "$DOT_DIR" && git pull --rebase)
    echo "==> [Dotfiles] Re-applying configurations..."
    bash "$DOT_DIR/install.sh"
    echo "==> [Dotfiles] Reloading shell environment..."
    [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null || true
    [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" 2>/dev/null || true
    [ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases" 2>/dev/null || true
    echo "✅ Dotfiles applied successfully!"
}

# Mở nhanh repo dotfiles trong cửa sổ VS Code hiện tại
dot-edit() {
    local DOT_DIR
    DOT_DIR=$(_find_dotfiles_dir)
    if [ -n "$DOT_DIR" ]; then
        code "$DOT_DIR"
    else
        echo "❌ Không tìm thấy thư mục dotfiles."
    fi
}
