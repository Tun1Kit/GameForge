# AGENTS.md — Harness Rule Engine Template

> Template bậc 1. Copy ra root, đổi tên thành `AGENTS.md`, customize theo project.

---

## PHẦN 1: QUY TẮC KHỞI ĐỘNG

### 1.1 Luồng bắt đầu phiên

```
TRƯỚC KHI làm bất cứ gì (viết code, sửa file, trả lời câu hỏi):

1. pwd — xác nhận thư mục làm việc
2. Đọc root/AGENTS.md ← (file này)
3. Đọc root/feature_list.json — chọn feature priority cao nhất chưa passing
4. Đọc root/claude-progress.md — xem baseline và bước tiếp theo
5. git log --oneline -5 — xem commit gần nhất
6. Chạy ./init.sh hoặc init.bat — xác minh baseline OK
7. Đọc root/quality-document.md — biết điểm yếu cần tránh
8. Đọc root/clean-state-checklist.md — biết lỗi đặc thù của project
```

### 1.2 Quy tắc vàng

> **Không chồng feature mới lên baseline hỏng.**
> Nếu bước 6 fail → SỬA baseline TRƯỚC. Không code tiếp.

---

## PHẦN 2: DEFINITION OF DONE

### 2.1 Một feature CHỈ XONG khi TẤT CẢ điều sau đúng:

```
□ Hành vi mục tiêu đã triển khai (đúng spec)
□ Xác minh đã chạy THỰC SỰ — không phải "code xong là done"
□ Bằng chứng ghi vào feature_list.json hoặc claude-progress.md
  (screenshot / log / test output / API response)
□ Repository vẫn boot được từ init script
□ Không có test fail (nếu có test)
□ Không vi phạm luật nào trong file này
□ feature_list.json đã cập nhật status
□ claude-progress.md đã ghi nhật ký phiên
```

### 2.2 Mỗi phiên nên làm gì

```
□ Một feature tại một thời điểm
□ Giữ thay đổi trong phạm vi feature đã chọn
□ Chỉ thoát phạm vi khi có BLOCKER nghiêm trọng cần sửa trước
□ Không đánh dấu passing khi chưa verify
```

---

## PHẦN 3: CUỘC TRÒ CHUYỆN vs TASK

### 3.1 Phân biệt

| Loại | Ví dụ | Agent làm gì |
|---|---|---|
| Trò chuyện | "Giải thích cái này", "Cái gì xảy ra nếu..." | Trả lời ngắn, không verify, không cập nhật harness |
| Task | "Sửa lỗi", "Thêm tính năng", "Refactor", "Tạo module" | Đọc harness → code → verify → cập nhật files → commit |

### 3.2 Khi nào cần cập nhật harness

```
Task hoàn thành → cập nhật feature_list.json + claude-progress.md
Task blocked    → ghi vào claude-progress.md blockers
Có lỗi mới    → thêm vào clean-state-checklist.md hoặc AGENTS.md
Có luật mới   → thêm vào AGENTS.md
```

---

## PHẦN 4: CẤU TRÚC PROJECT

### 4.1 Package Structure Template

```
src/main/java/
├── config/           ← Cấu hình framework, exception handler
├── controller/       ← HTTP handlers (REST hoặc MVC)
├── service/          ← Business logic (tách từ controller)
├── repository/       ← Data access (hoặc dao/)
├── entity/           ← Domain models, JPA entities
├── dto/              ← Data transfer objects
├── util/             ← Utilities, helpers
└── exception/         ← Custom exceptions

src/main/resources/
├── application.properties
└── database.properties

src/main/webapp/
├── assets/
│   ├── css/
│   ├── js/
│   └── images/
└── WEB-INF/
    ├── spring-servlet.xml
    └── views/       ← JSP hoặc templates
```

### 4.2 Tech Stack (Điền khi setup project)

```
Framework:      [FILL: Spring MVC / Express.js / Next.js / Django / ...]
Database:       [FILL: PostgreSQL / MySQL / SQL Server / MongoDB / ...]
ORM:            [FILL: Hibernate / JPA / Prisma / Mongoose / ...]
Build:          [FILL: Maven / Gradle / npm / pip / ...]
Auth:           [FILL: JWT / Session / OAuth / Spring Security / ...]
API Format:     [FILL: REST / GraphQL / tRPC / ...]
View:           [FILL: JSP / Thymeleaf / React / Vue / ...]
```

---

## PHẦN 5: ROUTE INVENTORY

### 5.1 Template — Điền khi setup

| Route | Method | Handler | Auth | Description |
|---|---|---|---|---|
| | | | | |

---

## PHẦN 6: DATABASE SCHEMA

### 6.1 Tables Template

| Table | PK | FK | Columns | Notes |
|---|---|---|---|---|
| | | | | |

---

## PHẦN 7: GUARD RULES — Chặn lỗi trước khi deploy

### 7.1 Input Validation

```
□ Null check trước khi dùng request param, session attribute
□ Validate length, format, range cho mọi user input
□ Sanitize input trước khi lưu database
□ Không dùng raw SQL — dùng parameterized query hoặc ORM
□ Không concat string vào SQL/Query string
□ Validate file upload (type, size, name)
```

### 7.2 Authentication & Authorization

```
□ Mọi protected route phải check session/token trước logic
□ Không trust client-side data — verify server-side
□ Role/Permission check phải ở server, không phải client
□ Logout phải invalidate session/token
□ Không hardcode role ID — dùng enum hoặc constant
□ Admin routes phải có explicit role guard
```

### 7.3 Error Handling

