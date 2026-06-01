# Kế Hoạch Phase 2 — KHÔNG THAY ĐỔI DATABASE

**Ngày:** 28/05/2026
**Ràng buộc:** Không sửa database, không thêm cột/bảng
**Nguyên tắc:** Dùng tạm thời những gì đã có, khi cần mới thêm

---

## Giới hạn không đổi database

| Feature | Không thể làm | Giải pháp tạm |
|---------|--------------|----------------|
| Profile (hồ sơ) | Thêm trường phone, address, gender | Chỉ hiển thị/đọc trường đã có |
| Nạp tiền | Tạo wallet record mới | Tạm thời **bỏ qua** — cần DB |
| Bug fix LicenseKey.status | Update license_key.status='SOLD' | **Bỏ qua** — cần DB update |

---

## Feature 1: Cập nhật header/user dropdown

**Mục tiêu:** Theo giao diện `dadangnhap.png`

### 1.1 Cần làm

Chỉ sửa JSP + JS, không đụng database.

**File:** `src/main/webapp/WEB-INF/views/index.jsp` — cập nhật phần dropdown

```
👤 Hồ sơ cá nhân      → link /profile (tạo trang đơn giản, chỉ đọc)
📦 Thư viện game      → link /library (tạo mới)
💰 Số dư: XXX,XXX₫    → đọc từ wallets table (đã có)
   [Nạp tiền]          → link /recharge (tạo trang, bỏ qua nếu chưa có wallet)
─────────────────────
❌ Đăng xuất
```

### 1.2 Đọc wallet balance

Dùng query có sẵn trong CheckoutController — tách ra service nhỏ hoặc dùng trực tiếp:

```java
// Trong mỗi controller cần hiển thị balance
BigDecimal walletBalance = BigDecimal.ZERO;
try {
    Object result = sessionFactory.getCurrentSession()
        .createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
        .setParameter("uid", currentUser.getId())
        .uniqueResult();
    if (result != null) {
        walletBalance = new BigDecimal(result.toString());
    }
} catch (Exception e) {
    // User chưa có wallet — hiển thị 0
}
model.addAttribute("walletBalance", walletBalance);
```

### 1.3 Thứ tự thực hiện

| Bước | File | Thay đổi |
|------|------|-----------|
| 1 | `HomeController.java` | Thêm walletBalance vào model |
| 2 | `index.jsp` | Cập nhật dropdown theo thiết kế |
| 3 | `GameDetailController.java` | Thêm walletBalance vào model |

---

## Feature 2: Trang Library (thư viện game)

**Mục tiêu:** User xem game đã sở hữu + xem license key

### 2.1 Database đã có sẵn

```sql
-- Bảng library_items đã tồn tại với các trường:
-- id, user_id, game_id, license_key_id, status, acquiredAt

-- Bảng license_keys đã tồn tại:
-- id, game_id, keyString, order_item_id, owner_id, status, createdAt, assignedAt

-- Bảng games đã tồn tại:
-- id, title, description, price, status, ...

-- Bảng game_media đã tồn tại:
-- id, game_id, mediaType, mediaUrl, isPrimary
```

→ Chỉ cần đọc, không cần thêm gì.

### 2.2 Tạo LibraryController

```java
@Controller
@RequestMapping("/library")
public class LibraryController {

    @GetMapping
    public String showLibrary(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        String hql = "SELECT li FROM LibraryItem li " +
            "JOIN FETCH li.game g " +
            "LEFT JOIN FETCH li.licenseKey " +
            "WHERE li.user.id = :uid AND li.status = 'ACTIVE' " +
            "ORDER BY li.acquiredAt DESC";

        List<LibraryItem> items = sessionFactory.getCurrentSession()
            .createQuery(hql, LibraryItem.class)
            .setParameter("uid", currentUser.getId())
            .getResultList();

        model.addAttribute("libraryItems", items);
        return "library";
    }
}
```

### 2.3 Tạo library.jsp

Giao diện grid 3 cột:
- Cover image (từ `game.mediaList[0].mediaUrl`)
- Title + category badges
- License key (blur ban đầu, click "Xem key" để hiện)
- Ngày mua
- Nút "Tải game" (popup thông tin)
- Nút "Yêu cầu hoàn tiền"

