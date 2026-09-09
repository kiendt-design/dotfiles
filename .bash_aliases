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

# 1-click sync và apply dotfiles tức thì vào Codespace đang chạy
dot-sync() {
    local DOT_DIR="$HOME/dotfiles"
    if [ ! -d "$DOT_DIR" ]; then
        echo "❌ Không tìm thấy thư mục $DOT_DIR"
        return 1
    fi
    echo "==> [Dotfiles] Pulling latest changes from GitHub..."
    (cd "$DOT_DIR" && git pull --rebase)
    echo "==> [Dotfiles] Re-applying configurations..."
    bash "$DOT_DIR/install.sh"
    echo "==> [Dotfiles] Reloading shell environment..."
    [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
    echo "✅ Dotfiles applied successfully!"
}

# Mở nhanh repo dotfiles trong cửa sổ VS Code hiện tại
dot-edit() {
    code "$HOME/dotfiles"
}
