# PLAN: SỬA LỖI "Could not obtain transaction-synchronized Session" - AuthController

**Ngày:** 2026-05-28
**Lỗi:** HTTP 500 — `HibernateException: Could not obtain transaction-synchronized Session for current thread`
**Xảy ra khi:** Đăng ký tài khoản mới → `processRegister` → `userDAO.save()`
**Root Cause:** `AuthController` không có `@Transactional` annotation

---

## 1. NGUYÊN NHÂN GỐC RỄ

### Exception stack trace

```
com.gamestore.dao.BaseDAO.save(BaseDAO.java:29)
com.gamestore.controller.AuthController.processRegister(AuthController.java:81)
```

### Giải thích

`BaseDAO.save()` gọi:
```java
sessionFactory.getCurrentSession().save(entity);  // Dòng 29
```

`getCurrentSession()` yêu cầu có **transaction đang active** trong thread hiện tại. Spring quản lý transaction bằng cách bind Session vào ThreadLocal — nhưng chỉ khi có `@Transactional`.

`CheckoutController` có `@Transactional` ở class level → hoạt động tốt.
`AuthController` **KHÔNG có** `@Transactional` → khi gọi `userDAO.save()` → không có session → crash.

---

## 2. SƠ ĐỒ VẤN ĐỀ

```
AUTHENTICATED REQUEST
        │
        ▼
AuthController.processRegister()
        │
        ▼
userDAO.save(newUser)        ← GỌI
        │
        ▼
BaseDAO.save()               ← GỌI
        │
        ▼
sessionFactory.getCurrentSession()  ← LỖI: KHÔNG CÓ SESSION
        │
        ▼
❌ HibernateException: Could not obtain transaction-synchronized Session
```

```
SỬA RỒI
        │
        ▼
AuthController (@Transactional)     ← THÊM ANNOTATION
        │
        ▼
Spring tạo Transaction + bind Session vào ThreadLocal
        │
        ▼
userDAO.save(newUser)
        │
        ▼
sessionFactory.getCurrentSession()  ← ✅ CÓ SESSION rồi
        │
        ▼
✅ INSERT thành công
```

---

## 3. CÁCH SỬA

### Sửa 1 dòng duy nhất

Thêm `@Transactional` vào class `AuthController`.

**File:** `src/main/java/com/gamestore/controller/AuthController.java`

```java
// ===== TRƯỚC =====
@Controller
public class AuthController {

// ===== SAU =====
@Controller
@Transactional                          // ← THÊM DÒNG NÀY
public class AuthController {
```

---

## 4. GIẢI THÍCH @Transactional TRONG SPRING

### Nó làm gì?

`@Transactional` là annotation của Spring, đánh dấu method/class cần chạy trong transaction.

```
Khi request đến method có @Transactional:
  1. Spring tạo transaction mới
  2. Spring bind Hibernate Session vào ThreadLocal
  3. Method chạy → mọi getCurrentSession() đều lấy được Session
  4. Method thành công → Spring COMMIT
  5. Method có exception → Spring ROLLBACK
```

### Nếu không có @Transactional?

```
Request đến method không có @Transactional:
  1. Không có transaction
  2. ThreadLocal không có Session
  3. getCurrentSession() gọi → ❌ Lỗi
```

### @Transactional ở đâu?

| Vị trí | Hiệu lực |
|---------|-----------|
| `@Transactional` trên **method** | Chỉ method đó có transaction |
| `@Transactional` trên **class** | Tất cả method trong class có transaction |
| `BaseDAO` có `@Transactional` | Tất cả DAO class kế thừa có transaction |

### Quan sát project

```java
// CheckoutController.java — CÓ @Transactional (hoạt động)
@Controller
@Transactional                    // ✅ Có rồi
public class CheckoutController { }

// AuthController.java — KHÔNG CÓ @Transactional (LỖI)
@Controller
public class AuthController { }  // ❌ Thiếu

// UserDAO.java — CÓ @Transactional (nhưng không đủ)
@Repository
@Transactional                    // ✅ Có
public class UserDAO extends BaseDAO<T> { }
```

**Tại sao `UserDAO` có `@Transactional` mà vẫn lỗi?**

`@Transactional` trên DAO không hoạt động khi controller gọi thẳng `sessionFactory.getCurrentSession()` trong `BaseDAO` — vì transaction chỉ hoạt động khi call chain đi qua proxy của Spring. Khi code gọi `userDAO.save()`, Spring proxy bắt đầu transaction từ đó, nhưng `BaseDAO.save()` gọi `getCurrentSession()` **trước** khi proxy wrap kịp.

Thực tế, cách an toàn nhất là để `@Transactional` ở **Controller** — nơi bắt đầu request — để toàn bộ call chain (Controller → DAO → Session) đều trong cùng 1 transaction.

---

## 5. CÁC TRƯỜNG HỢP KHÁC CẦN CHÚ Ý

### Khi nào cần @Transactional?

| Trường hợp | Cần @Transactional? |
|-------------|---------------------|
| Controller gọi DAO (qua Spring proxy) | ✅ Cần |
| DAO gọi `sessionFactory.getCurrentSession()` | ✅ Cần |
| Dùng `@Transactional` ở DAO mà controller gọi trực tiếp `sessionFactory` | ❌ Không đủ |
| Method chỉ đọc dữ liệu (SELECT) | Nên có (để đọc trong transaction) |
| Method không dùng Hibernate/Session | Không cần |

### Nếu muốn read-only transaction

```java
@Transactional(readOnly = true)  // Tối ưu hiệu năng
public List<User> getAllUsers() { ... }
```

### Rủi ro @Transactional ở class level

```java
@Controller
@Transactional                            // Áp dụng cho TẤT CẢ method
public class AuthController {
    @GetMapping("/login")
    public String showLogin() {           // ⚠️ Method này cũng có transaction
        return "login";                   // Lãng phí (nhưng không gây lỗi)
    }
}
```

**Giải pháp:** Chỉ đánh `@Transactional` ở method cần thao tác DB.

---

## 6. CÁC BƯỚC THỰC HIỆN

```
Bước 1: Mở AuthController.java
Bước 2: Thêm @Transactional vào trước class AuthController
Bước 3: Build lại project
Bước 4: Test đăng ký → Xem kết quả
```

### Trước

```java
@Controller
public class AuthController {
```

### Sau

```java
@Controller
@Transactional
public class AuthController {
```

---

## 7. MỞ RỘNG: VẤN ĐỀ TƯƠNG TỰ TRONG PROJECT

Kiểm tra tất cả Controller xem có thiếu `@Transactional` không:

| Controller | @Transactional | Trạng thái |
|-------------|-----------------|------------|
| `CheckoutController` | ✅ Có (class level) | OK |
| `AuthController` | ❌ Không | CẦN SỬA |

---

*Plan được tạo ngày 2026-05-28 bởi AI Coding Assistant*
