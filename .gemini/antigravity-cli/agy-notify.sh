#!/usr/bin/env bash
# Wrapper gọi trực tiếp script Python thông báo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${1:-$HOME/agy-task.log}"

if command -v python3 &> /dev/null; then
    python3 "$SCRIPT_DIR/agy-notify.py" "$LOG_FILE"
elif command -v python &> /dev/null; then
    python "$SCRIPT_DIR/agy-notify.py" "$LOG_FILE"
fi
