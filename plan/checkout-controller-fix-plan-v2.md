# KẾ HOẠCH SỬA LỖI — CheckoutController.java

**Ngày:** 2026-05-28
**File:** `src/main/java/com/gamestore/controller/CheckoutController.java`
**DB:** SQL Server — Database `GameStore`, Schema chuẩn từ `GGGG.sql`
**Tech stack:** Spring MVC 5.3.20 + Hibernate 5.6.9 + SQL Server + Java 8

---

## SƠ ĐỒ DATABASE (PHẦN LIÊN QUAN)

```
users (id, email NVARCHAR, password NVARCHAR, fullName, avatar, status)
  └── wallets (id, user_id FK, balance)
        └── wallet_transactions (id, wallet_id FK, type, amount, status, referenceId)

games (id, publisher_id, title, price, status, ...)
  └── license_keys (id, game_id FK, keyString, order_item_id FK nullable, owner_id FK nullable, status)
  └── game_media (id, game_id FK, mediaType, mediaUrl, isPrimary)

orders (id, user_id FK, subtotalAmount, discountAmount, totalAmount, promo_code_id, status, createdAt, paidAt)
  └── order_items (id, order_id FK, game_id FK, unitPrice, discountAmount, paidAmount, quantity, status)
        └── license_keys.order_item_id FK (nullable) ← MỐI QUAN HỆ NGƯỢC

library_items (id, user_id FK, game_id FK, license_key_id FK UNIQUE, status, acquiredAt)
  └── license_keys.id FK (UNIQUE — mỗi key gán cho đúng 1 library_item)

cart_items (id, user_id FK, game_id FK, quantity, addedAt)
```

---

## TỔNG HỢP LỖI — 14 LỖI

### CỘT 1: CRITICAL — Compile thất bại

| # | Tên | Vị trí | Mô tả |
|---|-----|--------|-------|
| C-1 | Thiếu entity `LicenseKey` | Dong 144-157 | Class `LicenseKey` không tồn tại trong `com.gamestore.entity` |
| C-2 | Thiếu entity `LibraryItem` | Dong 160-168 | Class `LibraryItem` không tồn tại trong `com.gamestore.entity` |
| C-3 | Thiếu entity `Wallet` | Dong 57-66 | Class `Wallet` không tồn tại — dùng để trừ số dư khi thanh toán |
| C-4 | Thiếu entity `WalletTransaction` | (cần cho C-3) | Ghi lịch sử giao dịch ví |

### CỘT 2: HIGH — Runtime lỗi logic

| # | Tên | Vị trí | Mô tả |
|---|-----|--------|-------|
| H-1 | `orderItem.getId()` = null | Dong 155 | Hibernate IDENTITY strategy chưa flush session nên ID chưa có |
| H-2 | Thiếu view `order-success.jsp` | Dong 205 | Spring không tìm thấy view |
| H-3 | Sai tên cột `owner_id` | Dong 154 | DB dùng `owner_id`, code dùng `setOwner(currentUser)` nhưng thiếu entity |
| H-4 | Entity `User` map sai kiểu | `User.java` | DB: `email/password` là `NVARCHAR` nhưng annotation không chỉ định |

### CỘT 3: MEDIUM — Logic thiếu

| # | Tên | Vị trí | Mô tả |
|---|-----|--------|-------|
| M-1 | Không trừ tiền ví | Dong 80-175 | Nhận `paymentMethod` nhưng không xử lý trừ số dư Wallet |
| M-2 | Không lưu thông tin giao hàng | Dong 119-128 | Các trường `fullName, phone, address, province, district, ward` không được set vào Order |
| M-3 | Không xử lý hết key | Dong 150-169 | Khi game không có `LicenseKey` AVAILABLE, không có key cho user |

### CỘT 4: LOW — Risk nhỏ

| # | Tên | Vị trí | Mô tả |
|---|-----|--------|-------|
| L-1 | Redirect error không xử lý | Dong 107, 192 | `?error=empty_cart` / `?error=invalid_order` không hiển thị ở view |
| L-2 | API removeCartItem lazy-load | Dong 223-226 | Có thể `LazyInitializationException` nếu `item.getUser()` trigger ngoài session |
| L-3 | Không validate wallet trước | Dong 56-72, 80-175 | Hiển thị số dư ví nhưng không kiểm tra đủ không đủ trước khi xử lý |

---

## CHI TIẾT TỪNG LỖI VÀ HƯỚNG XỬ LÝ

---

