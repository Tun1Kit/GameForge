# 📚 GAMEFORGE — HƯỚNG DẪN LƯU TRỮ

Nơi lưu trữ tất cả tài liệu hướng dẫn của project.

---

## Các hướng dẫn có sẵn

### 🛒 Checkout 500 Fix (29/05/2026)
**File:** `CHECKOUT-500-FIX-29-05-2026.md`

Fix lỗi 500 trả về HTML thay vì JSON khi bấm "Hoàn tất" thanh toán, bao gồm:

- **Lỗi 1:** 8 trường giao hàng bị `@Transient` — đã xóa `@Transient`, thêm `@Column`
- **Lỗi 2:** NPE khi `item.getGame().getPrice()` là null — đã thêm null check ở 3 nơi
- **Lỗi 3:** SQL Injection backdoor — đã xóa hoàn toàn
- **Lỗi 4:** Exception trả HTML thay vì JSON — đã tạo `GlobalExceptionHandler`
- **Lỗi 5:** Database thiếu 8 trường — user đã chạy ALTER TABLE

**Cách test:** 6 kịch bản test cho 3 phương thức thanh toán (Ví, Visa, Chuyển khoản)

---

### 🛒 Checkout Fix Guide
**File:** `CHECKOUT-FIX-GUIDE.md`

Hướng dẫn chi tiết cách sửa 14 lỗi trong `CheckoutController.java`, bao gồm:

- **Entity mới:** LicenseKey, LibraryItem, Wallet, WalletTransaction
- **Sửa entity:** User (NVARCHAR), Order (@Transient)
- **Logic:** Thanh toán ví, gán license key, trang thành công
- **Giải thích:** Hibernate, JPA, Spring MVC, SQL Server
- **Quy tắc:** 7 quy tắc vàng khi làm việc với JPA/Hibernate

**Đối tượng:** Người cần học cách fix checkout + hiểu rõ Spring MVC + Hibernate

---

### 🗄️ Xử lý dữ liệu không có trong Database
**File:** `HANDLE-TRANSIENT-FIELDS-GUIDE.md`

Giải thích chi tiết cách xử lý 8 trường giao hàng không tồn tại trong bảng `orders`, bao gồm:

- **`@Transient` là gì?** — Annotation bảo Hibernate bỏ qua field
- **Tại sao `@Transient` một mình không đủ?** — Khi redirect, dữ liệu bị mất
- **`HttpSession` là gì?** — Lưu dữ liệu tồn tại qua nhiều request
- **Giải pháp kết hợp:** `@Transient` + `Session` — dùng trong project
- **Tại sao không dùng `model.addAttribute`?** — Request scope vs Session scope
- **Luồng dữ liệu hoàn chỉnh** — Sơ đồ minh họa redirect
- **Rủi ro multi-tab** — Giải thích và cách xử lý
- **Khi nào nên sửa DB thay vì Session?** — Hướng dẫn quyết định

**Đối tượng:** Người cần hiểu sâu về request/redirect/session trong Spring MVC

---

### 🛠️ 5 Vấn đề còn tồn đọng
**File:** `5-REMAINING-ISSUES-GUIDE.md`

Phân tích chi tiết 5 vấn đề còn lại sau khi fix checkout, bao gồm:

- **Đăng nhập** — Navbar dùng `c:choose` để hiển thị tên user + dropdown menu
- **Giỏ hàng** — Tại sao localStorage ≠ Database, cách tạo API đồng bộ
- **Lỗi 500** — Nguyên nhân null wallet gây crash + cách fix
- **Validation** — 3 tầng: HTML5 `pattern`, JavaScript regex, Server `@Pattern`
- **Dark mode** — Tại sao `bg-light`/`bg-white` hardcoded không đổi màu, cách dùng CSS variables

**Đối tượng:** Người cần hiểu sâu về JSTL, async/await, validation, CSS custom properties

---

## Mục lục chi tiết (CHECKOUT-FIX-GUIDE.md)

```
1. Tổng quan project
   ├── Mục đích
   └── Các file chính liên quan

2. Tổng quan database
   ├── Schema liên quan đến checkout
   ├── Quan hệ giữa các bảng
   └── Chi tiết flow thanh toán

3. Cấu trúc code Java
   ├── Entity là gì?
   ├── Các annotation quan trọng
   ├── FetchType.LAZY vs FetchType.EAGER
   └── Spring @Transactional

4. 14 lỗi được phát hiện
   ├── CRITICAL (4 lỗi)
   ├── HIGH (4 lỗi)
   ├── MEDIUM (3 lỗi)
   └── LOW (3 lỗi)

5. Cách sửa từng lỗi (giải thích chi tiết)
   ├── Lỗi 1-4: Tạo 4 entity mới
   ├── Lỗi 5: orderItem.getId() = null
   ├── Lỗi 7: @Transient + Session
   ├── Lỗi 8: NVARCHAR
   ├── Lỗi 9-10: Thanh toán ví
   ├── Lỗi 11: Hết license key
   ├── Lỗi 12: Error param trong JSP
   └── Lỗi 13: LazyInitializationException

6. Quy tắc quan trọng
   ├── Luôn flush() sau save()
   ├── @Transient cho dữ liệu tạm
   ├── Session để truyền qua redirect
   ├── So sánh BigDecimal đúng
   ├── Kiểm tra null trước
   ├── LAZY fetch cần session
   └── Entity mapping với DB
```

---

## Cách đọc

1. **Mới bắt đầu** → Đọc phần 1-3 trước (tổng quan)
2. **Muốn hiểu lỗi** → Đọc phần 4 (bảng 14 lỗi)
3. **Muốn sửa lỗi** → Đọc phần 5 (chi tiết từng lỗi)
4. **Muốn nhớ quy tắc** → Đọc phần 6 (7 quy tắc vàng)

---

## Cách học hiệu quả

1. Đọc GUIDE → Hiểu tổng quan
2. Mở code thật → Đọc từng dòng
3. Chạy thử → Xem kết quả
4. Đặt câu hỏi → Nếu chưa hiểu

---

*Thư mục GUIDE — cập nhật khi có thêm hướng dẫn mới*
