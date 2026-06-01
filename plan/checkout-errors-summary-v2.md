# TÓM TẮT LỖI — CheckoutController.java (Phiên bản 2 - Cross-reference DB)

**File:** `src/main/java/com/gamestore/controller/CheckoutController.java`
**Database:** SQL Server `GameStore` từ `GGGG.sql`
**Tổng: 14 lỗi**

---

## CRITICAL — Compile thất bại (4 lỗi)

| # | Vị trí | Mô tả |
|---|---------|--------|
| C-1 | Dong 144 | Class `LicenseKey` chưa được tạo |
| C-2 | Dong 160 | Class `LibraryItem` chưa được tạo |
| C-3 | Dong 57-66 | Class `Wallet` chưa được tạo (lấy số dư ví) |
| C-4 | (cùng C-3) | Class `WalletTransaction` chưa được tạo (ghi lịch sử ví) |

**Nguyên nhân gốc:** 4 entity này có trong DB nhưng chưa được tạo trong code Java.

---

## HIGH — Runtime lỗi logic (4 lỗi)

| # | Vị trí | Mô tả |
|---|---------|--------|
| H-1 | Dong 155 | `orderItem.getId()` trả về null vì chưa flush session |
| H-2 | Dong 205 | View `order-success.jsp` chưa được tạo |
| H-3 | Dong 154 | DB dùng `owner_id` (Long) nhưng class LicenseKey chưa có |
| H-4 | User.java | DB dùng NVARCHAR, annotation không chỉ định encoding |

---

## MEDIUM — Logic thiếu (3 lỗi)

| # | Vị trí | Mô tả |
|---|---------|--------|
| M-1 | Dong 80-175 | Nhận paymentMethod nhưng không trừ tiền từ ví Wallet |
| M-2 | Dong 119-128 | Không lưu thông tin giao hàng (fullName, phone, address...) vào Order |
| M-3 | Dong 150-169 | Khi game không có LicenseKey AVAILABLE, user mất tiền nhưng không nhận game |

---

## LOW — Risk nhỏ (3 lỗi)

| # | Vị trí | Mô tả |
|---|---------|--------|
| L-1 | Dong 107, 192 | Redirect `?error=` nhưng `index.jsp` không xử lý param này |
| L-2 | Dong 223-226 | API `removeCartItem` có thể `LazyInitializationException` |
| L-3 | Dong 56-72 | Hiển thị số dư ví nhưng không validate đủ tiền trước thanh toán |

---

## FILE CẦN TẠO MỚI

| File | Đường dẫn |
|------|-----------|
| `LicenseKey.java` | `src/main/java/com/gamestore/entity/LicenseKey.java` |
| `LibraryItem.java` | `src/main/java/com/gamestore/entity/LibraryItem.java` |
| `Wallet.java` | `src/main/java/com/gamestore/entity/Wallet.java` |
| `WalletTransaction.java` | `src/main/java/com/gamestore/entity/WalletTransaction.java` |
| `order-success.jsp` | `src/main/webapp/WEB-INF/views/order-success.jsp` |

---

## FILE CẦN SỬA

| File | Thay đổi |
|------|-----------|
| `CheckoutController.java` | Thêm flush, xử lý ví, xử lý hết key |
| `User.java` | Thêm `columnDefinition = "NVARCHAR(...)"` cho các trường text |

---

## THỨ TỰ THỰC HIỆN

1. Tạo `LicenseKey.java`
2. Tạo `LibraryItem.java`
3. Tạo `Wallet.java`
4. Tạo `WalletTransaction.java`
5. Sửa `User.java` (NVARCHAR)
6. Thêm `flush()` sau save OrderItem trong `CheckoutController.java`
7. Tạo `order-success.jsp`
8. Thêm logic trừ ví Wallet trong `processCheckout`
9. Thêm cột giao hàng vào DB + entity `Order`
10. Xử lý trường hợp game không có license key
11. Xử lý error param trong `index.jsp`
12. Sửa API `removeCartItem`

---

Xem chi tiết đầy đủ: `checkout-controller-fix-plan-v2.md`
