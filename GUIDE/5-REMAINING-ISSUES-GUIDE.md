# HƯỚNG DẪN: PHÂN TÍCH 5 VẤN ĐỀ CÒN TỒN ĐỌNG

**Ngày:** 2026-05-28
**Project:** GameStore

---

## MỤC LỤC

1. [Vấn đề 1: Đăng nhập — Navbar và trang profile](#vấn-đề-1-đăng-nhập--navbar-và-trang-profile)
2. [Vấn đề 2: Giỏ hàng — localStorage vs Database](#vấn-đề-2-giỏ-hàng--localstorage-vs-database)
3. [Vấn đề 3: Lỗi 500 — Null Wallet](#vấn-đề-3-lỗi-500--null-wallet)
4. [Vấn đề 4: Validation số điện thoại](#vấn-đề-4-validation-số-điện-thoại)
5. [Vấn đề 5: Dark mode và CSS variables](#vấn-đề-5-dark-mode-và-css-variables)

---

## VẤN ĐỀ 1: ĐĂNG NHẬP — NAVBAR VÀ TRANG PROFILE

### Hiện tượng

- Sau khi đăng nhập, trên navbar vẫn hiển thị icon đăng nhập
- Không thấy tên user ở đâu
- Bấm vào icon đăng nhập → quay lại trang login thay vì trang profile

### Nguyên nhân

Code hiện tại trong `index.jsp`:

```jsp
<!-- Luôn hiển thị nút đăng nhập, không có điều kiện -->
<a href="${pageContext.request.contextPath}/login" class="gf-icon-btn...">
    <i data-lucide="circle-user" width="20" height="20"></i>
</a>
```

Sau khi đăng nhập, `currentUser` đã được lưu vào session:
```java
// AuthController.java - dòng 44
session.setAttribute("currentUser", user);
```

Nhưng `index.jsp` không kiểm tra `${currentUser != null}` để hiển thị khác.

### Giải pháp: Dùng JSTL c:choose

```jsp
<c:choose>
    <c:when test="${not empty currentUser}">
        <!-- Đã đăng nhập: hiển thị user -->
        <div class="dropdown">
            <button class="gf-icon-btn dropdown-toggle"
                    data-bs-toggle="dropdown" type="button">
                <i data-lucide="user" width="20" height="20"></i>
                ${currentUser.fullName}
            </button>
            <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/library">
                    <i data-lucide="library" width="16" height="16"></i> Thư viện game
                </a></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">
                    <i data-lucide="log-out" width="16" height="16"></i> Đăng xuất
                </a></li>
            </ul>
        </div>
    </c:when>
    <c:otherwise>
        <!-- Chưa đăng nhập: hiển thị icon đăng nhập -->
        <a href="${pageContext.request.contextPath}/login"
           class="gf-icon-btn gf-press" style="background:#C084FC">
            <i data-lucide="circle-user" width="20" height="20"></i>
        </a>
    </c:otherwise>
</c:choose>
```

### Tại sao dùng `c:choose`?

| Cách | Ví dụ | Ưu điểm |
|------|--------|--------|
| JSTL `c:choose` | `<c:when test="${not empty currentUser}">` | Render ở server, clean HTML |
| JavaScript `if` | `if ('${currentUser}' != '') { ... }` | Chạy ở client, có thể blink |
| Session scope | `${sessionScope.currentUser}` | Tường minh hơn |

### Cách kiểm tra session trong JSP

```jsp
${currentUser}           ← request + session + application
${sessionScope.currentUser}  ← chỉ session
${pageContext.session.maxInactiveInterval}  ← timeout
```

---

## VẤN ĐỀ 2: GIỎ HÀNG — localStorage VS DATABASE

### Hiện tượng

- Thêm game vào giỏ hàng (localStorage hiển thị đúng)
- Vào trang checkout → báo "Giỏ hàng trống!"
- Server query `cart_items` từ DB → không có gì

### Nguyên nhân gốc — Hai hệ thống giỏ hàng

```
TRÌNH DUYỆT                           SERVER
    │                                   │
    │ quickAddToCart(id)                │
    │     │                             │
    │     ▼                             │
    │ localStorage[id] = true           │
    │ cartCount++                       │
    │     │                             │
    │     ▼                             │
    │ DOM cập nhật badge               │
    │                                   │
    │                                   │ /checkout (GET)
    │                                   │     │
    │                                   │     ▼
    │                                   │ SELECT * FROM cart_items
    │                                   │ WHERE user_id = X
    │                                   │     │
    │                                   │     ▼
    │                                   │ cartItems = []  ← TRỐNG!
    │                                   │
    ▼                                   ▼
```

**Code hiện tại** — chỉ localStorage, không gọi server:

```javascript
// index.js - dòng 93-112
function quickAddToCart(event, id) {
    const gameId = String(id);
    if (cart.has(gameId)) cart.delete(gameId);
    else cart.add(gameId);
    saveState();

    /* Nếu có backend controller, bật đoạn này:
    await fetch(contextPath + '/cart/add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: 'gameId=' + encodeURIComponent(gameId)
    });
    */
}
```

### Giải pháp: Tạo API cart đồng bộ

**Bước 1: Tạo API thêm vào giỏ**

```java
@PostMapping("/api/cart/add")
@ResponseBody
public ResponseEntity<?> addToCart(@RequestParam("gameId") Long gameId, HttpSession session) {
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        return ResponseEntity.status(401).body(Map.of("success", false, "message", "Chưa đăng nhập."));
    }

    Session hqSession = sessionFactory.getCurrentSession();

    // Kiểm tra game đã có trong giỏ chưa
    String hql = "FROM CartItem WHERE user.id = :userId AND game.id = :gameId";
    CartItem existing = hqSession.createQuery(hql, CartItem.class)
            .setParameter("userId", currentUser.getId())
            .setParameter("gameId", gameId)
            .uniqueResult();

    if (existing == null) {
        CartItem item = new CartItem();
        item.setUser(currentUser);
        Game game = hqSession.get(Game.class, gameId);
        item.setGame(game);
        item.setQuantity(1);
        hqSession.save(item);
    }

    return ResponseEntity.ok(Map.of("success", true));
}
```

**Bước 2: Sửa index.js gọi API**

```javascript
async function quickAddToCart(event, id) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }

    const gameId = String(id);
    if (cart.has(gameId)) {
        cart.delete(gameId);
        // Gọi API xóa khỏi DB
        await fetch(contextPath + '/api/cart/remove?itemId=' + gameId, {
            method: 'POST'
        });
    } else {
        cart.add(gameId);
        // Gọi API thêm vào DB
        await fetch(contextPath + '/api/cart/add', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: 'gameId=' + encodeURIComponent(gameId)
        });
    }

    saveState();
}
```

### Tại sao dùng `async/await`?

```javascript
// Sai: fetch không đồng bộ, cart.add chạy trước khi server phản hồi
cart.add(gameId);
fetch('/api/cart/add');  // Request đi, không chờ

// Đúng: chờ server xác nhận rồi mới cập nhật UI
await fetch('/api/cart/add');  // Chờ 200 OK
cart.add(gameId);              // Sau đó mới cập nhật UI
```

---

## VẤN ĐỀ 3: LỖI 500 — NULL WALLET

### Hiện tượng

Bấm "Thanh toán an toàn" → HTTP 500

### Nguyên nhân

```
User đăng ký tài khoản mới
    ↓
User đăng nhập
    ↓
User thêm game vào giỏ
    ↓
User bấm thanh toán → paymentMethod = WALLET
    ↓
Code query: Wallet WHERE user_id = X
    ↓
wallet = null    ← User chưa có ví trong bảng wallets!
    ↓
Code kiểm tra: if (wallet == null) { return "checkout"; }
    ↓
Forward "checkout"  ← NHƯNG model chưa được set đầy đủ!
    ↓
checkout.jsp truy cập ${cartItems} = null
    ↓
❌ HTTP 500 — NullPointerException hoặc lỗi render
```

### Tại sao forward gây lỗi?

```java
// processCheckout — dòng 124-131
if (wallet == null) {
    model.addAttribute("error", "Tài khoản ví không tồn tại.");
    model.addAttribute("cartItems", cartItems);
    model.addAttribute("subtotal", subtotal);
    model.addAttribute("discount", discount);
    model.addAttribute("total", total);
    model.addAttribute("walletBalance", BigDecimal.ZERO);
    return "checkout";   // ← FORWARD, model có đủ
}
```

Đoạn này **không lỗi** — model có đủ. Lỗi thực sự có thể ở chỗ **khác**. Cần kiểm tra:

1. `currentUser` có bị detached khỏi session không?
2. Game trong `cartItems` có lazy-load không?
3. `walletBalance` query có lỗi không?

### Cách debug

Thêm log vào `processCheckout`:

```java
try {
    String hqlWallet = "SELECT balance FROM Wallet WHERE user_id = :userId";
    Object result = sessionFactory.getCurrentSession()
            .createNativeQuery(hqlWallet)
            .setParameter("userId", currentUser.getId())
            .uniqueResult();
} catch (Exception e) {
    e.printStackTrace();  // In lỗi ra console
}
```

### Giải pháp an toàn

```java
if ("WALLET".equals(paymentMethod)) {
    Wallet wallet = hqSession
            .createQuery("FROM Wallet WHERE user.id = :userId", Wallet.class)
            .setParameter("userId", currentUser.getId())
            .uniqueResult();

    if (wallet == null || wallet.getBalance().compareTo(total) < 0) {
        // ⚠️ Lỗi: chuyển hướng kèm tham số lỗi
        return "redirect:/checkout?error=wallet_error";
    }

    wallet.setBalance(wallet.getBalance().subtract(total));
    hqSession.update(wallet);

    WalletTransaction tx = new WalletTransaction();
    tx.setWallet(wallet);
    tx.setType("PURCHASE");
    tx.setAmount(total);
    tx.setStatus("SUCCESS");
    tx.setReferenceId("ORDER_" + System.currentTimeMillis());
    hqSession.save(tx);
}
```

---

## VẤN ĐỀ 4: VALIDATION SỐ ĐIỆN THOẠI

### Hiện tại

```html
<input type="tel" class="gf-checkout-input" name="phone"
       placeholder="Nhập số điện thoại liên lạc" required>
```

Chỉ kiểm tra **trống**. Không kiểm tra:
- Có phải số không? (`abc123` → chấp nhận)
- Đủ 10-11 ký tự không? (`0912` → chấp nhận)

### Các tầng validation

| Tầng | Cách | Ví dụ |
|------|------|--------|
| HTML | `pattern`, `minlength`, `maxlength` | `<input pattern="\d{10,11}">` |
| JavaScript | Regex trước khi submit | `if (!/^\d{10,11}$/.test(phone))` |
| Server | `@Valid`, `@Pattern` annotation | `@Pattern(regexp = "\\d{10,11}")` |

### Tầng 1: HTML5 validation

```html
<input
    type="tel"
    name="phone"
    class="gf-checkout-input"
    placeholder="Nhập số điện thoại"
    required
    minlength="10"
    maxlength="11"
    pattern="\d{10,11}"
    title="Số điện thoại phải là 10-11 chữ số"
>
```

### Tầng 2: JavaScript validation (checkout.js)

```javascript
form.addEventListener('submit', function(e) {
    const phoneInput = form.querySelector('[name="phone"]');
    const phone = phoneInput.value.trim();

    // Kiểm tra 10-11 chữ số
    if (!/^\d{10,11}$/.test(phone)) {
        e.preventDefault();
        alert('Số điện thoại phải là 10-11 chữ số!');
        phoneInput.focus();
        return;
    }

    // Kiểm tra bắt đầu bằng số 0
    if (!/^0/.test(phone)) {
        e.preventDefault();
        alert('Số điện thoại phải bắt đầu bằng số 0!');
        return;
    }
});
```

### Tầng 3: Server-side validation

```java
@PostMapping("/checkout/process")
public String processCheckout(
        @RequestParam("paymentMethod") String paymentMethod,
        @RequestParam("fullName") String fullName,
        @RequestParam("phone") @Pattern(regexp = "\\d{10,11}",
                                         message = "Số điện thoại phải là 10-11 chữ số")
            String phone,
        // ...
) {
    // Nếu regex không khớp, Spring tự động quay về checkout với lỗi
}
```

### Regex giải thích

```
^\d{10,11}$

^           ← Bắt đầu chuỗi
\d{10,11}   ← 10 đến 11 ký tự số (0-9)
$           ← Kết thúc chuỗi

→ "0912345678"  ✅ Hợp lệ (10 số)
→ "09123456789" ✅ Hợp lệ (11 số)
→ "9123456789"  ❌ Không hợp lệ (không bắt đầu bằng 0)
→ "09123abc567" ❌ Không hợp lệ (có chữ)
→ "091234567"   ❌ Không hợp lệ (9 số)
```

---

## VẤN ĐỀ 5: DARK MODE VÀ CSS VARIABLES

### Hiện tượng

Chế độ tối OK, nhưng khu vực chọn ví điện tử / nhập thẻ Visa **vẫn sáng trắng**.

### Nguyên nhân

CSS dùng **hardcoded color class** thay vì **CSS custom properties (variables)**.

```html
<!-- checkout.jsp - dòng 233 -->
<div id="paymentFields" class="p-3 border border-2 border-dark rounded-3 bg-light mb-2">
<!--                                                       ^^^^^^^^ hardcoded -->

<!-- checkout.jsp - dòng 270 -->
<div class="small fw-semibold text-secondary p-2 bg-white border rounded">
<!--                                                     ^^^^^^^^ hardcoded -->
```

`bg-light` và `bg-white` là class của Bootstrap, luôn giữ nền trắng bất kể dark mode.

### Cách CSS variables hoạt động

```css
/* Định nghĩa biến */
:root {
    --gf-card-bg: #FFFFFF;   /* Light mode: trắng */
}
html.gf-dark-mode {
    --gf-card-bg: #27272a;  /* Dark mode: xám đen */
}

/* Sử dụng biến */
.my-panel {
    background: var(--gf-card-bg);  /* Tự động đổi theo chế độ */
}
```

### Cách fix

```html
<!-- TRƯỚC -->
<div id="paymentFields" class="... bg-light ...">

<!-- SAU -->
<div id="paymentFields" class="..." style="background: var(--gf-card-bg);">
```

Hoặc thêm CSS rule:

```css
#paymentFields {
    background: var(--gf-card-bg) !important;
}
```

### Quy tắc khi dùng Bootstrap với dark mode

```
Bootstrap class    │ CSS variable tương đương
──────────────────┼───────────────────────────────
bg-white          │ var(--gf-card-bg)
bg-light          │ var(--gf-card-bg) hoặc var(--gf-paper)
text-dark         │ var(--gf-text-main)
text-muted        │ var(--gf-muted)
border-dark       │ var(--gf-ink)
```

---

## TÓM TẮT

| # | Vấn đề | Nguyên nhân | Giải pháp |
|---|---------|-------------|-----------|
| 1 | Navbar không hiển thị user | Không có `c:choose` kiểm tra session | Thêm JSTL điều kiện |
| 2 | Giỏ hàng trống dù thêm game | localStorage ≠ DB | Tạo API `/api/cart/add` |
| 3 | Lỗi 500 thanh toán | wallet = null + forward thiếu data | Redirect kèm error param |
| 4 | Không validate phone | Chỉ có HTML `required` | Thêm pattern + JS + server |
| 5 | Payment fields không đổi màu | `bg-light`/`bg-white` hardcoded | Dùng `var(--gf-card-bg)` |

---

*Guide được viết ngày 2026-05-28 bởi AI Coding Assistant*