### C-1 & C-2: TẠO ENTITY `LicenseKey` VÀ `LibraryItem`

#### A. `LicenseKey.java`

**Đường dẫn:** `src/main/java/com/gamestore/entity/LicenseKey.java`

**Schema DB:**
```sql
license_keys: id(bigint), game_id(bigint FK), keyString(varchar), order_item_id(bigint FK nullable),
              owner_id(bigint FK nullable), status(varchar: AVAILABLE|SOLD|RESERVED|DISABLED|REFUNDED),
              createdAt(datetime2), assignedAt(datetime2 nullable)
```

**Entity:**
```java
package com.gamestore.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "license_keys")
public class LicenseKey {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "game_id", nullable = false)
    private Game game;

    @Column(name = "keyString", nullable = false)
    private String keyString;

    @Column(name = "order_item_id")
    private Long orderItemId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private User owner;

    @Column(nullable = false, length = 50)
    private String status = "AVAILABLE";

    @Column(name = "createdAt", nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime assignedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Game getGame() { return game; }
    public void setGame(Game game) { this.game = game; }
    public String getKeyString() { return keyString; }
    public void setKeyString(String keyString) { this.keyString = keyString; }
    public Long getOrderItemId() { return orderItemId; }
    public void setOrderItemId(Long orderItemId) { this.orderItemId = orderItemId; }
    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getAssignedAt() { return assignedAt; }
    public void setAssignedAt(LocalDateTime assignedAt) { this.assignedAt = assignedAt; }
}
```

#### B. `LibraryItem.java`

**Đường dẫn:** `src/main/java/com/gamestore/entity/LibraryItem.java`

**Schema DB:**
```sql
library_items: id(bigint), user_id(bigint FK), game_id(bigint FK),
               license_key_id(bigint FK UNIQUE), status(varchar: ACTIVE|DISABLED|REFUNDED), acquiredAt(datetime2)
```

**Entity:**
```java
package com.gamestore.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "library_items")
public class LibraryItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "game_id", nullable = false)
    private Game game;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "license_key_id", unique = true)
    private LicenseKey licenseKey;

    @Column(nullable = false, length = 50)
    private String status = "ACTIVE";

    @Column(name = "acquiredAt", nullable = false)
    private LocalDateTime acquiredAt;

    @PrePersist
    public void prePersist() {
        if (acquiredAt == null) acquiredAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public Game getGame() { return game; }
    public void setGame(Game game) { this.game = game; }
    public LicenseKey getLicenseKey() { return licenseKey; }
    public void setLicenseKey(LicenseKey licenseKey) { this.licenseKey = licenseKey; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getAcquiredAt() { return acquiredAt; }
    public void setAcquiredAt(LocalDateTime acquiredAt) { this.acquiredAt = acquiredAt; }
}
```

---

### C-3 & C-4: TẠO ENTITY `Wallet` VÀ `WalletTransaction`

#### C. `Wallet.java`

**Đường dẫn:** `src/main/java/com/gamestore/entity/Wallet.java`

**Schema DB:**
```sql
wallets: id(bigint), user_id(bigint FK UNIQUE), balance(decimal(15,2))
wallet_transactions: id(bigint), wallet_id(bigint FK), type(varchar), amount(decimal(15,2)),
                    status(varchar), referenceId(nvarchar), createdAt(datetime2)
```

```java
package com.gamestore.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallets")
public class Wallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal balance = BigDecimal.ZERO;

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public BigDecimal getBalance() { return balance; }
    public void setBalance(BigDecimal balance) { this.balance = balance; }
}
```

#### D. `WalletTransaction.java`

**Đường dẫn:** `src/main/java/com/gamestore/entity/WalletTransaction.java`

```java
package com.gamestore.entity;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "wallet_transactions")
public class WalletTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @Column(nullable = false, length = 50)
    private String type; // PURCHASE, REFUND, DEPOSIT, WITHDRAW, ADJUSTMENT, PAYOUT

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false, length = 50)
    private String status; // SUCCESS, PENDING, FAILED, CANCELLED

    @Column(name = "referenceId")
    private String referenceId;

    @Column(name = "createdAt", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Wallet getWallet() { return wallet; }
    public void setWallet(Wallet wallet) { this.wallet = wallet; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
```

---

### H-1: SỬA `orderItem.getId()` = null

**Vấn đề:** Hibernate dùng `IDENTITY` generator không tự động gán ID vào object sau khi `save()` nếu session chưa flush. Khi gọi `assignedKey.setOrderItemId(orderItem.getId())`, ID có thể là null.

