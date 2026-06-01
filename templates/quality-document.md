# Tài liệu Chất lượng — Harness Template

> Template bậc 1. Copy ra root, đổi tên thành `quality-document.md`.

**Tần suất cập nhật:** Sau mỗi phiên quan trọng, hoặc trước khi bắt đầu giai đoạn mới.

**Thang điểm:**
- **A**: Tất cả xác minh đang vượt qua, kiến trúc sạch, test ổn định, agent đọc được
- **B**: Xác minh vượt qua, thiếu nhỏ về khả năng đọc hoặc độ phủ test
- **C**: Hoạt động một phần, có khoảng trống đã biết, một số vùng khó hiểu cho agent
- **D**: Không hoạt động, hoặc có vấn đề cấu trúc lớn

---

## PHẦN 1: THÔNG TIN PROJECT

```
Project:         [FILL: tên project]
Ngày baseline:  [FILL: YYYY-MM-DD]
Điểm baseline:  [FILL: A/B/C/D]
Cập nhật lần cuối: [FILL: YYYY-MM-DD]
```

---

## PHẦN 2: DOMAIN SẢN PHẨM

Mỗi domain = một nhóm tính năng nghiệp vụ liên quan.

| Domain | Điểm | Xác minh | Đọc được | Ổn định Test | Khoảng trống chính | Cập nhật |
|--------|-------|-----------|-----------|--------------|-------------------|---------|
| Authentication & Auth | [A/B/C/D] | [passing/fail/none] | [High/Med/Low] | [High/Med/Low] | [FILL] | [date] |
| [Domain 2] | | | | | | |
| [Domain 3] | | | | | | |
| [Domain 4] | | | | | | |
| [Domain 5] | | | | | | |

---

## PHẦN 3: LỚP KIẾN TRÚC

### 3.1 Controller / API Layer

```
Điểm: [A/B/C/D]

Điểm mạnh:
  □ [FILL]

Điểm yếu:
  □ [FILL]

Khoảng trống:
  □ [FILL]

Có thể cải thiện:
  □ [FILL]
```

### 3.2 Service Layer

```
Điểm: [A/B/C/D]

Điểm mạnh:
  □ [FILL]

Điểm yếu:
  □ [FILL]

Khoảng trống:
  □ [FILL]

Có thể cải thiện:
  □ [FILL]
```

### 3.3 Repository / DAO Layer

```
Điểm: [A/B/C/D]

Điểm mạnh:
  □ [FILL]

Điểm yếu:
  □ [FILL]

Khoảng trống:
  □ [FILL]

Có thể cải thiện:
  □ [FILL]
```

### 3.4 Entity / Model Layer

```
Điểm: [A/B/C/D]

Điểm mạnh:
  □ [FILL]

Điểm yếu:
  □ [FILL]

Khoảng trống:
  □ [FILL]

Có thể cải thiện:
  □ [FILL]
```

### 3.5 Configuration Layer

```
Điểm: [A/B/C/D]

Điểm mạnh:
  □ [FILL]

Điểm yếu:
  □ [FILL]

Khoảng trống:
  □ [FILL]

Có thể cải thiện:
  □ [FILL]
```

### 3.6 Frontend / View Layer

```
Điểm: [A/B/C/D]

Điểm mạnh:
  □ [FILL]

Điểm yếu:
  □ [FILL]

Khoảng trống:
  □ [FILL]

Có thể cải thiện:
  □ [FILL]
```

---

## PHẦN 4: SECURITY AUDIT

| Kiểm tra | Status | Notes |
|---------|--------|-------|
| Password Hashing | □ PASS □ FAIL | [FILL] |
| SQL Injection Prevention | □ PASS □ FAIL | [FILL] |
| XSS Prevention | □ PASS □ FAIL | [FILL] |
| CSRF Protection | □ PASS □ FAIL | [FILL] |
| Rate Limiting | □ PASS □ FAIL | [FILL] |
| Session Security | □ PASS □ FAIL | [FILL] |
| Credential Storage | □ PASS □ FAIL | [FILL] |
| HTTPS Enforced | □ PASS □ FAIL | [FILL] |
| Role/Permission Check | □ PASS □ FAIL | [FILL] |
| Input Validation | □ PASS □ FAIL | [FILL] |

```
Overall Security Score: [FILL: A/B/C/D]
```

---

## PHẦN 5: TESTING COVERAGE

| Test Type | Coverage | Priority | Notes |
|-----------|---------|----------|-------|
| Unit Tests (Service) | [%] | P[FILL] | |
| Integration Tests (DAO) | [%] | P[FILL] | |
| E2E Tests | [%] | P[FILL] | |
| API Tests | [%] | P[FILL] | |
| Security Tests | [%] | P[FILL] | |
| Smoke Tests | [%] | P[FILL] | |

---

## PHẦN 6: ĐIỂM TỔNG THỂ

```
□ A    □ B    □ C    □ D

Đánh giá tổng thể:
[FILL: Mo ta tong the]

Điểm manh lon nhat:
[FILL]

Van de nghiem trong nhat can giai quyet truoc:
[FILL]
```

---

## PHẦN 7: PRIORITY IMPROVEMENTS

### P0 — Critical (Fix truoc khi deploy)

```
1. [FILL]
2. [FILL]
```

### P1 — High Priority

```
1. [FILL]
2. [FILL]
```

### P2 — Medium

```
1. [FILL]
```

### P3 — Low / Future

```
1. [FILL]
```

---

## PHẦN 8: LỊCH SỬ THAY ĐỔI

### YYYY-MM-DD

```
- Thay đổi:              [FILL]
- Domain được nâng cấp:   [FILL]
- Domain bị hạ cấp:     [FILL]
- Khoảng trống mới:      [FILL]
- Khoảng trống đã đóng:  [FILL]
```

### YYYY-MM-DD

```
- Thay đổi:
- Domain được nâng cấp:
- Domain bị hạ cấp:
- Khoảng trống mới:
- Khoảng trống đã đóng:
```

---

## PHẦN 9: HƯỚNG DẪN SỬ DỤNG

### 9.1 Khi nào cập nhật

```
□ Sau mỗi phiên hoàn thành feature lớn
□ Trước khi bắt đầu giai đoạn công việc mới
□ Khi phát hiện issue mới nghiêm trọng
□ Khi có refactor lớn thay đổi kiến trúc
```

### 9.2 Ai cập nhật

```
□ Agent — tự động sau mỗi task lớn
□ Reviewer — khi nhận xét PR
□ Tech lead — khi có milestone hoàn thành
```

### 9.3 Cách đọc document này

```
1. Bắt đầu: xem PHẦN 6 (điểm tổng thể) để hiểu overall
2. Theo domain: xem PHẦN 2 để biết feature nào yếu
3. Theo layer: xem PHẦN 3 để biết layer nào cần cải thiện
4. Theo security: xem PHẦN 4 để biết risk bảo mật
5. Theo cải thiện: xem PHẦN 7 để biết P0-P3 cần làm gì
```
