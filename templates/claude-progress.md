# Nhật ký Tiến độ — Harness Template

> Template bậc 1. Copy ra root, đổi tên thành `claude-progress.md`, customize.

---

## PHẦN 1: TRẠNG THÁI ĐÃ XÁC MINH HIỆN TẠI

### 1.1 Thông tin Project

```
- Thư mục gốc kho lưu trữ:  [FILL: /path/to/project]
- Đường dẫn khởi động chuẩn: [FILL: ./init.sh hoặc ./init.bat]
- Đường dẫn xác minh chuẩn:  [FILL: mvn test / npm test / ...]
- Tính năng chưa hoàn thành ưu tiên cao nhất:
  ID: [FILL]
  Title: [FILL]
  Priority: [FILL]
- Sự cố chặn hiện tại:        [FILL: ghi rõ nếu có]
```

### 1.2 Baseline Status — 4 kiểm tra bắt buộc

```
Baseline Boot:
  □ Chưa xác minh
  □ PASS — [ngày]
  □ FAIL — [ngày] — lỗi: [mô tả]

Baseline Compile:
  □ Chưa xác minh
  □ PASS — [ngày]
  □ FAIL — [ngày] — lỗi: [mô tả]

Baseline Database (nếu có DB):
  □ Chưa xác minh
  □ PASS — [ngày]
  □ FAIL — [ngày] — lỗi: [mô tả]

Baseline Smoke Test:
  □ Chưa xác minh
  □ PASS — [ngày]
  □ FAIL — [ngày] — lỗi: [mô tả]
```

---

## PHẦN 2: ĐIỂM NÓNG — ISSUES CẦN THEO DÕI

### 2.1 Critical Issues (P0 — Sửa ngay)

| ID | Issue | Severity | Status | Created | Notes |
|----|-------|----------|--------|---------|-------|
| C01 | [Mô tả issue] | Critical | Open | YYYY-MM-DD | [Chi tiết] |
| C02 | | | | | |

### 2.2 Warning Issues (P1 — Sửa sớm)

| ID | Issue | Severity | Status | Created | Notes |
|----|-------|----------|--------|---------|-------|
| W01 | | | | | |

### 2.3 Info Issues (P2 — Ghi nhận)

| ID | Issue | Severity | Status | Created | Notes |
|----|-------|----------|--------|---------|-------|
| I01 | | | | | |

---

## PHẦN 3: NHẬT KÝ PHIÊN

### 3.1 Session Count

```
Tổng số phiên: 0
Phiên gần nhất: [FILL: số]
Cập nhật lần cuối: YYYY-MM-DD
```

### Phiên 001 — YYYY-MM-DD

```
- Ngày:
- Người dùng/Agent:
- Mục tiêu:          [Mô tả ngắn gọn task của phiên này]
- Tính năng làm:     [ID từ feature_list.json]

Đã hoàn thành:
  □ [Mô tả cụ thể]
  □ [Mô tả cụ thể]

Chưa hoàn thành:
  □ [Mô tả cụ thể]

Xác minh đã chạy:
  □ Baseline boot      — [PASS/FAIL] — [ngày]
  □ Baseline compile   — [PASS/FAIL] — [ngày]
  □ Smoke test         — [PASS/FAIL] — [ngày]
  □ Feature test       — [PASS/FAIL] — [ngày]

Bằng chứng đã ghi:
  - [Tên file/screenshots/log]
  - [Tên file/screenshots/log]

Commit:
  - Hash: [FILL]
  - Message: [FILL]

Tệp đã cập nhật:
  □ feature_list.json  — [mô tả thay đổi]
  □ claude-progress.md — [mô tả thay đổi]
  □ AGENTS.md         — [mô tả thay đổi]

Rủi ro đã biết hoặc vấn đề chưa giải quyết:
  - [Mô tả]
  - [Mô tả]

Bước tốt nhất tiếp theo:
  1. [FILL]
  2. [FILL]
  3. [FILL]
```

---

## PHẦN 4: PROGRESS MILESTONES

### 4.1 Milestones

| Milestone | Target Date | Status | Notes |
|-----------|-------------|--------|-------|
| Baseline hoàn tất | [FILL] | [ ] | |
| Feature P0-P1 hoàn tất | [FILL] | [ ] | |
| Feature P2 hoàn tất | [FILL] | [ ] | |
| Security hardening | [FILL] | [ ] | |
| Performance optimization | [FILL] | [ ] | |
| Documentation hoàn tất | [FILL] | [ ] | |

---

## PHẦN 5: HANDOFF CHO PHIÊN TIẾP THEO

### 5.1 Điều kiện để phiên tiếp theo bắt đầu được

```
Phiên tiếp theo có thể TIẾP TỤC NGAY mà KHÔNG cần sửa tay khi:
  □ Init script chạy được (không lỗi)
  □ Baseline boot thành công
  □ Tất cả blockers đã được ghi trong issues tracker
  □ Nhật ký tiến độ đầy đủ (đủ thông tin để hiểu đang ở đâu)

→ Nếu BẤT KỲ điều kiện nào KHÔNG thỏa
  → BÁO BLOCKER TRƯỚC. Không tự ý sửa.
```

### 5.2 Những gì phiên tiếp theo cần biết

```
1. [FILL: ví dụ: Feature hiện tại là F005-Checkout, đang ở bước 3/8]
2. [FILL: ví dụ: Cần hoàn thành wallet transaction trước]
3. [FILL: ví dụ: Đã fix bug C01 — race condition, cần test thêm]
```

### 5.3 Tài liệu nào cần đọc trước

```
□ root/AGENTS.md          — luật chặn lỗi
□ root/feature_list.json   — trạng thái features
□ root/claude-progress.md — (file này)
□ root/quality-document.md — điểm yếu kiến trúc
□ root/clean-state-checklist.md — lỗi đặc thù
```

---

## PHẦN 6: ARCHITECTURE SCORE (Baseline)

### 6.1 Điểm hiện tại

| Layer | Điểm | Notes |
|-------|-------|-------|
| Controller | [FILL: A+/A/A-/B+/B/B-/C] | |
| Service | [FILL] | |
| DAO/Repository | [FILL] | |
| Entity/Model | [FILL] | |
| Config | [FILL] | |
| Frontend | [FILL] | |
| Security | [FILL] | |
| **Tổng** | **[FILL: A/B/C/D]** | |

---

## PHẦN 7: CÁCH ĐIỀN PROGRESS LOG

### 7.1 Mỗi phiên phải điền

```
1. Copy template "Phiên 001" ở trên, đổi số tăng dần
2. Điền ngày thực tế
3. Mục tiêu: copy từ feature_list.json
4. Đã hoàn thành: mô tả CỤ THỂ những gì đã xong
5. Chưa hoàn thành: mô tả những gì còn dở
6. Xác minh: ghi rõ test nào chạy, kết quả gì
7. Bằng chứng: tên file/log/screenshot thực tế
8. Commit: hash + message
9. Tệp đã cập nhật: liệt kê file harness nào thay đổi
10. Bước tiếp theo: 3 bước cụ thể cho phiên sau
```
