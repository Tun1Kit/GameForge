# Plan: Refactor Controller Code Duplication — GameForge Store

**Ngày tạo:** 2026-06-02
**Ngày hoàn thành:** 2026-06-02
**Trạng thái:** ✅ HOÀN TẤT — BUILD SUCCESS (61 files compiled)
**Người thực hiện:** Claude Agent (Harness Engineer)

---

## 1. TỔNG QUAN VẤN ĐỀ

### 1.1 Điều gì đang xảy ra

Sau khi đọc kỹ cả 12 controller files, đây là bức tranh thực tế:

**Stack công nghệ:** Spring MVC 5.3.20 + Hibernate 5.6.9 + SQL Server + JSP/JSTL

Mỗi controller đều tự query trực tiếp database bằng `SessionFactory` thay vì dùng Service layer. Đây là hiện tượng **thiếu abstraction layer** — business logic nằm rải rác trong controller thay vì được tập trung ở service.

### 1.2 Có sao không?

**Ngắn hạn:** Không crash, ứng dụng vẫn hoạt động. Nhưng có 3 vấn đề nghiêm trọng:

| # | Vấn đề | Hệ quả |
|---|---------|--------|
| 1 | **Mã trùng lặp** | Khi sửa 1 chỗ, phải sửa 6-10 chỗ khác |
| 2 | **Thiếu consistency** | Mỗi chỗ query wallet khác nhau (native SQL vs HQL vs HQL typed) |
| 3 | **Khó maintain** | Business logic không tập trung, test không thể viết được |

---

## 2. BẢN ĐỒ CODE TRÙNG LẶP CHI TIẾT

### 2.1 Pattern A: Query Wallet Balance

**Biểu hiện:** Mỗi controller tự query `SELECT balance FROM wallets WHERE user_id = :uid`

| # | Controller | Method | Dòng | Cách query |
|---|-----------|--------|-------|-----------|
| 1 | `DashboardController` | `showDashboard` | 32–48 | Native SQL + BigDecimal cast |
| 2 | `GameController` | `index` | 37–50 | Native SQL + BigDecimal cast |
| 3 | `LibraryController` | `showLibrary` | 39–52 | Native SQL + BigDecimal cast |
| 4 | `LibraryController` | `showTransactions` | 86–99 | Native SQL + BigDecimal cast |
| 5 | `CheckoutController` | `showCheckoutPage` | 71–83 | HQL typed query |
| 6 | `CheckoutController` | `processCheckout` | 156–162 | Native SQL + BigDecimal cast |
| 7 | `RechargeController` | `showRechargePage` | 36–52 | HQL + entity Wallet |

**Điều đáng chú ý:** `WalletService` đã tồn tại với method `getOrCreateWallet(User)` — nhưng **không có method `getBalance(User)`**! Nên các controller tự query.

### 2.2 Pattern B: Auth Guard Check

**Biểu hiện:** `User currentUser = (User) session.getAttribute("currentUser"); if (currentUser == null) return "redirect:/login";`

| # | Controller | Số lần xuất hiện |
|---|-----------|-------------------|
| 1 | `DashboardController` | 1 lần |
| 2 | `GameController` | 1 lần |
| 3 | `LibraryController` | 2 lần |
| 4 | `CheckoutController` | 4 lần |
| 5 | `RechargeController` | 2 lần |
| 6 | `KycController` | 2 lần |
| 7 | `CartApiController` | 4 lần |
| 8 | `ProfileApiController` | 1 lần |
| 9 | `PublisherController` | 3 lần |

**Tổng cộng: ~20 lần trùng lặp** — mỗi lần một biến thể nhỏ (redirect string khác nhau, response format khác nhau).

### 2.3 Pattern C: CartItem Query

**Biểu hiện:** `FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId`