**Sửa:** Thêm `hqSession.flush()` ngay sau khi save `OrderItem`.

```java
hqSession.save(orderItem);
hqSession.flush(); // Force INSERT -> ID được gán ngay
```

**Vị trí sửa:** Trong method `processCheckout`, sau dòng `hqSession.save(orderItem);` (khoảng dòng 141).

---

### H-2: TẠO VIEW `order-success.jsp`

**Đường dẫn:** `src/main/webapp/WEB-INF/views/order-success.jsp`

View cần hiển thị:
- Mã đơn hàng: `order.orderCode` (= "ORD" + id)
- Tổng tiền: `order.totalAmount`
- Ngày mua: `order.paidAt`
- Danh sách license key đã gán (từ query ở dòng 196-200 trong controller)
- Nút quay về trang chủ
- Nút xem thư viện game

---

### H-4: SỬA `User.java` — Chỉ định kiểu NVARCHAR

**Vấn đề:** DB SQL Server dùng `NVARCHAR` cho `email` và `password`, nhưng JPA annotation mặc định map sang `VARCHAR`. Tiếng Việt có dấu (như tên người dùng) có thể bị lỗi encoding.

**Sửa:** Thêm `@Column(columnDefinition = "NVARCHAR(255)")` cho các trường text.

```java
@Column(nullable = false, columnDefinition = "NVARCHAR(255)")
private String email;

@Column(nullable = false, columnDefinition = "NVARCHAR(255)")
private String password;

@Column(columnDefinition = "NVARCHAR(255)")
private String fullName;

@Column(columnDefinition = "NVARCHAR(500)")
private String avatar;
```

**Đồng thời thêm** `import java.sql.Timestamp` (hoặc `java.time.LocalDateTime`) và import JPA `Column` đầy đủ nếu thiếu.

---

### M-1: XỬ LÝ TRỪ TIỀN VÍ KHI `paymentMethod = "WALLET"`

**Vấn đề:** Controller nhận `paymentMethod` nhưng không làm gì với ví. User có thể thanh toán dù số dư không đủ.

**Thêm logic sau khi lấy cartItems:**

```java
// 2b. Kiểm tra và trừ ví nếu thanh toán bằng WALLET
if ("WALLET".equals(paymentMethod)) {
    // Lấy ví của user
    Wallet wallet = hqSession.createQuery(
            "FROM Wallet WHERE user.id = :userId", Wallet.class)
            .setParameter("userId", currentUser.getId())
            .uniqueResult();

    if (wallet == null) {
        model.addAttribute("error", "Tài khoản ví không tồn tại.");
        return "checkout";
    }

    if (wallet.getBalance().compareTo(total) < 0) {
        model.addAttribute("error", "Số dư ví không đủ. Vui lòng nạp thêm tiền.");
        return "checkout";
    }

    // Trừ số dư
    wallet.setBalance(wallet.getBalance().subtract(total));
    hqSession.update(wallet);

    // Ghi lịch sử giao dịch
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

### M-2: LƯU THÔNG TIN GIAO HÀNG VÀO ORDER

**Vấn đề:** Entity `Order` thiếu các trường: `fullName, phone, address, province, district, ward, notes, paymentMethod`.

**Cách 1 (Khuyên dùng):** Thêm các trường này vào `Order.java` và map với DB bằng ALTER TABLE.

**Cách 2 (Đơn giản):** Hiện tại `Order` có `promoCodeId` là trường nullable duy nhất. Có thể lưu thông tin giao hàng vào `promoCodeId`? — **KHÔNG NÊN**, vì gây confusion.

**Hướng xử lý:** Thêm các cột mới vào bảng `orders`:
```sql
ALTER TABLE orders ADD fullName NVARCHAR(255);
ALTER TABLE orders ADD phone VARCHAR(20);
ALTER TABLE orders ADD address NVARCHAR(500);
ALTER TABLE orders ADD province NVARCHAR(100);
ALTER TABLE orders ADD district NVARCHAR(100);
ALTER TABLE orders ADD ward NVARCHAR(100);
ALTER TABLE orders ADD notes NVARCHAR(MAX);
ALTER TABLE orders ADD paymentMethod VARCHAR(50);
```

Sau đó cập nhật `Order.java` entity và set trong `processCheckout`.

---

### M-3: XỬ LÝ KHI GAME KHÔNG CÓ LICENSE KEY

**Vấn đề:** Nếu `keys.isEmpty()`, không có key được gán, không có `LibraryItem`, user mất tiền nhưng không nhận game.

**Sửa:**
```java
if (keys.isEmpty()) {
    // Log cảnh báo hoặc tạo key tự động (mock)
    // Trong thực tế có thể rollback transaction
    System.out.println("WARNING: Game " + item.getGame().getTitle() + " khong co license key!");
    // Tiếp tục xóa cart item nhưng skip gán key
} else {
    // Logic gán key hiện tại
}
```

---

### L-1: XỬ LÝ PARAM `error` TRONG `index.jsp`

Thêm đoạn code xử lý error param vào đầu `index.jsp`:
```jsp
<c:if test="${not empty param.error}">
    <div class="alert alert-danger">
        <c:choose>
            <c:when test="${param.error == 'empty_cart'}">Giỏ hàng trống!</c:when>
            <c:when test="${param.error == 'invalid_order'}">Đơn hàng không hợp lệ.</c:when>
            <c:otherwise>Đã xảy ra lỗi.</c:otherwise>
        </c:choose>
    </div>
