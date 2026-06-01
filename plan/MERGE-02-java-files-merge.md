# MERGE-02: JAVA FILES MERGE

## TỔNG QUAN

```
Nhóm A: Lấy hoàn toàn từ đồng nghiệp (GamestoreLTW)
Nhóm B: Giữ hoàn toàn GameForge
Nhóm C: Merge cẩn thận (lấy tốt nhất từ cả 2)
```

---

## NHÓM A: LẤY HOÀN TOÀN TỪ GAMESTORELTW

### A1. AuthController.java — MERGE VỚI OTP EMAIL
```
SOURCES:
  - GameForge: src/main/java/com/gamestore/controller/AuthController.java
  - Colleague: colleague/main/src/main/java/com/gamestore/controller/AuthController.java

Lý do lấy từ đồng nghiệp:
  - Bổ sung hệ thống xác thực OTP qua email trước khi đăng ký
  - Đăng ký: gửi mail OTP → verify → tạo tài khoản
  - BCrypt auto-upgrade cho password cũ
  - Role-based redirect sau login (ADMIN → /admin, PUBLISHER → /publisher)

GIỮ TỪ GAMEFORGE:
  - Login hỗ trợ email OR username (đồng nghiệp chỉ có email)
  - PasswordEncoderUtil (thay vì gọi BCryptPasswordEncoder trực tiếp)
  - Session fixation fix (session.invalidate())

MERGE: Tạo AuthController mới kết hợp tốt nhất từ cả 2:

CẤU TRÚC AUTHCONTROLLER MỚI:
  1. GET /login          → showLoginPage()              ← giữ GameForge
  2. POST /login         → processLogin()               ← merge: emailOrUsername + BCrypt upgrade
  3. GET /register       → showRegisterPage()          ← giữ GameForge
  4. POST /register      → processRegister()            ← thay: gửi OTP email → verify-otp
  5. GET /logout         → processLogout()              ← giữ GameForge
  6. GET /verify-otp     → showVerifyOtpPage()         ← THÊM từ đồng nghiệp
  7. POST /verify-otp    → processVerifyOtp()          ← THÊM từ đồng nghiệp

FILES CẦN COPY THÊM:
  1. EmailService.java                               ← THÊM
  2. PendingRegisterDTO.java                          ← THÊM
  3. verify-otp.jsp                                  ← THÊM (JSP)
  4. mail.properties (cấu hình SMTP)                 ← THÊM

Bước:
  1. Đọc AuthController đồng nghiệp làm base
  2. Đổi BCryptPasswordEncoder → PasswordEncoderUtil.matches/encode
  3. Giữ login emailOrUsername (không đổi sang email-only)
  4. Giữ session fixation fix (session.invalidate())
  5. Giữ wallet auto-create trong verify-otp thành công
  6. Copy EmailService + PendingRegisterDTO
  7. Copy verify-otp.jsp
  8. Copy/kiểm tra mail.properties
```

### A2. AuthInterceptor.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/interceptor/AuthInterceptor.java
Đặt vào: src/main/java/com/gamestore/interceptor/AuthInterceptor.java
Lý do: Route guard theo role (ADMIN, PUBLISHER, USER)
       GameForge không có interceptor này
Lưu ý: Cần đăng ký interceptor trong spring-servlet.xml
```

### A3. Role.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/entity/Role.java
Đặt vào: src/main/java/com/gamestore/entity/Role.java
Lý do: Entity cơ bản, không có gì khác biệt
```

### A4. RoleDAO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dao/RoleDAO.java
Đặt vào: src/main/java/com/gamestore/dao/RoleDAO.java
Lý do: GameForge không có RoleDAO
Cần kiểm tra: có method findByCode(String code) hay không
```

### A5. WalletService.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/service/WalletService.java
Đặt vào: src/main/java/com/gamestore/service/WalletService.java
Lý do: Cung cấp backend cho withdraw, refund, payout publisher
       (RECHARGE đã có trong GameForge RechargeController)
Lưu ý: KHÔNG ghi đè RechargeController.java
```

### A6. WalletDAO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dao/WalletDAO.java
Đặt vào: src/main/java/com/gamestore/dao/WalletDAO.java
```

### A7. WalletTransactionDAO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dao/WalletTransactionDAO.java
Đặt vào: src/main/java/com/gamestore/dao/WalletTransactionDAO.java
```

### A8. AdminController.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/controller/AdminController.java
Đặt vào: src/main/java/com/gamestore/controller/AdminController.java
Lý do: GameForge không có → bổ sung hoàn toàn
Chức năng: dashboard, user management, KYC, payouts
```

### A9. AdminDashboardService.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/service/AdminDashboardService.java
Đặt vào: src/main/java/com/gamestore/service/AdminDashboardService.java
```

