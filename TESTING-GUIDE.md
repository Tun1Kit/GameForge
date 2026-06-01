# GameForge — Hướng Dẫn Test

> Cập nhật: 2026-06-01 | Project: GameForge (Spring MVC + Hibernate + SQL Server)

---

## 1. Chuẩn Bị Môi Trường

### 1.1 Kiểm tra services đang chạy

```powershell
# PowerShell
Get-Service -Name "*SQL*"        # SQL Server đang chạy?
Get-Service -Name "*Tomcat*"     # Tomcat đang chạy?
Get-NetTCPConnection -LocalPort 8080  # Port 8080 đang listen?
```

### 1.2 Database connection

```powershell
sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -Q "SELECT 1"
```

### 1.3 Build & Deploy

```powershell
cd D:\Eclipse\GameStore
mvn clean package -DskipTests

# Copy WAR
Copy-Item "target\gamestore.war" "$env:CATALINA_HOME\webapps\"

# Restart Tomcat
& "$env:CATALINA_HOME\bin\shutdown.bat"
Start-Sleep 3
& "$env:CATALINA_HOME\bin\startup.bat"
```

### 1.4 Verify app boot

```powershell
Invoke-WebRequest -Uri "http://localhost:8080/gamestore/" -TimeoutSec 10
# Mong đợi: HTTP 200
```

---

## 2. Test Flow — Người Dùng Thường

### 2.1 Đăng ký + OTP

1. Truy cập `http://localhost:8080/gamestore/login`
2. Click **"Đăng ký"**
3. Điền: username, email, password, fullName
4. Click **"Đăng ký"**
5. **OTP sẽ in ra console Tomcat** (email disabled trong dev):

```
[Email] Sending OTP 123456 to user@email.com
```

6. Nhập OTP vào form → **Đăng ký thành công** → redirect `/dashboard`
7. **Kiểm tra:** Wallet tự tạo với balance = 0

### 2.2 Đăng nhập

1. Truy cập `/login`
2. Đăng nhập bằng username/password vừa đăng ký
3. **Kiểm tra:** Redirect về `/dashboard`, hiển thị username + wallet balance

### 2.3 Mua game (Checkout flow)

**Điều kiện:** Ví có đủ tiền. Cần test recharge trước (xem 2.3b).

1. Truy cập `/` → Trang chủ game
2. Click **"Thêm vào giỏ"** trên 1 game chưa sở hữu
3. Icon giỏ hàng trên navbar hiển thị số
4. Click giỏ hàng → `/checkout`
5. **Kiểm tra:** Game hiển thị trong giỏ, giá đúng
6. (Tùy chọn) Nhập **Promo Code** → click Áp dụng
7. Click **"Thanh toán"**
8. **Kiểm tra sau checkout:**
   - Redirect `/checkout/success`
   - Balance wallet trừ đúng
   - Game xuất hiện trong `/library`
   - Giỏ hàng trống
   - Order mới trong `/transactions`

### 2.3b Nạp tiền (Recharge)

1. Truy cập `/recharge`
2. Chọn mức nạp (VD: 500.000đ)
3. **Kiểm tra bonus:**
   - 500.000đ → nhận 530.000đ (+6%)
   - 1.000.000đ → nhận 1.080.000đ (+8%)
   - 2.000.000đ → nhận 2.220.000đ (+11%)
4. Nhập Transaction ID (tùy ý)
5. Click **"Nạp tiền"**
6. **Kiểm tra:** Balance tăng đúng, Transaction mới trong `/transactions`

### 2.4 Thư viện game

1. Truy cập `/library`
2. **Kiểm tra:**
   - Game đã mua hiển thị với thumbnail, tên, giá gốc
   - License key hiển thị (nếu có)
   - Badge "Đã sở hữu" cho game đã mua
   - Nút "Thêm vào giỏ" bị disabled cho game đã sở hữu

### 2.5 Lịch sử giao dịch

1. Truy cập `/transactions`
2. **Kiểm tra:**
   - Mỗi giao dịch hiển thị: mã GD, số tiền (+/-), loại, thời gian
   - Running balance cuối cùng khớp với wallet balance
   - Phân biệt rõ: DEPOSIT (+), ORDER (-), RECHARGE (+)

---

## 3. Test Flow — Admin

**Điều kiện:** Login bằng tài khoản có `ROLE_ADMIN`.

### 3.1 Admin Dashboard

1. Truy cập `/admin`
2. **Kiểm tra:**
   - 4 stats cards: Tổng users, games, orders, revenue
   - 4 secondary stats: KYC pending, Payout pending, Orders today, Publishers
   - Quick actions: Quản lý người dùng, Duyệt KYC, Cài đặt

### 3.2 Khóa / Mở khóa người dùng

1. Truy cập `/admin/users`
2. Tìm user bất kỳ
3. Click **"Khóa"** → Xác nhận
4. **Kiểm tra:**
   - Badge trạng thái đổi sang LOCKED
   - Nút đổi thành **"Mở khóa"**
5. Click **"Mở khóa"**
6. **Kiểm tra:** Badge về ACTIVE, nút về **"Khóa"**

### 3.3 Duyệt KYC

1. Truy cập `/admin/kyc` (cần có user đã submit KYC)
2. **Kiểm tra tab filter:** PENDING / APPROVED / REJECTED
3. Click **"Duyệt"** trên 1 request
4. **Kiểm tra:**
   - Badge đổi sang APPROVED
   - Nút hành động biến mất, thay bằng badge "Đã duyệt"
5. Click **"Từ chối"** trên 1 request khác
6. **Kiểm tra:** Modal hiện lên, yêu cầu nhập lý do, nếu bỏ trống → cảnh báo

