# MERGE-03: JSP VIEWS + ASSETS MERGE

## TỔNG QUAN

GameForge đã có sẵn JSP views + CSS/JS. Đồng nghiệp cũng có JSP views.

**Nguyên tắc: GIỮ GAMEFORGE làm base, bổ sung từ đồng nghiệp nếu cần.**

---

## TRẠNG THÁI HIỆN TẠI

### GameForge (bạn) — JSP Views
```
src/main/webapp/WEB-INF/views/
├── index.jsp                  ← Trang chủ (đã có)
├── login.jsp                 ← (đã có)
├── checkout/
│   ├── index.jsp
│   └── success.jsp            ← (đồng nghiệp có cùng file)
├── error/
│   ├── access-denied.jsp
│   └── error.jsp
├── library/
│   └── index.jsp
└── [các file khác]
```

### GamestoreLTW (đồng nghiệp) — JSP Views
```
src/main/webapp/WEB-INF/views/
├── admin/
│   ├── dashboard.jsp          ← BỔ SUNG
│   ├── kyc.jsp              ← BỔ SUNG
│   ├── payouts.jsp           ← BỔ SUNG
│   ├── settings.jsp          ← BỔ SUNG
│   └── users.jsp             ← BỔ SUNG
├── checkout/
│   └── success.jsp            ← CÓ THỂ CONFLICT
├── error/
│   ├── access-denied.jsp
│   └── error.jsp
├── index.jsp                  ← CÓ THỂ CONFLICT
├── kyc/
│   └── index.jsp            ← BỔ SUNG
├── login.jsp                 ← CÓ THỂ CONFLICT
├── orders/
│   ├── detail.jsp           ← BỔ SUNG
│   └── index.jsp            ← BỔ SUNG
├── publisher/
│   ├── dashboard.jsp        ← BỔ SUNG
│   └── payouts.jsp          ← BỔ SUNG
├── verify-otp.jsp           ← BỔ SUNG
└── wallet/
    └── index.jsp             ← BỔ SUNG
```

---

## XỬ LÝ TỪNG FILE

### 1. login.jsp

```
GameForge: có login form (email OR username) + register form
GamestoreLTW: có login form + register form + verify-otp flow

XỬ LÝ:
  → GIỮ login.jsp của GameForge (hỗ trợ email OR username)
  → NOTE: AuthController đổi flow register → gửi OTP → verify-otp.jsp
  → verify-otp.jsp sẽ redirect về login sau khi verify thành công
  → login.jsp cần giữ nguyên form đăng ký (vì vẫn submit POST /register)
```

### 2. verify-otp.jsp (FILE MỚI — BẮT BUỘC)

```
Nguồn: colleague/main/src/main/webapp/WEB-INF/views/verify-otp.jsp
XỬ LÝ: COPY vào src/main/webapp/WEB-INF/views/verify-otp.jsp
Lý do:
  - File mới hoàn toàn, không conflict với GameForge
  - BẮT BUỘC vì AuthController mới dùng OTP flow
  - Sau khi verify thành công → redirect sang login với thông báo success
Kiểm tra:
  - Form POST /verify-otp
  - Có countdown 5 phút (hết hạn → redirect register)
  - Có link gửi lại OTP
```

### 3. index.jsp

```
GameForge: trang chủ với Neo-Brutalism design
GamestoreLTW: trang chủ đơn giản

XỬ LÝ:
  → GIỮ index.jsp của GameForge (design đẹp hơn)
  → Nếu có logic mới cần thiết (VD: hiển thị game mới),
    thêm vào từ version đồng nghiệp
```

### 4. checkout/success.jsp

```
GameForge: có
GamestoreLTW: có

XỬ LÝ:
  → SO SÁNH 2 file
  → Nếu GameForge đã có logic hoàn chỉnh → GIỮ
  → Nếu đồng nghiệp có logic tốt hơn → MERGE
```

### 5. wallet/index.jsp (FILE MỚI)

```
Nguồn: colleague/main/src/main/webapp/WEB-INF/views/wallet/index.jsp
XỬ LÝ: COPY vào src/main/webapp/WEB-INF/views/wallet/index.jsp
Lý do: GameForge không có → bổ sung
```

### 6. orders/index.jsp + orders/detail.jsp (FILE MỚI)

```
Nguồn: colleague/main/src/main/webapp/WEB-INF/views/orders/
XỬ LÝ: COPY cả 2 file
Lý do: GameForge không có orders view
```

### 7. admin/* (FILE MỚI — THƯ MỤC MỚI)

```
Nguồn: colleague/main/src/main/webapp/WEB-INF/views/admin/
├── dashboard.jsp
├── kyc.jsp
├── payouts.jsp
├── settings.jsp
└── users.jsp

XỬ LÝ: COPY cả thư mục admin/
Lý do: GameForge không có admin views
```

### 8. publisher/* (FILE MỚI — THƯ MỤC MỚI)

```
Nguồn: colleague/main/src/main/webapp/WEB-INF/views/publisher/
├── dashboard.jsp
└── payouts.jsp

XỬ LÝ: COPY cả thư mục publisher/
Lý do: GameForge không có publisher views
```

### 9. kyc/index.jsp (FILE MỚI)

```
Nguồn: colleague/main/src/main/webapp/WEB-INF/views/kyc/index.jsp
XỬ LÝ: COPY vào src/main/webapp/WEB-INF/views/kyc/index.jsp
```

### 10. error/*

```
access-denied.jsp + error.jsp

XỬ LÝ:
  → SO SÁNH 2 file
  → Giữ version GameForge
  → Nếu đồng nghiệp có thêm nội dung tốt, bổ sung
```

### 11. library/index.jsp

```
GameForge có library view.
GamestoreLTW có library view.

XỬ LÝ:
  → SO SÁNH 2 file
  → GIỮ GameForge (đã customize)
  → Kiểm tra logic hiển thị library items
```

---

## CSS / JS ASSETS

```
GameForge có Neo-Brutalism CSS đẹp.
GamestoreLTW có CSS cơ bản.

XỬ LÝ:
  → GIỮ CSS/JS của GameForge
  → KHÔNG ghi đè bằng version đồng nghiệp
  → Nếu đồng nghiệp có CSS mới cần thiết (VD: admin.css, wallet.css),
    COPY thêm file mới, không ghi đè file hiện có
```

---

## LƯU Ý

1. **GIỮ design Neo-Brutalism** — không ghi đè bằng design đơn giản
2. **verify-otp.jsp** — file mới, copy nguyên
3. **wallet, orders, admin, publisher, kyc** — thư mục mới, copy nguyên
4. **login.jsp, index.jsp, library/index.jsp** — có thể conflict, so sánh trước khi quyết định
5. **Kiểm tra path references** — sau khi copy JSP mới, kiểm tra
   `<jsp:include>` và `<%@ include %>` có đúng đường dẫn không
