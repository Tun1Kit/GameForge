# AGENTS.md — GameForge Harness: Luật Chặn Lỗi

> Cập nhật: 2026-06-01 | Harness Engineer: Claude Agent | Project: GameForge (Spring MVC + Hibernate + SQL Server)

---

## 1. QUY TẮC BẮT BUỘC CHUNG

### 1.1 Nền tảng & Stack
- **Framework:** Spring MVC 5.3.20 + Hibernate 5.6.9
- **Database:** SQL Server (SQLServer2012Dialect) — kết nối qua `mssql-jdbc 9.4.1.jre8`
- **Build:** Maven WAR (packaging: war, Java 1.8, encoding: UTF-8)
- **View:** JSP + JSTL 1.2 + Bootstrap 5 (CDN) + Lucide Icons (CDN)
- **Auth:** BCrypt — **KHÔNG BAO GIỜ** so sánh password bằng `String.equals()` — bắt buộc dùng `PasswordEncoder.matches()`

### 1.2 Cấu trúc Package
```
com.gamestore/
├── config/       → GlobalExceptionHandler.java
├── controller/   → AuthController, GameController, CartApiController,
│                  CheckoutController, DashboardController, LibraryController,
│                  PromoApiController, ProfileApiController, RechargeController
├── dao/          → BaseDAO (abstract), UserDAO, CartItemDAO
├── entity/       → User, Game, CartItem, Order, OrderItem, LicenseKey,
│                  LibraryItem, PromoCode, Wallet, WalletTransaction,
│                  GameMedia, Category
├── service/      → EmailService.java
├── util/         → PasswordEncoderUtil.java
└── test/         → DbTest.java
```

### 1.3 Cấu hình Spring
- `spring-servlet.xml` scan base-package: `com.gamestore`
- View resolver: prefix `/WEB-INF/views/`, suffix `.jsp`
- Resource mapping: `/assets/**` → `/assets/`
- Transaction manager: `HibernateTransactionManager` + `@Transactional`
- DataSource: đọc từ `classpath:database.properties`

---

## 2. LUẬT CHẶN LỖI — DAO LAYER

### 2.1 Bắt buộc Named Parameter trong HQL/JPQL
```java
// ✅ ĐÚNG — Named Parameter
session.createQuery("FROM User WHERE username = :username", User.class)
       .setParameter("username", username)
       .uniqueResult();

// ❌ SAI — Positional Parameter
session.createQuery("FROM User WHERE username = ?", User.class)
       .setParameter(0, username)
       .uniqueResult();

// ❌ SAI — String Concatenation (SQL Injection)
session.createQuery("FROM User WHERE username = '" + username + "'", User.class);
```

**Lý do:** Dự án này dùng `BaseDAO.findAll()` và `UserDAO` đã tự định nghĩa nhiều query. Mọi HQL phải dùng named parameter để tránh SQL injection và lỗi type-safety.

### 2.2 Kiểm tra Null trước khi Query
```java
// ✅ Bắt buộc kiểm tra null cho findById
User user = baseDAO.findById(userId);
if (user == null) {
    throw new EntityNotFoundException("User not found: " + userId);
}
```

### 2.3 Transaction Boundary
- Mọi method write (INSERT, UPDATE, DELETE) trong Controller/Service **PHẢI** có annotation `@Transactional`
- Không gọi `session.flush()` thủ công trừ khi cần evict sau write

### 2.4 Entity Lifecycle
- Entity mới: dùng `session.save(entity)` → trả về Serializable ID
- Entity đã attached: dùng `session.update(entity)` hoặc `session.merge(entity)`
- Không dùng `saveOrUpdate()` khi không rõ trạng thái entity

---

## 3. LUẬT CHẶN LỖI — CONTROLLER LAYER

### 3.1 Bảo vệ File Tĩnh (CSS / JS)

```
BẮT BUỘC giữ nguyên các file CSS/JS hiện có trong /assets/:
  /assets/css/index.css      — 753 lines, Neo-Brutalism design system
  /assets/css/login.css      — 242 lines
  /assets/css/dashboard.css  — 9 lines
  /assets/css/checkout.css   — 339 lines
  /assets/css/library.css    — 46 lines
  /assets/css/recharge.css   — 77 lines
  /assets/css/transactions.css — 271 lines
  /assets/js/index.js        — 490 lines, cart/favorites trong localStorage
  /assets/js/login.js        — 214 lines
  /assets/js/dashboard.js    — 40 lines
  /assets/js/checkout.js     — 1016 lines, core checkout logic + promo
  /assets/js/library.js       — 335 lines
  /assets/js/recharge.js      — 274 lines
  /assets/js/transactions.js  — 224 lines
```