### A10. PublisherController.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/controller/PublisherController.java
Đặt vào: src/main/java/com/gamestore/controller/PublisherController.java
```

### A11. PayoutService.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/service/PayoutService.java
Đặt vào: src/main/java/com/gamestore/service/PayoutService.java
```

### A12. KycController.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/controller/KycController.java
Đặt vào: src/main/java/com/gamestore/controller/KycController.java
```

### A13. KycService.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/service/KycService.java
Đặt vào: src/main/java/com/gamestore/service/KycService.java
```

### A14. KycRequestDAO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dao/KycRequestDAO.java
Đặt vào: src/main/java/com/gamestore/dao/KycRequestDAO.java
```

### A15. PayoutRequestDAO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dao/PayoutRequestDAO.java
Đặt vào: src/main/java/com/gamestore/dao/PayoutRequestDAO.java
```

### A16. CheckoutService.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/service/CheckoutService.java
Đặt vào: src/main/java/com/gamestore/service/CheckoutService.java
Lý do: Tách business logic khỏi controller
```

### A17. PendingRegisterDTO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dto/PendingRegisterDTO.java
Đặt vào: src/main/java/com/gamestore/dto/PendingRegisterDTO.java
```

### A18. PageResult.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dto/PageResult.java
Đặt vào: src/main/java/com/gamestore/dto/PageResult.java
```

### A19. WalletActionForm.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dto/WalletActionForm.java
Đặt vào: src/main/java/com/gamestore/dto/WalletActionForm.java
```

### A20. AdminStatsDTO.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/dto/AdminStatsDTO.java
Đặt vào: src/main/java/com/gamestore/dto/AdminStatsDTO.java
```

### A21. EmailService.java
```
Nguồn: colleague/main/src/main/java/com/gamestore/service/EmailService.java
Đặt vào: src/main/java/com/gamestore/service/EmailService.java
Lưu ý: Kiểm tra file cấu hình email (mail.properties)
```

---

## NHÓM B: GIỮ HOÀN TOÀN GAMEFORGE

### B1. RechargeController.java — QUAN TRỌNG
```
Vị trí: src/main/java/com/gamestore/controller/RechargeController.java
Lý do:
  - Neo-Brutalism UI với QR, confetti, bonus system
  - MoMo, ZaloPay, Bank, Card payment methods
  - 500k→+30k, 1M→+80k, 2M→+220k bonus
  - Đồng nghiệp KHÔNG có recharge UI → GIỮ NGUYÊN
Lưu ý: KHÔNG ghi đè bằng WalletController của đồng nghiệp
```

### B2. recharge.jsp
```
Vị trí: src/main/webapp/WEB-INF/views/recharge.jsp
Lý do: Neo-Brutalism UI đẹp, đồng nghiệp không có
```

### B3. recharge.js
```
Vị trí: src/main/webapp/assets/js/recharge.js
Lý do: QR generation, confetti, counter animation
```

### B4. recharge.css (nếu có)
```
Vị trí: src/main/webapp/assets/css/recharge.css
Lý do: Custom style cho recharge page
```

### B5. CheckoutController.java
```
Vị trí: src/main/java/com/gamestore/controller/CheckoutController.java
Lý do: 657 dòng, đã customize cho flow của bạn
       Có logic checkout đầy đủ
Lưu ý: Cần kiểm tra có dùng User entity cũ không
       → Nếu có, sau khi merge User entity, cần compile lại
```

### B6. GameController.java
```
Vị trí: src/main/java/com/gamestore/controller/GameController.java
Lý do: Game browsing, game detail đã implement
```

### B7. DashboardController.java
```
Vị trí: src/main/java/com/gamestore/controller/DashboardController.java
Lý do: Dashboard đã implement
Lưu ý: Đồng nghiệp có AdminController — KHÔNG ghi đè
```

### B8. LibraryController.java
```
Vị trí: src/main/java/com/gamestore/controller/LibraryController.java
Lý do: Library đã implement
```

### B9. AuthController.java — GIỮ NGUYÊN, CHỈ MERGE NHỎ
```
Vị trí: src/main/java/com/gamestore/controller/AuthController.java
Lý do GIỮ NGUYÊN:
  - Login hỗ trợ email HOẶC username (đồng nghiệp chỉ hỗ trợ email)
  - Register tạo account ngay lập tức + tạo wallet
  - Đã dùng PasswordEncoderUtil
  - Đã có session fixation fix (session.invalidate())
  - Đã có check trùng email + trùng username

