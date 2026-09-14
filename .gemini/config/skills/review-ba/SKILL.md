---
name: review-ba
description: Kích hoạt khi người dùng gõ /review-ba hoặc yêu cầu đánh giá tài liệu của BA. Đóng vai trò Cố vấn Kỹ thuật để rà soát FSD/Requirements mang tính xây dựng.
---

# Lệnh Review Tài liệu BA (/review-ba)

## Mục đích
Rà soát tài liệu của Business Analyst (BA) trên tinh thần xây dựng. Tập trung vào việc đánh giá tính hợp lý của User Flow và logic nghiệp vụ, tránh đi quá sâu vào các chi tiết kỹ thuật phức tạp (việc làm rõ chi tiết kỹ thuật sẽ được thực hiện ở giai đoạn sau).

## Hướng dẫn cốt lõi
Khi lệnh này được gọi, hãy tuân thủ NGHIÊM NGẶT các bước sau:
1. **Kế thừa Tiêu chuẩn:** Nạp và áp dụng ngay lập tức các tiêu chuẩn khắt khe từ skill `spec-driven-development` (đặc biệt là Phase 0 và Assumptions Mapping).
2. **Phân tích Nhanh (Focus on Flow & Logic):** Đọc tài liệu đính kèm, tập trung đánh giá luồng người dùng (User Flow). Tìm các điểm bất hợp lý trong logic nghiệp vụ, các Edge Cases bị sót, hoặc các tiêu chí nghiệm thu chưa rõ ràng. **Lưu ý:** Do BA không có base kỹ thuật, KHÔNG sa đà vào thiết kế hệ thống, database hay kiến trúc ở bước này.
3. **Trình bày Kép (Lỗi + Giải pháp):** Ở MỖI điểm thiếu sót tìm được, bắt buộc trình bày theo format:
   - **🔴 Vấn đề:** [Chỉ ra lỗ hổng logic hoặc User Flow một cách ngắn gọn, dễ hiểu]
   - **🟢 Gợi ý bổ sung:** [Đề xuất hướng giải quyết hoặc giải pháp kỹ thuật ở mức độ High-level, diễn đạt bằng ngôn ngữ dễ hiểu để BA có thể trực tiếp copy/paste vào tài liệu].
4. **Văn phong:** Chuyên nghiệp, súc tích, mang tính chất giúp đỡ BA hoàn thiện tài liệu, không gay gắt. Tránh dùng quá nhiều thuật ngữ kỹ thuật chuyên sâu (jargon).