</c:if>
```

---

### L-2: SỬA API `removeCartItem`

```java
CartItem item = sessionFactory.getCurrentSession().get(CartItem.class, itemId);
if (item == null) {
    response.put("success", false);
    response.put("message", "Sản phẩm không tồn tại.");
    return ResponseEntity.status(404).body(response);
}
if (!currentUser.getId().equals(item.getUser().getId())) {
    response.put("success", false);
    response.put("message", "Bạn không có quyền xóa sản phẩm này.");
    return ResponseEntity.status(403).body(response);
}
sessionFactory.getCurrentSession().delete(item);
```

---

## THỨ TỰ ƯU TIÊN THỰC HIỆN

| Thứ tự | Lỗi | Tên | Ghi chú |
|--------|------|-----|---------|
| 1 | C-1 | Tạo `LicenseKey.java` | Cần cho C-2 |
| 2 | C-2 | Tạo `LibraryItem.java` | Cần import LicenseKey |
| 3 | C-3 | Tạo `Wallet.java` | Cần cho C-4, M-1 |
| 4 | C-4 | Tạo `WalletTransaction.java` | Cần cho M-1 |
| 5 | H-4 | Sửa `User.java` NVARCHAR | Thêm columnDefinition |
| 6 | H-1 | Thêm `flush()` sau save OrderItem | 1 dòng, rất nhỏ |
| 7 | H-2 | Tạo `order-success.jsp` | View mới |
| 8 | M-1 | Xử lý trừ ví trong `processCheckout` | Quan trọng |
| 9 | M-2 | Thêm cột giao hàng vào `orders` | Cần ALTER TABLE |
| 10 | M-3 | Xử lý hết license key | Có thể skip nếu luôn có key |
| 11 | L-1 | Xử lý error param trong `index.jsp` | Nhỏ |
| 12 | L-2 | Sửa `removeCartItem` API | Nhỏ |

---

## CÁC BƯỚC CẦN THỰC HIỆN TRONG DATABASE (ALTER TABLE)

```sql
-- Thêm cột giao hàng cho bảng orders
ALTER TABLE [GameStore].[dbo].[orders]
  ADD fullName NVARCHAR(255),
      phone VARCHAR(20),
      address NVARCHAR(500),
      province NVARCHAR(100),
      district NVARCHAR(100),
      ward NVARCHAR(100),
      notes NVARCHAR(MAX),
      paymentMethod VARCHAR(50);
GO
```

---

## GHI CHÚ QUAN TRỌNG

- **IDENTITY generator:** SQL Server IDENTITY sinh ID tại thời điểm INSERT thực sự. Trong cùng transaction, `getId()` có thể null. Luôn `flush()` sau khi save nếu cần dùng ID ngay.
- **Foreign key constraint:** `library_items.license_key_id` có UNIQUE constraint — mỗi key chỉ gán cho đúng 1 library_item. Đảm bảo không gán trùng.
- **Wallet:** Bảng `wallets` có UNIQUE trên `user_id` — mỗi user chỉ có 1 ví.
- **NVARCHAR:** SQL Server dùng NVARCHAR cho tiếng Việt. JPA/Hibernate mặc định dùng VARCHAR. Cần chỉ định rõ `columnDefinition = "NVARCHAR(...)"` để tránh lỗi encoding.
- **Transaction:** Class có `@Transactional`, nên rollback tự động nếu có exception. Không cần commit thủ công.
