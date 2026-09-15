---
name: review-ui-ux
description: Kích hoạt khi người dùng gõ /review-ui-ux hoặc yêu cầu đánh giá thiết kế UI/UX từ Figma. Đóng vai trò Design QA Lead để rà soát tính đầy đủ trạng thái, edge cases, logic giao diện, và tuân thủ Design Token. Không tập trung vào lập trình. Bổ trợ cho review-ba (logic nghiệp vụ) và figma (implement design).
---

# Review UI/UX Design (/review-ui-ux)

## Mục đích

Rà soát chất lượng thiết kế UI/UX **trước khi chuyển sang giai đoạn lập trình**. Tập trung vào tính đúng đắn của logic giao diện, sự đầy đủ của các trạng thái và edge cases, và tính tuân thủ Design Token. **Không** đi vào chi tiết triển khai code.

## Vai trò

Đóng vai **Design QA Lead** — rà soát thiết kế với con mắt của Technical PM, đánh giá tính khả thi, tính nhất quán, và sự hoàn thiện trước khi handoff cho team dev.

## Hướng dẫn cốt lõi

Khi lệnh này được gọi, tuân thủ NGHIÊM NGẶT 5 lớp kiểm tra sau theo đúng thứ tự.

### Lớp 1: Thu thập Context

1. Nếu người dùng cung cấp **URL Figma**: trích xuất `fileKey` và `nodeId` từ URL, gọi Figma MCP `get_figma_data` để lấy cấu trúc node tree, sau đó gọi `download_figma_images` để lấy screenshot tham chiếu.
2. Nếu người dùng cung cấp **ảnh screenshot**: phân tích trực tiếp từ hình ảnh.
3. Xác định loại màn hình (List, Detail, Form, Dashboard, Modal, Dialog, Bottom Sheet, ...) để calibrate checklist phù hợp.

**Quy tắc:** Luôn ưu tiên Figma MCP khi có URL. Data từ MCP cho phép kiểm tra chính xác giá trị color, spacing, typography ở Lớp 5.

### Lớp 2: Kiểm tra Tính đầy đủ Trạng thái (State Completeness)

Với mỗi màn hình/component, kiểm tra sự tồn tại của các trạng thái bắt buộc:

| Nhóm trạng thái | Checklist |
|---|---|
| **Data States** | Empty state (0 items), Dữ liệu tràn (overflow), Loading skeleton |
| **Error States** | Network/Server error, Validation error (inline), Permission denied, Session expired |

**Output format cho mỗi trạng thái thiếu:**

```
🔴 THIẾU: [Tên trạng thái]
   📍 Màn hình: [Tên màn/component]
   💡 Lý do cần: [Tại sao trạng thái này quan trọng]
   📝 Gợi ý: [Mô tả ngắn gọn nên thiết kế như thế nào]
```

### Lớp 3: Kiểm tra Edge Cases về Data & Hiển thị

Rà soát từng element hiển thị dữ liệu động trên thiết kế:

| Loại Edge Case | Kiểm tra |
|---|---|
| **Text Overflow** | Tên/tiêu đề quá dài → truncate hay wrap? Có ellipsis không? Tooltip khi hover? |
| **Số lượng cực trị** | 0 items, 1 item, 1000+ items → pagination/infinite scroll? |
| **Giá trị đặc biệt** | Số âm, số 0, số cực lớn, null/undefined → hiển thị gì? |

**Output format:**

```
🟡 EDGE CASE: [Mô tả ngắn]
   📍 Element: [Tên element trên thiết kế]
   🎯 Kịch bản: [Khi nào xảy ra]
   📝 Đề xuất xử lý: [Cách hiển thị/hành vi mong đợi]
```

### Lớp 4: Kiểm tra Logic & Flow Consistency

| Hạng mục | Kiểm tra |
|---|---|
| **Action Consistency** | CTA chính có nổi bật nhất không? Destructive action có màu cảnh báo + bước confirm không? |
| **State Transitions** | Loading → Success, Error → Retry, Empty → Has Data — flow có rõ ràng không? |

**Output format:**

```
🔴 LOGIC: [Mô tả vấn đề]
   📍 Vị trí: [Màn hình / Flow]
   ⚡ Tác động: [Ảnh hưởng đến UX như thế nào]
   📝 Gợi ý: [Hướng sửa]
```

### Lớp 5: Kiểm tra Design Token Compliance

Trích xuất giá trị thiết kế thực tế từ Figma node tree (qua MCP) và đối chiếu với Design System/Token:

| Thuộc tính | Kiểm tra |
|---|---|
| **Color** | Mọi màu sử dụng có nằm trong bảng Color Tokens không? Có dùng màu hardcode (#hex) thay vì token không? |
| **Typography** | Font family, size, weight, line-height có khớp với Typography Scale không? Có style lạ ngoài hệ thống không? |
| **Spacing** | Padding, margin, gap có tuân theo spacing scale (4px, 8px, 12px, 16px, 24px, 32px, ...) không? |
| **Border & Shadow** | Border-radius, border-width, box-shadow có dùng token chuẩn không? |
| **Icon** | Size icon có nhất quán (16, 20, 24px) không? Có dùng icon ngoài thư viện chuẩn không? |
| **Component Reuse** | Element nào có thể/nên là shared component mà đang bị vẽ lại từ đầu? |

**Lưu ý:** Nếu project có file Design Tokens (JSON/YAML) hoặc Figma Variables, agent dùng làm source-of-truth. Nếu không có, đánh giá dựa trên tính nhất quán nội bộ (internal consistency) của chính file thiết kế.

**Output format:**

```
🟠 TOKEN: [Mô tả vi phạm]
   📍 Element: [Node/Layer name trong Figma]
   🎨 Giá trị hiện tại: [Giá trị thực tế đang dùng]
   ✅ Token chuẩn: [Token nên dùng / giá trị đúng]
```

## Output tổng hợp

Sau khi chạy 5 lớp kiểm tra, xuất báo cáo dạng artifact với cấu trúc:

```markdown
# Design Review: [Tên màn hình / Feature]

## Tóm tắt
- 🔴 Critical: X vấn đề
- 🟡 Warning: Y vấn đề
- 🟠 Token: Z vi phạm
- 🟢 Passed: N hạng mục đạt

## [Screenshot tham chiếu - nếu có]

## Chi tiết theo Lớp
### Lớp 2: State Completeness
...
### Lớp 3: Edge Cases
...
### Lớp 4: Logic & Flow
...
### Lớp 5: Design Token Compliance
...

## Checklist cho Designer
- [ ] Bổ sung empty state cho màn [X]
- [ ] Xử lý text overflow cho element [Y]
- [ ] Thay màu hardcode #FF0000 bằng token `color-error`
- ...
```

## Phân cấp Severity

| Mức | Ý nghĩa | Ví dụ |
|---|---|---|
| 🔴 **Critical** | Thiếu trạng thái khiến user không biết làm gì tiếp, hoặc logic sai gây hiểu nhầm nghiệp vụ | Không có error state cho form submit, nút Delete không có confirm |
| 🟡 **Warning** | Edge case chưa xử lý, có thể gây trải nghiệm kém nhưng không block user | Text overflow không có ellipsis, thiếu loading skeleton |
| 🟠 **Token** | Vi phạm Design System, không ảnh hưởng logic nhưng gây technical debt | Dùng màu hardcode, spacing lệch chuẩn |
| 🟢 **Info** | Gợi ý cải thiện, không bắt buộc | Có thể thêm animation transition, micro-interaction |


