# GameForge — Claude Progress Tracker

> Cập nhật: 2026-06-01 | Harness Engineer: Claude Agent | Phase: Merge Complete — Branch: feature/otp-auth-merge

---

## TRẠNG THÁI HIỆN TẠI CỦA THƯ MỤC GỐC (d:\Eclipse\GameStore)

```
D:\Eclipse\GameStore\
├── pom.xml                         ✅ Maven WAR — Spring MVC + Hibernate + SQL Server
├── .gitignore                     ✅ Credentials excluded
├── .cursorrules                   ✅ Harness agent prompt
├── AGENTS.md                       ✅ Harness Rule Engine
├── feature_list.json               ✅ 16 features, 18 tables
├── claude-progress.md              ✅ ← TRACKER NÀY
├── quality-document.md             ✅ Architecture quality scoring
├── clean-state-checklist.md        ✅ Tomcat/SQL Server health check
├── init.bat / init.sh              ✅ DB init scripts
├── templates/                      ✅ Harness templates
├── plan/                           ✅ Merge plan + migration scripts
│   ├── MERGE-00..04.md
│   ├── migrate-create-new-tables.sql
│   └── migrate-seed-roles.sql
└── src\main\
    ├── java\com\gamestore\
    │   ├── config\GlobalExceptionHandler.java    ✅
    │   ├── controller\                           ✅ 12 Controllers
    │   │   ├── AuthController.java               ✅ OTP email + BCrypt auto-upgrade
    │   │   ├── AdminController.java              ✅ NEW — RBAC admin dashboard
    │   │   ├── PublisherController.java          ✅ NEW — payout requests
    │   │   ├── KycController.java               ✅ NEW — KYC submission
    │   │   ├── CartApiController.java
    │   │   ├── CheckoutController.java
    │   │   ├── DashboardController.java
    │   │   ├── GameController.java
    │   │   ├── LibraryController.java
    │   │   ├── PromoApiController.java
    │   │   ├── ProfileApiController.java
    │   │   └── RechargeController.java
    │   ├── dao\                                  ✅ 11 DAOs
    │   │   ├── BaseDAO.java                      ✅ + update(), saveOrUpdate()
    │   │   ├── UserDAO.java                     ✅ + findByUsername, existsByUsername, changeStatus
    │   │   ├── CartItemDAO.java
    │   │   ├── RoleDAO.java                     ✅ NEW
    │   │   ├── WalletDAO.java                    ✅ NEW
    │   │   ├── WalletTransactionDAO.java         ✅ NEW — pagination
    │   │   ├── KycRequestDAO.java               ✅ NEW
    │   │   ├── PayoutRequestDAO.java           ✅ NEW
    │   │   ├── PublisherProfileDAO.java         ✅ NEW
    │   │   ├── SystemSettingDAO.java            ✅ NEW
    │   │   ├── GameDAO.java                    ✅ NEW
    │   │   ├── OrderDAO.java                   ✅ NEW
    │   │   └── LicenseKeyDAO.java              ✅ NEW
    │   ├── entity\                              ✅ 16 Entities
    │   │   ├── User.java                       ✅ + roles (EAGER), hasRole()
    │   │   ├── Role.java                       ✅ NEW
    │   │   ├── Wallet.java
    │   │   ├── WalletTransaction.java
    │   │   ├── Game.java                       ✅ + publisher field
    │   │   ├── LicenseKey.java                 ✅ + assignTo(), orderItem FK
    │   │   ├── LibraryItem.java                 ✅ + orderItem FK
    │   │   ├── Order.java / OrderItem.java
    │   │   ├── CartItem.java / PromoCode.java
    │   │   ├── Category.java / GameMedia.java
    │   │   ├── KycRequest.java                 ✅ NEW
    │   │   ├── PayoutRequest.java              ✅ NEW
    │   │   ├── PublisherProfile.java           ✅ NEW
    │   │   └── SystemSetting.java              ✅ NEW
    │   ├── service\                             ✅ 7 Services
    │   │   ├── EmailService.java               ✅ + sendOtpEmail()
    │   │   ├── WalletService.java              ✅ NEW — deposit/withdraw/refund/payout
    │   │   ├── CheckoutService.java             ✅ NEW — single-game buy flow
    │   │   ├── AdminDashboardService.java      ✅ NEW
    │   │   ├── KycService.java                ✅ NEW
    │   │   ├── PayoutService.java             ✅ NEW
    │   │   └── SystemSettingService.java      ✅ NEW
    │   ├── dto\                                 ✅ 4 DTOs
    │   │   ├── PendingRegisterDTO.java        ✅ NEW
    │   │   ├── PageResult.java                ✅ NEW
    │   │   ├── AdminStatsDTO.java             ✅ NEW
    │   │   └── WalletActionForm.java         ✅ NEW (WalletService)
    │   ├── interceptor\                         ✅ NEW
    │   │   └── AuthInterceptor.java           ✅ RBAC: /admin, /publisher, /kyc guards
    │   └── util\PasswordEncoderUtil.java
    ├── resources\
    │   ├── database.properties
    │   └── mail.properties.example
    └── webapp\
        ├── WEB-INF\
        │   ├── spring-servlet.xml               ✅ + interceptor, multipart, mailSender
        │   ├── web.xml
        │   └── views\
        │       ├── verify-otp.jsp               ✅ NEW
        │       ├── index.jsp / login.jsp / checkout.jsp
        │       ├── dashboard.jsp / recharge.jsp / library.jsp
        │       ├── transactions.jsp / order-success.jsp
        │       └── admin/ / publisher/ / kyc/ ← CẦN TẠO JSP
        └── assets\css/ + assets\js/
```

