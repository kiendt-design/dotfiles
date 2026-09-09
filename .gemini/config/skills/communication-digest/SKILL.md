---
name: communication-digest
description: >-
  Quy trình chuyên sâu để đọc, lọc, phân loại và tổng hợp tin nhắn hoặc email từ đa kênh
  (Telegram, WhatsApp qua Beeper MCP; Gmail, Google Chat qua Google Workspace MCP).
  Kích hoạt khi người dùng yêu cầu: tổng hợp chat/mail, tóm tắt tin nhắn, kiểm tra đầu việc
  mới, daily briefing, morning digest, hoặc theo dõi tiến độ các kênh giao tiếp.
---

# Communication Digest — Multi-Channel Synthesis Workflow

Đọc, lọc và tổng hợp thông tin từ đa kênh (Telegram, WhatsApp, Gmail, Google Chat) — thông minh, súc tích, tối ưu token.

---

## 1. Blacklist (Tự động loại trừ)

Bỏ qua hoàn toàn (không đọc nội dung) các **nhóm chat / email** có tên hoặc tiêu đề chứa (case-insensitive):

`monitor`, `monitoring`, `alert`, `cảnh báo`, `report`, `daily report`, `on-live`, `payment monitor`, `noreply`, `no-reply`, `notification`, `cron`, `system`.

Cũng bỏ qua: nhóm bot thông báo tự động, kênh chỉ chứa log hệ thống, email quảng cáo/newsletter.

> **Ngoại lệ:** DM (chat cá nhân, `is_group: false`) không áp dụng blacklist — luôn đọc, nhưng vẫn lọc theo đối tượng mục tiêu (Section 2).

---

## 2. Đối tượng mục tiêu

Chỉ trích xuất nội dung liên quan đến:
- **Kiên:** `Kien`, `Kiên`, `kiendt`, `Đoàn Trung Kiên`, `anh Kiên`, `a Kiên`.
- **Sao:** `Sao`, `chị Sao`, `c Sao`.

### Tiêu chí trích xuất:
1. **Mention / Assign:** Được tag (@), giao việc, hỏi ý kiến, yêu cầu phản hồi trực tiếp.
2. **Sent by:** Tin nhắn/email do Kiên hoặc Sao gửi đi (để nắm ngữ cảnh chỉ đạo).
3. **Decisions & Deadlines:** Chốt kỹ thuật, kiến trúc, hợp đồng, lịch release — dù không tag trực tiếp.
4. **Incidents & Blockers:** Sự cố, rủi ro cần cấp quản lý can thiệp.

---

## 3. Quy trình thực thi

### Scope mặc định
Nếu user không chỉ định khung thời gian → mặc định **24 giờ gần nhất**.

### A. Telegram & WhatsApp (Beeper MCP)
1. **Quét:** `beeper/list_inbox` (limit=100) hoặc `beeper/list_unread`.
2. **Lọc:** Loại nhóm blacklist. Giữ nhóm có `unread_count > 0` hoặc `last_message_at` trong scope.
3. **Đọc — gọi song song (parallel tool calls):**
   - Unread < 10 → `read_chat limit=10`
   - Unread 10–50 → `read_chat limit=30`
   - Tra cứu cụ thể → `search_messages` thay vì đọc tuần tự
   - **Gọi `read_chat` cho tất cả nhóm đã lọc trong cùng 1 block tool call**, không gọi tuần tự.

### B. Gmail (Google Workspace MCP)
1. `search_gmail_messages` với query loại trừ noise:
   `is:unread -from:noreply -from:notification -subject:alert -subject:report`
2. Đọc batch: `get_gmail_messages_content_batch`.

### C. Google Chat (Google Workspace MCP)
1. `search_messages` hoặc quét space/thread dự án trọng điểm.
2. Bỏ qua space thông báo bot.

---

## 4. Phân loại Project & Topic

Tự động nhóm kết quả theo dự án/chủ đề. Gợi ý mapping:

| Project | Nhận diện qua |
|---|---|
| **VTVgo** | VTVgo, VGO, Media Hub, VNPT×TĐM, VnLink |
| **VTVHub** | VTVHub |
| **IMD-VTV** | IMD, VTV (không phải VTVgo/VTVcab) |
| **BảoHiểmSố** | VDS, BaohiemSo, BHXH, CBH, PVI |
| **CDN & Hạ tầng** | CDN, CDNetworks, VNETWORK, Sigma |
| **OTT/IPTV Partners** | RVR, Playbox, NKC, Anonet, Ano play |
| **India** | India, Vdigital, Green Latern |

Nhóm chứa `TDM`, `TĐM`, `Thủ Đô`, `Thu Do` → dùng làm context nhận diện công ty, kết hợp với tên đối tác để xác định đúng project.

Nhóm mới chưa có trong bảng → tự phân loại theo tên, thông báo cho user.

---

## 5. Output

Trả lời **trực tiếp trong conversation** dạng bảng, sắp xếp theo Priority (Critical → Low):

| Title | Project | Type | Assignee | Deadline | Priority |
|---|---|---|---|---|---|
| Tóm tắt công việc/quyết định/câu hỏi | Tên dự án | Dự án / Cá nhân / Ý tưởng | Người phụ trách | YYYY-MM-DD | Critical/High/Medium/Low |

**Quy tắc:**
- **Title:** Viết ngắn gọn, rõ hành động cần làm hoặc quyết định đã chốt.
- **Type:** `Dự án` = task/issue thuộc project, `Cá nhân` = việc riêng/HR, `Ý tưởng` = đề xuất chưa chốt.
- **Deadline:** Ghi `—` nếu không xác định được.
- **Priority:** `Critical` = sự cố/block, `High` = deadline gần hoặc request trực tiếp, `Medium` = cần theo dõi, `Low` = FYI.
- Không có cập nhật đáng chú ý → trả ngắn: *"Không có cập nhật cần xử lý trong [khung giờ]."*

---

## 6. Tiết kiệm Token
- Không trích dẫn nguyên văn tin nhắn/email; luôn tóm lược dạng hành động.
- Adaptive limit theo unread count, không kéo toàn bộ lịch sử.
- Đã đọc nhóm nào trong cùng conversation → không đọc lại trừ khi user yêu cầu.
