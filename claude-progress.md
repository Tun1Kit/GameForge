# GameForge — Claude Progress Tracker

> Cập nhật: 2026-06-01 | Harness Engineer: Claude Agent | Phase: Baseline Established

---

## TRẠNG THÁI HIỆN TẠI CỦA THƯ MỤC GỐC (d:\Eclipse\GameStore)

```
D:\Eclipse\GameStore\
├── pom.xml                         ✅ Maven WAR project — Spring MVC + Hibernate
├── AGENTS.md                       ✅ Harness Rule Engine (đã populate)
├── feature_list.json               ✅ Feature inventory (đã populate)
├── claude-progress.md              ✅ ← TRACKER NÀY
├── quality-document.md             ✅ Architecture quality scoring (đã populate)
├── clean-state-checklist.md        ✅ Tomcat/SQL Server health check (đã populate)
├── src\
│   └── main\
│       ├── java\com\gamestore\
│       │   ├── config\GlobalExceptionHandler.java    ✅
│       │   ├── controller\                           ✅ 9 Controllers
│       │   │   ├── AuthController.java               ✅ Login/Register/Logout
│       │   │   ├── CartApiController.java            ✅ Cart CRUD
│       │   │   ├── CheckoutController.java           ✅ Checkout + Order flow
│       │   │   ├── DashboardController.java           ✅ Dashboard stats
│       │   │   ├── GameController.java               ✅ Game listing + Admin keys
│       │   │   ├── LibraryController.java             ✅ Library + Transactions
│       │   │   ├── PromoApiController.java            ✅ Promo validation
│       │   │   ├── ProfileApiController.java          ✅ Profile update
│       │   │   └── RechargeController.java           ✅ Wallet recharge
│       │   ├── dao\                                  ✅ 3 DAOs
│       │   │   ├── BaseDAO.java                      ✅ Generic CRUD
│       │   │   ├── CartItemDAO.java                  ✅ Cart-specific queries
│       │   │   └── UserDAO.java                       ✅ User-specific queries
│       │   ├── entity\                               ✅ 12 Entities
│       │   │   ├── CartItem.java
│       │   │   ├── Category.java
│       │   │   ├── Game.java                         ⚠️ EAGER fetch
│       │   │   ├── GameMedia.java
│       │   │   ├── LibraryItem.java
│       │   │   ├── LicenseKey.java
│       │   │   ├── Order.java
│       │   │   ├── OrderItem.java
│       │   │   ├── PromoCode.java
│       │   │   ├── User.java
│       │   │   ├── Wallet.java
│       │   │   └── WalletTransaction.java
│       │   ├── service\EmailService.java             ⚠️ DISABLED
│       │   ├── test\DbTest.java
│       │   └── util\PasswordEncoderUtil.java
│       ├── resources\
│       │   └── database.properties                   ⚠️ Credentials — gitignore
│       └── webapp\
│           ├── assets\
│           │   ├── css\                              ✅ 7 CSS files
│           │   └── js\                               ✅ 7 JS files
│           └── WEB-INF\
│               ├── spring-servlet.xml                 ✅ Spring config
│               ├── web.xml                            ✅ Servlet config
│               └── views\                             ✅ 8 JSP files
```

---

## THIẾT LẬP BASELINE — PHASE 0 COMPLETE

### Ngày: 2026-06-01
### Trạng thái: ✅ BASELINE ESTABLISHED

**Baseline Checklist — Hoàn thành 100%:**

- [x] Quét toàn bộ cấu trúc dự án (53 files)
- [x] Phân tích 9 Controllers → routes, session handling, auth patterns
- [x] Phân tích 12 Entities → relationships, fetch strategies
- [x] Phân tích 3 DAOs → HQL patterns, query safety
- [x] Phân tích spring-servlet.xml → Spring beans, Hibernate config
- [x] Phân tích database.properties → SQL Server connection
- [x] Phân tích 8 JSP views → forms, Bootstrap usage, API calls
- [x] Phân tích 7 JS files → localStorage keys, API endpoints, theme toggle
- [x] Phân tích 7 CSS files → Neo-Brutalism design system
- [x] Tạo AGENTS.md → 13 sections, regex patterns cho code review
- [x] Tạo feature_list.json → 12 features + 2 placeholder modules
- [x] Tạo quality-document.md → 5 domains, architecture scoring
- [x] Tạo clean-state-checklist.md → Tomcat + SQL Server checks

---

## CHẶN LỖI CRITICAL ĐÃ XÁC ĐỊNH

### 🔴 Critical (Cần fix ngay)

| ID | Issue | Location | Risk |
|---|---|---|---|
| C01 | Game entity EAGER fetch mediaList + categories | Game.java | N+1 query khi load list game |
| C02 | Checkout race condition — không có optimistic/pessimistic lock | CheckoutController.processOrder() | Double spend wallet |
| C03 | Named Parameter enforcement — UserDAO dùng positional param | UserDAO.java line ~30 | SQL injection risk |
| C04 | Simulated payment — không verify real transaction | RechargeController.processRecharge() | Fake recharge |
| C05 | Duplicate CartItem prevention — không có unique constraint | CartItemDAO | User có thể add cùng game nhiều lần |
| C06 | Password update không yêu cầu current password | ProfileApiController.updateProfile() | Account takeover |
| C07 | No pagination — Library, Transactions, game listing | Multiple controllers | Performance degradation |
| C08 | Email disabled — không có retry mechanism | EmailService | Lost notifications |

### 🟡 Warning (Cần cải thiện)

