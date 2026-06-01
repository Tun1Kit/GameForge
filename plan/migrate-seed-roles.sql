USE [GameStore]
GO

-- Xoa data cu (neu co) de dam bao sach
DELETE FROM user_roles;
DELETE FROM roles WHERE id > 0;

-- Seed 3 roles co ban
SET IDENTITY_INSERT [dbo].[roles] ON

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (1, 'ROLE_USER', N'Nguoi dung thong thuong')

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (2, 'ROLE_ADMIN', N'Quan tri vien')

INSERT [dbo].[roles] ([id], [code], [description])
VALUES (3, 'ROLE_PUBLISHER', N'Nha phat hanh game')

SET IDENTITY_INSERT [dbo].[roles] OFF

PRINT 'Seeded 3 roles: ROLE_USER, ROLE_ADMIN, ROLE_PUBLISHER'

-- Gan ROLE_USER mac dinh cho tat ca user chua co role
DECLARE @userCount INT = (SELECT COUNT(*) FROM users)
IF @userCount > 0
BEGIN
    INSERT INTO user_roles (user_id, role_id)
    SELECT u.id, 1
    FROM users u
    WHERE u.id NOT IN (SELECT user_id FROM user_roles)

    DECLARE @assigned INT = @@ROWCOUNT
    PRINT CONCAT('Assigned ROLE_USER to ', @assigned, ' users')
END

-- Gan ROLE_ADMIN cho admin (thay doi email theo account thuc te)
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

PRINT 'Role seed completed'
GO