CHỈ BỔ SUNG từ đồng nghiệp:
  1. Thêm method isBCryptHash() vào processLogin()
     → Nếu password cũ là plain text, auto-upgrade sang BCrypt
  2. Sau khi tạo account mới, gán ROLE_USER cho user đó

CHỈ COPY FILE MỚI:
  - verify-otp.jsp (OTP page — file mới, không conflict)
```

### B10. GlobalExceptionHandler.java
```
Vị trí: src/main/java/com/gamestore/exception/GlobalExceptionHandler.java
Lý do: Exception handling đã có
Lưu ý: Kiểm tra đồng nghiệp có GlobalExceptionHandler không
       → Nếu có, so sánh và giữ tốt hơn
```

### B10. Wallet entity
```
Vị trí: src/main/java/com/gamestore/entity/Wallet.java
Lý do:
  - Schema HOÀN TOÀN GIỐNG NHAU
  - GameForge dùng @OneToOne(fetch = FetchType.LAZY) → tốt hơn EAGER
  - Có tất cả getter/setter cần thiết
Lưu ý: KHÔNG lấy Wallet.java từ đồng nghiệp
```

### B11. WalletTransaction entity
```
Vị trí: src/main/java/com/gamestore/entity/WalletTransaction.java
Lý do:
  - Schema HOÀN TOÀN GIỐNG NHAU
  - GameForge có @PrePersist → đồng nghiệp cũng có
  - Giữ bản GameForge (không khác biệt)
Lưu ý: KHÔNG lấy từ đồng nghiệp
```

---

## NHÓM C: MERGE CẨN THẬN

### C1. User.java — ENTITY (QUAN TRỌNG NHẤT)

```
Bước thực hiện:

1. Đọc User.java hiện tại của GameForge
2. Đọc User.java của đồng nghiệp
3. Merge như sau:

GIỮ TỪ GAMEFORGE:
  - id (Long)
  - email (String)
  - password (String) — dù là plain text hay BCrypt
  - fullName (String)
  - avatar (String)
  - status (String)
  - createdAt (LocalDateTime)
  - username (String) — ĐỒNG NGHIỆP KHÔNG CÓ, GIỮ

THÊM TỪ ĐỒNG NGHIỆP:
  - Set<Role> roles — @ManyToMany với user_roles
  - @PrePersist — tự động set defaults
  - hasRole(String roleCode) method — CỰC KỲ QUAN TRỌNG

MERGE KẾT QUẢ (User.java mới):
```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    private String fullName;
    private String avatar;
    private String status;
    private LocalDateTime createdAt;
    private String username;  // ← GIỮ từ GameForge

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<Role>();

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (status == null) status = "ACTIVE";
        if (avatar == null) avatar = "default-avatar.png";
    }

    public boolean hasRole(String roleCode) {
        if (roles == null) return false;
        for (Role role : roles) {
            if (roleCode.equals(role.getCode())) return true;
        }
        return false;
    }

    // + tất cả getter/setter từ cả 2 file
}
```

Lưu ý:
  → Sau khi merge, test login bằng tài khoản cũ
  → BCrypt auto-upgrade trong AuthController sẽ tự động hash password cũ
  → Method hasRole() dùng trong AuthInterceptor
```

### C2. UserDAO.java

```
Cần kiểm tra đồng nghiệp có method nào khác không:
  → findByEmail(String email) ← CÓ, dùng cho login
  → Có thể có thêm findByUsername() nếu bạn cần

Bước:
1. Giữ UserDAO hiện tại
2. Thêm method findByEmail nếu chưa có
3. Thêm method findByRole nếu cần query user theo role
```

### C3. spring-servlet.xml — INTERCEPTOR CONFIG

```
Đây là file dễ conflict nhất.

Bước:
1. Đọc spring-servlet.xml hiện tại của GameForge
2. Đọc spring-servlet.xml của đồng nghiệp
3. Thêm interceptor mapping từ đồng nghiệp vào:

Interceptor mapping cần thêm:
  <mvc:interceptor>
      <mvc:mapping path="/admin/**"/>
      <mvc:exclude-mapping path="/login"/>
      <mvc:exclude-mapping path="/register"/>
      <bean class="com.gamestore.interceptor.AuthInterceptor"/>
  </mvc:interceptor>

  <mvc:interceptor>
      <mvc:mapping path="/publisher/**"/>
      <mvc:exclude-mapping path="/login"/>
      <bean class="com.gamestore.interceptor.AuthInterceptor"/>
  </mvc:interceptor>

Lưu ý:
  → Giữ nguyên interceptor hiện tại (nếu có)
  → Chỉ THÊM interceptor mới, KHÔNG ghi đè
```

### C4. OrderController.java

```
GameForge có thể có OrderController (kiểm tra src/)
Đồng nghiệp có OrderController.

