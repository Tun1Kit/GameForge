# PLAN: SỬA 5 VẤN ĐỀ CÒN TỒN ĐỌNG

**Ngày:** 2026-05-28
**Trạng thái:** Chưa thực hiện

---

## VẤN ĐỀ 1: Đăng nhập — Không hiển thị tên user + Nút đăng nhập không ra trang profile

**Mức độ:** HIGH
**Nguyên nhân:**
- Navbar luôn hiển thị icon đăng nhập (`/login`), không có điều kiện hiển thị tên user
- Sau khi đăng nhập thành công → redirect `/` nhưng nút vẫn là icon, không hiển thị `fullName`
- Không có trang `user.jsp` hoặc controller `/user`

**Cách sửa:**
1. Trong `index.jsp`, dùng JSTL `c:choose` để kiểm tra `${currentUser != null}`
2. Nếu đã đăng nhập → hiển thị avatar + fullName + menu dropdown (logout)
3. Nếu chưa đăng nhập → hiển thị icon đăng nhập
4. Thêm `AuthController.processLogout()` — đã có sẵn `@GetMapping("/logout")`
5. Tạo trang profile (tùy chọn, nếu cần)

**Thay đổi file:** `index.jsp`

---

## VẤN ĐỀ 2: Giỏ hàng — Thêm game vào tài khoản không hoạt động

**Mức độ:** HIGH
**Nguyên nhân gốc:** Hai hệ thống giỏ hàng hoàn toàn tách biệt

| Hệ thống | Công nghệ | Ai thấy |
|-----------|-----------|---------|
| Giỏ hàng hiện tại | `localStorage` (JavaScript) | Chỉ 1 trình duyệt |
| Giỏ hàng thực | `cart_items` DB | Tất cả thiết bị |

Code `quickAddToCart()` trong `index.js` chỉ lưu vào localStorage. Server không biết có game nào được thêm.

**Cách sửa (2 phương án):**

**Phương án A — Backend đồng bộ (khuyến nghị):**
1. Tạo API `POST /api/cart/add`
2. Tạo API `DELETE /api/cart/remove`
3. `index.js` gọi API thay vì chỉ localStorage
4. Khi vào checkout → query `cart_items` từ DB (đã có sẵn)

**Phương án B — Chỉ client-side:**
1. Khi vào checkout → JS đọc localStorage → gửi danh sách gameId lên server
2. Server tạo `CartItem` từ danh sách đó
3. Tiếp tục checkout như bình thường

**Thay đổi file:** `CheckoutController.java` (thêm 2 method), `index.js`

---

## VẤN ĐỀ 3: Lỗi 500 khi bấm "Thanh toán an toàn"

**Mức độ:** CRITICAL
**Nguyên nhân:** User đăng nhập nhưng **chưa có wallet** trong bảng `wallets`

Code xử lý ví:
```java
if ("WALLET".equals(paymentMethod)) {
    Wallet wallet = hqSession
        .createQuery("FROM Wallet WHERE user.id = :userId", Wallet.class)
        .setParameter("userId", currentUser.getId())
        .uniqueResult();   // ← null nếu user chưa có ví

    if (wallet == null) {  // ← Bỏ qua nếu ví null? KHÔNG!
        return "checkout";  // ← Forward (không redirect), nhưng...
    }
    // ...
}
```

**Vấn đề:** Khi `wallet == null` → return `"checkout"` (forward) → nhưng **model chưa được set lại** → `checkout.jsp` thiếu `cartItems`, `subtotal`, `total` → crash.

**Cách sửa:**
1. Khi `wallet == null` → trả về redirect kèm error param
2. Hoặc tạo ví tự động cho user khi checkout

**Thay đổi file:** `CheckoutController.java`

---

## VẤN ĐỀ 4: Validation số điện thoại — Thiếu ràng buộc

**Mức độ:** MEDIUM
**Nguyên nhân:** Form checkout không có validation. HTML `required` chỉ kiểm tra trống, không kiểm tra:
- Phải là chữ số (0-9)
- Phải có 10-11 ký tự

**Cách sửa:**
1. Thêm HTML5 `pattern="\d{10,11}"` vào input phone
2. Thêm `minlength="10"` và `maxlength="11"`
3. Thêm JavaScript validation (để hiển thị thông báo đẹp hơn)
4. Thêm server-side validation trong `processCheckout`

**Thay đổi file:** `checkout.jsp`, `CheckoutController.java`

---

## VẤN ĐỀ 5: Dark mode không áp dụng cho payment fields

**Mức độ:** LOW
**Nguyên nhân:**

1. `#paymentFields` hardcode `bg-light`:
```html
<div id="paymentFields" class="p-3 border border-2 border-dark rounded-3 bg-light mb-2">
```
→ `bg-light` = nền trắng, không đổi theo dark mode

2. `#fields-BANK` hardcode `bg-white`:
```html
<div class="small fw-semibold text-secondary p-2 bg-white border rounded">
```
→ `bg-white` = trắng cứng, không thay đổi

**Cách sửa:**
1. `#paymentFields`: `bg-light` → `var(--gf-card-bg)`
2. `#fields-BANK` inner div: `bg-white` → `var(--gf-card-bg)`
3. Kiểm tra các element khác trong checkout.jsp có hardcode màu không

**Thay đổi file:** `checkout.jsp`

---

## TỔNG HỢP FILE CẦN SỬA

| File | Vấn đề |
|------|---------|
| `index.jsp` | VĐ1: Thêm điều kiện hiển thị user |
| `CheckoutController.java` | VĐ2: Thêm API cart; VĐ3: Fix null wallet; VĐ4: Validation |
| `index.js` | VĐ2: Gọi API cart |
| `checkout.jsp` | VĐ4: Validation; VĐ5: Dark mode CSS |