**Quy tắc:**
- **KHÔNG XÓA** bất kỳ selector CSS nào đang được JSP sử dụng
- **KHÔNG ĐỔI TÊN** file CSS/JS đang được JSP `<link>` hoặc `<script>` refer
- Khi thêm feature mới, tạo file mới (vd: `admin.css`) thay vì sửa file cũ trừ khi cần
- Kiểm tra `grep` tên file trong JSP trước khi rename

### 3.2 Session / Authentication
```java
// ✅ ĐÚNG — Kiểm tra session trước khi thao tác
HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("user") == null) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    return;
}
User user = (User) session.getAttribute("user");

// ❌ Tránh — Không cast trực tiếp mà không kiểm tra
User user = (User) request.getSession().getAttribute("user"); // NullPointerException nếu chưa login
```

### 3.3 Route Protection
Tất cả routes cần đăng nhập (trừ `/`, `/login`, `/register`, `/api/auth/*`):
```java
// Pattern bắt buộc ở đầu mỗi Controller method
if (session.getAttribute("user") == null) {
    return "redirect:/login";
}
```

### 3.4 API Response Format
```java
// ✅ ĐÚNG — JSON response nhất quán
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
PrintWriter out = response.getWriter();
out.print("{\"success\": true, \"message\": \"...\"}");

// ❌ Tránh — Inconsistent content type
response.setContentType("text/plain");
```

### 3.5 Input Validation
```java
// ✅ Bắt buộc trim + validate trước khi dùng
String username = request.getParameter("username");
if (username == null || username.trim().isEmpty()) {
    // handle error
}
username = username.trim();

// ❌ Không dùng raw input trực tiếp
String username = request.getParameter("username"); // null possible
```

---

## 4. LUẬT CHẶT LỖI — CHECKOUT FLOW (Nghiệp vụ quan trọng nhất)

### 4.1 Thứ tự thao tác bắt buộc
Checkout flow phải theo đúng thứ tự sau (trong `CheckoutController.processOrder`):

```
1. Validate cart (empty check)
2. Validate wallet balance >= total
3. BEGIN TRANSACTION
   3.1. Deduct wallet (UPDATE Wallet SET balance = balance - amount)
   3.2. Insert WalletTransaction (type=ORDER, amount=-)
   3.3. Insert Order (8 shipping fields)
   3.4. Insert OrderItem(s) cho từng game
   3.5. Generate/Assign LicenseKey cho từng game
   3.6. Insert LibraryItem cho từng game
   3.7. Delete CartItem(s) đã mua
   3.8. Mark PromoCode usage (nếu có)
4. COMMIT TRANSACTION
5. Send email confirmation (async, non-blocking)
6. Redirect to /checkout/success
```

**Nếu bất kỳ bước nào thất bại → ROLLBACK + refund wallet**

### 4.2 Kiểm tra số dư Wallet
```java
// ✅ Bắt buộc double-check balance ở server
Wallet wallet = baseDAO.findById(user.getWallet().getId());
if (wallet.getBalance().compareTo(totalPrice) < 0) {
    // reject, return error
}

// ❌ Không tin client-side total (hoàn toàn có thể bị manipulate)
double clientTotal = Double.parseDouble(request.getParameter("total")); // ❌ Untrusted
```

### 4.3 License Key Generation
```java
// ✅ Dùng UUID + game prefix
String licenseKey = game.getId() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
// Kết quả: "3-A1B2C3D4"

// ❌ Không dùng Math.random() hoặc timestamp đơn giản
String key = "KEY" + System.currentTimeMillis(); // ❌ Dễ đoán, không unique
```

### 4.4 Promo Code Validation
```java
// Kiểm tra 3 điều kiện trong CheckoutController.validatePromo:
if (promo == null) return "Mã không hợp lệ";
if (promo.getExpiryDate() != null && promo.getExpiryDate().before(new Date())) return "Mã đã hết hạn";
if (promo.getMaxUsage() != null && promo.getUsageCount() >= promo.getMaxUsage()) return "Mã đã hết lượt sử dụng";
```

---

## 5. LUẬT CHẶT LỖI — RECHARGE FLOW

### 5.1 Bonus Calculation (Cố định theo business logic)
```java
// ✅ ĐÚNG — Giữ nguyên bảng bonus hiện tại
if (amount >= 500_000)  bonusRate = 0.06;  // 500k → +30k
else if (amount >= 1_000_000) bonusRate = 0.08; // 1M → +80k
else if (amount >= 2_000_000) bonusRate = 0.11; // 2M → +220k

// ❌ Không thay đổi tỷ lệ bonus mà không có approval từ business owner
```