### 2.4 Tạo library.js

- Toggle hiện/ẩn key (blur CSS)
- Nút tải game → popup
- Nút hoàn tiền → gọi API

---

## Feature 3: Gửi mail hóa đơn

**Mục tiêu:** Sau thanh toán, gửi email với thông tin đơn hàng + license keys

### 3.1 Database đã có

- `orders` — có email của user từ `orders.user_id → users.email`
- `order_items` — có game name, giá
- `license_keys` — có keyString đã assign

### 3.2 Tạo EmailService

```java
@Service
public class EmailService {

    @Autowired private JavaMailSender mailSender;

    public void sendOrderConfirmation(User user, Order order) {
        String html = buildOrderEmailHTML(user, order);
        SimpleMailMessage msg = new SimpleMailMessage();
        msg.setTo(user.getEmail());
        msg.setSubject("GameStore - Xác nhận đơn hàng #" + order.getId());
        msg.setText(html);
        msg.setFrom("noreply@gamestore.com");
        mailSender.send(msg);
    }

    private String buildOrderEmailHTML(User user, Order order) {
        // Build HTML với:
        // - Header GameStore
        // - Thông tin khách hàng
        // - Bảng sản phẩm + key
        // - Tổng tiền
    }
}
```

### 3.3 Cấu hình mail tạm

```properties
# Trong application.properties
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# Hoặc mock mode (log ra console thay vì gửi)
email.enabled=true
```

Thêm config flag để có thể bật/tắt:
```java
@Value("${email.enabled:true}")
private boolean emailEnabled;

public void sendOrderConfirmation(...) {
    if (!emailEnabled) {
        logger.info("=== EMAIL MOCK ===");
        logger.info("To: " + user.getEmail());
        logger.info("Subject: Xác nhận đơn hàng #" + order.getId());
        logger.info(html);
        return;
    }
    mailSender.send(msg);
}
```

### 3.4 Gắn vào CheckoutController

```java
// Trong processCheckout(), sau khi tạo order thành công:
try {
    emailService.sendOrderConfirmation(currentUser, order);
} catch (Exception e) {
    logger.error("Email send failed (non-critical): " + e.getMessage());
    // Không rollback transaction
}
```

### 3.5 Thêm dependency (pom.xml)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```

---

## Feature 4: Hoàn tiền (Refund request)

**Mục tiêu:** User gửi yêu cầu hoàn tiền, xem lịch sử

### 4.1 Database đã có sẵn

```sql
-- Bảng refund_requests đã tồn tại:
-- id, order_id, order_item_id, user_id, amount, reason, status, requestedAt, processedAt

-- Ràng buộc: mỗi order_item chỉ có 1 refund request (UNIQUE trên order_item_id)
```

### 4.2 Tạo API refund request

```java
@RestController
@RequestMapping("/api/library")
public class LibraryApiController {

    @PostMapping("/refund-request")
    @ResponseBody
    public Map<String, Object> requestRefund(
            @RequestParam("orderItemId") Long orderItemId,
            @RequestParam("reason") String reason,
            HttpSession session) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return Map.of("success", false, "message", "Vui lòng đăng nhập");
        }

        // 1. Verify order_item belongs to user
        // 2. Check chưa có refund request cho item này
        // 3. Tạo RefundRequest (PENDING)
        // 4. Update order_item.status = 'REFUND_REQUESTED'
        // 5. Return result
    }
}
```

### 4.3 Tạo trang refund-history.jsp

Hiển thị danh sách refund requests của user:
- Tên game, số tiền, trạng thái (PENDING / APPROVED / REJECTED)
- Ngày yêu cầu, ngày xử lý
- Lý do (nếu có)

---

## Feature 5: Trang nạp tiền (Simulated)

**Mục tiêu:** Trang `/recharge` cho user nạp tiền vào ví

### 5.1 Hạn chế

- Cần bảng `wallets` có record cho user → **nếu chưa có thì bỏ qua**
- Wallet phải được tạo khi user đăng ký (AuthController) → cần insert vào DB

**→ Nếu database đã có wallet cho user đăng nhập → làm được**
**→ Nếu chưa có → bỏ qua tính năng này cho đến khi có DB migration**

### 5.2 Nếu làm được

