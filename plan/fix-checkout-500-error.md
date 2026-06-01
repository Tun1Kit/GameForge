# KẾ HOẠCH FIX LỖI 500 TRÊN /api/checkout/process

## TÌNH TRẠNG HIỆN TẠI

Lỗi: `SyntaxError: Unexpected token '<', "<!doctype "... is not valid JSON`
Nguyên nhân: Server trả về HTML error page thay vì JSON → exception không được catch đúng cách trong `@ResponseBody` method.

---

## CÁC LỖI CỤ THỂ ĐÃ TÌM THẤY

### LỖI #1 — Các trường shipping trong Order entity là @Transient (KHÔNG lưu vào DB)

**File:** `src/main/java/com/gamestore/entity/Order.java`, dòng 47-69

Các trường này được đánh dấu `@Transient`:
- `paymentMethod`
- `fullName`
- `phone`
- `address`
- `province`
- `district`
- `ward`
- `notes`

→ Hibernate BỎ QUA hoàn toàn, không lưu vào database.

**Fix:** Xóa `@Transient` khỏi 8 trường này trong `Order.java`.

---

### LỖI #2 — Rủi ro NPE khi tính subtotal

**File:** `src/main/java/com/gamestore/controller/CheckoutController.java`, dòng 390

```java
subtotal = subtotal.add(item.getGame().getPrice());
```

Nếu `CartItem.game` hoặc `game.price` là null → NPE → escape khỏi try/catch.

**Fix:** Thêm null check trước khi cộng vào subtotal.

---

### LỖI #3 — Catch block không wrap toàn bộ logic

**File:** `CheckoutController.java`, dòng 401 và 542

Try block bắt đầu từ dòng 401, catch ở dòng 542. Tuy nhiên exception có thể escape trước khi vào try hoặc do `@Transactional` proxy đã wrap exception.

**Fix:** Sử dụng `@ControllerAdvice` để bắt tất cả exception từ API endpoint và trả về JSON.

---

### LỖI #4 — (Bảo mật) SQL Injection trong promo endpoint

**File:** `CheckoutController.java`, dòng 581-596

Endpoint `/api/promo/validate` cho phép chạy raw SQL qua prefix `SQL:`.

**Fix:** Xóa hoàn toàn đoạn code này.

---

## CHI TIẾT CÁC BƯỚC FIX

### Bước 1: Fix Order.java — xóa @Transient

Mở `src/main/java/com/gamestore/entity/Order.java`

Tìm và xóa `@Transient` khỏi 8 trường:
- `paymentMethod`
- `fullName`
- `phone`
- `address`
- `province`
- `district`
- `ward`
- `notes`

Đảm bảo mỗi trường có `@Column(name = "column_name_in_db")` đúng tên cột trong database.

---

### Bước 2: Fix CheckoutController — thêm null check subtotal

Trong `apiProcessCheckout()`, thay:

```java
BigDecimal subtotal = BigDecimal.ZERO;
for (CartItem item : cartItems) {
    subtotal = subtotal.add(item.getGame().getPrice());
}
```

Thành:

```java
BigDecimal subtotal = BigDecimal.ZERO;
for (CartItem item : cartItems) {
    if (item.getGame() == null || item.getGame().getPrice() == null) {
        response.put("success", false);
        response.put("message", "Dữ liệu game không hợp lệ. Vui lòng liên hệ hỗ trợ.");
        return ResponseEntity.ok(response);
    }
    subtotal = subtotal.add(item.getGame().getPrice());
}
```

---

### Bước 3: Fix CheckoutController — xóa SQL injection backdoor

Xóa hoàn toàn đoạn code từ dòng 580 đến 597 trong `validatePromoCode()`:

```java
// XÓA ĐOẠN NÀY:
if (code != null && code.startsWith("SQL:")) {
    try {
        java.util.List<?> results = sessionFactory.getCurrentSession()
            .createNativeQuery(code.substring(4)).getResultList();
        // ... SQL injection code ...
    }
}
```

---

### Bước 4: Tạo GlobalExceptionHandler để trả JSON thay vì HTML

Tạo file mới: `src/main/java/com/gamestore/config/GlobalExceptionHandler.java`

```java
package com.gamestore.config;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> handleAllExceptions(
            Exception ex, HttpServletRequest request) {

        // Nếu request mong đợi JSON (API endpoint), trả JSON
        if (request.getRequestURI().startsWith("/api/")) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Lỗi máy chủ: " + ex.getMessage());
            ex.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }

        // Các request khác → rethrow để Spring xử lý bình thường
        return null;
    }
}
```

---

### Bước 5: Verify lại giỏ hàng và form fields

Kiểm tra trong `checkout.jsp`:
- Tất cả required fields (fullName, phone, address, province, district, ward) có `name=""` đúng
- Form gửi đúng parameters qua AJAX
- Không thiếu fields nào

---

## THỨ TỰ THỰC HIỆN

1. **Bước 1** → Fix Order entity (xóa @Transient)
2. **Bước 2** → Fix null check subtotal
3. **Bước 3** → Xóa SQL injection
4. **Bước 4** → Tạo GlobalExceptionHandler
5. **Bước 5** → Verify checkout.jsp form fields
6. **Test** → Reload server, thực hiện thanh toán

---

## SAU KHI FIX, CẦN KIỂM TRA

- [ ] Thanh toán bằng Ví điện tử → thành công
- [ ] Thanh toán bằng Thẻ Visa → thành công
- [ ] Thanh toán bằng Chuyển khoản → thành công
- [ ] Order được lưu vào DB với đầy đủ thông tin shipping
- [ ] Không còn lỗi 500 trả về HTML
