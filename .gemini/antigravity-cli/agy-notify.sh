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

# Xây dựng prompt cho AI phụ (Flash)
if [ "$WORD_COUNT" -lt 1500 ]; then
    PROMPT="Một tác vụ chạy ngầm vừa hoàn thành.
YÊU CẦU:
1. Đọc nội dung kết quả từ file: $LOG_FILE.
2. Dùng tool search_messages(user_google_email='kiendt@thudomultimedia.com') để tìm space_id của cuộc hội thoại Google Chat gần nhất (hoặc lấy từ biến môi trường GOOGLE_CHAT_SPACE_ID nếu có).
3. Dùng tool send_message gửi TOÀN BỘ kết quả đó vào space_id tìm được cho user_google_email='kiendt@thudomultimedia.com'.
4. NẾU không tìm được space_id nào trên Google Chat hoặc gặp lỗi, BẮT BUỘC dùng tool send_gmail_message gửi toàn bộ kết quả về to='kiendt@thudomultimedia.com' với subject='[AI Report] Kết quả tác vụ'."
else
    PROMPT="Một tác vụ chạy ngầm vừa hoàn tất với nội dung lớn ($WORD_COUNT từ).
YÊU CẦU:
1. Đọc nội dung file log: $LOG_FILE.
2. Dùng tool create_doc của google-workspace để tạo 1 Google Doc mới đặt tên 'Báo cáo tác vụ AI - $(date +'%d/%m/%Y %H:%M')' chứa toàn bộ nội dung file log này.
3. Dùng tool search_messages(user_google_email='kiendt@thudomultimedia.com') để tìm space_id trên Google Chat (hoặc lấy từ GOOGLE_CHAT_SPACE_ID nếu có).
4. Dùng tool send_message gửi link Google Doc vừa tạo kèm 1-2 dòng mô tả ngắn vào space_id đó.
5. NẾU không gửi được qua Google Chat, BẮT BUỘC dùng tool send_gmail_message gửi đường link Google Doc này về email to='kiendt@thudomultimedia.com'."
fi

echo "==> Đang gọi AI Flash xử lý gửi tin..." >> "$NOTIFY_LOG"
agy --dangerously-skip-permissions -m flash -p "$PROMPT" >> "$NOTIFY_LOG" 2>&1
echo "==> [$(date)] Hoàn tất quy trình gửi báo cáo." >> "$NOTIFY_LOG"
