# MERGE-04: FINAL MIGRATION + VERIFICATION

## TỔNG HỢP MIGRATION SCRIPTS

Sau khi hoàn thành MERGE-01, MERGE-02, MERGE-03, chạy các bước cuối cùng để hoàn tất merge.

---

## MIGRATION SCRIPTS

### Script 1: migrate-create-user-roles.sql
```
Mục đích: Tạo bảng user_roles (GameForge không có, đồng nghiệp có)
Lưu vào: D:\Eclipse\GameStore\plan\migrate-create-user-roles.sql
```

### Script 2: migrate-add-unique-constraints.sql
```
Mục đích: Thêm UNIQUE constraints (lấy từ đồng nghiệp)
Lưu vào: D:\Eclipse\GameStore\plan\migrate-add-unique-constraints.sql
```

### Script 3: migrate-seed-roles.sql
```
Mục đích: Seed 3 roles cơ bản + gán role cho user test
Lưu vào: D:\Eclipse\GameStore\plan\migrate-seed-roles.sql
```

---

## CÁCH TẠO 3 SCRIPTS

### migrate-create-user-roles.sql

```sql
USE [GameStore]
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'user_roles')
BEGIN
    CREATE TABLE [dbo].[user_roles](
        [user_id] [bigint] NOT NULL,
        [role_id] [bigint] NOT NULL,
        CONSTRAINT [PK_user_roles] PRIMARY KEY CLUSTERED
        (
            [user_id] ASC,
            [role_id] ASC
        )
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
              IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    ) ON [PRIMARY]

    ALTER TABLE [dbo].[user_roles] WITH CHECK
    ADD CONSTRAINT [FK_user_roles_roles]
    FOREIGN KEY([role_id]) REFERENCES [dbo].[roles] ([id]) ON DELETE CASCADE

    ALTER TABLE [dbo].[user_roles] WITH CHECK
    ADD CONSTRAINT [FK_user_roles_users]
    FOREIGN KEY([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE

    ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_roles]
    ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_users]

    PRINT 'Created user_roles table'
END
ELSE
BEGIN
    PRINT 'user_roles table already exists'
END
GO
```

### migrate-add-unique-constraints.sql

```sql
USE [GameStore]
GO

-- cart_items: 1 user không mua cùng 1 game 2 lần
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_cart_items_user_game')
BEGIN
    ALTER TABLE cart_items
    ADD CONSTRAINT UQ_cart_items_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_cart_items_user_game'
END

-- library_items: mỗi license key chỉ gán 1 lần
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_library_items_license')
BEGIN
    ALTER TABLE library_items
    ADD CONSTRAINT UQ_library_items_license UNIQUE (license_key_id)
    PRINT 'Added UQ_library_items_license'
END

-- library_items: không mua lại game đã có
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_library_items_user_game')
BEGIN
    ALTER TABLE library_items
    ADD CONSTRAINT UQ_library_items_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_library_items_user_game'
END

-- reviews: mỗi user chỉ review 1 game 1 lần
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_reviews_user_game')
BEGIN
    ALTER TABLE reviews
    ADD CONSTRAINT UQ_reviews_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_reviews_user_game'
END

-- wishlists: không thêm cùng game vào wishlist 2 lần
IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'UQ_wishlists_user_game')
BEGIN
    ALTER TABLE wishlists
    ADD CONSTRAINT UQ_wishlists_user_game UNIQUE (user_id, game_id)
    PRINT 'Added UQ_wishlists_user_game'
END
GO
```

### migrate-seed-roles.sql

```sql
USE [GameStore]
GO

-- Đảm bảo roles table trống
DELETE FROM user_roles;
DELETE FROM roles;

-- Insert 3 roles cơ bản
SET IDENTITY_INSERT [dbo].[roles] ON

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (1, 'ROLE_USER', N'Người dùng thông thường')

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (2, 'ROLE_ADMIN', N'Quản trị viên')

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (3, 'ROLE_PUBLISHER', N'Nhà phát hành game')

SET IDENTITY_INSERT [dbo].[roles] OFF

-- Gán role cho user có trong database
-- Thay đổi user_id theo data thực tế của bạn
DECLARE @userCount INT = (SELECT COUNT(*) FROM users)
PRINT CONCAT('Total users: ', @userCount)

-- Gán ROLE_USER mặc định cho tất cả user chưa có role
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, 1
FROM users u
WHERE u.id NOT IN (SELECT user_id FROM user_roles)
AND @userCount > 0

DECLARE @assigned INT = @@ROWCOUNT
PRINT CONCAT('Assigned ROLE_USER to ', @assigned, ' users')

-- Verify
SELECT 'Roles table' AS info, COUNT(*) AS total FROM roles
UNION ALL
SELECT 'User-roles assignments', COUNT(*) FROM user_roles
GO
```

