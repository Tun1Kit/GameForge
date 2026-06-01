# Templates — Harness System

> Bộ template generic để thiết lập harness cho mọi project. Copy ra root, customize.

---

## TỔNG QUAN

### Cấu trúc thư mục

```
project-root/
├── src/                          ← Mã nguồn
├── templates/                     ← GENERIC TEMPLATES (copy ra root)
│   ├── README.md                 ← File này
│   ├── AGENTS.md                 ← Luật chặn lỗi + coding standards
│   ├── feature_list.json          ← Ma trận tính năng + trạng thái
│   ├── claude-progress.md         ← Nhật ký phiên + baseline status
│   ├── quality-document.md        ← Chấm điểm domain + kiến trúc
│   ├── clean-state-checklist.md   ← Checklist trước commit
│   └── evaluator-rubric.md        ← Rubric đánh giá feature
└── .cursorrules                  ← Prompt cho agent (đọc 5 file root)
```

### 5 file bắt buộc khi làm việc với project

```
project-root/
├── AGENTS.md                     ← Luật chặn lỗi (đọc mỗi phiên)
├── feature_list.json               ← Ma trận tính năng (đọc khi chọn task)
├── claude-progress.md            ← Baseline + progress (đọc khi bắt đầu)
├── quality-document.md             ← Điểm chất lượng (đọc khi review)
└── clean-state-checklist.md       ← Checklist trước commit (đọc khi kết thúc)
```

### Mối quan hệ giữa các file

```
Agent bắt đầu phiên:
  .cursorrules
    ↓
  claude-progress.md (đọc baseline status + bước tiếp theo)
    ↓
  feature_list.json (chọn feature ưu tiên cao nhất)
    ↓
  AGENTS.md (đọc guard rules trước khi code)
    ↓
  quality-document.md (biết điểm yếu cần tránh)
    ↓
  clean-state-checklist.md (biết lỗi đặc thù project)

Agent kết thúc phiên:
  Cập nhật feature_list.json (status, evidence)
    ↓
  Cập nhật claude-progress.md (nhật ký phiên)
    ↓
  Chạy clean-state-checklist.md (verify pre-commit)
    ↓
  evaluator-rubric.md (đánh giá feature — tùy chọn)
    ↓
  quality-document.md (cập nhật nếu có thay đổi lớn)
    ↓
  Commit
```

---

## CÁCH SỬ DỤNG

### Bước 1: Copy template ra root

```
1. Mở thư mục project
2. Copy 6 file từ templates/ ra root
   - AGENTS.md              → project-root/AGENTS.md
   - feature_list.json        → project-root/feature_list.json
   - claude-progress.md      → project-root/claude-progress.md
   - quality-document.md     → project-root/quality-document.md
   - clean-state-checklist.md → project-root/clean-state-checklist.md
   - evaluator-rubric.md    → project-root/evaluator-rubric.md
3. Tạo .cursorrules ở root (copy nội dung bên dưới)
4. Tạo init.sh / init.bat (xem mẫu bên dưới)
5. Tạo README.md ở root
```

### Bước 2: Customize từng file

#### AGENTS.md
```
Điền:
  - Tech stack (Framework, DB, ORM, Build tool)
  - Package structure (điều chỉnh theo project)
  - Route inventory (danh sách routes thực tế)
  - DB schema (tables thực tế)
  - Guard rules đặc thù (nếu có)
  - Regex patterns cho code review
```

#### feature_list.json
```
Điền:
  - project: tên project
  - last_updated: ngày hiện tại
  - features: thêm feature PROJ-001 (baseline = passing)
  - Thêm các feature khác của project
  - routes_inventory: danh sách routes thực tế
  - db_schema_summary: tables thực tế
  - api_inventory: endpoints thực tế
```

#### claude-progress.md
```
Điền:
  - Thư mục gốc kho lưu trữ
  - Đường dẫn khởi động chuẩn (./init.sh)
  - Đường dẫn xác minh chuẩn (mvn test / npm test)
  - Baseline status (4 kiểm tra)
  - Tiến độ milestones
```

#### quality-document.md
```
Điền:
  - Tên project, ngày baseline
  - Điền 7 domain hoặc ít hơn tùy project
  - Điền 6 lớp kiến trúc
  - Điền security audit checklist
  - Điền test coverage
  - Điền priority improvements
```

#### clean-state-checklist.md
```
Điền:
  - Các check đặc thù của project (nếu có)
  - Thêm phần "Dành cho project XYZ" với check cụ thể
```

### Bước 3: Tạo init script

#### init.sh (Unix/macOS/Linux)
```bash
#!/bin/bash
set -e

echo "=== Project Init ==="

echo "[1/4] Checking dependencies..."
# Thêm kiểm tra Java, Node, Python tùy project

echo "[2/4] Starting services..."
# Thêm: khởi động database, server

echo "[3/4] Building..."
# Thêm: mvn compile / npm run build

echo "[4/4] Running smoke tests..."
# Thêm: mvn test / npm test

echo "=== Done ==="
```

