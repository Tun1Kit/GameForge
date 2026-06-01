-- =============================================
-- Script: Cập nhật username cho 4 tài khoản có sẵn
-- Chạy tất cả cùng lúc (Ctrl+A → F5)
-- =============================================

-- Thêm column username nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users') AND name = 'username')
BEGIN
    ALTER TABLE [dbo].[users] ADD [username] [nvarchar](100) NULL;
END
GO

-- Cập nhật username cho 4 tài khoản
UPDATE [dbo].[users] SET [username] = 'demouser'  WHERE [email] = 'user@test.com';
UPDATE [dbo].[users] SET [username] = 'demopublisher' WHERE [email] = 'publisher@test.com';
UPDATE [dbo].[users] SET [username] = 'demoadmin'  WHERE [email] = 'admin@test.com';

-- Nếu có tài khoản cũ không có username, gán tạm username để tránh NOT NULL lỗi
UPDATE [dbo].[users] SET [username] = 'old_user_' + CAST(id AS VARCHAR(50)) WHERE [username] IS NULL;

-- Đổi password sang BCrypt "123" cho 3 tài khoản test
UPDATE [dbo].[users] SET [password] = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.wEfmFGpXRa3T.AzGKy'
WHERE [email] IN ('user@test.com', 'publisher@test.com', 'admin@test.com');

-- Tạo ví cho admin (user_id=3) nếu chưa có
IF NOT EXISTS (SELECT 1 FROM [dbo].[wallets] WHERE [user_id] = 3)
BEGIN
    INSERT INTO [dbo].[wallets] ([user_id], [balance]) VALUES (3, 0);
END

-- Kiểm tra
SELECT id, email, username, password, fullName FROM [dbo].[users];