### 3.4 Duyệt Payout

1. Truy cập `/admin/payouts` (cần có publisher đã request payout)
2. Click **"Duyệt"** trên 1 request
3. **Kiểm tra:**
   - Badge đổi sang APPROVED
   - Số tiền trong wallet publisher được trừ
4. Click **"Từ chối"** trên 1 request
5. **Kiểm tra:** Modal yêu cầu ghi chú, badge đổi sang REJECTED

### 3.5 Cài đặt hệ thống

1. Truy cập `/admin/settings`
2. Thay đổi **Phí hoa hồng nền tảng** (VD: 15 → 20)
3. Click **"Lưu phí hoa hồng"**
4. **Kiểm tra:** Thông báo thành công, trang reload, giá trị mới hiển thị

---

## 4. Test Flow — Publisher

**Điều kiện:** User đã được approve KYC + có `ROLE_PUBLISHER`.

### 4.1 Publisher Dashboard

1. Truy cập `/publisher`
2. **Kiểm tra:**
   - Stats: Số dư ví, Tổng doanh thu, Số game đã đăng, Payout đang chờ
   - Bảng giao dịch gần đây
   - Quick actions: Yêu cầu Payout, Nạp KYC, Đăng game mới

### 4.2 Yêu cầu rút tiền (Payout)

1. Truy cập `/publisher/payouts`
2. **Kiểm tra stats:** Số dư khả dụng hiển thị đúng
3. Nhập số tiền muốn rút (VD: 100.000)
4. Click **"Gửi yêu cầu"**
5. **Kiểm tra:**
   - Redirect về cùng trang
   - Yêu cầu mới xuất hiện trong bảng với badge PENDING
   - Số dư "Đang chờ" tăng
6. **Test validation:**
   - Nhập số tiền < 10.000 → Cảnh báo "Tối thiểu 10.000đ"
   - Nhập số tiền > số dư khả dụng → Cảnh báo

---

## 5. Test Flow — KYC

**Điều kiện:** User thường (chưa có ROLE_PUBLISHER).

### 5.1 Submit KYC

1. Truy cập `/kyc`
2. **Kiểm tra:** Badge trạng thái "CHƯA NẠP"
3. Chọn loại giấy tờ (CCCD / Hộ chiếu / Bằng lái)
4. Nhập số giấy tờ + họ và tên
5. (Tùy chọn) Upload ảnh mặt trước / mặt sau
6. Click **"Gửi hồ sơ KYC"**
7. **Kiểm tra:**
   - Badge trạng thái đổi sang **PENDING**
   - Thông báo "KYC đang chờ duyệt"
   - Form bị ẩn đi
8. **Test validation:**
   - Bỏ trống số giấy tờ → Cảnh báo
   - Bỏ trống họ tên → Cảnh báo
   - Không chọn loại giấy tờ → Cảnh báo

### 5.2 Sau khi Admin duyệt

1. Admin approve KYC (xem 3.3)
2. User refresh trang `/kyc`
3. **Kiểm tra:**
   - Badge trạng thái **APPROVED**
   - Navbar: Xuất hiện link "Dashboard Nhà phát hành"
   - User có thể truy cập `/publisher`

---

## 6. Test Edge Cases

### 6.1 Checkout không đủ tiền

1. Ví có 50.000đ
2. Thêm game giá 100.000đ vào giỏ
3. Checkout → **Phải báo lỗi** "Số dư không đủ"

### 6.2 Mua game đã sở hữu

1. Game đã có trong library
2. Thử thêm game đó vào giỏ → Nên được block hoặc hiển thị badge "Đã sở hữu"

### 6.3 Promo code hết hạn / hết lượt

1. Nhập promo code đã hết hạn → Message lỗi
2. Nhập promo code đã đạt max usage → Message lỗi

### 6.4 Self-lock protection

1. Admin đang login → Thử khóa chính tài khoản mình
2. **Phải báo lỗi** "Không thể khóa tài khoản của bạn"

### 6.5 Payout vượt số dư

1. Số dư khả dụng: 500.000đ
2. Request payout: 1.000.000đ
3. **Phải báo lỗi** tương ứng

### 6.6 Refresh trang checkout

1. Submit checkout → Redirect `/checkout/success?orderId=X`
2. F5 refresh → **Không tạo order mới** (PRG pattern)

---

## 7. Test Dark / Light Mode

1. Toggle theme trên navbar (biểu tượng mặt trăng/mặt trời)
2. **Kiểm tra:** Toàn bộ trang đổi theme, preference lưu vào localStorage
3. Test trên cả: `/`, `/dashboard`, `/library`, `/checkout`

---

## 8. Checklist Trước Khi Merge

```
□ Build không lỗi:     mvn clean package -DskipTests
□ App boot được:       http://localhost:8080/gamestore/ → HTTP 200
□ Đăng ký + OTP:       User mới tạo, wallet balance = 0
□ Login/Logout:        Session hoạt động đúng
□ Checkout:            Order tạo, wallet trừ, library có game
□ Recharge:            Wallet cộng đúng bonus
□ Admin lock/unlock:  Trạng thái user đổi trong DB
□ Admin KYC approve:  User lên ROLE_PUBLISHER
□ Admin payout:        Publisher wallet trừ khi approved
□ Publisher payout:    Tạo request, min 10.000đ
□ KYC submit:         Status chuyển PENDING
□ Dark mode toggle:    Hoạt động trên tất cả trang
□ Không lỗi JavaScript console
□ Không lỗi 500 trên mọi route
```