```
□ Try-catch cho mọi external call (DB, HTTP, file I/O, email)
□ Wrap exception thành custom error — không throw raw ra ngoài
□ Error response có format nhất quán: {success, message, errors}
□ Không expose stack trace cho client ở production
□ Log đầy đủ (level, timestamp, request ID, user ID)
□ Non-critical operation (email, notification) không được block main flow
```

### 7.4 Transaction & Concurrency Safety

```
□ Write operation (INSERT/UPDATE/DELETE) phải có transaction
□ Đọc balance/số tiền phải verify ở server, không tin client
□ Rollback toàn bộ nếu bất kỳ bước nào trong transaction fail
□ Kiểm tra race condition — dùng optimistic lock hoặc pessimistic lock
□ Idempotency: API mutating cần có idempotency key hoặc PRG pattern
□ Double-check balance sau khi update: SELECT balance FROM wallet WHERE ...
```

### 7.5 Static File Protection

```
□ File CSS/JS/image không được xóa hoặc đổi tên nếu đang được JSP/template refer
□ Thêm feature mới → tạo file mới, không sửa file chung trừ khi cần
□ Check <link>, <script>, <img> trong template trước khi rename file
```

---

## PHẦN 8: API DESIGN RULES

### 8.1 REST Conventions

```
GET    /resources           → list (200)
GET    /resources/{id}      → get one (200) hoặc not found (404)
POST   /resources           → create (201) hoặc bad request (400)
PUT    /resources/{id}      → update (200) hoặc not found (404)
DELETE /resources/{id}      → delete (204) hoặc not found (404)
```

### 8.2 Response Format

```json
{
  "success": true,
  "data": { },
  "message": "Operation successful",
  "errors": [],
  "timestamp": "2026-06-01T00:00:00Z"
}
```

### 8.3 HTTP Status Codes

```
200 OK              ← Đọc / Update thành công
201 Created         ← Tạo mới thành công
204 No Content      ← Xóa thành công
400 Bad Request     ← Invalid input
401 Unauthorized    ← Chưa login
403 Forbidden       ← Không có quyền
404 Not Found       ← Resource không tồn tại
409 Conflict        ← Duplicate (VD: trùng username)
422 Unprocessable  ← Validation fail
500 Internal Error  ← Lỗi server
```

---

## PHẦN 9: CODING STANDARDS

### 9.1 Naming Conventions

```
Class/Interface:     PascalCase  (UserService, PaymentGateway)
Method/Variable:    camelCase  (getUserById, calculateTotal)
Constant:           UPPER_SNAKE (MAX_RETRY, DEFAULT_PAGE_SIZE)
Database column:    snake_case (created_at, user_id)
Package:            lowercase  (com.example.service)
```

### 9.2 When to Comment

```
NÊN comment:
  - Thuật toán phức tạp, tại sao chọn cách này
  - Trade-off đã cân nhắc và quyết định
  - Constraint đặc biệt của business logic
  - Workaround cho bug/third-party issue

KHÔNG comment:
  - "// increment counter" — code đã đọc được
  - "// getter" — rõ ràng
  - "// check null" — tên biến đã nói lên ý nghĩa
```

---

## PHẦN 10: REGEX PATTERNS CHO CODE REVIEW

```
# SQL Injection — concat string vào query
SQL_CONCAT:   /CREATEQUERY.*["']\s*\+|query\s*\+.*\"|SELECT.*\+.*FROM/

# NullPointer — cast không check null
NULL_CAST:    /\.getAttribute\([^)]+\)\)\s+[A-Z]\w+;/

# Hardcoded credential
SECRET:       /password\s*[=:]\s*["'][^"']+["']|api[_-]?key\s*[=:]\s*["'][^"']+["']

# Missing transaction — write without @Transactional
MISSING_TX:   /\.save\(|\.update\(|\.delete\(/

# Sync check — LAZY field accessed outside transaction
LAZY_ACCESS:  /get[A-Z][a-zA-Z]+\(\)/   // verify Hibernate.initialize()

# Console/print debug left in code
DEBUG_PRINT:  /console\.log|System\.out\.print|print\(/
```

---

## PHẦN 11: CREDENTIALS & SECURITY

### 11.1 Never Commit

```
□ Password / API key / secret → .gitignore ngay
□ File config chứa credential → .gitignore
□ Credential trong code → THAY BẰNG biến môi trường
□ Backup file chứa credential → xóa trước khi commit
```

### 11.2 .gitignore mẫu

```
.env
.env.*
*.env
application-local.properties
database.properties
src/main/resources/database.properties
*.pem
*.key
*.cer
credentials.json
```

---

## PHẦN 12: CUỐI PHIÊN

### 12.1 Bắt buộc trước khi kết thúc

```
1. Cập nhật feature_list.json
   — status: not_started → in_progress → passing
   — verification: thêm bằng chứng
   — notes: ghi rõ đã làm gì

2. Cập nhật claude-progress.md
   — Thêm session mới vào nhật ký
   — Ghi rõ đã hoàn thành, chưa hoàn thành gì
   — Ghi blocker nếu có

3. Chạy clean-state-checklist.md
   — Baseline vẫn OK?
   — Không có debug print/log trong code?
   — Không commit credentials?

4. Commit khi ở trạng thái an toàn
   — git add . && git commit -m "MESSAGE"

5. Để repo sạch
   — git status sạch hoặc chỉ thay đổi có chủ đích
   — Init script vẫn chạy được ngay
```

### 12.2 Khi nào KHÔNG nên commit

```
□ Baseline đang fail
□ Test đang fail
□ Code còn half-done không chạy được
□ Credential bị leak trong working directory
□ Chưa chạy clean-state-checklist
```
