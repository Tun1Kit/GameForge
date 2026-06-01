# MERGE OVERVIEW — GameForge + GamestoreLTW

**Ngày:** 2026-06-01
**Nguồn:** GameForge (local) + GamestoreLTW (colleague, `colleague/main`)
**Ưu tiên:** Giữ chức năng đã làm của GameForge (bạn) — bổ sung từ đồng nghiệp

---

## THỐNG KÊ SCHEMA

| Metric | GameForge (bạn) | GamestoreLTW (đồng nghiệp) |
|--------|-----------------|------------------------------|
| Tables | 25 | 25 |
| Cùng tên | 25/25 | 25/25 |
| Schema khác biệt | 3 bảng | — |
| DB seed data | CÓ (cart_items, games...) | KHÔNG |
| Role seed | KHÔNG | KHÔNG |
| Tổng dòng SQL | ~200K | ~200K |

---

## KẾT LUẬN: CẢ 2 SCHEMA GẦN NHƯ GIỐNG NHAU

**Chỉ có 3 điểm khác biệt thực sự:**

| Bảng | GameForge | GamestoreLTW | Xử lý |
|-------|-----------|--------------|--------|
| `users` | Có column `username` | Không có column `username` | **GIỮ** GameForge — bổ sung `user_roles` |
| `games` | Có column `original_price` | Không có `original_price` | **GIỮ** GameForge |
| `orders` | Có 7 field shipping (phone, address...) | Chỉ có 5 field | **GIỮ** GameForge |
| `cart_items` | Không có UNIQUE | Có UNIQUE(user_id, game_id) | **LẤY** của GamestoreLTW |
| `library_items` | Không có UNIQUE | Có 2 UNIQUE constraint | **LẤY** của GamestoreLTW |
| `reviews` | Không có UNIQUE | Có UNIQUE(user_id, game_id) | **LẤY** của GamestoreLTW |
| `wishlists` | Không có UNIQUE | Có UNIQUE(user_id, game_id) | **LẤY** của GamestoreLTW |

---

## NGUYÊN TẮC MERGE TỔNG QUAN

### Quy tắc 1: Ưu tiên GameForge (bạn) cho:
- Checkout flow (CheckoutController)
- Game browsing (GameController)
- Neo-Brutalism CSS / UI design
- JSP views đã có
- Database schema đã có thêm cột
- Tất cả seed data
- Recharge: Neo-Brutalism UI với QR, confetti, bonus

### Quy tắc 2: Lấy từ đồng nghiệp cho:
- AuthInterceptor (route guard theo role — GameForge không có)
- Role entity + RoleDAO + user_roles table (cho hệ thống đa quyền)
- OTP email verification → merge vào AuthController
- EmailService + PendingRegisterDTO (cho OTP)
- verify-otp.jsp (trang nhập OTP)
- WalletService + DAO (withdraw, refund, payout)
- Admin/Publisher/KYC controllers + services
- Các DAO mới (KycRequestDAO, PayoutRequestDAO...)
- DTOs (PageResult, PendingRegisterDTO, WalletActionForm...)
- CheckoutService

### Quy tắc 3: Kết hợp khi cần:
- AuthController → merge tốt nhất từ cả 2 (OTP từ đồng nghiệp, emailOrUsername từ GameForge)
- Entity classes → giữ field GameForge + thêm hasRole() method
- Java config files → merge interceptor config

---

## PHÂN LOẠI FILES

### Nhóm A: Lấy hoàn toàn từ GamestoreLTW
- AuthInterceptor.java (route guard theo role — GameForge không có)
- Role.java + RoleDAO.java + user_roles table
- EmailService.java (gửi OTP mail)
- PendingRegisterDTO.java (lưu pending registration trong session)
- WalletService.java + WalletDAO.java + WalletTransactionDAO.java
  (KHÔNG lấy Wallet entity — giữ GameForge vì @OneToOne LAZY tốt hơn)
  (KHÔNG lấy WalletController — đã có RechargeController)
- AdminController.java + AdminDashboardService.java
- PublisherController.java + PayoutService.java
- KycController.java + KycService.java + KycRequestDAO.java
- PayoutRequestDAO.java
- PageResult.java
- WalletActionForm.java
- CheckoutService.java

### Nhóm B: Giữ hoàn toàn của GameForge
- AuthController.java (MERGE: giữ emailOrUsername, thêm OTP từ đồng nghiệp)
- verify-otp.jsp (từ đồng nghiệp — file mới)
- RechargeController.java + recharge.jsp + recharge.js (Neo-Brutalism, bonus, QR, confetti)
- CheckoutController.java (657 dòng, đã customize)
- GameController.java
- DashboardController.java
- LibraryController.java
- Wallet.java entity (giữ @OneToOne LAZY — tốt hơn EAGER của đồng nghiệp)
- WalletTransaction.java entity
- Game.java entity
- Store.sql + seed data
- Tất cả JSP views
- Tất cả CSS/JS assets
- pom.xml (kiểm tra conflict dependency)

### Nhóm C: Merge cẩn thận
- spring-servlet.xml (thêm interceptor config)
- User.java entity (giữ username + thêm hasRole + roles)

---

## CÁC BƯỚC THỰC HIỆN

```
Bước 1: Backup
Bước 2: Tạo branch mới
Bước 3: Merge database
Bước 4: Merge Java entity + auth + OTP
Bước 5: Merge service + DAO layer
Bước 6: Merge controller layer
Bước 7: Merge JSP views
Bước 8: Merge config files
Bước 9: Thêm role seed data
Bước 10: Verify
```

Chi tiết từng bước → xem các file plan/MERGE-XX-*.md tương ứng.

---

## FILE PLAN CHI TIẾT

| File | Nội dung |
|------|----------|
| `MERGE-00-overview.md` | File này — tổng quan + nguyên tắc |
| `MERGE-01-database-merge.md` | Chi tiết merge SQL schema |
| `MERGE-02-java-files-merge.md` | Chi tiết merge Java files theo từng layer |
| `MERGE-03-jsp-views-merge.md` | Chi tiết merge JSP views |
| `MERGE-04-final-migration.md` | Script migration + seed data cuối cùng |
