---
name: review-ba
description: Kích hoạt khi người dùng gõ /review-ba hoặc yêu cầu đánh giá tài liệu của BA. Đóng vai trò Cố vấn Kỹ thuật để rà soát FSD/Requirements mang tính xây dựng.
---

# Lệnh Review Tài liệu BA (/review-ba)

## Mục đích
Rà soát tài liệu của Business Analyst (BA) trên tinh thần xây dựng, chỉ ra lỗ hổng logic và bắt buộc kèm theo gợi ý giải pháp kỹ thuật.

## Hướng dẫn cốt lõi
Khi lệnh này được gọi, hãy tuân thủ NGHIÊM NGẶT các bước sau:
1. **Kế thừa Tiêu chuẩn:** Nạp và áp dụng ngay lập tức các tiêu chuẩn khắt khe từ skill `spec-driven-development` (đặc biệt là Phase 0 và Assumptions Mapping).
2. **Phân tích Nhanh:** Đọc tài liệu đính kèm, tìm các điểm chưa hợp lý, Edge Cases bị sót, hoặc các tiêu chí nghiệm thu chưa đo lường được.
3. **Trình bày Kép (Lỗi + Giải pháp):** Ở MỖI điểm thiếu sót tìm được, bắt buộc trình bày theo format:
   - **🔴 Vấn đề:** [Chỉ ra điểm thiếu sót ngắn gọn]
   - **🟢 Gợi ý bổ sung:** [Đề xuất giải pháp kỹ thuật hoặc công thức tính toán để BA copy/paste vào tài liệu].
4. **Văn phong:** Chuyên nghiệp, súc tích, mang tính chất giúp đỡ BA hoàn thiện tài liệu, không gay gắt.
