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
    local log_file="$HOME/agy-task.log"
    echo "🚀 Đã giao việc cho AI chạy ngầm [Model: $model_display]: '$task'"
    echo "📝 Theo dõi tiến độ tại: tail -f $log_file"

    local cmd="agy --dangerously-skip-permissions $model_arg -p \"$task\""

    # Script báo cáo thông minh: Dưới 1500 từ -> Gửi trực tiếp. Trên 1500 từ -> Tạo Google Doc và gửi link.
    local notify_script="
    word_count=\$(wc -w < \"$log_file\" | tr -d ' ')
    if [ \"\$word_count\" -lt 1500 ]; then
        notify_prompt=\"Nhiệm vụ: '$task' vừa hoàn tất. Đọc file log tại $log_file và gửi TRỰC TIẾP toàn bộ kết quả qua Google Chat cho email kiendt@thudomultimedia.com bằng tool send_message. KHÔNG CẦN tóm tắt.\"
    else
        notify_prompt=\"Nhiệm vụ: '$task' vừa hoàn tất. Nội dung log tại $log_file rất dài. YÊU CẦU: 1. Dùng tool create_doc (và modify_doc_text nếu cần) của google-workspace để tạo 1 Google Doc mới chứa toàn bộ nội dung file $log_file. 2. Dùng tool send_message gửi duy nhất đường link của Google Doc vừa tạo kèm 1-2 dòng mô tả siêu ngắn gọn qua Google Chat cho email kiendt@thudomultimedia.com.\"
    fi
    agy --dangerously-skip-permissions -m flash -p \"\$notify_prompt\" > /dev/null 2>&1
    "

    if command -v tmux &> /dev/null; then
        tmux kill-session -t agy-run 2>/dev/null || true
        tmux new-session -d -s agy-run "$cmd 2>&1 | tee -a \"$log_file\"; $notify_script"
        echo "🔍 Xem màn hình AI đang làm: tmux a -t agy-run"
    else
        nohup bash -c "$cmd 2>&1 | tee -a \"$log_file\"; $notify_script" > /dev/null 2>&1 &
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