```java
// RechargeController.processRecharge()
@PostMapping("/recharge/process")
@ResponseBody
public Map<String, Object> processRecharge(
        @RequestParam("amount") BigDecimal amount,
        @RequestParam("method") String method,
        HttpSession session) {

    // 1. Simulate payment (giả lập thành công)
    // 2. Update wallet.balance += amount
    // 3. Create wallet_transaction (SUCCESS)
    // 4. Return new balance
}
```

### 5.3 Kiểm tra trước

Chạy query kiểm tra user có wallet chưa:
```sql
SELECT * FROM wallets WHERE user_id = 1;
```

Nếu chưa có → skip feature này.

---

## Feature 6: Trang hồ sơ (Profile)

**Mục tiêu:** User xem và cập nhật thông tin cá nhân

### 6.1 Hạn chế

- Thêm trường phone, address, gender → cần ALTER TABLE
- **→ Chỉ hiển thị những trường đã có: email, fullName, avatar**

### 6.2 ProfileController đơn giản

```java
@GetMapping("/profile")
public String showProfile(HttpSession session, Model model) {
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) return "redirect:/login";

    // Chỉ cập nhật fullName và avatar (đã có trong DB)
    model.addAttribute("user", currentUser);
    model.addAttribute("walletBalance", getWalletBalance(currentUser.getId()));
    return "profile";
}

@PostMapping("/profile/update")
public String updateProfile(@RequestParam("fullName") String fullName,
                            HttpSession session) {
    User currentUser = (User) session.getAttribute("currentUser");
    // Update fullName
    session.setAttribute("currentUser", updatedUser);
    return "redirect:/profile?success=1";
}
```

---

## Tổng hợp file cần tạo / sửa

### File mới (8 file)

| # | File | Feature |
|---|------|---------|
| 1 | `src/main/java/com/gamestore/controller/LibraryController.java` | Library |
| 2 | `src/main/java/com/gamestore/controller/LibraryApiController.java` | Refund API |
| 3 | `src/main/java/com/gamestore/controller/ProfileController.java` | Profile |
| 4 | `src/main/java/com/gamestore/service/EmailService.java` | Email |
| 5 | `src/main/webapp/WEB-INF/views/library.jsp` | Library UI |
| 6 | `src/main/webapp/WEB-INF/views/refund-history.jsp` | Refund history |
| 7 | `src/main/webapp/WEB-INF/views/profile.jsp` | Profile UI |
| 8 | `src/main/webapp/assets/js/library.js` | Library JS |

### File sửa (6 file)

| # | File | Thay đổi |
|---|------|-----------|
| 1 | `src/main/webapp/WEB-INF/views/index.jsp` | Header dropdown |
| 2 | `src/main/java/com/gamestore/controller/HomeController.java` | Thêm walletBalance |
| 3 | `src/main/java/com/gamestore/controller/CheckoutController.java` | Gọi EmailService |
| 4 | `src/main/java/com/gamestore/controller/AuthController.java` | Tạo wallet khi đăng ký (nếu chưa có) |
| 5 | `pom.xml` | Thêm spring-boot-starter-mail |
| 6 | `src/main/resources/application.properties` | Thêm mail config |

---

## Thứ tự thực hiện

| Thứ tự | Feature | Lý do |
|--------|---------|-------|
| 1 | **Header dropdown** | Dễ nhất, cải thiện UX ngay |
| 2 | **Library page** | Không cần DB change, đọc bảng đã có |
| 3 | **Email hóa đơn** | Không cần DB change, gửi sau checkout |
| 4 | **Refund request API** | Không cần DB change, dùng bảng đã có |
| 5 | **Refund history page** | UI cho refund |
| 6 | **Profile page** | Chỉ dùng trường đã có |
| 7 | **Recharge page** | Chỉ nếu user đã có wallet trong DB |

---

## Checklist trước khi bắt đầu

```sql
-- 1. Kiểm tra user có wallet chưa
SELECT * FROM wallets WHERE user_id = 1;

-- 2. Kiểm tra library_items có dữ liệu chưa
SELECT * FROM library_items;

-- 3. Kiểm tra license_keys
SELECT * FROM license_keys LIMIT 5;

-- 4. Kiểm tra orders
SELECT * FROM orders LIMIT 5;
```