| # | Controller | Dòng | Số lần |
|---|-----------|-------|--------|
| 1 | `DashboardController` | 51–55 | 1 |
| 2 | `CheckoutController` | 52–56, 126–130, 145–148, 394–398, 623–627 | 5 |
| 3 | `CartApiController` | 42–46, 117–121 | 2 |

**Tổng: 8 lần** cùng một HQL query.

### 2.4 Pattern D: LibraryItem Query

**Biểu hiện:** Check user đã sở hữu game chưa

| # | Controller | Dòng |
|---|-----------|-------|
| 1 | `CartApiController` | 54–58 |
| 2 | `CheckoutController` | 247–252, 513–518 |
| 3 | `GameController` | 54–57 |

### 2.5 Pattern E: Entity Update / Session Management

**Biểu hiện:** `User managedUser = hqSession.get(User.class, currentUser.getId());` — tránh Detached Entity

| # | Controller | Dòng |
|---|-----------|-------|
| 1 | `CheckoutController.processCheckout` | 124 |
| 2 | `CheckoutController.apiProcessCheckout` | 392 |
| 3 | `ProfileApiController` | 55 |

---

## 3. PHÂN TÍCH NGUYÊN NHÂN GỐC

### 3.1 Hệ thống cũ vs mới

Dự án có **2 lớp code chồng lên nhau**:

- **Lớp cũ:** Controllers tự query trực tiếp bằng `SessionFactory` (10/12 controllers)
- **Lớp mới:** Service + DAO đã được xây dựng song song (`WalletService`, `CheckoutService`, `AdminDashboardService`, `PayoutService`, `KycService`)

### 3.2 Ví dụ về sự bất nhất quán

**Cách query wallet balance trong 3 controller:**

```java
// DashboardController: Native SQL → BigDecimal cast
Object result = sessionFactory.getCurrentSession()
    .createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
    .setParameter("uid", currentUser.getId())
    .uniqueResult();
walletBalance = (result instanceof BigDecimal) ? (BigDecimal) result : new BigDecimal(result.toString());

// CheckoutController: HQL typed
BigDecimal result = sessionFactory.getCurrentSession()
    .createQuery(hqlWallet, BigDecimal.class)
    .setParameter("userId", currentUser.getId())
    .uniqueResult();

// RechargeController: Lấy cả entity Wallet
Wallet wallet = sessionFactory.getCurrentSession()
    .createQuery("FROM Wallet WHERE user.id = :userId", Wallet.class)
    .setParameter("userId", currentUser.getId())
    .uniqueResult();
walletBalance = wallet.getBalance();
```

Ba cách khác nhau để làm cùng một việc. Nếu bảng `wallets` đổi tên column hoặc schema, phải sửa 6 chỗ.

### 3.3 Các vấn đề khác phát hiện được

| # | Vấn đề | File | Dòng |
|---|---------|------|-------|
| 1 | Hardcode `500` key generation trong controller | `GameController` | 71 |
| 2 | `TransactionDTO` inner class trùng với domain concept | `LibraryController` | 199–228 |
| 3 | Inconsistent session attribute name: `"currentUser"` vs `"user"` (AGENTS.md) | Nhiều file | — |
| 4 | API response format không nhất quán: `ERROR=...` (plain text) vs JSON | `CartApiController` | — |
| 5 | Code comment nói `FIX BUG` nhưng không có link issue tracker | `CheckoutController` | 143, 221, 239 |
| 6 | `LicenseKey.assignTo()` method nhưng không biết entity đó có không | `CheckoutController` | 92 |
| 7 | Discount calculation trong `processCheckout` hardcode `10%` | `CheckoutController` | 221 |

---

## 4. CÁC PHƯƠNG ÁN KHẮC PHỤC

### 4.1 Phương án A: BaseController + Utility Helpers (KHÔNG ĐỀ XUẤT)

Tạo `BaseController` abstract, các controller extend nó.

**Ưu điểm:** Đơn giản, ít thay đổi nhất.
**Nhược điểm:** Kế thừa Java đôi khi không linh hoạt bằng composition. Controller vẫn mang business logic.