#### init.bat (Windows)
```bat
@echo off
echo === Project Init ===

echo [1/4] Checking dependencies...
rem Thêm kiểm tra Java, Node

echo [2/4] Starting services...
rem Thêm: khởi động database

echo [3/4] Building...
rem Thêm: mvn compile

echo [4/4] Running smoke tests...
rem Thêm: mvn test

echo === Done ===
```

### Bước 4: Tạo .cursorrules

```markdown
Mày là một Kỹ sư Hệ thống (Harness Engineer).

THƯ MỤC GỐC CHỨA 5 FILE HARNESS ĐÃ CUSTOMIZE CHO PROJECT NÀY.
templates/ CHỨA GENERIC TEMPLATE — DÙNG KHI BẮT ĐẦU PROJECT MỚI.

TRƯỚC KHI làm bất cứ gì, BẮT BUỘC đọc 5 file harness từ THƯ MỤC GỐC:

1. AGENTS.md — luật chặn lỗi (đặc biệt: Named Parameter, cấu trúc package)
2. feature_list.json — ma trận tính năng, routes, db tables
3. claude-progress.md — baseline + progress
4. quality-document.md — điểm yếu kiến trúc cần tránh
5. clean-state-checklist.md — lỗi đặc thù project

ĐỊNH NGHĨA HOÀN THÀNH (trong AGENTS.md):
  □ Hành vi đã implement đúng spec
  □ Xác minh chạy với bằng chứng
  □ Repository vẫn boot từ init script
  □ Harness files đã cập nhật
```

---

## DANH MỤC FILE

| File | Mục đích | Khi nào đọc | Dòng |
|------|-----------|-------------|------|
| `AGENTS.md` | Luật chặn lỗi + coding standards | Mỗi phiên, trước khi code | ~355 |
| `feature_list.json` | Ma trận tính năng + trạng thái | Khi chọn task | ~270 |
| `claude-progress.md` | Nhật ký phiên + baseline status | Bắt đầu mỗi phiên | ~230 |
| `quality-document.md` | Chấm điểm domain + kiến trúc | Review định kỳ | ~220 |
| `clean-state-checklist.md` | Checklist trước commit | Kết thúc mỗi phiên | ~270 |
| `evaluator-rubric.md` | Rubric đánh giá feature | Sau khi implement | ~240 |

---

## NGUYÊN TẮC THIẾT KẾ

### 5 nguyên tắc vàng

```
1. Không chồng lên baseline hỏng
   → Sửa baseline trước, không thêm feature lên trên

2. Một feature tại một thời điểm
   → Tránh context switching, giữ phạm vi rõ ràng

3. Verification có bằng chứng
   → Không phải "code xong = done"

4. Artifact bền hơn chat
   → Ghi vào file, không nhờ mình nhớ trong đầu

5. Cuối phiên phải sạch
   → Init script chạy được ngay, không cần sửa tay
```

### Luồng Agent

```
Mỗi phiên:
  BẮT ĐẦU → Đọc harness → Chọn feature → Code → Verify
    → Cập nhật harness → Commit → KẾT THÚC

Baseline fail → Sửa baseline → Tiếp tục feature
Feature blocked → Ghi blocker → Chọn feature khác
```

---

## GIẢI THÍCH 5 FILE BẮT BUỘC

### 1. AGENTS.md — "Luật chơi"
```
Nội dung: Các luật phải tuân theo khi viết code
- Named Parameter, Input validation, Auth guards
- Transaction safety, Static file protection
- API design, Coding standards, Regex patterns

Khi nào dùng: Đọc trước khi code bất kỳ gì
```

### 2. feature_list.json — "Bảng điểm danh"
```
Nội dung: Tất cả features, ai đang làm, status gì, verify gì
- Status: not_started / in_progress / blocked / passing
- Routes impacted, DB tables used
- Verification steps, Evidence

Khi nào dùng: Khi cần chọn task để làm
```

### 3. claude-progress.md — "Nhật ký"
```
Nội dung: Baseline ổn không, đang ở đâu, blocker gì
- Baseline status (4 kiểm tra)
- Issues tracker (C01, W01, I01)
- Session log (đã làm gì, cần làm gì)

Khi nào dùng: Khi bắt đầu phiên để hiểu context
```

### 4. quality-document.md — "Báo cáo chất lượng"
```
Nội dung: Domain nào tốt, layer nào yếu, security ra sao
- 7 domain điểm A/B/C/D
- 6 lớp kiến trúc điểm
- Security audit checklist
- P0-P3 priority improvements

Khi nào dùng: Khi cần hiểu tổng thể chất lượng project
```

### 5. clean-state-checklist.md — "Checklist cuối ngày"
```
Nội dung: Trước khi commit cần check gì
- Baseline vẫn OK?
- Không có debug print?
- Không leak credentials?
- Harness updated?
- git status sạch?

Khi nào dùng: Trước khi kết thúc mỗi phiên
```
