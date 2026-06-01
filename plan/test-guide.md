# GameStore — Hướng dẫn Test 8 Bug đã sửa + Username

> **Lưu ý quan trọng:**
> - Tài khoản cũ sẽ không đăng nhập được sau khi fix BCrypt. Cần tạo tài khoản mới.
> - Chạy `plan/migrate-add-username.sql` trong SQL Server trước khi deploy.
> - Sau khi deploy, chạy lại script để tạo 3 tài khoản test có BCrypt password "123".

---

## Trước khi test — Tạo tài khoản mới

1. Chạy script `plan/migrate-add-username.sql` trong SQL Server
2. Vào `/register`, điền thông tin (có field **Tên đăng nhập** mới)
3. Sau đó `/login` với tài khoản mới

---

## Test 9: Đăng ký + Đăng nhập bằng Username (MỚI)

**Đăng ký:**
1. Vào `/register`
2. Điền: Tên đăng nhập = `testuser123`, Tên hiển thị = `Nguyễn Văn Test`, Email = `test@example.com`, Password = `Test@123`
3. Submit → phải hiển thị "Đăng ký thành công!"
4. Query DB: `SELECT email, username, fullName FROM users WHERE email = 'test@example.com'`
   - `username` phải = `testuser123`
   - `fullName` phải = `Nguyễn Văn Test`
   - `password` phải là hash `$2a$...`

**Đăng nhập bằng email:**
5. Vào `/login`, nhập `test@example.com` + password → phải login thành công

**�ăng nhập bằng username:**
6. Logout, quay lại `/login`, nhập `testuser123` + password → phải login thành công

**Trùng username:**
7. Đăng ký lại với username `testuser123` → phải báo: "Tên đăng nhập đã được sử dụng!"

---

## Test 1: Bug #5 — BCrypt password (CRITICAL)

**Cách test:**
1. Đăng ký tài khoản mới tại `/register`
2. Mở SQL Server, query:
```sql
SELECT email, password FROM users WHERE email = 'email_cua_ban'
```
3. Password **không được** là plain-text (ví dụ `abc123`), mà phải là chuỗi hash dạng `$2a$10$...` dài ~60 ký tự

---

## Test 2: Bug #6 — Session fixation (CRITICAL)

**Cách test:**
1. Mở DevTools (F12) → Application → Cookies → copy giá trị `JSESSIONID`
2. Đăng nhập bằng tài khoản mới
3. Kiểm tra `JSESSIONID` trong Cookies — giá trị **phải khác** giá trị trước khi login

---

## Test 3: Bug #8 — Cart API ownership check (HIGH)

**Cách test:**
1. Đăng nhập bằng tài khoản A, thêm game vào giỏ
2. Mở DevTools → Network, bắt request `POST /api/cart/remove`
3. Thử xóa cart item của user khác (hoặc dùng Postman gọi API với session khác)
4. Response phải trả **HTTP 403** với message: `"Bạn không có quyền xóa sản phẩm này."`

---

## Test 4: Bug #1 — LicenseKey đánh dấu SOLD (HIGH)

**Cách test:**
1. Đăng nhập tài khoản mới
2. Nạp tiền vào ví (ví dụ 200k — không có bonus)
3. Thêm game vào giỏ hàng và checkout qua **Ví GameForge**
4. Sau khi thanh toán thành công, mở SQL Server query:

```sql
SELECT key_string, status, owner_id, order_item_id, assigned_at
FROM license_keys
WHERE owner_id = (SELECT id FROM users WHERE email = 'email_cua_ban')
```

**Kỳ vọng:**
- `status` phải là **SOLD** (không phải AVAILABLE)
- `owner_id` phải có giá trị (không phải NULL)
- `assigned_at` phải có thời gian
5. Vào `/library` — game phải xuất hiện trong thư viện

---

## Test 5: Bug #4 — Block CARD/BANK (HIGH)

**Cách test:**
1. Thêm game vào giỏ, đến trang `/checkout`
2. Chọn phương thức **"Thẻ Visa/MasterCard"** hoặc **"Ngân hàng"**
3. Click thanh toán
4. Phải hiển thị lỗi đỏ: **"Hiện tại chỉ hỗ trợ thanh toán qua Ví GameForge. Vui lòng chọn 'Ví điện tử'."**
5. Chọn **"Ví điện tử"** → thanh toán bình thường

---

## Test 6: Bug #2 — Promo code (MEDIUM)

### Server-side — Test các trường hợp

**Test promo hợp lệ:**
```sql
INSERT INTO promo_codes (code, discount_percentage, status, current_usage)
VALUES ('SUMMER20', 20.00, 'ACTIVE', 0);
```