---

## CHẠY TỪNG BƯỚC CUỐI

### Bước F-1: Backup database
```bash
sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 ^
  -Q "BACKUP DATABASE GameStore TO DISK='D:\Eclipse\GameStore\backup\GameStore_20260601.bak' WITH INIT"
```

### Bước F-2: Chạy migration scripts theo thứ tự
```bash
sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore ^
  -i D:\Eclipse\GameStore\plan\migrate-create-user-roles.sql

sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore ^
  -i D:\Eclipse\GameStore\plan\migrate-add-unique-constraints.sql

sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore ^
  -i D:\Eclipse\GameStore\plan\migrate-seed-roles.sql
```

### Bước F-3: Xác minh database
```sql
SELECT 'roles' AS tbl, COUNT(*) AS cnt FROM roles
UNION ALL
SELECT 'user_roles', COUNT(*) FROM user_roles
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'games', COUNT(*) FROM games
UNION ALL
SELECT 'wallets', COUNT(*) FROM wallets
```

### Bước F-4: Build project
```bash
cd D:\Eclipse\GameStore
mvn clean compile -DskipTests
```

### Bước F-5: Start Tomcat
```bash
# Copy WAR vào Tomcat
copy target\gamestore.war %CATALINA_HOME%\webapps\

# Hoặc chạy dev
mvn tomcat7:run
```

### Bước F-6: Test các chức năng quan trọng
```
□ Test login với tài khoản cũ (plain text password → BCrypt upgrade)
□ Test đăng ký + OTP (nếu EmailService config đúng)
□ Test trang chủ game browsing
□ Test checkout flow
□ Test wallet deposit
□ Test wallet withdraw
□ Test /admin/* route guard (cần login admin)
□ Test /publisher/* route guard (cần login publisher)
□ Test library view
```

### Bước F-7: Tạo test accounts mới
```sql
-- Tạo user mới với BCrypt password (password: 123)
-- Hash BCrypt: $2a$10$... (dùng PasswordEncoderUtil.encode("123"))

INSERT INTO users (email, password, fullName, status, createdAt, username)
VALUES ('admin@gamestore.com', '$2a$10$...BCRYPT_HASH...', 'Admin', 'ACTIVE', GETDATE(), 'admin')

INSERT INTO user_roles (user_id, role_id)
VALUES (SCOPE_IDENTITY(), 2)  -- ROLE_ADMIN
```

---

## CHECKLIST CUỐI CÙNG

### Pre-merge
```
□ Backup thư mục D:\Eclipse\GameStore
□ Backup database GameStore
□ Tạo branch mới: git checkout -b merge-colleague
□ Commit baseline trước khi merge
```

### Database
```
□ Chạy Store.sql (giữ seed data)
□ migrate-create-user-roles.sql
□ migrate-add-unique-constraints.sql
□ migrate-seed-roles.sql
□ Verify: roles, user_roles có data
```

### Java
```
□ Merge User.java entity (cẩn thận nhất)
□ Copy Role.java, Wallet.java, WalletTransaction.java
□ Copy tất cả DAO mới
□ Copy tất cả Service mới
□ Copy AuthController, AuthInterceptor
□ Copy WalletController, AdminController, PublisherController, KycController
□ GIỮ: CheckoutController, GameController, DashboardController, LibraryController
□ Merge spring-servlet.xml (thêm interceptor config)
□ Check pom.xml (thêm spring-security-crypto, javax.mail)
□ mvn compile → fix errors
```

### JSP / Views
```
□ Copy verify-otp.jsp
□ Copy wallet/index.jsp
□ Copy orders/*
□ Copy admin/*
□ Copy publisher/*
□ Copy kyc/*
□ GIỮ: index.jsp, login.jsp, library/index.jsp, checkout/*
□ Kiểm tra link path trong các JSP mới
```

### Post-merge
```
□ mvn clean package -DskipTests
□ Deploy WAR
□ Test login
□ Test checkout
□ Test wallet
□ Test admin routes
□ Update feature_list.json với features mới
□ Update claude-progress.md
□ Commit kết quả
```

---

## ROLLBACK PLAN

Nếu merge thất bại:

```bash
# 1. Khôi phục database
sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 ^
  -Q "RESTORE DATABASE GameStore FROM DISK='D:\Eclipse\GameStore\backup\GameStore_20260601.bak' WITH REPLACE"

# 2. Khôi phục code
git checkout -- .
git branch -d merge-colleague

# 3. Xóa WAR đã deploy
del %CATALINA_HOME%\webapps\gamestore.war
del %CATALINA_HOME%\webapps\gamestore
```
