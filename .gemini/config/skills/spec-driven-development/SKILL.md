---
name: spec-driven-development
description: Thiết kế API Contracts và Data Schema trước khi viết code (Clean Architecture).
---

# Spec-Driven Development (SDD)

## Mục đích
Đảm bảo tuân thủ tuyệt đối Clean Architecture. Không viết code khi chưa thống nhất API Contracts và Data Schemas.

## Hướng dẫn cốt lõi
1. **API First**: Bắt buộc tạo OpenAPI/Swagger specs hoặc gRPC protobuf trước khi implement.
2. **Data Schema**: Định nghĩa rõ ràng schema cho MongoDB, Elasticsearch, hoặc Kafka Topics.
3. **Review Bảo mật**: Kiểm tra phân quyền (AuthZ/AuthN) trên API Gateway (Kong) trong bản spec.
4. **No Code Without Spec**: Từ chối sinh code logic nếu Spec chưa được phê duyệt.

## Trigger
Kích hoạt khi bắt đầu một tính năng mới, hoặc khi người dùng yêu cầu viết code mà chưa có API/Schema rõ ràng. Yêu cầu chốt Spec trước.
