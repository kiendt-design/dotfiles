# Tự động cấp toàn bộ quyền thực thi cho agy CLI (Bypass confirmation prompts)
alias agy="agy --dangerously-skip-permissions"
alias agy-safe="command agy"

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

# Giao việc cho AI chạy ngầm (Fire & Forget, tắt terminal không chết)
agy-bg() {
    if [ -z "$1" ]; then
        echo "Usage: agy-bg <prompt>"
        echo "Example: agy-bg 'Viết unit test cho auth module'"
        return 1
    fi
    local task="$*"
    local log_file="$HOME/agy-task.log"
    echo "🚀 Đã giao việc cho AI chạy ngầm: '$task'"
    echo "📝 Theo dõi tiến độ tại: tail -f $log_file"

    if command -v tmux &> /dev/null; then
        tmux kill-session -t agy-run 2>/dev/null || true
        tmux new-session -d -s agy-run "agy -p \"$task\" 2>&1 | tee -a \"$log_file\""
        echo "🔍 Xem màn hình AI đang làm: tmux a -t agy-run"
    else
        nohup bash -c "agy -p \"$task\"" > "$log_file" 2>&1 &
    fi
}