---

## SESSION / SESSION TRACKING

| Session Key | Type | Used In | Description |
|---|---|---|---|
| `currentUser` | User object | All authenticated routes | Current logged-in user (MIGRATED: was `user`) |
| `pendingRegister` | PendingRegisterDTO | /register → /verify-otp | OTP registration flow |
| No explicit session timeout set | — | — | Default Tomcat (30 min) |

---

## PROGRESS MILESTONES

| Milestone | Date | Status | Notes |
|---|---|---|---|
| Phase 0: Baseline Scan | 2026-06-01 | ✅ COMPLETE | Toàn bộ codebase đã phân tích |
| Phase 1: Baseline Commit | 2026-06-01 | ✅ COMPLETE | Git commit 95 files, .gitignore, 1 branch |
| Phase 2: Merge OTP Auth + RBAC | 2026-06-01 | ✅ COMPLETE | OTP email, Role entity, AuthInterceptor |
| Phase 3: Admin/Publisher/KYC | 2026-06-01 | ✅ COMPLETE | Controllers + Services + DAOs |
| Phase 4: Spring Config Merge | 2026-06-01 | ✅ COMPLETE | Interceptor, multipart, mailSender |
| Phase 5: Build Verify | 2026-06-01 | ✅ COMPLETE | **BUILD SUCCESS** — 58 files compile |
| Phase 6: Harness Update | 2026-06-01 | ✅ COMPLETE | 16 features, 18 tables, all harness files |
| C01-C08: Critical Fixes | TBD | ⬜ PENDING | EAGER fetch, race condition, SQL injection |
| W01-W07: Warning Fixes | TBD | ⬜ PENDING | Rate limiting, pagination, CSRF |
| **JSP Pages**: admin/ publisher/ kyc | TBD | ⬜ PENDING | Tạo JSP views cho admin/publisher/kyc |
| Database: Chạy migrate scripts | TBD | ⬜ PENDING | migrate-create-new-tables.sql + migrate-seed-roles.sql |

---

## CHẶN LỖI CRITICAL ĐÃ XÁC ĐỊNH

### 🔴 Critical (Cần fix ngay)

| ID | Issue | Location | Risk |
|---|---|---|---|
| C01 | Game entity EAGER fetch mediaList + categories | Game.java | N+1 query khi load list game |
| C02 | Checkout race condition — không có optimistic/pessimistic lock | CheckoutController.processOrder() | Double spend wallet |
| C03 | ~~Named Parameter enforcement~~ | UserDAO.java | ✅ ĐÃ FIX — chuyển sang named params |
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

---

## TIẾP THEO CẦN LÀM GÌ?

**Ngay sau merge:**

1. **Tạo JSP pages cho admin/publisher/kyc** — Controllers đã có nhưng chưa có views
2. **Chạy migration scripts** trong SQL Server:
   - `plan/migrate-create-new-tables.sql` — tạo 6 bảng mới + FK columns
   - `plan/migrate-seed-roles.sql` — seed 3 roles + gán ROLE_USER cho users hiện tại
3. **C03 ĐÃ FIX**: UserDAO chuyển sang named parameters
4. **Sửa C02**: Thêm optimistic lock vào Wallet entity
5. **Sửa C05**: Thêm unique constraint trên CartItem(userId, gameId)
6. **Sửa C01**: Game.java EAGER → LAZY fetch

---

## FILE INVENTORY (MERGE STATE)

| Category | Count | Files |
|---|---|---|
| Java Controllers | 12 | Auth, Admin, Publisher, Kyc, + 8 existing |
| Java Entities | 16 | User, Role, KycRequest, PayoutRequest, PublisherProfile, + 11 existing |
| Java DAOs | 13 | BaseDAO, UserDAO, + 11 new/updated |
| Java Services | 7 | EmailService, WalletService, CheckoutService, + 4 new |
| Java DTOs | 4 | PendingRegisterDTO, PageResult, AdminStatsDTO, WalletActionForm |
| Java Interceptors | 1 | AuthInterceptor |
| JSP Views | 9 | verify-otp.jsp + 8 existing (admin/publisher/kyc cần tạo) |
| SQL Migration | 3 | migrate-create-new-tables.sql, migrate-seed-roles.sql |
