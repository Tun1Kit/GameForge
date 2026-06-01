# HƯỚNG DẪN SỬA LỖI CHECKOUT — GAMEFORGE

**Ngày:** 2026-05-28
**Project:** GameStore - Cửa hàng game trực tuyến
**Tech stack:** Spring MVC 5 + Hibernate 5 + SQL Server + Java 8
**Database:** GameStore (20 bảng)

---

## MỤC LỤC

1. [Tổng quan project](#1-tổng-quan-project)
2. [Tổng quan database](#2-tổng-quan-database)
3. [Cấu trúc code Java](#3-cấu-trúc-code-java)
4. [14 lỗi được phát hiện](#4-14-lỗi-được-phát-hiện)
5. [Cách sửa từng lỗi (giải thích chi tiết)](#5-cách-sửa-từng-lỗi-giải-thích-chi-tiết)
6. [Quy tắc quan trọng](#6-quy-tắc-quan-trọng)

---

## 1. TỔNG QUAN PROJECT

### Mục đích
Cho phép user mua game online với các bước:
1. Thêm game vào giỏ hàng
2. Xem giỏ hàng → sang trang checkout
3. Nhập thông tin giao hàng + chọn thanh toán
4. Xử lý thanh toán → gán license key → thêm vào thư viện
5. Hiển thị trang thành công với license key

### Các file chính liên quan

```
src/main/java/com/gamestore/
├── controller/
│   └── CheckoutController.java      ← XỬ LÝ CHÍNH
├── entity/
│   ├── User.java                   ← Người dùng
│   ├── Game.java                   ← Game
│   ├── CartItem.java               ← Item trong giỏ
│   ├── Order.java                  ← Đơn hàng
│   ├── OrderItem.java              ← Chi tiết đơn hàng
│   ├── LicenseKey.java             ← Key game (MỚI TẠO)
│   ├── LibraryItem.java            ← Game trong thư viện (MỚI TẠO)
│   ├── Wallet.java                 ← Ví điện tử (MỚI TẠO)
│   └── WalletTransaction.java      ← Lịch sử ví (MỚI TẠO)
└── dao/
    └── CartItemDAO.java

src/main/webapp/WEB-INF/views/
├── index.jsp                       ← Trang chính
├── checkout.jsp                     ← Trang checkout
└── order-success.jsp               ← Trang thành công (MỚI TẠO)
```

---

## 2. TỔNG QUAN DATABASE

### Schema liên quan đến checkout

```
users
├── id (PK, bigint)
├── email (NVARCHAR)
├── password (NVARCHAR)
├── fullName (NVARCHAR)
└── status (VARCHAR)

wallets                          ← MỚI cần entity
├── id (PK)
├── user_id (FK → users, UNIQUE)
└── balance (DECIMAL)

wallet_transactions              ← MỚI cần entity
├── id (PK)
├── wallet_id (FK → wallets)
├── type (VARCHAR: PURCHASE, REFUND...)
├── amount (DECIMAL)
├── status (VARCHAR: SUCCESS, FAILED...)
└── referenceId (NVARCHAR)

games
├── id (PK)
├── publisher_id (FK → publisher_profiles)
├── title (NVARCHAR)
├── price (DECIMAL)
└── status (VARCHAR)

license_keys                     ← MỚI cần entity
├── id (PK)
├── game_id (FK → games)
├── keyString (VARCHAR)
├── order_item_id (FK → order_items, nullable)
├── owner_id (FK → users, nullable)
├── status (VARCHAR: AVAILABLE, SOLD, REFUNDED...)
└── assignedAt (DATETIME)

orders
├── id (PK)
├── user_id (FK → users)
├── subtotalAmount (DECIMAL)
├── discountAmount (DECIMAL)
├── totalAmount (DECIMAL)
├── promo_code_id (FK → promo_codes, nullable)
├── status (VARCHAR: PENDING, PAID, REFUNDED...)
├── createdAt (DATETIME)
└── paidAt (DATETIME)

order_items
├── id (PK)
├── order_id (FK → orders)
├── game_id (FK → games)
├── unitPrice (DECIMAL)
├── discountAmount (DECIMAL)
├── paidAmount (DECIMAL)
├── quantity (INT)
└── status (VARCHAR: PAID, REFUND_REQUESTED...)

library_items                    ← MỚI cần entity
├── id (PK)
├── user_id (FK → users)
├── game_id (FK → games)
├── license_key_id (FK → license_keys, UNIQUE, NOT NULL)
├── status (VARCHAR: ACTIVE, DISABLED, REFUNDED)
└── acquiredAt (DATETIME)

cart_items
├── id (PK)
├── user_id (FK → users)
├── game_id (FK → games)
└── quantity (INT, DEFAULT 1)
```

### Quan hệ giữa các bảng (giải thích flow)

```
                    ┌─────────────────────────────────────────┐
                    │           USER mua 1 game               │
                    └──────────────┬──────────────────────────┘
                                   │
               ┌───────────────────┼───────────────────┐
               ▼                   ▼                   ▼
         cart_items ───→ orders ──→ order_items ──→ license_keys
         (giỏ hàng)      (đơn)      (chi tiết)        (key game)
                                   │
                                   └──────────────────→ library_items
                                                        (thư viện)
                                       │
                                       └─────────────────── wallets
                                                           (ví)
                                              wallet_transactions
                                              (lịch sử ví)
```

### Chi tiết flow thanh toán

```
1. User chọn game → thêm vào cart_items
2. User bấm "Thanh toán" → /checkout (GET)
   → Lấy cart_items của user
   → Tính subtotal, discount, total
   → Lấy số dư ví từ wallets
   → Hiển thị checkout.jsp

3. User điền form → /checkout/process (POST)
   ├─ Nếu thanh toán = WALLET
   │   ├─ Kiểm tra ví tồn tại?
   │   ├─ Kiểm tra số dư đủ không?
   │   └─ Trừ số dư + ghi wallet_transactions
   │
   ├─ Tạo Order (PAID)
   ├─ Với mỗi cart_item:
   │   ├─ Tạo OrderItem
   │   ├─ Tìm LicenseKey AVAILABLE cho game đó
   │   │   ├─ Đánh dấu key = SOLD
   │   │   ├─ Gán owner = currentUser
   │   │   ├─ Tạo LibraryItem để game xuất hiện trong thư viện
   │   │   └─ Ghi key +o session để hiển thị ở trang success
   │   │   (Nếu không có key → bỏ qua LibraryItem, ghi "[Đang chờ cấp phát]")
   │   └─ Xóa cart_item
   └─ Redirect → /checkout/success?orderId=X

4. /checkout/success (GET)
   → Đọc Order từ DB
   → Đọc keys + shippingInfo từ SESSION (vì DB không lưu)
   → Hiển thị order-success.jsp với license key
```

---

## 3. CẤU TRÚC CODE JAVA

### Entity là gì?

Entity = class Java ánh xạ 1-1 với 1 bảng trong DB.

```java
@Entity              // Đánh dấu class này là entity
@Table(name = "X")  // Ánh xạ với bảng X trong DB
public class EntityName {
    @Id                              // Đây là PRIMARY KEY
    @GeneratedValue(...)              // ID tự tăng (IDENTITY)
    private Long id;

    @Column(name = "column_name")    // Ánh xạ với cột trong bảng
    private String fieldName;

    @ManyToOne                       // Quan hệ N-1 (nhiều Order → 1 User)
    @JoinColumn(name = "user_id")    // Cột FK trong bảng
    private User user;

    @OneToMany(mappedBy = "order")   // Quan hệ 1-N (1 Order → nhiều OrderItem)
    private List<OrderItem> items;

    @Transient                       // KHÔNG lưu xuống DB (giải thích bên dưới)
    private String tempData;
}
```

### Các annotation quan trọng

| Annotation | Ý nghĩa |
|-------------|---------|
| `@Entity` | Đánh dấu class là entity JPA |
| `@Table(name = "X")` | Ánh xạ với bảng X |
| `@Id` | Đây là primary key |
| `@GeneratedValue(strategy = GenerationType.IDENTITY)` | ID tự tăng (SQL Server IDENTITY) |
| `@Column(name = "col")` | Ánh xạ với cột col |
| `@ManyToOne` | Quan hệ N-1 (Employee → Department) |
| `@OneToMany(mappedBy = "X")` | Quan hệ 1-N (Department → Employee) |
| `@OneToOne` | Quan hệ 1-1 (User → Wallet) |
| `@JoinColumn(name = "fk_col")` | Cột FK trong bảng con |
| `@Transient` | KHÔNG lưu xuống DB |
| `@PrePersist` | Chạy trước khi INSERT |
| `@Fetch(FetchType.LAZY)` | Load dữ liệu khi cần (mặc định) |
| `@Fetch(FetchType.EAGER)` | Load dữ liệu NGAY (cẩn thận, gây N+1) |

### FetchType.LAZY vs FetchType.EAGER

```java
// Mặc định là LAZY — Hibernate chỉ load khi gọi getX()
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "user_id")
private User user;

// Khi gọi cartItem.getUser() — Hibernate sẽ tự động:
// 1. Tạo câu SQL: SELECT * FROM users WHERE id = ?
// 2. Gán kết quả vào user
```

### Spring @Transactional

```java
@Controller
@Transactional    // Tất cả method trong class này đều tự động có transaction
public class CheckoutController {
    // Nếu có exception → tự động ROLLBACK
    // Nếu không exception → tự động COMMIT
    // Không cần viết begin/commit/rollback thủ công
}
```

---

## 4. 14 LỖI ĐƯỢC PHÁT HIỆN

### CRITICAL — Compile thất bại (4 lỗi)

Code gọi `new LicenseKey()`, `new Wallet()`... nhưng **class đó chưa được tạo**.

| # | Thiếu entity | Dùng để |
|---|-------------|---------|
| 1 | `LicenseKey.java` | Gán key cho user khi mua game |
| 2 | `LibraryItem.java` | Thêm game vào thư viện của user |
| 3 | `Wallet.java` | Lấy số dư và trừ tiền ví |
| 4 | `WalletTransaction.java` | Ghi lịch sử giao dịch ví |

### HIGH — Runtime lỗi logic (4 lỗi)

| # | Lỗi | Vấn đề |
|---|------|--------|
| 5 | `orderItem.getId()` = null | Hibernate IDENTITY chưa flush nên ID chưa có |
| 6 | Thiếu `order-success.jsp` | Spring không tìm thấy view |
| 7 | DB không có `paymentMethod` trong `orders` | Muốn lưu nhưng không có cột |
| 8 | `User.java` thiếu NVARCHAR | DB dùng NVARCHAR, code không chỉ định → tiếng Việt lỗi |

### MEDIUM — Logic thiếu (3 lỗi)

| # | Lỗi | Vấn đề |
|---|------|--------|
| 9 | Không trừ tiền ví | Nhận paymentMethod nhưng không xử lý |
| 10 | Không lưu thông tin giao hàng | fullName, phone, address... không đâu cả |
| 11 | Hết license key thì crash | DB constraint NOT NULL, không có key = lỗi |

### LOW — Risk nhỏ (3 lỗi)

| # | Lỗi | Vấn đề |
|---|------|--------|
| 12 | Redirect error param không xử lý | `?error=empty_cart` không hiển thị ở view |
| 13 | `removeCartItem` lazy-load | Có thể `LazyInitializationException` |
| 14 | Không validate số dư ví | User có thể mua dù số dư không đủ |

---

## 5. CÁCH SỬA TỪNG LỖI (GIẢI THÍCH CHI TIẾT)

---

### LỖI 1-4: TẠO 4 ENTITY MỚI

#### Tại sao cần entity?

Code cũ:
```java
// Code gọi nhưng class không tồn tại → COMPILE LỖI
LicenseKey key = new LicenseKey();  // ❌ Lỗi: class not found
LibraryItem item = new LibraryItem(); // ❌ Lỗi
Wallet wallet = new Wallet();         // ❌ Lỗi
WalletTransaction tx = new WalletTransaction(); // ❌ Lỗi
```

Khi code gọi đến 1 class, class đó PHẢI tồn tại. 4 entity này có trong DB nhưng chưa có trong Java.

#### Cách tạo đúng

Quy tắc: **Nhìn DB schema → tạo entity y hệt.**

```java
@Entity
@Table(name = "license_keys")           // Tên bảng trong DB
public class LicenseKey {

    @Id                                 // PRIMARY KEY
    @GeneratedValue(strategy = GenerationType.IDENTITY) // IDENTITY tự tăng
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // Quan hệ N-1 với Game
    @JoinColumn(name = "game_id", nullable = false) // FK column trong DB
    private Game game;

    // DB: keyString VARCHAR(255) NOT NULL
    @Column(name = "keyString", nullable = false)
    private String keyString;

    // DB: order_item_id BIGINT NULL → dùng Long (nullable)
    @Column(name = "order_item_id")
    private Long orderItemId;

    // DB: owner_id BIGINT NULL → dùng User entity
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner;

    // DB: status VARCHAR(50) NOT NULL DEFAULT 'AVAILABLE'
    @Column(nullable = false, length = 50)
    private String status = "AVAILABLE";

    // DB: createdAt DATETIME NOT NULL DEFAULT sysdatetime()
    @Column(name = "createdAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "assignedAt")
    private LocalDateTime assignedAt;

    @PrePersist                              // Tự động gọi TRƯỚC khi INSERT
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    // Getter/Setter cho tất cả field...
}
```

#### LibraryItem — điểm quan trọng

```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "license_key_id", unique = true) // UNIQUE constraint
private LicenseKey licenseKey;
```

DB có `UNIQUE` trên `license_key_id` nên annotation có `unique = true`. Điều này đảm bảo mỗi license key chỉ gán cho đúng 1 library item.

---

### LỖI 8: SỬA USER.JAVA — NVARCHAR

#### Vấn đề

SQL Server dùng `NVARCHAR` để lưu tiếng Việt có dấu. Hibernate/JPA mặc định map `String` sang `VARCHAR`, có thể gây lỗi encoding.

#### Cách sửa

```java
// TRƯỚC (có thể lỗi tiếng Việt):
@Column(nullable = false)
private String email;
@Column(nullable = false)
private String password;

// SAU (đúng):
@Column(nullable = false, columnDefinition = "NVARCHAR(255)")
private String email;
@Column(nullable = false, columnDefinition = "NVARCHAR(255)")
private String password;
@Column(columnDefinition = "NVARCHAR(255)")
private String fullName;
@Column(columnDefinition = "NVARCHAR(500)")
private String avatar;
```

`columnDefinition` ghi đè kiểu SQL. Hibernate sẽ tạo cột đúng kiểu NVARCHAR.

---

### LỖI 5: SỬA ORDERITEM.GETID() = NULL

#### Vấn đề

```java
hqSession.save(orderItem);              // INSERT vào DB, ID được sinh
hqSession.flush();                      // ← THIẾU DÒNG NÀY

assignedKey.setOrderItemId(orderItem.getId()); // ID vẫn null!
```

SQL Server IDENTITY generator sinh ID tại thời điểm INSERT thực sự. Hibernate batch các câu SQL lại → INSERT chưa chạy → ID chưa có.

#### Cách sửa

```java
hqSession.save(orderItem);   // Thêm vào persistence context
hqSession.flush();           // BẮT BUỘC: gửi SQL INSERT ngay lập tức
                               // → ID được gán vào object

assignedKey.setOrderItemId(orderItem.getId()); // ✅ ID đã có
```

`flush()` gửi tất cả câu SQL đang chờ trong batch xuống DB ngay lập tức, buộc IDENTITY sinh ID. Sau đó Hibernate tiếp tục batch các câu tiếp theo.

---

### LỖI 9-10: XỬ LÝ THANH TOÁN VÍ + THÔNG TIN GIAO HÀNG

#### Vấn đề thanh toán ví

Code nhận `paymentMethod` từ form nhưng không làm gì. User chọn "WALLET" nhưng tiền không bị trừ.

#### Cách sửa

```java
if ("WALLET".equals(paymentMethod)) {
    // 1. Lấy ví của user từ DB
    Wallet wallet = hqSession
        .createQuery("FROM Wallet WHERE user.id = :userId", Wallet.class)
        .setParameter("userId", currentUser.getId())
        .uniqueResult();

    // 2. Kiểm tra ví tồn tại
    if (wallet == null) {
        model.addAttribute("error", "Tài khoản ví không tồn tại.");
        return "checkout"; // Quay về trang checkout, hiển thị lỗi
    }

    // 3. Kiểm tra số dư đủ không
    if (wallet.getBalance().compareTo(total) < 0) {
        model.addAttribute("error", "Số dư ví không đủ.");
        return "checkout";
    }

    // 4. Trừ số dư
    wallet.setBalance(wallet.getBalance().subtract(total));
    hqSession.update(wallet);

    // 5. Ghi lịch sử giao dịch
    WalletTransaction tx = new WalletTransaction();
    tx.setWallet(wallet);
    tx.setType("PURCHASE");
    tx.setAmount(total);
    tx.setStatus("SUCCESS");
    tx.setReferenceId("ORDER_" + System.currentTimeMillis());
    hqSession.save(tx);
}
```

#### Cách so sánh BigDecimal đúng

```java
// SAI: dùng ==, !=, >
if (wallet.getBalance() < total) { }

// ĐÚNG: dùng compareTo
if (wallet.getBalance().compareTo(total) < 0) { }
  // < 0  : balance nhỏ hơn total
  // == 0 : balance bằng total
  // > 0  : balance lớn hơn total
```

BigDecimal là object, không dùng toán tử `==` được. Phải dùng `compareTo()`.

---

### LỖI 7: LƯU 8 TRƯỜNG GIAO HÀNG — @TRANSIENT

#### Vấn đề

Muốn lưu `paymentMethod, fullName, phone, address...` vào `Order` nhưng DB **không có** các cột này. Tuy nhiên, user YÊU CẦU tuyệt đối không sửa database.

#### Giải pháp: @Transient + Session

```java
@Entity
@Table(name = "orders")
public class Order {
    // Những trường DB có thật
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;

    // Những trường KHÔNG có trong DB → dùng @Transient
    @Transient
    private String paymentMethod; // Bỏ qua khi INSERT/UPDATE

    @Transient
    private String fullName;

    @Transient
    private String phone;
    // ... 5 trường nữa
}
```

#### @Transient là gì?

```java
@Transient
private String tempData;
```

Annotation này bảo Hibernate **hoàn toàn bỏ qua** field này khi:
- INSERT vào DB
- UPDATE xuống DB
- SELECT từ DB

Field chỉ tồn tại trong object Java, không đụng gì đến database.

#### Vấn đề: SELECT từ DB thì @Transient = null

```java
@GetMapping("/checkout/success")
public String orderSuccess(@RequestParam Long orderId, ...) {
    // Order từ DB → 8 trường @Transient đều = null!
    Order order = hqSession.get(Order.class, orderId);
    order.getFullName(); // null! Lấy từ đâu?
}
```

#### Giải pháp: Dùng HttpSession

```java
@PostMapping("/checkout/process")
public String processCheckout(..., HttpSession session) {
    // Lưu vào SESSION trước khi redirect
    Map<String, String> shippingInfo = new HashMap<>();
    shippingInfo.put("fullName", fullName);
    shippingInfo.put("phone", phone);
    // ...
    session.setAttribute("shippingInfo", shippingInfo);
    session.setAttribute("assignedKeys", assignedKeys);

    return "redirect:/checkout/success?orderId=" + order.getId();
}

@GetMapping("/checkout/success")
public String orderSuccess(@RequestParam Long orderId, ..., HttpSession session) {
    Order order = hqSession.get(Order.class, orderId);

    // Đọc từ SESSION (đã lưu ở bước trên)
    @SuppressWarnings("unchecked")
    Map<String, String> shippingInfo = (Map<String, String>) session.getAttribute("shippingInfo");

    model.addAttribute("order", order);
    model.addAttribute("shippingInfo", shippingInfo);

    // Dọn session sau khi dùng
    session.removeAttribute("shippingInfo");
    session.removeAttribute("assignedKeys");

    return "order-success";
}
```

#### Tại sao dùng session mà không dùng request scope?

Vì `redirect` = HTTP redirect (status 302). Browser gửi request MỚI đến `/checkout/success`. Request cũ bị mất → dữ liệu mất theo.

| Cách lưu | Phạm vi | Redirect mất? |
|-----------|---------|---------------|
| `model.addAttribute` | Request | ✅ Mất |
| `HttpSession.setAttribute` | Session | ❌ Còn |
| `@SessionAttributes` | Session | ❌ Còn |

---

### LỖI 11: XỬ LÝ HẾT LICENSE KEY

#### Vấn đề

```sql
[license_key_id] [bigint] NOT NULL   -- DB bắt buộc có key!
```

Khi game không có license key AVAILABLE, mà cố tạo `LibraryItem` không có key → **constraint violation**.

#### Cách sửa

```java
List<LicenseKey> keys = hqSession.createQuery(keyHql, LicenseKey.class)
    .setParameter("gameId", item.getGame().getId())
    .setMaxResults(1)
    .getResultList();

LicenseKey assignedKey = (!keys.isEmpty()) ? keys.get(0) : null;

if (assignedKey != null) {
    // Có key → gán bình thường
    assignedKey.setStatus("SOLD");
    assignedKey.setOwner(currentUser);
    hqSession.update(assignedKey);

    LibraryItem libItem = new LibraryItem();
    libItem.setUser(currentUser);
    libItem.setGame(item.getGame());
    libItem.setLicenseKey(assignedKey);  // ← NOT NULL nên phải có
    libItem.setStatus("ACTIVE");
    hqSession.save(libItem);
}
// Không có key → KHÔNG tạo LibraryItem (tránh lỗi constraint)
```

#### Và ghi log để hiển thị ở trang success

```java
Map<String, Object> keyInfo = new HashMap<>();
keyInfo.put("gameTitle", item.getGame().getTitle());
keyInfo.put("keyString", (assignedKey != null)
    ? assignedKey.getKeyString()
    : "[Đang chờ cấp phát]");
keyInfo.put("hasKey", assignedKey != null);
assignedKeys.add(keyInfo);
```

---

### LỖI 12: XỬ LÝ ERROR PARAM TRONG JSP

#### Vấn đề

Controller redirect với param:
```java
return "redirect:/?error=empty_cart";
```

Nhưng `index.jsp` không xử lý param này → user không thấy thông báo lỗi.

#### Cách sửa

```jsp
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<body>
  <%-- Đặt ngay sau <body> để hiển thị ở đầu trang --%>
  <c:if test="${not empty param.error}">
    <div class="alert alert-danger d-flex align-items-center gap-2 fw-bold">
      <i data-lucide="alert-circle" width="18" height="18"></i>
      <c:choose>
        <c:when test="${param.error == 'empty_cart'}">Giỏ hàng trống!</c:when>
        <c:when test="${param.error == 'invalid_order'}">Đơn hàng không hợp lệ.</c:when>
        <c:otherwise>Đã xảy ra lỗi.</c:otherwise>
      </c:choose>
    </div>
  </c:if>
```

`${param.error}` đọc query param `error` từ URL.

---

### LỖI 13: SỬA API REMOVECARTITEM

#### Vấn đề

```java
// CÓ THỂ lỗi LazyInitializationException
if (!currentUser.getId().equals(item.getUser().getId())) {
//                                   ↑ Hibernate cần session để load User
```

`item.getUser()` là LAZY load. Nếu gọi ở method không có `@Transactional`, hoặc sau khi session đóng, sẽ lỗi.

#### Cách sửa

```java
@PostMapping("/api/cart/remove")
@ResponseBody
public ResponseEntity<?> removeCartItem(@RequestParam Long itemId, HttpSession session) {
    CartItem item = sessionFactory.getCurrentSession().get(CartItem.class, itemId);

    // So sánh ID trực tiếp thay vì gọi getUser().getId()
    if (!currentUser.getId().equals(item.getUser().getId())) {
        response.put("success", false);
        response.put("message", "Bạn không có quyền xóa.");
        return ResponseEntity.status(403).body(response);
    }

    sessionFactory.getCurrentSession().delete(item);
}
```

#### Cách tốt hơn: Dùng native query

```java
// Lấy user_id trực tiếp từ DB, không cần load User entity
CartItem item = session.createQuery(
    "SELECT c FROM CartItem c WHERE c.id = :id AND c.user.id = :userId",
    CartItem.class)
    .setParameter("id", itemId)
    .setParameter("userId", currentUser.getId())
    .uniqueResult();

if (item == null) {
    // Không tìm thấy HOẶC không thuộc user → coi như không có quyền
    response.put("success", false);
    return ResponseEntity.status(404).body(response);
}
```

---

## 6. QUY TẮC QUAN TRỌNG

### Quy tắc 1: Luôn flush() sau save() nếu cần dùng ID ngay

```java
hqSession.save(orderItem);
hqSession.flush();  // Bắt buộc nếu cần orderItem.getId()
```

### Quy tắc 2: Dùng @Transient cho dữ liệu không cần lưu DB

```java
@Transient
private String temporaryField;  // Chỉ tồn tại trong Java object
```

### Quy tắc 3: Dùng Session để truyền dữ liệu qua redirect

```java
// Trước redirect
session.setAttribute("key", value);

// Sau redirect (request mới)
Object value = session.getAttribute("key");
session.removeAttribute("key");  // Dọn khi xong
```

### Quy tắc 4: So sánh BigDecimal phải dùng compareTo()

```java
// Sai
if (wallet.getBalance() < total) { }

// Đúng
if (wallet.getBalance().compareTo(total) < 0) { }
```

### Quy tắc 5: Kiểm tra null trước khi so sánh

```java
// Sai: NullPointerException nếu wallet = null
if (wallet.getBalance().compareTo(total) < 0) { }

// Đúng
if (wallet == null) { /* xử lý lỗi */ }
if (wallet.getBalance().compareTo(total) < 0) { }
```

### Quy tắc 6: LAZY fetch cần session để truy cập

```java
// Trong method có @Transactional → session còn mở → OK
item.getUser().getId();

// Ngoài @Transactional → session đã đóng → LazyInitializationException
```

### Quy tắc 7: Mỗi class entity = 1 bảng trong DB

Nhìn DB schema → đoán ra entity. Tra cứu annotation tương ứng:

| DB | Java |
|----|------|
| BIGINT, IDENTITY | `Long id` + `@GeneratedValue` |
| NVARCHAR(255) | `@Column(columnDefinition = "NVARCHAR(255)")` |
| DECIMAL(15,2) | `BigDecimal` |
| VARCHAR(50) | `@Column(length = 50)` |
| FK NOT NULL | `@ManyToOne` + `@JoinColumn(nullable = false)` |
| FK NULL | `@ManyToOne` (nullable mặc định) |
| UNIQUE | `@JoinColumn(unique = true)` |

---

## TÓM TẮT CÁC FILE ĐÃ TẠO/SỬA

| File | Hành động | Giải thích |
|------|-----------|------------|
| `LicenseKey.java` | TẠO MỚI | Entity cho bảng license_keys |
| `LibraryItem.java` | TẠO MỚI | Entity cho bảng library_items |
| `Wallet.java` | TẠO MỚI | Entity cho bảng wallets |
| `WalletTransaction.java` | TẠO MỚI | Entity cho bảng wallet_transactions |
| `User.java` | SỬA | Thêm columnDefinition NVARCHAR |
| `Order.java` | SỬA | Thêm @Transient cho 8 trường giao hàng |
| `CheckoutController.java` | SỬA TOÀN BỘ | flush, ví, giao hàng, key, session |
| `order-success.jsp` | TẠO MỚI | Trang xác nhận thành công |
| `index.jsp` | SỬA | Thêm xử lý error param |
| `checkout-controller-fix-plan-v2.md` | TẠO | Kế hoạch chi tiết |
| `checkout-errors-summary-v2.md` | TẠO | Bảng tóm tắt 14 lỗi |
| `GUIDE.md` | TẠO | File hướng dẫn này |

---

*Guide được viết ngày 2026-05-28 bởi AI Coding Assistant*
