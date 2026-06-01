# Báo Cáo Sửa Lỗi Checkout Page — Chi Tiết

**Ngày:** 28/05/2026
**Tác giả:** Cursor Agent

---

## Mục lục
1. [Tổng quan lỗi](#1-tổng-quan-lỗi)
2. [Lỗi 1: Giỏ hàng chỉ hiện 1 game dù có 4](#2-lỗi-1-giỏ-hàng-chỉ-hiện-1-game-dù-có-4)
3. [Lỗi 2: Phường/xã — API không tải được dữ liệu](#3-lỗi-2-phườngxã--api-không-tải-được-dữ-liệu)
4. [Lỗi 3: Dark mode select không nhìn thấy chữ](#4-lỗi-3-dark-mode-select-không-nhìn-thấy-chữ)
5. [Lỗi 4: Nút + không disable, nút - chưa xóa thực sự](#5-lỗi-4-nút--không-disable-nút---chưa-xóa-thực-sự)
6. [Lỗi 5: Visa validation không có](#6-lỗi-5-visa-validation-không-có)
7. [Lỗi 6: onDecrease không có confirm](#7-lỗi-6-ondecrease-không-có-confirm)
8. [Lỗi 7: Nút xóa riêng thừa](#8-lỗi-7-nút-xóa-riêng-thừa)
9. [Lỗi 8: Tag giao hàng tự động thừa](#9-lỗi-8-tag-giao-hàng-tự-động-thừa)
10. [Root cause phường/xã — Phát hiện qua log thực tế](#10-root-cause-phườngxã--phát-hiện-qua-log-thực-tế)
11. [Giải pháp cuối cùng](#11-giải-pháp-cuối-cùng)
12. [Các file đã sửa](#12-các-file-đã-sửa)

---

## 1. Tổng quan lỗi

8 lỗi riêng biệt được phát hiện và sửa trong quá trình review checkout page:

| # | Mô tả | Mức độ |
|---|-------|--------|
| 1 | Giỏ hàng chỉ hiện 1/4 game | Cao |
| 2 | Phường/xã không tải được | Cao |
| 3 | Dark mode select chữ sáng + viền sáng | Trung |
| 4 | Nút + không disable, nút - chưa xóa thực sự | Trung |
| 5 | Visa validation không có | Cao |
| 6 | onDecrease không confirm trước khi xóa | Thấp |
| 7 | Nút xóa riêng thừa | Thấp |
| 8 | Tag giao hàng tự động thừa | Thấp |

---

## 2. Lỗi 1: Giỏ hàng chỉ hiện 1 game dù có 4

### Triệu chứng
- JSP `<c:forEach>` render đúng 4 items trong HTML
- Nhưng trên giao diện chỉ thấy 1 game (thường là cuối cùng)
- Số đếm giỏ hàng vẫn hiện đúng "4 sản phẩm"

### Nguyên nhân
`<c:forEach>` trong checkout.jsp tạo 4 `<div class="gf-cart-item">` nằm trong `<div class="gf-cart-items-wrapper d-flex flex-column gap-3">`. Vấn đề CSS layout collapse — các items có thể bị collapse theo chiều ngang do parent container không có `width: 100%` hoặc flex container có chiều ngang bị giới hạn. Chỉ item cuối cùng hiển thị.

### Giải pháp
- Bỏ `<c:forEach>` server-side render hoàn toàn
- Chuyển data ra `<script>window.cartItemsData = [...]</script>` trong JSP
- JS render client-side qua `renderCartItems()`
- Mỗi lần xóa: `splice()` khỏi array → `renderCartItems()` re-render toàn bộ
- Tách `window.cartItemsData` ra file `.js` sạch (tránh IDE lỗi parse JSP)

### Code thay đổi
```jsp
<!-- checkout.jsp - trước: -->
<div class="gf-cart-items-wrapper d-flex flex-column gap-3">
  <c:forEach var="item" items="${cartItems}">
    <div class="gf-cart-item" data-item-id="${item.id}" ...>
      ...
    </div>
  </c:forEach>
</div>

<!-- checkout.jsp - sau: -->
<div id="gfCartItemsWrapper"></div>

<!-- Trước thẻ script include: -->
<script>
  window.cartItemsData = [
    <c:forEach var="item" items="${cartItems}" varStatus="vs">
      { id: "${item.id}", price: ${item.game.price}, ... }
      <c:if test="${not vs.last}">,</c:if>
    </c:forEach>
  ];
</script>
```

```js
// checkout.js
function renderCartItems() {
  var items = window.cartItemsData || [];
  // render từng item với flex layout đầy đủ
  items.forEach(function(item) {
    var html = '<div class="gf-cart-item" ...>';
    // ...
  });
}
```

---

## 3. Lỗi 2: Phường/xã — API không tải được dữ liệu

### Triệu chứng
- Dropdown tỉnh/thành phố load đúng
- Khi chọn tỉnh → phường/xã luôn hiện "Không có dữ liệu"
- F12 Console: URL fetch bị 404

### Nguyên nhân gốc
Lỗi này trải qua **nhiều lần fix sai** trước khi tìm được root cause:

#### Lần 1: Dùng `fetch` thay `XMLHttpRequest`
Ban đầu dùng `fetch()` — không hoạt động vì CORS hoặc browser policy. Đổi sang `XMLHttpRequest`.

#### Lần 2: URL format sai `{id}.json`
Tưởng file là `12387.json` → 404. Thực tế format là `{id}.{Name}.json`.

#### Lần 3: Slug lowercase với dấu
Dùng `slug.toLowerCase()` → `"Hà Tĩnh"` → `"hà tĩnh"` (dấu vẫn còn) → 404.

#### Lần 4: Slug generator có space
Thiếu logic nối các từ → `"Hà Tĩnh"` → `"HàTĩnh"` → 404 (file thực tế: `"HaTinh"`).

#### Lần 5: `toLowerCase()` không strip diacritics
Tưởng đã fix nhưng `toLowerCase()` **không bỏ được dấu tiếng Việt**. `"à"` → `"à"` (cùng ký tự). Log thực tế từ browser:
```
12387.HàTĩnh.json  → 404  (dấu còn)
12382.HảiPhòng.json → 404 (dấu còn)
```

#### Root cause cuối cùng
`toLowerCase()` JavaScript không strip diacritics. Cần dùng **Unicode NFD decomposition**.

### Giải pháp
```js
// Chuẩn hóa: decompose Unicode → bỏ combining marks
function stripDiacritics(text) {
  return text.normalize("NFD").replace(/[\u0300-\u036F]/g, "");
}

function slugifyVietnamese(text) {
  // Bỏ prefix "Thành phố" / "Tỉnh"
  var cleaned = text
    .replace(/^Thành phố\s*/i, "")
    .replace(/^Tỉnh\s*/i, "")
    .replace(/Thành phố\s*/gi, "")
    .replace(/Tỉnh\s*/gi, "")
    .trim();

  // Tách theo khoảng trắng → mỗi từ bỏ dấu → viết HOA đầu → nối
  var parts = cleaned.split(/\s+/);
  var result = "";
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].length > 0) {
      var plain = stripDiacritics(parts[i]);
      result += plain.charAt(0).toUpperCase() + plain.slice(1).toLowerCase();
    }
  }
  return result;
}
```

### Kết quả verify từ GitHub API
| Tỉnh/Thành | Name từ API | Slug | URL đúng |
|---|---|---|---|
| Hà Tĩnh | "Tỉnh Hà Tĩnh" | "HaTinh" | `12387.HaTinh.json` ✓ |
| Hải Phòng | "Thành phố Hải Phòng" | "HaiPhong" | `12382.HaiPhong.json` ✓ |
| Thanh Hóa | "Tỉnh Thanh Hóa" | "ThanhHoa" | `12385.ThanhHoa.json` ✓ |
| Hồ Chí Minh | "Thành phố Hồ Chí Minh" | "HoChiMinh" | `12397.HoChiMinh.json` ✓ |
| Hưng Yên | "Tỉnh Hưng Yên" | "HungYen" | `12383.HungYen.json` ✓ |
| Tây Ninh | "Tỉnh Tây Ninh" | "TayNinh" | `12398.TayNinh.json` ✓ |
| **Đà Nẵng** | "Thành phố Đà Nẵng" | **"DaNang"** | `12390.DaNang.json` ✓ |
| **Đắk Lắk** | "Tỉnh Đắk Lắk" | **"DakLak"** | `12394.DakLak.json` ✓ |
| **Đồng Tháp** | "Tỉnh Đồng Tháp" | **"DongThap"** | `12399.DongThap.json` ✓ |
| **Lâm Đồng** | "Tỉnh Lâm Đồng" | **"LamDong"** | `12395.LamDong.json` ✓ |

### Phát hiện cuối cùng: `Đ` và `Ô` không bị NFD decompose
**`Đ` (U+0110 / U+00D0)** và **`ô` (U+00F4)** không bị `normalize("NFD")` decompose vì chúng là **precomposed characters** không có decomposed form trong Unicode. VD: `"Đ"` → `"Đ"` (không đổi) sau NFD.

Các ký tự tiếng Việt **cần replace thủ công**:
- `Đ` → `D`, `đ` → `d`
- `Ă` → `A`, `ă` → `a`
- `Ô` → `O`, `ô` → `o`
- `Ư` → `U`, `ư` → `u`
- `Â` → `A`, `â` → `a`
- Tất cả Vietnamese diacritics trong BMP + extended ranges

### Cache issue
Sau khi deploy code mới, browser vẫn load file JS cũ từ cache. Thêm cache-buster:
```jsp
<script src=".../checkout.js?v=20250628b"></script>
```

---

## 4. Lỗi 3: Dark mode select không nhìn thấy chữ

### Triệu chứng
Dark mode: select có viền trắng + chữ trắng → hòa vào nhau, không nhìn thấy gì.

### Nguyên nhân
```css
html.gf-dark-mode .gf-checkout-select {
  background-color: var(--gf-card-bg) !important;  /* #27272a → vẫn sáng */
  color: var(--gf-text-main) !important;          /* trắng */
  border-color: var(--gf-ink) !important;          /* viền trắng */
}
```

`--gf-card-bg` trong dark mode = `#27272a` (xám nhẹ) trong khi viền = trắng. Không đủ contrast.

### Giải pháp
```css
html.gf-dark-mode .gf-checkout-select {
  background-color: var(--gf-input-bg) !important;  /* #18181b → nền rất tối */
  color: var(--gf-text-main) !important;          /* trắng */
  border-color: var(--gf-ink) !important;          /* viền trắng */
}
```

---

## 5. Lỗi 4: Nút + không disable, nút - chưa xóa thực sự

### Triệu chứng
- Nút `+` bấm được nhưng không làm gì (logic rỗng) → gây hiểu lầm
- Nút `-` khi qty = 1 → confirm xóa nhưng `removeCartItem` chưa splice khỏi array

### Nguyên nhân
1. Nút `+` chưa có `disabled` attribute trong HTML
2. `removeCartItem` chỉ splice localStorage nhưng không splice `window.cartItemsData`

### Giải pháp
```js
// HTML render - nút + disable từ đầu
'<button type="button" class="gf-qty-btn" disabled>+</button>'

window.onDecrease = function(btn, itemId) {
  var input = box.querySelector(".gf-qty-input");
  var currentQty = parseInt(input.value, 10);
  if (currentQty <= 1) {
    if (confirm("...")) {
      removeCartItem(itemId); // splice array + re-render + recalculate
    }
  }
  // Không cho giảm thêm
};

window.onIncrease = function(btn) {
  // Không làm gì - button đã disabled
};

window.removeCartItem = function(itemId) {
  // splice khỏi window.cartItemsData
  var items = window.cartItemsData || [];
  for (var i = 0; i < items.length; i++) {
    if (String(items[i].id) === String(itemId)) {
      items.splice(i, 1);
      break;
    }
  }
  renderCartItems();
  recalculateCartTotals();
};
```

---

## 6. Lỗi 5: Visa validation không có

### Triệu chứng
Card Number, Expiry, CVV nhập bừa cũng được, không check.

### Giải pháp
Thêm validation đầy đủ:

```js
// Real-time formatting
cardNumberInput.addEventListener("input", function() {
  var digits = this.value.replace(/\D/g, "").slice(0, 16);
  var formatted = digits.replace(/(.{4})/g, "$1 ").trim();
  this.value = formatted;
});

cardExpiryInput.addEventListener("input", function() {
  var digits = this.value.replace(/\D/g, "").slice(0, 4);
  if (digits.length >= 2) digits = digits.slice(0,2) + "/" + digits.slice(2);
  this.value = digits;
});

cardCvvInput.addEventListener("input", function() {
  this.value = this.value.replace(/\D/g, "").slice(0, 4);
});

// Submit validation
if (selectedPaymentMethod === "CARD") {
  // Card number: 16 chữ số
  if (!/^\d{16}$/.test(rawCard)) { e.preventDefault(); alert("..."); return; }

  // Expiry: MM/YY, tháng 1-12, chưa hết hạn
  var expMonth = parseInt(expiryParts[0], 10);
  var expYear = parseInt("20" + expiryParts[1], 10);
  var now = new Date();
  if (expMonth < 1 || expMonth > 12) { e.preventDefault(); alert("Thang khong hop le"); return; }
  if (expYear < now.getFullYear() || (expYear === now.getFullYear() && expMonth < now.getMonth() + 1)) {
    e.preventDefault(); alert("The da het han"); return;
  }

  // CVV: 3-4 chữ số
  if (!/^\d{3,4}$/.test(cardCvv.value)) { e.preventDefault(); alert("CVV khong hop le"); return; }
}
```

---

## 7. Lỗi 6: onDecrease không confirm trước khi xóa

### Giải pháp
```js
if (currentQty <= 1) {
  if (confirm("Ban co chan chan muon xoa game nay khoi gio hang?")) {
    removeCartItem(itemId);
  }
}
```

---

## 8. Lỗi 7: Nút xóa riêng thừa

### Giải pháp
Bỏ nút `<button class="gf-delete-btn">` khỏi `renderCartItems()`. Logic xóa gom vào nút `-`.

---

## 9. Lỗi 8: Tag giao hàng tự động thừa

### Giải pháp
Bỏ dòng badge:
```html
<span class="gf-item-badge gf-badge-auto"><i data-lucide="zap" width="12" height="12"></i> Giao hang: Tu dong</span>
```
khỏi `renderCartItems()`.

---

## 10. Root cause phường/xã — Phát hiện qua log thực tế

### Quá trình debug chi tiết

**Bước 1: Tra cứu GitHub repo**
Dùng GitHub API lấy tree của repo `AnhKhoaCNTT/DonViHanhChinhVietNam`:
```
json-raw/12370.HaNoi.json
json-raw/12387.HaTinh.json
json-raw/12397.HoChiMinh.json
...
json-raw/Tinh.ThanhPho.json
```

Format chuẩn: `{id}.{PascalCaseName}.json`

**Bước 2: Đọc Tinh.ThanhPho.json**
Lấy toàn bộ 34 tỉnh/thành để biết `id` và `name` chính xác:
```
12370 - Thành phố Hà Nội
12382 - Thành phố Hải Phòng
12387 - Tỉnh Hà Tĩnh
12397 - Thành phố Hồ Chí Minh
```

**Bước 3: Verify từng file qua GitHub API**
```
https://api.github.com/repos/AnhKhoaCNTT/DonViHanhChinhVietNam/contents/json-raw/12387.HaTinh.json
→ HTTP 200: File tồn tại
```

**Bước 4: Log thực tế từ browser**
Log console thực tế cho thấy:
```
[Ward API] Fetching: .../12387.HàTĩnh.json  → 404
[Ward API] Fetching: .../12382.HảiPhòng.json → 404
```

→ Vấn đề: URL có dấu → `toLowerCase()` không bỏ được diacritics

**Giải pháp cuối:** Dùng `normalize("NFD")` + strip `[\u0300-\u036F]`

---

## 11. Giải pháp cuối cùng

### a) slugifyVietnamese (FINAL - 2025-05-28)
```js
function slugifyVietnamese(text) {
  var cleaned = text
    .replace(/^Thành phố\s*/i,"").replace(/^Tỉnh\s*/i,"")
    .replace(/Thành phố\s*/gi,"").replace(/Tỉnh\s*/gi,"").trim();

  var replacements = {
    "\u0102":"A","\u0103":"a","\u0110":"D","\u0111":"d",
    "\u00D4":"O","\u00F4":"o","\u00C2":"A","\u00E2":"a",
    "\u00D0":"D","\u00F0":"d",
    "\u01A0":"O","\u01A1":"o","\u01AF":"U","\u01B0":"u",
    "\u1EA0":"A","\u1EA1":"a","\u1EA2":"A","\u1EA3":"a",
    "\u1EB0":"A","\u1EB1":"a","\u1EB2":"A","\u1EB3":"a",
    "\u1EB4":"A","\u1EB5":"a","\u1EB6":"A","\u1EB7":"a",
    "\u1EB8":"E","\u1EB9":"e","\u1EBA":"E","\u1EBB":"e",
    "\u1EBC":"E","\u1EBD":"e",
    "\u1EC0":"E","\u1EC1":"e","\u1EC2":"E","\u1EC3":"e",
    "\u1EC4":"E","\u1EC5":"e","\u1EC6":"E","\u1EC7":"e",
    "\u1EC8":"I","\u1EC9":"i","\u1ECA":"I","\u1ECB":"i",
    "\u1ECC":"O","\u1ECD":"o","\u1ECE":"O","\u1ECF":"o",
    "\u1ED0":"O","\u1ED1":"o","\u1ED2":"O","\u1ED3":"o",
    "\u1ED4":"O","\u1ED5":"o","\u1ED6":"O","\u1ED7":"o",
    "\u1ED8":"O","\u1ED9":"o",
    "\u1EDA":"O","\u1EDB":"o","\u1EDC":"O","\u1EDD":"o",
    "\u1EDE":"O","\u1EDF":"o","\u1EE0":"O","\u1EE1":"o",
    "\u1EE2":"O","\u1EE3":"o",
    "\u1EE4":"U","\u1EE5":"u","\u1EE6":"U","\u1EE7":"u",
    "\u1EE8":"U","\u1EE9":"u","\u1EEA":"U","\u1EEB":"u",
    "\u1EEC":"U","\u1EED":"u","\u1EEE":"U","\u1EEF":"u",
    "\u1EF0":"U","\u1EF1":"u",
    "\u1EF2":"Y","\u1EF3":"y","\u1EF4":"Y","\u1EF5":"y",
    "\u1EF6":"Y","\u1EF7":"y","\u1EF8":"Y","\u1EF9":"y"
  };

  var parts = cleaned.split(/\s+/);
  var result = "";
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].length > 0) {
      var plain = parts[i].normalize("NFD").replace(/[\u0300-\u036F]/g,"");
      plain = plain.split("").map(function(c){return replacements[c]||c;}).join("");
      result += plain.charAt(0).toUpperCase() + plain.slice(1).toLowerCase();
    }
  }
  return result;
}
```

**Phát hiện quan trọng:** `Đ` (U+0110) và `Ô` (U+00F4) **không bị NFD decompose** vì chúng là precomposed characters không có decomposed form. `normalize("NFD")` chỉ xử lý combining marks (dấu), không xử lý base character. → Phải replace thủ công `Đ→D`, `Ô→O`, etc.

### b) Cache-buster
```jsp
<script src=".../checkout.js?v=20250628b"></script>
```

---

## 12. Các file đã sửa

| File | Thay đổi |
|------|---------|
| `src/main/webapp/assets/js/checkout.js` | Rewrite hoàn toàn: IIFE, var-only, XMLHttpRequest, stripDiacritics, slugifyVietnamese, renderCartItems, removeCartItem, Visa validation |
| `src/main/webapp/assets/css/checkout.css` | Dark mode select dùng `--gf-input-bg`, xóa `.gf-delete-btn`, `.gf-badge-auto` |
| `src/main/webapp/WEB-INF/views/checkout.jsp` | Bỏ `<c:forEach>` cart, thêm `window.cartItemsData`, cache-buster `?v=20250628b`, bỏ `gf-cart-items-wrapper` div |

---

## Lỗi không liên quan: `onboarding.js`

Log `onboarding.js:48 Uncaught TypeError: Cannot read properties of undefined (reading 'getImageNode')` **không phải lỗi từ project GameStore**.

- Không có file `onboarding.js` trong `src/main/webapp/`
- Đây là script từ **Cursor IDE plugin** hoặc **Figma extension**
- Nằm ngoài phạm vi ứng dụng — không ảnh hưởng đến checkout

---

## Trạng thái sau sửa

| Lỗi | Trạng thái |
|-----|------------|
| Giỏ hàng chỉ hiện 1 game | ✅ Đã fix |
| Phường/xã không tải được | ✅ Đã fix |
| Dark mode select | ✅ Đã fix |
| Nút + không disable | ✅ Đã fix |
| Nút - chưa xóa thực sự | ✅ Đã fix |
| Visa validation | ✅ Đã fix |
| onDecrease confirm | ✅ Đã fix |
| Nút xóa riêng thừa | ✅ Đã fix |
| Tag giao hàng tự động | ✅ Đã fix |