### 5.2 Cổng thanh toán mô phỏng
- Hiện tại dùng **simulated payment** (MBBank mock QR)
- Nếu thêm cổng thật (VNPay, MoMo, ZaloPay) → tạo interface `PaymentGateway`
- Không hard-code logic gateway mới vào `RechargeController`

---

## 6. LUẬT CHẶT LỖI — ENTITY & DATABASE

### 6.1 Hibernate Fetch Strategy
```java
// Game.java có EAGER fetch — CẨN THẬN N+1 query
@OneToMany(mappedBy = "game", fetch = FetchType.EAGER)
// Khi load list games → load hết media + categories
// Chỉ dùng trong Controller getGameById(), KHÔNG load danh sách lớn với EAGER

// CartItem/OrderItem dùng EAGER — OK vì số lượng nhỏ
```

### 6.2 SQL Server Dialect
```xml
<!-- ✅ ĐÚNG -->
<prop key="hibernate.dialect">org.hibernate.dialect.SQLServer2012Dialect</prop>

<!-- ❌ Không dùng MySQLDialect hoặc PostgreSQLDialect -->
```

### 6.3 Cấu hình Kết nối Database
```properties
# ✅ ĐÚNG — SQL Server connection string
jdbc.url=jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=GameStore;encrypt=false;trustServerCertificate=true

# ❌ Không đổi instance name hoặc database name mà không cập nhật DB
```

### 6.4 Entity Field Naming
- Không thay đổi tên column `@Column(name="...")` đã map
- Nếu đổi → tạo migration script, không xóa column cũ trực tiếp

---

## 7. LUẬT CHẶT LỖI — FRONTEND (JSP / JS / CSS)

### 7.1 Bảo vệ Dashboard (index.jsp)
```javascript
// ✅ ĐÚNG — LocalStorage keys đang dùng trong index.js
localStorage.getItem('cartItems')     // Array<{gameId, quantity, price, name, image}>
localStorage.getItem('favorites')      // Array<number> (game IDs)
localStorage.getItem('theme')          // 'light' | 'dark'

// ❌ Không dùng key khác làm cart/favorites storage
// localStorage.setItem('cart', ...) → ❌ Đổi thành 'cartItems'
```

### 7.2 Bootstrap 5 Classes (Neo-Brutalism)
```css
/* Design system hiện tại dùng:
   - Primary: #FF6B6B (coral-red)
   - Secondary: #4ECDC4 (teal)
   - Accent: #FFE66D (yellow)
   - Dark: #2C3E50
   - Light: #F8F9FA
   - Border: 3px solid black
   - Box-shadow: 5px 5px 0px #000
*/

/* ❌ Không thay đổi biến CSS root mà không kiểm tra tất cả các file khác */
```

### 7.3 API URL Pattern
```javascript
// ✅ ĐÚNG — API endpoint pattern trong JS
const API_BASE = ''; // Relative path

// Cart
POST /api/cart/add          (gameId, quantity)
GET  /api/cart/count
GET  /api/cart/items
POST /api/cart/remove       (cartItemId)
POST /api/cart/remove-by-game (gameId)

// Checkout
POST /api/checkout/process  (total, promoCode?)
POST /api/promo/validate    (code, gameIds[])
POST /api/promo/by-games    (gameIds[])

// Profile
POST /api/profile/update    (fullName, password, avatar)

// Recharge
POST /api/recharge/process   (amount, paymentMethod, transactionId)
```

### 7.4 Theme Toggle
```javascript
// index.js + checkout.js + library.js + recharge.js + transactions.js
// Dùng data-bs-theme="dark|light" trên thẻ <html> và toggle body class
// Cần đồng bộ giữa tất cả file JS
```

---

## 8. LUẬT CHẶT LỖI — EMAIL SERVICE

### 8.1 Email Disabled by Default
```java
// database.properties: email.enabled=false
// EmailService.sendOrderConfirmation() chỉ gửi khi email.enabled=true
// Khi gửi: dùng HTML template trong EmailService.confirmTemplate
// Luôn dùng try-catch riêng cho email (non-blocking)

// ❌ Không throw exception khi email fail — non-critical operation
```

---

## 9. LUẬT CHẶT LỖI — CẤU HÌNH (XML / PROPERTIES)

### 9.1 Bảo vệ spring-servlet.xml
```xml
<!-- Cấu hình KHÔNG được thay đổi: -->
<context:component-scan base-package="com.gamestore" />
<mvc:annotation-driven />
<mvc:resources mapping="/assets/**" location="/assets/" />
<mvc:default-servlet-handler />
<!-- DataSource, SessionFactory, TransactionManager: giữ nguyên -->
```