Bước:
1. Kiểm tra GameForge có OrderController không
2. Nếu có: so sánh, giữ version tốt hơn hoặc merge
3. Nếu không: lấy từ đồng nghiệp
```

### C5. pom.xml — DEPENDENCY CHECK

```
Bước:
1. So sánh dependencies giữa 2 pom.xml
2. Lấy union của tất cả dependencies
3. Kiểm tra conflict version

Dependencies CẦN THÊM từ đồng nghiệp:
  → spring-security-crypto (BCryptPasswordEncoder)
  → javax.mail (EmailService)
  → Có thể có thêm validation API

Sau khi copy đồng nghiệp's AuthController, build sẽ fail nếu thiếu dependency
→ Thêm vào pom.xml
```

---

## THỨ TỰ THỰC HIỆN JAVA MERGE

```
Bước JAVA-1: Copy toàn bộ entity files từ đồng nghiệp vào thư mục temp
             → Không ghi đè, chỉ copy để so sánh

Bước JAVA-2: Merge User.java (CẨN THẬN NHẤT)
             → Giữ field GameForge + thêm hasRole() + roles

Bước JAVA-3: Copy Role.java
             → KHÔNG conflict

Bước JAVA-4: Copy WalletDAO.java, WalletTransactionDAO.java
             → Entity Wallet + WalletTransaction GIỮ NGUYÊN GameForge

Bước JAVA-5: Copy toàn bộ DAO files (RoleDAO, KycRequestDAO, PayoutRequestDAO)
             → KHÔNG conflict với GameForge

Bước JAVA-6: Copy toàn bộ Service files (WalletService, AdminDashboardService,
             PayoutService, KycService, CheckoutService, EmailService)
             → KHÔNG conflict (GameForge có EmailService, kiểm tra trùng)

Bước JAVA-7: Copy Controller files (Nhóm A)
             → Backup RechargeController + CheckoutController trước
             → Copy AuthController, AdminController, PublisherController,
               KycController
             → KHÔNG copy WalletController (vì RechargeController đã có)

Bước JAVA-8: Giữ nguyên RechargeController, CheckoutController,
             GameController, DashboardController, LibraryController (Nhóm B)

Bước JAVA-9: Copy DTO files

Bước JAVA-10: Copy AuthInterceptor vào interceptor/

Bước JAVA-11: Merge spring-servlet.xml (thêm interceptor config)

Bước JAVA-12: Kiểm tra pom.xml, thêm dependencies thiếu

Bước JAVA-13: Build project (mvn compile)
              → Fix lỗi nếu có

Bước JAVA-14: Test login với tài khoản cũ
```

---

## FILES CẦN COPY TỪ COLLEAGUE (DANH SÁCH ĐẦY ĐỦ)

```
src/main/java/com/gamestore/
├── controller/
│   ├── AuthController.java        ← A1
│   ├── AdminController.java       ← A8
│   ├── PublisherController.java   ← A10
│   ├── KycController.java        ← A12
│   └── OrderController.java       ← C4 (kiểm tra trùng trước)
├── entity/
│   └── Role.java                 ← A3
│   (Wallet.java, WalletTransaction.java → GIỮ GAMEFORGE)
├── dao/
│   ├── RoleDAO.java              ← A4
│   ├── WalletDAO.java            ← A6
│   ├── WalletTransactionDAO.java ← A7
│   ├── KycRequestDAO.java        ← A14
│   └── PayoutRequestDAO.java     ← A15
├── service/
│   ├── WalletService.java        ← A5
│   ├── AdminDashboardService.java ← A9
│   ├── PayoutService.java        ← A11
│   ├── KycService.java           ← A13
│   └── CheckoutService.java      ← A16
├── dto/
│   ├── PendingRegisterDTO.java   ← A17
│   ├── PageResult.java           ← A18
│   ├── WalletActionForm.java     ← A19
│   └── AdminStatsDTO.java       ← A20
└── interceptor/
    └── AuthInterceptor.java      ← A2
```

---

## LƯU Ý SAU KHI MERGE JAVA

1. **Build ngay sau khi copy** — `mvn compile` để check lỗi
2. **User entity là file dễ crash nhất** — nếu compile fail, 90% là User.java
3. **Interceptor** — sau khi copy AuthInterceptor, phải đăng ký trong spring-servlet.xml
4. **EmailService** — kiểm tra mail.properties có tồn tại không
5. **BCryptPasswordEncoder** — cần dependency spring-security-crypto trong pom.xml
6. **Wallet** — KHÔNG lấy entity từ đồng nghiệp, giữ nguyên bản GameForge
7. **RechargeController** — KHÔNG ghi đè, giữ nguyên GameForge
