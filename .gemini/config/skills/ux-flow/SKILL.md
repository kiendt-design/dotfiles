---
name: ux-flow
description: Thiết kế State Machine và xử lý Edge Cases cho Client/UI.
---

# UX Flow & State Management

## Mục đích
Mô hình hóa các trạng thái của Client (Web/Smart TV/Mobile) và xử lý các kịch bản ngoại lệ (Edge cases).

## Hướng dẫn cốt lõi
1. **State Machine**: Trình bày UX dưới dạng State Machine thay vì miêu tả giao diện thuần túy. Sử dụng Mermaid (State diagram).
2. **Edge Cases OTT**: Bắt buộc cover các case: rớt kết nối mạng, token hết hạn, fallback CDN, buffering timeouts.
3. **Tương tác Backend**: Mapping mỗi state transition với các API calls tương ứng (Kong API/Microservices).

## Trigger
Kích hoạt khi người dùng yêu cầu thiết kế luồng UX, luồng người dùng (user flow), hoặc xử lý các trạng thái giao diện phức tạp.
