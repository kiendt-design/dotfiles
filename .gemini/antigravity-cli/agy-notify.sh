#!/usr/bin/env bash
# Script thông báo kết quả tự động sau khi agy chạy ngầm xong
LOG_FILE="${1:-$HOME/agy-task.log}"
NOTIFY_LOG="$HOME/agy-notify.log"

echo "==========================================" >> "$NOTIFY_LOG"
echo "==> [$(date)] Bắt đầu quy trình gửi báo cáo..." >> "$NOTIFY_LOG"

if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Không tìm thấy file log: $LOG_FILE" >> "$NOTIFY_LOG"
    exit 1
fi

WORD_COUNT=$(wc -w < "$LOG_FILE" | tr -d ' ')
echo "==> Độ dài log: $WORD_COUNT từ" >> "$NOTIFY_LOG"

# Space ID cố định của 'Me' trên Google Chat
ME_SPACE_ID="spaces/AAAAk904Sm4"

# Xây dựng prompt cho AI phụ (Flash)
if [ "$WORD_COUNT" -lt 1500 ]; then
    PROMPT="Một tác vụ chạy ngầm vừa hoàn thành.
YÊU CẦU BẮT BUỘC:
1. Đọc nội dung kết quả từ file: $LOG_FILE.
2. Dùng tool send_message của google-workspace gửi TOÀN BỘ nội dung kết quả đó với:
   - space_id: '$ME_SPACE_ID'
   - user_google_email: 'kiendt@thudomultimedia.com'
   - message_text: nội dung kết quả (KHÔNG CẦN tóm tắt)."
else
    PROMPT="Một tác vụ chạy ngầm vừa hoàn tất với nội dung lớn ($WORD_COUNT từ).
YÊU CẦU BẮT BUỘC:
1. Đọc nội dung file log: $LOG_FILE.
2. Dùng tool create_doc của google-workspace để tạo 1 Google Doc mới đặt tên 'Báo cáo tác vụ AI - $(date +'%d/%m/%Y %H:%M')' chứa toàn bộ nội dung file log này.
3. Dùng tool send_message gửi đường link của Google Doc vừa tạo kèm 1-2 dòng mô tả ngắn gọn với:
   - space_id: '$ME_SPACE_ID'
   - user_google_email: 'kiendt@thudomultimedia.com'"
fi

echo "==> Đang gọi AI Flash xử lý gửi tin..." >> "$NOTIFY_LOG"
agy --dangerously-skip-permissions -m flash -p "$PROMPT" >> "$NOTIFY_LOG" 2>&1
echo "==> [$(date)] Hoàn tất quy trình gửi báo cáo." >> "$NOTIFY_LOG"
