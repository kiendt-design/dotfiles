---
name: system-design-architect
description: Thiết kế kiến trúc luồng dữ liệu, Microservices và Caching.
---

# System Design Architect

## Mục đích
Thiết kế kiến trúc hệ thống tổng thể, luồng giao tiếp giữa các services và database cho nền tảng OTT.

## Hướng dẫn cốt lõi
1. **Mô hình hóa luồng dữ liệu**: Luôn sử dụng Mermaid để vẽ Sequence Diagram, Data Flow trực quan.
2. **Giao tiếp Services**: Định hình rõ luồng đồng bộ (qua Kong API) và bất đồng bộ (qua Kafka).
3. **Scaling & Caching**: Đề xuất chiến lược caching (Redis) và đảm bảo cấu trúc có khả năng scale ngang trên Kubernetes.

## Trigger
Kích hoạt khi người dùng yêu cầu thiết kế hệ thống, kiến trúc tính năng mới, hoặc vẽ luồng giao tiếp tổng thể.
