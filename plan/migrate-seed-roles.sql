-- ============================================================
-- MERGE-05b: Role Seed Data
-- Chạy SAU migrate-create-new-tables.sql
-- ============================================================

USE [GameStore]
GO

-- Seed 3 roles
IF NOT EXISTS (SELECT 1 FROM roles WHERE code = 'ROLE_USER')
BEGIN
    SET IDENTITY_INSERT [dbo].[roles] ON
    INSERT [dbo].[roles] ([id], [code], [description]) VALUES (1, 'ROLE_USER', N'Người dùng thông thường')
    SET IDENTITY_INSERT [dbo].[roles] OFF
    PRINT 'Seeded ROLE_USER'
END

IF NOT EXISTS (SELECT 1 FROM roles WHERE code = 'ROLE_ADMIN')
BEGIN
    SET IDENTITY_INSERT [dbo].[roles] ON
    INSERT [dbo].[roles] ([id], [code], [description]) VALUES (2, 'ROLE_ADMIN', N'Quản trị viên')
    SET IDENTITY_INSERT [dbo].[roles] OFF
    PRINT 'Seeded ROLE_ADMIN'
END

IF NOT EXISTS (SELECT 1 FROM roles WHERE code = 'ROLE_PUBLISHER')
BEGIN
    SET IDENTITY_INSERT [dbo].[roles] ON
    INSERT [dbo].[roles] ([id], [code], [description]) VALUES (3, 'ROLE_PUBLISHER', N'Nhà phát hành game')
    SET IDENTITY_INSERT [dbo].[roles] OFF
    PRINT 'Seeded ROLE_PUBLISHER'
END

-- Seed platform commission rate
IF NOT EXISTS (SELECT 1 FROM system_settings WHERE setting_key = 'PLATFORM_COMMISSION_RATE')
BEGIN
    INSERT [dbo].[system_settings] ([setting_key], [setting_value])
    VALUES ('PLATFORM_COMMISSION_RATE', '10.00')
    PRINT 'Seeded PLATFORM_COMMISSION_RATE = 10.00'
END

-- Gán ROLE_USER cho tất cả user chưa có role
DECLARE @userCount INT = (SELECT COUNT(*) FROM users)
IF @userCount > 0
BEGIN
    INSERT INTO user_roles (user_id, role_id)
    SELECT u.id, 1
    FROM users u
    WHERE u.id NOT IN (SELECT user_id FROM user_roles)

    DECLARE @assigned INT = @@ROWCOUNT
    PRINT CONCAT('Assigned ROLE_USER to ', @assigned, ' existing users')
END

-- Gán ROLE_ADMIN cho admin
IF EXISTS (SELECT 1 FROM users WHERE email LIKE '%admin%')
BEGIN
    INSERT INTO user_roles (user_id, role_id)
    SELECT id, 2
    FROM users
    WHERE email LIKE '%admin%'
    AND id NOT IN (SELECT user_id FROM user_roles WHERE role_id = 2)
    PRINT 'Assigned ROLE_ADMIN to admin users'
END

-- Verify
SELECT 'roles' AS tbl, COUNT(*) AS cnt FROM roles
UNION ALL
SELECT 'user_roles', COUNT(*) FROM user_roles
UNION ALL
SELECT 'system_settings', COUNT(*) FROM system_settings

PRINT 'Role seed completed!'
GO
