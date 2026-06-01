# HƯỚNG DẪN: XỬ LÝ DỮ LIỆU KHÔNG CÓ TRONG DATABASE

**Ngày:** 2026-05-28
**Project:** GameStore
**Vấn đề thực tế:** Bảng `orders` trong DB không có 8 trường giao hàng (fullName, phone, address, province, district, ward, notes, paymentMethod). Code cần dùng 8 trường này để hiển thị trang thành công sau khi thanh toán.

---

## MỤC LỤC

1. [Bài toán thực tế](#1-bài-toán-thực-tế)
2. [Giải pháp 1: @Transient (chỉ dùng trong Java)](#2-giải-pháp-1-transient-chỉ-dùng-trong-java)
3. [Giải pháp 2: Session (truyền qua redirect)](#3-giải-pháp-2-session-truyền-qua-redirect)
4. [Kết hợp cả 2 cách — giải pháp được dùng trong project](#4-kết-hợp-cả-2-cách--giải-pháp-được-dùng-trong-project)
5. [Tại sao không dùng request scope?](#5-tại-sao-không-dùng-request-scope)
6. [So sánh các giải pháp](#6-so-sánh-các-giải-pháp)

---

## 1. BÀI TOÁN THỰC TẾ

### Schema DB hiện tại (bảng orders)

```sql
CREATE TABLE [dbo].[orders](
    [id]              [bigint] IDENTITY(1,1) NOT NULL,
    [user_id]         [bigint] NOT NULL,
    [subtotalAmount]  [decimal](15, 2) NOT NULL,
    [discountAmount]  [decimal](15, 2) NOT NULL,
    [totalAmount]     [decimal](15, 2) NOT NULL,
    [promo_code_id]   [bigint] NULL,
    [status]          [varchar](50) NOT NULL,
    [createdAt]       [datetime2](0) NOT NULL,
    [paidAt]          [datetime2](0) NULL,
    -- ❌ THIẾU: paymentMethod, fullName, phone, address,
    -- ❌ THIẾU: province, district, ward, notes
)
```

### Nhu cầu business

- Form checkout thu thập 8 trường: paymentMethod, fullName, phone, address, province, district, ward, notes
- Trang thành công (`order-success.jsp`) cần hiển thị 8 trường này
- **TUYỆT ĐỐI KHÔNG sửa database**

---

## 2. GIẢI PHÁP 1: @Transient (CHỈ DÙNG TRONG JAVA)

### @Transient là gì?

`@Transient` là annotation của JPA/Hibernate, đánh dấu một field trong entity **KHÔNG** được Hibernate quan tâm khi:
- INSERT vào DB
- UPDATE xuống DB
- SELECT từ DB

Field đó chỉ tồn tại trong object Java, không đụng gì đến database.

### Cách dùng

```java
@Entity
@Table(name = "orders")
public class Order {

    // ===== CÁC TRƯỜNG CÓ TRONG DB =====
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;

    // ===== CÁC TRƯỜNG KHÔNG CÓ TRONG DB =====
    @Transient
    private String paymentMethod;   // ← Hibernate BỎ QUA hoàn toàn

    @Transient
    private String fullName;

    @Transient
    private String phone;

    @Transient
    private String address;

    @Transient
    private String province;

    @Transient
    private String district;

    @Transient
    private String ward;

    @Transient
    private String notes;
}
```

### Khi nào dùng @Transient?

✅ **ĐÚNG** khi:
- Dữ liệu chỉ cần dùng TRONG cùng một request
- Không cần lưu xuống DB
- Chỉ dùng để tính toán hoặc hiển thị tạm thời
- Ví dụ: tổng phụ trong hóa đơn, chuỗi định dạng address...

❌ **SAI** khi:
- Dữ liệu cần lưu lại qua nhiều request
- Dùng chung giữa backend và frontend

### Ví dụ đúng với @Transient

```java
// Tính tổng tiền trong một request
@Transient
private BigDecimal grandTotal; // Chỉ cần trong request hiện tại

// Chuỗi địa chỉ đầy đủ để hiển thị
@Transient
private String fullAddress; // Ghép từ address + ward + district + province
```

---

## 3. GIẢI PHÁP 2: Session (TRUYỀN QUA REDIRECT)

### Vấn đề của @Transient

Dùng `@Transient` một mình sẽ gặp vấn đề:

```java
@PostMapping("/checkout/process")
public String processCheckout(..., HttpSession session) {
    Order order = new Order();
    order.setPaymentMethod("WALLET");      // ✅ Lưu được
    order.setFullName("Nguyen Van A");    // ✅ Lưu được

    hqSession.save(order);                 // INSERT xuống DB
    hqSession.flush();

    return "redirect:/checkout/success?orderId=" + order.getId();
    // ⚠️ Redirect = request MỚI
}

@GetMapping("/checkout/success")
public String orderSuccess(@RequestParam Long orderId, ...) {
    Order order = hqSession.get(Order.class, orderId);

    // ❌ order.getPaymentMethod() = null!
    // ❌ order.getFullName() = null!
    // Vì Order được fetch TỪ DB, không phải từ object cũ
}
```

**Nguyên nhân:** Redirect tạo HTTP request mới. Object `order` cũ bị mất. Khi fetch lại từ DB, 8 trường `@Transient` không có trong DB nên = null.

### Giải pháp: Dùng HttpSession

```java
@PostMapping("/checkout/process")
public String processCheckout(..., HttpSession session) {
    // 1. Lấy cart items và tính tiền...
    BigDecimal total = ...;

    // 2. Xử lý thanh toán ví (nếu chọn WALLET)
    if ("WALLET".equals(paymentMethod)) {
        Wallet wallet = hqSession.get(Wallet.class, currentUser.getId());
        wallet.setBalance(wallet.getBalance().subtract(total));
        hqSession.update(wallet);
    }

    // 3. Tạo Order
    Order order = new Order();
    order.setUser(currentUser);
    order.setTotalAmount(total);
    order.setStatus("PAID");
    // paymentMethod, fullName... chỉ set vào object, KHÔNG lưu DB

    hqSession.save(order);

    // 4. LƯU 8 TRƯỜNG VÀO SESSION
    Map<String, String> shippingInfo = new HashMap<>();
    shippingInfo.put("paymentMethod", paymentMethod);
    shippingInfo.put("fullName", fullName);
    shippingInfo.put("phone", phone);
    shippingInfo.put("address", address);
    shippingInfo.put("province", province);
    shippingInfo.put("district", district);
    shippingInfo.put("ward", ward);
    shippingInfo.put("notes", notes);

    session.setAttribute("shippingInfo", shippingInfo);  // ← LƯU VÀO SESSION

    return "redirect:/checkout/success?orderId=" + order.getId();
}

@GetMapping("/checkout/success")
public String orderSuccess(@RequestParam Long orderId, ..., HttpSession session) {
    // 1. Fetch Order từ DB (chỉ lấy 9 trường có trong DB)
    Order order = hqSession.get(Order.class, orderId);

    // 2. ĐỌC 8 TRƯỜNG TỪ SESSION
    @SuppressWarnings("unchecked")
    Map<String, String> shippingInfo =
        (Map<String, String>) session.getAttribute("shippingInfo");

    if (shippingInfo == null) {
        shippingInfo = new HashMap<>(); // Tránh null pointer
    }

    // 3. Gửi cả 2 sang view
    model.addAttribute("order", order);
    model.addAttribute("shippingInfo", shippingInfo);

    // 4. DỌN SESSION sau khi dùng
    session.removeAttribute("shippingInfo");

    return "order-success";
}
```

### View (JSP) sử dụng shippingInfo

```jsp
<!-- Thay vì ${order.fullName} → dùng ${shippingInfo.fullName} -->

<div class="fw-bold">
    ${shippingInfo.fullName} | ${shippingInfo.phone}<br>
    ${shippingInfo.address}, ${shippingInfo.ward},
    ${shippingInfo.district}, ${shippingInfo.province}
</div>
```

---

## 4. KẾT HỢP CẢ 2 CÁCH — GIẢI PHÁP ĐƯỢC DÙNG TRONG PROJECT

### Cách làm

Trong `Order.java`, 8 trường đánh dấu `@Transient` để code trong `processCheckout` gọi `set*()` bình thường mà không lỗi.

```java
@Transient
private String paymentMethod;  // setPaymentMethod() hoạt động

@Transient
private String fullName;      // setFullName() hoạt động
```

Trong `CheckoutController.java`:
1. `set*()` bình thường vào object Order
2. Đồng thời lưu vào `session.setAttribute("shippingInfo", ...)`
3. Redirect sang trang success

Trong `order-success.jsp`:
- Dùng `${shippingInfo.fullName}` thay vì `${order.fullName}`

### Tại sao giữ @Transient trên Order?

Có 2 lý do:

**a) Code gọi set*() không lỗi**

```java
// Trong processCheckout:
order.setPaymentMethod(paymentMethod);  // ✅ Hoạt động dù là @Transient
order.setFullName(fullName);
```

**b) Đảm bảo tính nhất quán**

Entity `Order` có đầy đủ 17 getter/setter. Nếu sau này bạn muốn thêm 8 cột này vào DB, chỉ cần xóa `@Transient` — code ở các nơi khác không cần sửa.

### Luồng dữ liệu hoàn chỉnh

```
Browser                    Server                         DB
  │                          │                            │
  │── GET /checkout ─────────▶│                           │
  │                          │── SELECT cart_items ──────▶│
  │                          │◀── trả về cart items ──────│
  │◀── checkout.jsp ─────────│                            │
  │                          │                            │
  │── POST /checkout/process ─▶│                          │
  │                          │── INSERT orders (9 cột) ──▶│
  │                          │  (8 trường @Transient     │
  │                          │   KHÔNG được insert)       │
  │                          │                            │
  │                          │ session.setAttribute(      │
  │                          │   "shippingInfo", {...})   │
  │                          │                            │
  │◀── 302 Redirect ─────────│                            │
  │                          │                            │
  │── GET /checkout/success ──▶│                          │
  │                          │── SELECT orders BY ID ────▶│
  │                          │  (chỉ 9 cột, 8 = null)    │
  │                          │◀── trả về order ──────────│
  │                          │                            │
  │                          │ session.getAttribute(      │
  │                          │   "shippingInfo") = map    │
  │                          │                            │
  │                          │ model.addAttribute(        │
  │                          │   "order", order,          │
  │                          │   "shippingInfo", map)      │
  │                          │                            │
  │                          │ session.removeAttribute(   │
  │                          │   "shippingInfo")          │
  │                          │                            │
  │◀── order-success.jsp ─────│                            │
  │  (dùng shippingInfo để    │                            │
  │   hiển thị 8 trường)      │                            │
```

---

## 5. TẠI SAO KHÔNG DÙNG REQUEST SCOPE?

### Cơ chế request scope (model.addAttribute)

```java
// ❌ SAI — DÙNG REQUEST SCOPE
@PostMapping("/checkout/process")
public String processCheckout(..., Model model) {
    model.addAttribute("shippingInfo", shippingInfo);
    return "redirect:/checkout/success"; // ← Redirect = request MỚI
}

// Request MỚI → model bị mất hoàn toàn
```

### Cơ chế session (session.setAttribute)

```java
// ✅ ĐÚNG — DÙNG SESSION
@PostMapping("/checkout/process")
public String processCheckout(..., HttpSession session) {
    session.setAttribute("shippingInfo", shippingInfo);
    return "redirect:/checkout/success";
}

// Session tồn tại qua NHIỀU request
// → Trang success vẫn đọc được shippingInfo
```

### So sánh

| Tiêu chí | `model.addAttribute` | `session.setAttribute` |
|-----------|----------------------|----------------------|
| Phạm vi | 1 request duy nhất | Toàn bộ phiên làm việc |
| Redirect giữ được? | ❌ Không | ✅ Có |
| Multi-tab? | ❌ Mỗi tab riêng | ⚠️ Chia sẻ chung |
| Tự dọn? | Tự động | ❌ Phải `removeAttribute` |
| Dùng khi nào | Forward (trong server) | Redirect (sang URL mới) |

### Quy tắc

- **Forward (return "checkout"):** Dùng `model.addAttribute` — cùng request
- **Redirect (return "redirect:/path"):** Dùng `session.setAttribute` — khác request

---

## 6. SO SÁNH CÁC GIẢI PHÁP

### Bảng so sánh

| Giải pháp | Sửa DB? | Rủi ro bảo mật | Độ phức tạp | Khuyến nghị |
|------------|---------|-----------------|-------------|-------------|
| ALTER TABLE thêm cột | ✅ Cần | Thấp | Cao (migration) | Khi thực sự cần lưu |
| `@Transient` thuần | ❌ Không | Thấp | Thấp | Dữ liệu trong 1 request |
| `Session` + `@Transient` | ❌ Không | Trung bình* | Trung bình | ✅ **Tốt nhất khi không sửa DB** |

*Session lưu tạm trên server, an toàn hơn URL param.

### Các rủi ro khi dùng Session

**1. Multi-tab (nhiều tab cùng mua)**

```java
// ⚠️ Tab 1: mua game A → session.set("shippingInfo_A")
// ⚠️ Tab 2: mua game B → session.set("shippingInfo_B") ← GHI ĐÈ!

// Kết quả: Tab 1 sang success → thấy thông tin của Tab 2
```

**Cách xử lý:** Dùng request param thay vì session:

```java
// Tốt hơn: dùng query param cho multi-tab
return "redirect:/checkout/success?orderId=" + order.getId();
```

**2. Session bị clear khi logout**

```java
// User đặt hàng xong → Logout → Quay lại trang success
// → shippingInfo = null → trang trắng hoặc lỗi
```

**Cách xử lý:** Kiểm tra null:

```java
if (shippingInfo == null) {
    shippingInfo = new HashMap<>();
}
```

### Khi nào nên sửa DB thay vì dùng Session?

Dùng `@Transient` + `Session` là **giải pháp tạm**, phù hợp khi:
- Không muốn thay đổi schema
- Dữ liệu chỉ cần hiển thị 1 lần sau mua hàng
- Không có yêu cầu lưu trữ lâu dài

Nên sửa DB (ALTER TABLE) khi:
- Dữ liệu cần query lại sau này
- Cần admin xem lịch sử giao hàng
- Cần export báo cáo
- Cần tích hợp với API bên thứ 3 (shipping API...)

---

## TÓM TẮT

```
Vấn đề: Cần dùng 8 trường không có trong DB

Giải pháp: Kết hợp @Transient + Session

1. @Transient trên Order.java
   → Cho phép gọi setX() bình thường, không lỗi

2. Session lưu 8 trường trước redirect
   session.setAttribute("shippingInfo", map)

3. Trang success đọc từ session
   model.addAttribute("shippingInfo", session.getAttribute(...))

4. Dọn session sau khi dùng
   session.removeAttribute("shippingInfo")

→ DB không đụng gì, code hoạt động bình thường
```

---

*Guide được viết ngày 2026-05-28 bởi AI Coding Assistant*
