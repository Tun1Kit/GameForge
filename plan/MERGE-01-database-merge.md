# MERGE-01: DATABASE MERGE

## TÌNH TRẠNG HIỆN TẠI

### GameForge (bạn) — Store.sql
- 25 bảng
- Có seed data (cart_items, games, categories...)
- File: `D:\Eclipse\GameStore\Store.sql`
- DB name: `GameStore`
- SQL Server path: `C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\`

### GamestoreLTW (đồng nghiệp) — databasestorecuaTue.sql
- 25 bảng (cùng tên)
- KHÔNG có seed data
- File: `colleague/main:databasestorecuaTue.sql`
- DB name: `GameStore`
- SQL Server path: `C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\`

---

## SO SÁNH CHI TIẾT TỪNG BẢNG

### Bảng 1: users

```
GameForge (bạn):
  id, email, password, fullName, avatar, status, createdAt, username
  → Có username (nvarchar 100), có seed data
  → Password có thể là plain text

GamestoreLTW (đồng nghiệp):
  id, email, password, fullName, avatar, status, createdAt
  → KHÔNG có username
  → Password dùng BCrypt

QUYẾT ĐỊNH: GIỮ GAMEFORGE
  → Giữ nguyên 8 columns
  → KHÔNG cần thêm column từ đồng nghiệp
  → Sau khi merge, cần migrate: tạo user_roles table + thêm role entity
```

### Bảng 2: games

```
GameForge (bạn):
  id, publisher_id, title, slug, description, price, developer,
  releaseDate, minimumRequirements, recommendedRequirements, status,
  createdAt, original_price
  → Có original_price (decimal 18,2) — cho phép sale discount
  → Có seed data

GamestoreLTW (đồng nghiệp):
  id, publisher_id, title, slug, description, price, developer,
  releaseDate, minimumRequirements, recommendedRequirements, status, createdAt
  → KHÔNG có original_price

QUYẾT ĐỊNH: GIỮ GAMEFORGE
  → Giữ nguyên 13 columns (bao gồm original_price)
  → Giữ nguyên seed data
```

### Bảng 3: orders

```
GameForge (bạn):
  id, user_id, subtotalAmount, discountAmount, totalAmount,
  promo_code_id, status, createdAt, paidAt,
  paymentMethod, fullName, phone, address, province, district, ward, notes
  → 16 columns — có đầy đủ thông tin giao hàng
  → Có seed data

GamestoreLTW (đồng nghiệp):
  id, user_id, subtotalAmount, discountAmount, totalAmount,
  promo_code_id, status, createdAt, paidAt
  → 9 columns — chỉ có order cơ bản

QUYẾT ĐỊNH: GIỮ GAMEFORGE
  → Giữ nguyên 16 columns
  → Giữ seed data
```

### Bảng 4: cart_items

```
GameForge (bạn):
  id, user_id, game_id, quantity, addedAt
  → Không có UNIQUE constraint

GamestoreLTW (đồng nghiệp):
  id, user_id, game_id, quantity, addedAt
  → Có UNIQUE(user_id, game_id)
     (CONSTRAINT UQ_cart_items_user_game)

QUYẾT ĐỊNH: LẤY UNIQUE TỪ COLLEAGUE
  → Sau khi giữ Store.sql, thêm migration:
    ALTER TABLE cart_items
    ADD CONSTRAINT UQ_cart_items_user_game UNIQUE (user_id, game_id)
  → Ngăn trùng game trong cart
```

### Bảng 5: library_items

```
GameForge (bạn):
  id, user_id, game_id, license_key_id, status, acquiredAt
  → Không có UNIQUE constraint

GamestoreLTW (đồng nghiệp):
  id, user_id, game_id, license_key_id, status, acquiredAt
  → Có UNIQUE(license_key_id) — mỗi key chỉ gán 1 lần
  → Có UNIQUE(user_id, game_id) — không mua lại game đã có

QUYẾT ĐỊNH: LẤY 2 UNIQUE TỪ COLLEAGUE
  → Migration:
    ALTER TABLE library_items
    ADD CONSTRAINT UQ_library_items_license UNIQUE (license_key_id)

    ALTER TABLE library_items
    ADD CONSTRAINT UQ_library_items_user_game UNIQUE (user_id, game_id)
```

### Bảng 6: reviews

```
GameForge (bạn):
  id, game_id, user_id, rating, comment, publisherReply, createdAt
  → Không có UNIQUE constraint

GamestoreLTW (đồng nghiệp):
  id, game_id, user_id, rating, comment, publisherReply, createdAt
  → Có UNIQUE(user_id, game_id)
     (CONSTRAINT UQ_reviews_user_game)

QUYẾT ĐỊNH: LẤY UNIQUE TỪ COLLEAGUE
  → Migration:
    ALTER TABLE reviews
    ADD CONSTRAINT UQ_reviews_user_game UNIQUE (user_id, game_id)
  → Mỗi user chỉ review 1 game 1 lần
```

### Bảng 7: wishlists

```
GameForge (bạn):
  id, user_id, game_id, addedAt
  → Không có UNIQUE constraint

GamestoreLTW (đồng nghiệp):
  id, user_id, game_id, addedAt
  → Có UNIQUE(user_id, game_id)
     (CONSTRAINT UQ_wishlists_user_game)

QUYẾT ĐỊNH: LẤY UNIQUE TỪ COLLEAGUE
  → Migration:
    ALTER TABLE wishlists
    ADD CONSTRAINT UQ_wishlists_user_game UNIQUE (user_id, game_id)
