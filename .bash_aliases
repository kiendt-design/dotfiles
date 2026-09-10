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

# Giao việc cho AI chạy ngầm với Full Permission và tùy chọn Model
# Cú pháp: agy-bg [-m <model>] <task>
agy-bg() {
    local model_arg=""
    local model_display="Default"

    # Kiểm tra cờ -m hoặc --model
    if [ "$1" = "-m" ] || [ "$1" = "--model" ]; then
        if [ -n "$2" ]; then
            model_arg="--model $2"
            model_display="$2"
            shift 2
        else
            echo "Usage: agy-bg [-m <model>] <task>"
            return 1
        fi
    fi

    if [ -z "$1" ]; then
        echo "Usage: agy-bg [-m <model>] <task>"
        echo "Ví dụ:"
        echo "  agy-bg 'Viết unit test cho auth module'"
        echo "  agy-bg -m pro 'Thiết kế kiến trúc hệ thống OTT'"
        echo "  agy-bg -m flash 'Sửa lỗi chính tả trong docs'"
        return 1
    fi

    local task="$*"
    
    # Tạo thư mục log riêng và tự động dọn rác (giữ log trong 7 ngày)
    mkdir -p "$HOME/agy-logs"
    find "$HOME/agy-logs" -type f -name "task_*.log" -mtime +7 -delete 2>/dev/null || true
    
    local timestamp
    timestamp=$(date +'%Y%m%d_%H%M%S')
    local log_file="$HOME/agy-logs/task_$timestamp.log"
    ln -sf "$log_file" "$HOME/agy-task.log"

    echo "🚀 Đã giao việc cho AI chạy ngầm [Model: $model_display]: '$task'"
    echo "📝 Theo dõi tiến độ tại: tail -f ~/agy-task.log"

    # Tăng giới hạn timeout mặc định (5 phút) lên 20 phút để xử lý các task nặng (tải file, tổng hợp dài)
    local cmd="agy --dangerously-skip-permissions --print-timeout 20m $model_arg -p \"$task\""
    local notify_cmd="agy-notify \"$log_file\" 2>/dev/null || $HOME/.gemini/antigravity-cli/agy-notify.sh \"$log_file\""

    if command -v tmux &> /dev/null; then
        tmux kill-session -t agy-run 2>/dev/null || true
        tmux new-session -d -s agy-run "$cmd 2>&1 | tee -a \"$log_file\"; $notify_cmd"
        echo "🔍 Xem màn hình AI đang làm: tmux a -t agy-run"
    else
        nohup bash -c "$cmd 2>&1 | tee -a \"$log_file\"; $notify_cmd" > /dev/null 2>&1 &
    fi
}

# 2 phím tắt siêu nhanh cho Pro (việc khó) và Flash (việc nhanh)
agy-pro() {
    [ -z "$1" ] && echo "Usage: agy-pro <task>" && return 1
    agy-bg -m pro "$*"
}

agy-flash() {
    [ -z "$1" ] && echo "Usage: agy-flash <task>" && return 1
    agy-bg -m flash "$*"
}

# Đọc nội dung từ task.md để chạy (Tiện lợi khi dùng Web Editor gõ tiếng Việt / paste link)
# Cú pháp: agy-run [file_path] [-m <model>]
agy-run() {
    local file="task.md"
    local model_arg=""

    if [ "$1" = "-m" ] || [ "$1" = "--model" ]; then
        model_arg="-m $2"
        shift 2
    fi

    if [ -n "$1" ] && [ -f "$1" ]; then
        file="$1"
        shift
    fi

    if [ "$1" = "-m" ] || [ "$1" = "--model" ]; then
        model_arg="-m $2"
        shift 2
    fi

    if [ ! -f "$file" ]; then
        echo "❌ Không tìm thấy file: $file"
        echo "💡 Hãy tạo file $file trong editor, gõ tiếng Việt / paste link vào đó rồi chạy lại 'agy-run'."
        return 1
    fi

    local content
    content=$(cat "$file")
    if [ -z "$content" ]; then
        echo "❌ File $file đang rỗng. Hãy điền nội dung vào trước khi chạy."
        return 1
    fi

    echo "📄 Đang đọc prompt từ '$file'..."
    if [ -n "$model_arg" ]; then
        agy-bg $model_arg "$content"
    else
        agy-bg "$content"
    fi
}

agy-run-pro() {
    agy-run "$1" -m pro
}

agy-run-flash() {
    agy-run "$1" -m flash
}