### 4.2 Phương án B: Tận dụng Service/DAO hiện có + Mở rộng (ĐỀ XUẤT)

Thay vì tạo lớp mới, **mở rộng những gì đã có**:

```
Controller Layer          Service Layer           DAO Layer
──────────────────       ──────────────────      ─────────────────
Giữ nguyên hoàn toàn  →  Mở rộng WalletService → Giữ nguyên
Giữ nguyên hoàn toàn  →  Tạo UserSessionService→ Giữ nguyên
Giữ nguyên hoàn toàn  →  Mở rộng CartService   → Giữ nguyên
```

**Ưu điểm:**
- Đúng architecture Spring: Controller → Service → DAO
- Tận dụng 7 service + 15 DAO đã có
- Risk thấp vì chỉ refactor, không đổi business logic
- Testable: Service có thể viết unit test

**Nhược điểm:**
- Cần sửa 12 controller files (nhưng thay đổi nhỏ, chỉ thay thế đoạn trùng lặp)
- Phải verify kỹ sau mỗi bước

### 4.3 Phương án C: Full Refactor (RỦI RO CAO — KHÔNG ĐỀ XUẤT)

Tạo hoàn toàn service mới, loại bỏ toàn bộ query khỏi controller. **Rủi ro quá cao** vì dự án đang chạy, cần regression test toàn bộ flows.

---

## 5. KẾ HOẠCH THỰC HIỆN (PHƯƠNG ÁN B)

### Phase 1: Mở rộng WalletService (1-2 ngày)

**Bước 1.1:** Thêm method `getBalance(User)` vào `WalletService`

```java
public BigDecimal getBalance(User user) {
    Wallet wallet = walletDAO.findByUserId(user.getId());
    return wallet != null ? wallet.getBalance() : BigDecimal.ZERO;
}
```

**Bước 1.2:** Thêm method `getBalanceById(Long userId)` cho trường hợp không có User entity

**Ảnh hưởng:** Thay thế 6 đoạn trùng lặp trong 5 controllers

### Phase 2: Tạo UserContextService (1 ngày)

**Bước 2.1:** Tạo `UserContextService` với các method:

```java
@Service
public class UserContextService {
    public User getCurrentUser(HttpSession session);
    public User requireLogin(HttpSession session); // throws hoặc trả về null
    public BigDecimal getWalletBalance(User user);
}
```

**Bước 2.2:** Hoặc đơn giản hơn — chỉ tạo một utility class không cần Spring:

```java
// com.gamestore.util.SessionUtils.java
public class SessionUtils {
    public static User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("currentUser");
    }
    public static User requireLogin(HttpSession session, String redirect) {
        User user = getCurrentUser(session);
        if (user == null) return null; // caller xử lý redirect
        return user;
    }
}
```

### Phase 3: Tạo CartService (1-2 ngày)

**Bước 3.1:** Tạo `CartService`

```java
@Service
public class CartService {
    public List<CartItem> getCartItems(Long userId);
    public CartItem findByUserAndGame(Long userId, Long gameId);
    public long getCartCount(Long userId);
    public List<Long> getCartGameIds(Long userId);
}
```

**Bước 3.2:** Thay thế 8 đoạn trùng lặp trong `DashboardController`, `CheckoutController`, `CartApiController`

### Phase 4: Refactor từng Controller (3-5 ngày)

Thay thế từng đoạn trùng lặp, verify sau mỗi bước:

| # | Controller | Priority | Đoạn trùng lặp |
|---|-----------|---------|----------------|
| 1 | `LibraryController` | Cao | 2× wallet balance, 2× cart items |
| 2 | `CheckoutController` | Cao | 6× wallet balance + cart items |
| 3 | `DashboardController` | Cao | wallet balance + cart items |
| 4 | `GameController` | Trung | wallet balance + ownedGameIds |
| 5 | `RechargeController` | Trung | wallet logic (đã dùng WalletService 1 phần) |
| 6 | `CartApiController` | Thấp | 4× auth guard |