| ID | Issue | Location | Risk |
|---|---|---|---|
| W01 | No rate limiting on login | AuthController | Brute force attack |
| W02 | LocalStorage favorites không sync cross-device | index.js | Data inconsistency |
| W03 | License key plain text trong DB | LicenseKey.entity | Security risk |
| W04 | Avatar URL không validate | ProfileApiController | Potential XSS |
| W05 | No idempotency key trong checkout | CheckoutController | Duplicate orders on refresh |
| W06 | Running balance tính sai khi có failed tx | LibraryController.getTransactionHistory() | Incorrect balance display |
| W07 | CartItem không có TTL/expiry | CartItem table | Orphaned cart items forever |

### 🟢 Info (Ghi nhận)

| ID | Issue | Location | Risk |
|---|---|---|---|
| I01 | BCrypt default rounds (10) — OK cho scale hiện tại | User.java, PasswordEncoderUtil | Good enough |
| I02 | SQL Server dialect SQLServer2012Dialect — OK | spring-servlet.xml | Correct dialect |
| I03 | Character encoding UTF-8 — OK | web.xml filter + pom.xml | i18n ready |
| I04 | Spring Security Crypto cho password — OK | pom.xml | No Spring Security core needed |

---

## SESSION / SESSION TRACKING

### Active Sessions

| Session Key | Type | Used In | Description |
|---|---|---|---|
| `user` | User object | All authenticated routes | Current logged-in user |
| No explicit session timeout set | — | — | Default Tomcat session timeout (30 min) |

### LocalStorage Keys (Frontend)

| Key | Type | Used In | Description |
|---|---|---|---|
| `cartItems` | Array<{gameId, quantity, price, name, image}> | index.js, checkout.js | Client-side cart items |
| `favorites` | Array<number> (game IDs) | index.js | Favorite game IDs |
| `theme` | 'light' \| 'dark' | index.js, checkout.js, library.js, recharge.js, transactions.js | Theme preference |

---

## PROGRESS MILESTONES

| Milestone | Date | Status | Notes |
|---|---|---|---|
| Phase 0: Baseline Scan | 2026-06-01 | ✅ COMPLETE | Toàn bộ codebase đã phân tích |
| Phase 1: Critical Fixes | TBD | ⬜ PENDING | 8 critical issues identified |
| Phase 2: Warning Fixes | TBD | ⬜ PENDING | 7 warning issues identified |
| Phase 3: New Features | TBD | ⬜ PENDING | MODULE_11 + MODULE_12 placeholders |
| Phase 4: Security Hardening | TBD | ⬜ PENDING | Rate limiting, 2FA, audit log |
| Phase 5: Performance | TBD | ⬜ PENDING | Pagination, caching, lazy loading |

---

## RESERVED MODULES

```
MODULE_11: [RESERVED — TBD]
  Gợi ý: Admin Dashboard | Game Review/Rating | Wishlist |
         Order Refund | Real Payment Gateway (VNPay/MoMo/ZaloPay) |
         Pagination | Rate Limiting | 2FA

MODULE_12: [RESERVED — TBD]
  Gợi ý: Social Login (Google/Facebook) | Game Search & Filter |
         Recommendation Engine | Loyalty Points | Gift Card |
         Multi-currency Support
```

---

## ARCHITECTURE SCORE (Baseline)

| Layer | Score | Notes |
|---|---|---|
| Overall | **B+** | Solid MVC foundation, missing critical production features |
| Controller Layer | **A-** | Clean separation, good session handling, API consistency |
| DAO Layer | **B-** | Generic BaseDAO works, positional params need fix, missing DAO layer |
| Entity Layer | **B** | Well-structured, EAGER fetch risk, missing indexes |
| Service Layer | **C** | Thin service layer, EmailService disabled, logic in controllers |
| Frontend (JSP/JS/CSS) | **A** | Neo-Brutalism design, localStorage strategy, theme toggle |
| Configuration | **B+** | Clean XML config, credentials outside git, UTF-8 encoding |
| Security | **C+** | BCrypt OK, no rate limiting, simulated payment, no CSRF protection |

---

## FILE INVENTORY (53 files total)

| Category | Count | Files |
|---|---|---|
| Java Controllers | 9 | Auth, CartApi, Checkout, Dashboard, Game, Library, PromoApi, ProfileApi, Recharge |
| Java Entities | 12 | CartItem, Category, Game, GameMedia, LibraryItem, LicenseKey, Order, OrderItem, PromoCode, User, Wallet, WalletTransaction |
| Java DAOs | 3 | BaseDAO, CartItemDAO, UserDAO |
| Java Config/Util/Test | 4 | GlobalExceptionHandler, EmailService, PasswordEncoderUtil, DbTest |
| JSP Views | 8 | index, login, dashboard, checkout, library, recharge, transactions, order-success |
| JavaScript | 7 | index, login, dashboard, checkout, library, recharge, transactions |
| CSS | 7 | index, login, dashboard, checkout, library, recharge, transactions |
| Config XML | 2 | spring-servlet.xml, web.xml |
| Config Properties | 1 | database.properties |
| Maven | 1 | pom.xml |
| **TOTAL** | **53** | |

---

## TIẾP THEO CẦN LÀM GÌ?

1. **Ưu tiên cao**: Sửa UserDAO positional parameters → named parameters (C03)
2. **Ưu tiên cao**: Thêm optimistic lock hoặc pessimistic lock vào Checkout flow (C02)
3. **Ưu tiên cao**: Thêm unique constraint (userId, gameId) trên CartItem (C05)
4. **Ưu tiên cao**: Fix Game.java EAGER fetch → LAZY + @JsonIgnore (C01)
5. **Ưu tiên**: Thêm rate limiting cho login endpoint
6. **Ưu tiên**: Implement pagination cho Library, Transactions, game listing
7. **Tương lai**: MODULE_11 placeholder — chọn 1 feature để implement