### 9.2 Không commit credentials vào git
```properties
# database.properties chứa password — THÊM VÀO .gitignore:
# src/main/resources/database.properties

# Nếu tạo file mới → dùng database.properties.example làm template
```

---

## 10. LUẬT CHẶT LỖI — MIGRATION & DEPLOYMENT

### 10.1 Database Migration
- **KHÔNG BAO GIỜ** drop table trực tiếp trong code
- Mọi schema change phải qua ALTER TABLE script đã review
- Backup trước khi migration

### 10.2 Tomcat Deployment
- Context path: `/gamestore` (pom.xml WAR name: `gamestore`)
- WAR file: `gamestore.war` → deploy vào `$CATALINA_HOME/webapps/`
- Server startup: kiểm tra `localhost:8080/gamestore` sau khi deploy
- Kiểm tra log: `$CATALINA_HOME/logs/catalina.out`

### 10.3 Maven Commands
```bash
# Build
mvn clean package -DskipTests

# Deploy (copy WAR)
mvn clean package -DskipTests && cp target/gamestore.war $CATALINA_HOME/webapps/

# Chỉ chạy tests khi đã có DB test hoặc H2 in-memory
# mvn test  # Tạm thời skip vì chưa có test DB
```

---

## 11. DANH SÁCH CÁC ROUTE HIỆN TẠI

| Route | Method | Controller | Auth | Description |
|---|---|---|---|---|
| `/` | GET | GameController | No | Trang chủ, game listing |
| `/home` | GET | GameController | No | Alias cho trang chủ |
| `/login` | GET/POST | AuthController | No | Login / Register |
| `/register` | POST | AuthController | No | Đăng ký tài khoản |
| `/logout` | GET | AuthController | Yes | Đăng xuất |
| `/dashboard` | GET | DashboardController | Yes | Dashboard với wallet, cart, orders |
| `/checkout` | GET | CheckoutController | Yes | Trang thanh toán |
| `/checkout/process` | POST | CheckoutController | Yes | Xử lý thanh toán (redirect) |
| `/checkout/success` | GET | CheckoutController | Yes | Trang thành công |
| `/library` | GET | LibraryController | Yes | Thư viện game đã sở hữu |
| `/transactions` | GET | LibraryController | Yes | Lịch sử giao dịch |
| `/recharge` | GET | RechargeController | Yes | Trang nạp tiền |
| `/api/auth/*` | * | AuthController | No | Auth API endpoints |
| `/api/cart/*` | * | CartApiController | Yes | Cart API |
| `/api/checkout/*` | * | CheckoutController | Yes | Checkout API |
| `/api/promo/*` | * | PromoApiController | * | Promo API |
| `/api/profile/*` | * | ProfileApiController | Yes | Profile API |
| `/api/recharge/*` | * | RechargeController | Yes | Recharge API |
| `/api/admin/generate-keys` | POST | GameController | Yes | Generate license keys |

---

## 12. DANH SÁCH CÁC DB TABLE

| Table | Entity | Primary Key | Notes |
|---|---|---|---|
| Users | User | userId | BCrypt password, link Wallet |
| Wallet | Wallet | walletId | balance DECIMAL(18,2) |
| WalletTransaction | WalletTransaction | transactionId | + deposit, - order |
| Game | Game | gameId | EAGER media + categories |
| GameMedia | GameMedia | mediaId | |
| Category | Category | categoryId | |
| CartItem | CartItem | cartItemId | FK userId + gameId |
| `Order` | Order | orderId | 8 shipping fields |
| OrderItem | OrderItem | orderItemId | FK orderId + gameId + licenseKeyId |
| LicenseKey | LicenseKey | keyId | gameId + key string |
| LibraryItem | LibraryItem | libraryItemId | FK userId + gameId |
| PromoCode | PromoCode | promoId | usage limit + expiry |

---

## 13. REGEX PATTERN CHO CODE REVIEW

```regex
# Phát hiện HQL không dùng Named Parameter
HQL_CONCAT: /FROM \w+ WHERE \w+ = ['"]?\+ \w+ \+ ['"]?/

# Phát hiện password so sánh thủ công
PASSWORD_COMPARE: /\.equals\s*\(.*password/i

# Phát hiện SQL String concatenation
SQL_CONCAT: /CREATEQUERY.*["']\s*\+/

# Phát hiện thiếu @Transactional
MISSING_TX: /session\.save\(|session\.update\(|session\.delete\(/  // without @Transactional above

# Phát hiện thiếu null check trước cast
NULL_CAST: /session\.getAttribute\([^)]+\)\)\s*as TypeCast/

# Phát hiện balance check thiếu server-side
BALANCE_CHECK: /wallet\.getBalance\(\).*<.*total/  // chỉ client-side
```
