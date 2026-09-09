---
name: project-history
description: Tra cứu, liệt kê và xem lại toàn bộ lịch sử các phiên chat (conversations/transcripts) thuộc riêng workspace/project hiện tại. Kích hoạt khi người dùng hỏi về lịch sử chat, các phiên thảo luận trước đây, session history của project.
---

# Project History Skill

Skill này giúp tra cứu và trích xuất danh sách tất cả các phiên chat trong quá khứ liên quan đến workspace/project hiện tại.

## Khi nào kích hoạt:
- Người dùng yêu cầu: "xem lịch sử chat của project", "các phiên chat trước đây", "tổng hợp thảo luận cũ", "tìm session cũ trong project này".

## Quy trình thực hiện:
1. Xác định đường dẫn workspace hiện tại (`os.getcwd()` hoặc từ ngữ cảnh).
2. Quét các file transcript trong `~/.gemini/antigravity-ide/brain/*/`:
   - Kiểm tra `transcript.jsonl` hoặc `transcript_full.jsonl`.
   - Lọc các session có chứa đường dẫn workspace.
3. Trích xuất metadata:
   - Conversation ID.
   - Thời gian cập nhật (`mtime`).
   - Tin nhắn mở đầu của User (`USER_INPUT`).
   - Các artifact / kế hoạch đã tạo.
4. Trình bày kết quả dạng bảng Markdown trực quan, chuyên nghiệp kèm Conversation ID để người dùng dễ tra cứu.