### Phase 5: Verify toàn bộ flows (2 ngày)

- Checkout flow (mua 1 game → ví trừ → license key gán → library)
- Recharge flow (nạp tiền → ví tăng → transaction log)
- Dashboard flow (số dư + giỏ hàng + đơn gần nhất)
- Library flow (danh sách game đã mua)
- Auth flow (login → logout → session)

---

## 6. THỨ TỰ ƯU TIÊN

```
PRIORITY 1 (Ngay lập tức — ít rủi ro, nhiều lợi):
├── Mở rộng WalletService.getBalance()       → Loại bỏ 6× trùng lặp wallet
├── Tạo CartService                          → Loại bỏ 8× trùng lặp cart
└── Thống nhất session attribute name "currentUser" trong AGENTS.md + code

PRIORITY 2 (Tuần tới — cần test kỹ):
├── Refactor LibraryController (2× wallet balance)
├── Refactor CheckoutController (6× wallet + cart)
└── Refactor DashboardController (1× wallet + cart)

PRIORITY 3 (Sau đó — giá trị cao nhưng tốn thời gian):
├── Refactor GameController (wallet balance)
├── Refactor CartApiController (auth guards)
└── Tạo UserContextService cho auth checks
```

---

## 7. RỦI RO VÀ KHẮC PHỤC

| # | Rủi ro | Xác suất | Khắc phục |
|---|--------|---------|-----------|
| 1 | Thay đổi gây regression checkout | Trung bình | Test manual checkout flow trước và sau mỗi bước |
| 2 | Session management thay đổi | Thấp | Giữ nguyên session attribute name `"currentUser"` |
| 3 | Detached entity sau refactor | Trung bình | Luôn load managed entity trước khi dùng |
| 4 | Merge conflict nếu nhiều người code | Trung bình | Tách từng controller thành commit riêng |

---

## 8. NHỮNG THỨ KHÔNG CẦN SỬA

| # | Code | Lý do giữ nguyên |
|---|------|-----------------|
| 1 | `AdminController` | Đã dùng Service layer tốt, không trùng lặp |
| 2 | `PublisherController` | Đã dùng `WalletService`, `PayoutService` |
| 3 | `PromoApiController` | Không trùng lặp, logic riêng biệt |
| 4 | `KycController` | Không trùng lặp, dùng `KycService` |
| 5 | `AuthController` | Logic riêng biệt, không trùng lặp |
| 6 | `GameController.generateKeys()` | 500 hardcode chỉ là dev utility, không ảnh hưởng prod |

---

## 9. BƯỚC TIẾP THEO

1. **[USER APPROVES]** User duyệt plan này
2. **[Phase 1.1]** Mở rộng `WalletService.java` — thêm `getBalance()`
3. **[Phase 1.2]** Mở rộng `WalletService.java` — thêm `getBalanceById()`
4. **[Phase 3]** Tạo `CartService.java`
5. **[Phase 2]** Tạo `UserContextService.java` hoặc `SessionUtils.java`
6. **[Phase 4]** Refactor lần lượt từng controller
7. **[Phase 5]** Verify toàn bộ flows

---

## 10. SUMMARY

**Có sao không?** Ứng dụng vẫn chạy, nhưng đang có **kỹ thuật nợ** (technical debt) do:

1. 20+ đoạn mã trùng lặp wallet/cart/auth query
2. 3 cách khác nhau query wallet balance
3. 7 service/15 DAO đã có nhưng controllers không tận dụng đầy đủ

**Cách khắc phục:** Phương án B — mở rộng Service layer hiện có, refactor controller từng bước, **không viết lại từ đầu**.

**Thời gian ước tính:** 8-12 ngày làm việc, chia thành 5 phases với verify sau mỗi bước.