**Test promo hết hạn:**
```sql
INSERT INTO promo_codes (code, discount_percentage, status, expiry_date, current_usage)
VALUES ('EXPIRED10', 10.00, 'ACTIVE', DATEADD(day, -1, GETDATE()), 0);
```

**Test promo hết lượt dùng:**
```sql
INSERT INTO promo_codes (code, discount_percentage, status, usage_limit, current_usage)
VALUES ('LIMITED5', 15.00, 'ACTIVE', 5, 5);
```

**Test fallback client-side (không cần DB):**
```sql
-- Không cần insert, hệ thống tự fallback với mã SALE10
```

### UI Test:
1. Thêm game vào giỏ, đến `/checkout`
2. Nhập mã `SUMMER20` vào ô **"Mã khuyến mãi"**, click **"Áp dụng"**
   - Discount phải thay đổi (số tiền giảm tăng)
   - Message hiển thị xanh: **"Đã áp dụng mã SUMMER20..."**
3. Thanh toán thành công → kiểm tra `orders.discount_amount` trong DB đúng số
4. Test `EXPIRED10` → phải báo đỏ: **"Mã khuyến mãi không hợp lệ hoặc đã hết hạn."**
5. Test `LIMITED5` → phải báo đỏ tương tự
6. Test `SALE10` → phải hoạt động (fallback client-side)

---

## Test 7: Bug #3 — Recharge bonus display (LOW)

**Cách test:**
1. Vào `/recharge`
2. Click từng gói tiền nạp, kiểm tra số tiền nhận được:

| Gói | Số tiền nhận | Bonus hiển thị |
|------|-------------|----------------|
| 100k | 100,000đ | Không bonus |
| 200k | 200,000đ | Không bonus |
| 500k | **530,000đ** | **+30K** (màu đỏ) |
| 1M | **1,080,000đ** | **+80K** (màu đỏ) |
| 2M | **2,220,000đ** | **+220K** (màu đỏ) |

---

## Test 8: Bug #7 — Wallet balance refresh (LOW)

**Cách test:**
1. Vào `/recharge`, ghi nhớ số dư ví hiện tại (ví dụ: 200,000đ)
2. Chọn gói **500k** → tạo QR → xác nhận đã chuyển khoản
3. Sau khi modal đóng:
   - Số dư ví trên **header** phải **tự động tăng** (animation chạy số)
   - Số dư trong recharge page phải update → **730,000đ** (200k + 530k)
   - Alert hiện đúng: **"Nạp tiền thành công! Bạn nhận được 530.000đ (bao gồm cả tiền thưởng)."**
   - Redirect về `/library` sau ~1.6 giây

---

## Checklist tổng hợp

| # | Bug | Test | Kỳ vọng |
|---|-----|------|----------|
| 1 | LicenseKey SOLD | Mua game → query DB | `status=SOLD`, `owner_id` có giá trị |
| 2 | Promo code | Nhập `SUMMER20` → checkout | Giảm đúng % từ DB |
| 3 | Recharge bonus | Click gói 500k | Hiện +30K, đúng số tiền |
| 4 | Block CARD/BANK | Chọn thẻ Visa → checkout | Lỗi "chỉ Ví GameForge" |
| 5 | BCrypt password | Đăng ký mới → query DB | Password là hash `$2a$` |
| 6 | Session fixation | Login → check JSESSIONID | Session ID đổi sau login |
| 7 | Wallet refresh | Nạp tiền → xem số dư | Tự update không cần reload |
| 8 | Cart ownership | Xóa cart item user khác | HTTP 403 |

---

## SQL test promo codes

```sql
-- Promo hợp lệ (20% giảm)
INSERT INTO promo_codes (code, discount_percentage, status, current_usage)
VALUES ('SUMMER20', 20.00, 'ACTIVE', 0);

-- Promo hết hạn
INSERT INTO promo_codes (code, discount_percentage, status, expiry_date, current_usage)
VALUES ('EXPIRED10', 10.00, 'ACTIVE', DATEADD(day, -1, GETDATE()), 0);

-- Promo hết lượt dùng
INSERT INTO promo_codes (code, discount_percentage, status, usage_limit, current_usage)
VALUES ('LIMITED5', 15.00, 'ACTIVE', 5, 5);

-- Kiểm tra license key sau khi mua
SELECT lk.key_string, lk.status, lk.owner_id, lk.order_item_id, lk.assigned_at, u.email
FROM license_keys lk
JOIN users u ON u.id = lk.owner_id
WHERE u.email = 'test@example.com';

-- Kiểm tra order discount
SELECT o.id, o.subtotal_amount, o.discount_amount, o.total_amount, o.payment_method
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE u.email = 'test@example.com';
```
