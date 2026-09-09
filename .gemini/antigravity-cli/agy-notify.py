#!/usr/bin/env python3
"""
Bộ gửi thông báo tự động và tạo Google Doc qua Google API trực tiếp.
Không phụ thuộc LLM/tool calling, không tốn token, chạy tức thì trong 1 giây.
"""
import os
import sys
import json
import time
import urllib.request
import urllib.parse
from datetime import datetime

SPACE_ID = "spaces/AAAAk904Sm4"
DEFAULT_EMAIL = "kiendt@thudomultimedia.com"
NOTIFY_LOG = os.path.expanduser("~/agy-notify.log")

def log(msg: str):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line)
    try:
        with open(NOTIFY_LOG, "a", encoding="utf-8") as f:
            f.write(line + "\n")
    except Exception:
        pass

def get_credentials():
    cred_path = os.path.expanduser(f"~/.google_workspace_mcp/credentials/{DEFAULT_EMAIL}.json")
    if not os.path.exists(cred_path):
        log(f"❌ Không tìm thấy file credentials: {cred_path}")
        return None
    try:
        with open(cred_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        log(f"❌ Lỗi đọc file credentials: {e}")
        return None

def get_access_token(creds):
    token = creds.get("token")
    # Kiểm tra refresh nếu token hết hạn
    refresh_token = creds.get("refresh_token")
    client_id = creds.get("client_id") or os.getenv("GOOGLE_OAUTH_CLIENT_ID")
    client_secret = creds.get("client_secret") or os.getenv("GOOGLE_OAUTH_CLIENT_SECRET")
    token_uri = creds.get("token_uri", "https://oauth2.googleapis.com/token")

    if refresh_token and client_id and client_secret:
        try:
            data = urllib.parse.urlencode({
                "client_id": client_id,
                "client_secret": client_secret,
                "refresh_token": refresh_token,
                "grant_type": "refresh_token",
            }).encode("utf-8")
            req = urllib.request.Request(token_uri, data=data)
            with urllib.request.urlopen(req, timeout=10) as resp:
                res = json.loads(resp.read().decode("utf-8"))
                new_token = res.get("access_token")
                if new_token:
                    return new_token
        except Exception as e:
            log(f"⚠️ Không refresh được token (dùng token cũ): {e}")

    return token

def send_chat_message(token, text):
    url = f"https://chat.googleapis.com/v1/{SPACE_ID}/messages"
    body = json.dumps({"text": text}).encode("utf-8")
    req = urllib.request.Request(url, data=body, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json; charset=utf-8"
    })
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            log("✅ Gửi tin nhắn Google Chat thành công!")
            return True
    except Exception as e:
        log(f"❌ Lỗi gửi tin nhắn Google Chat: {e}")
        return False

def create_google_doc(token, title, content):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json; charset=utf-8"
    }
    # 1. Tạo file Doc trống
    url_create = "https://docs.googleapis.com/v1/documents"
    body_create = json.dumps({"title": title}).encode("utf-8")
    req_create = urllib.request.Request(url_create, data=body_create, headers=headers)
    
    try:
        with urllib.request.urlopen(req_create, timeout=15) as resp:
            res = json.loads(resp.read().decode("utf-8"))
            doc_id = res.get("documentId")
            
        # 2. Ghi nội dung vào Doc
        url_update = f"https://docs.googleapis.com/v1/documents/{doc_id}:batchUpdate"
        body_update = json.dumps({
            "requests": [{"insertText": {"location": {"index": 1}, "text": content}}]
        }).encode("utf-8")
        req_update = urllib.request.Request(url_update, data=body_update, headers=headers)
        with urllib.request.urlopen(req_update, timeout=20) as resp2:
            pass
            
        doc_url = f"https://docs.google.com/document/d/{doc_id}/edit"
        log(f"✅ Tạo Google Doc thành công: {doc_url}")
        return doc_url
    except Exception as e:
        log(f"❌ Lỗi tạo Google Doc: {e}")
        return None

def main():
    log("==========================================")
    log("Bắt đầu quy trình gửi thông báo tự động...")
    
    log_file = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/agy-task.log")
    if not os.path.exists(log_file):
        log(f"❌ Không tìm thấy file log: {log_file}")
        return

    try:
        with open(log_file, "r", encoding="utf-8", errors="replace") as f:
            content = f.read().strip()
    except Exception as e:
        log(f"❌ Không đọc được file log: {e}")
        return

    words = content.split()
    word_count = len(words)
    log(f"Độ dài kết quả: {word_count} từ ({len(content)} ký tự).")

    creds = get_credentials()
    if not creds:
        return

    token = get_access_token(creds)
    if not token:
        log("❌ Không lấy được access token hợp lệ.")
        return

    now_str = datetime.now().strftime("%d/%m/%Y %H:%M")

    if word_count < 1500:
        log("Kết quả < 1500 từ: Gửi trực tiếp vào Google Chat...")
        msg = f"📋 [AI Task Completed - {now_str}]\n\n{content}"
        send_chat_message(token, msg)
    else:
        log("Kết quả >= 1500 từ: Tạo Google Doc và gửi link...")
        title = f"Báo cáo tác vụ AI - {now_str}"
        doc_url = create_google_doc(token, title, content)
        if doc_url:
            msg = f"📄 [AI Task Completed - {now_str}]\nKết quả tác vụ dài ({word_count} từ) đã được lưu vào Google Doc:\n👉 {doc_url}"
            send_chat_message(token, msg)
        else:
            log("Fallback gửi tin nhắn rút gọn vào Chat...")
            summary = "\n".join(content.splitlines()[-30:])
            msg = f"⚠️ [AI Task Completed]\nKhông tạo được Google Doc. 30 dòng log cuối:\n\n{summary}"
            send_chat_message(token, msg)

    log("Quy trình thông báo kết thúc.")

if __name__ == "__main__":
    main()
