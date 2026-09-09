#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> [Dotfiles] Setting up Antigravity ecosystem for Codespaces..."

# 1. Cài đặt Python `uv` cho Google Workspace MCP
if ! command -v uvx &> /dev/null; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# 2. Cài đặt RTK (Rust Token Killer)
if ! command -v rtk &> /dev/null; then
    echo "==> Installing RTK..."
    # codespace chạy linux, pull binary rtk hoặc giả lập command
    # Ở đây chúng ta tạo một alias hoặc tải từ resource (tạm mock vì chưa có URL release cụ thể)
    echo "Requires manual RTK binary setup if not on cargo. Skipping strict install for now..."
fi

# 3. Inject Bash Aliases
if ! grep -q "\.bash_aliases" "$HOME/.bashrc"; then
    echo "source $HOME/.bash_aliases" >> "$HOME/.bashrc"
fi
cp "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"

# 4. Thiết lập Symlink thư mục cấu hình
echo "==> Symlinking configurations..."
mkdir -p "$HOME/.gemini/config"
mkdir -p "$HOME/.gemini/antigravity-cli"

ln -sf "$DOTFILES_DIR/.gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"
ln -sf "$DOTFILES_DIR/.gemini/config/mcp_config.json" "$HOME/.gemini/config/mcp_config.json"
ln -sf "$DOTFILES_DIR/.gemini/antigravity-cli/settings.json" "$HOME/.gemini/antigravity-cli/settings.json"

# 5. Phục hồi Custom Skills tĩnh
echo "==> Restoring custom static skills..."
mkdir -p "$HOME/.gemini/config/skills"
if [ -d "$DOTFILES_DIR/.gemini/config/skills" ]; then
    cp -rsf "$DOTFILES_DIR/.gemini/config/skills/"* "$HOME/.gemini/config/skills/" 2>/dev/null || true
fi

# 6. Tải Base Layer từ Agentic Awesome Skills (AAS)
echo "==> Downloading Core Base from Agentic Awesome Skills..."
AAS_CORE_SKILLS="architecture-patterns,code-review-excellence,clean-code-guard,api-security-best-practices,threat-modeling-expert,brainstorming,writing-plans"
npx --yes agentic-awesome-skills --path "$HOME/.gemini/config/skills" --skills "$AAS_CORE_SKILLS"

# 7. Phục hồi vĩnh viễn Google Workspace OAuth Token (từ Codespace Secret)
if [ -n "$GWORKSPACE_CREDENTIALS_JSON" ]; then
    echo "==> Restoring Google Workspace MCP credentials..."
    mkdir -p "$HOME/.google_workspace_mcp/credentials"
    echo "$GWORKSPACE_CREDENTIALS_JSON" > "$HOME/.google_workspace_mcp/credentials/kiendt@thudomultimedia.com.json"
fi

# 8. Tùy chọn cài đặt agy-hud để theo dõi Token
if [ ! -d "$HOME/.gemini/config/plugins/agy-hud" ]; then
    echo "==> Installing agy-hud..."
    mkdir -p /tmp/agy-hud-pkg
    curl -fsSL -o /tmp/agy-hud-pkg/agy-hud.tar.gz https://github.com/franksde/agy-hud/releases/latest/download/agy-hud.tar.gz
    tar -xzf /tmp/agy-hud-pkg/agy-hud.tar.gz -C /tmp/agy-hud-pkg/ || true
    agy plugin install /tmp/agy-hud-pkg 2>/dev/null || true
    rm -rf /tmp/agy-hud-pkg
fi

echo "==> [Dotfiles] Setup completed perfectly!"