```

### Bảng 8: wallets

```
GameForge: id, user_id, balance
GamestoreLTW: id, user_id, balance
→ HOÀN TOÀN GIỐNG NHAU
→ GIỮ GAMEFORGE
```

### Bảng 9: wallet_transactions

```
GameForge: id, wallet_id, type, amount, status, referenceId, createdAt
GamestoreLTW: id, wallet_id, type, amount, status, referenceId, createdAt
→ HOÀN TOÀN GIỐNG NHAU
→ GIỮ GAMEFORGE
```

### Bảng 10: orders, order_items, categories, game_categories, game_media

```
Tất cả các bảng này đều HOÀN TOÀN GIỐNG NHAU
→ GIỮ GAMEFORGE (vì có seed data)
```

### Bảng 11: roles

```
GameForge: id, code, description
GamestoreLTW: id, code, description
→ HOÀN TOÀN GIỐNG NHAU về schema
→ GIỮ GAMEFORGE (giữ schema)
→ CẦN THÊM: user_roles table + seed data cho roles
→ CẦN THÊM: user_roles table từ đồng nghiệp (chưa có trong Store.sql)
```

### Bảng 12: publisher_profiles, kyc_requests, promo_codes, refund_requests,
payout_requests, patch_notes, tickets, ticket_messages, license_keys, system_settings

```
Tất cả HOÀN TOÀN GIỐNG NHAU về schema
→ GIỮ GAMEFORGE (vì bạn đã có đầy đủ)
```

---

## DANH SÁCH MIGRATION CẦN CHẠY

### Migration 1: Tạo roles table (đã có trong Store.sql — giữ nguyên)
→ Kiểm tra Store.sql đã có `CREATE TABLE roles` → OK, giữ nguyên

### Migration 2: Tạo user_roles table (CẦN THÊM)
→ Đồng nghiệp có bảng này nhưng GameForge KHÔNG có
→ Cần thêm:

```sql
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
```

### Migration 3: Thêm UNIQUE constraints (từ đồng nghiệp)

```sql
-- cart_items: 1 user không mua cùng 1 game 2 lần
ALTER TABLE cart_items
ADD CONSTRAINT UQ_cart_items_user_game UNIQUE (user_id, game_id)

-- library_items: mỗi license key chỉ gán 1 lần
ALTER TABLE library_items
ADD CONSTRAINT UQ_library_items_license UNIQUE (license_key_id)

-- library_items: không mua lại game đã có
ALTER TABLE library_items
ADD CONSTRAINT UQ_library_items_user_game UNIQUE (user_id, game_id)

-- reviews: mỗi user chỉ review 1 game 1 lần
ALTER TABLE reviews
ADD CONSTRAINT UQ_reviews_user_game UNIQUE (user_id, game_id)

-- wishlists: không thêm cùng game vào wishlist 2 lần
ALTER TABLE wishlists
ADD CONSTRAINT UQ_wishlists_user_game UNIQUE (user_id, game_id)
```

### Migration 4: Seed roles (CẦN THÊM — đồng nghiệp không có)

```sql
-- Xóa data cũ nếu có
DELETE FROM user_roles;
DELETE FROM roles WHERE id > 0;

-- Insert 3 roles cơ bản
SET IDENTITY_INSERT [dbo].[roles] ON
INSERT [dbo].[roles] ([id], [code], [description])
VALUES (1, 'ROLE_USER', N'Người dùng thông thường')

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (2, 'ROLE_ADMIN', N'Quản trị viên')

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (3, 'ROLE_PUBLISHER', N'Nhà phát hành game')
SET IDENTITY_INSERT [dbo].[roles] OFF

-- Gán role USER cho user test (user_id=1)
INSERT INTO user_roles (user_id, role_id) VALUES (1, 1)
INSERT INTO user_roles (user_id, role_id) VALUES (2, 1)
INSERT INTO user_roles (user_id, role_id) VALUES (2, 2)
INSERT INTO user_roles (user_id, role_id) VALUES (3, 1)
INSERT INTO user_roles (user_id, role_id) VALUES (3, 3)
```

---

## THỨ TỰ THỰC HIỆN DATABASE MERGE

```
Bước DB-1: Backup database hiện tại
  → sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -Q "BACKUP DATABASE GameStore TO DISK='D:\Eclipse\GameStore\backup\GameStore_backup_20260601.bak'"

Bước DB-2: Chạy Store.sql (giữ nguyên) — tạo full schema + seed
  → sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -i D:\Eclipse\GameStore\Store.sql

Bước DB-3: Tạo user_roles table (migration 2)
  → sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -i D:\Eclipse\GameStore\plan\migrate-create-user-roles.sql

Bước DB-4: Thêm UNIQUE constraints (migration 3)
  → sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -i D:\Eclipse\GameStore\plan\migrate-add-unique-constraints.sql

Bước DB-5: Seed roles (migration 4)
  → sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -i D:\Eclipse\GameStore\plan\migrate-seed-roles.sql

Bước DB-6: Xác minh
  → SELECT COUNT(*) FROM users;       -- nên có data
  → SELECT * FROM roles;               -- nên có 3 rows
  → SELECT * FROM user_roles;         -- nên có assignment rows
```

---

## LƯU Ý QUAN TRỌNG

1. **KHÔNG chạy databasestorecuaTue.sql** — đồng nghiệp không có seed data, sẽ xóa hết data hiện tại
2. **GIỮ Store.sql** làm base — đã có đầy đủ schema + seed
3. **Tạo user_roles table** — đồng nghiệp có nhưng GameForge không có
4. **Seed roles** — đồng nghiệp cũng không có, cần tự thêm
5. **BCrypt password** — sau merge, user cũ có thể login bình thường nhờ auto-upgrade path trong AuthController đồng nghiệp
