-- GameForge Seed Accounts
-- Chạy: & 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\sqlcmd.exe' -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -C -i plan\seed-accounts.sql

SET NOCOUNT ON;

-- ============================================================
-- 1. TÀI KHOẢN USER THƯỜNG
-- Username: testuser | Password: user123
-- Balance: 5,000,000 VND
-- Roles: ROLE_USER
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'testuser')
BEGIN
    DECLARE @uid1 BIGINT;

    INSERT INTO users (username, email, password, fullName, status, createdAt)
    VALUES (
        'testuser',
        'testuser@gamestore.local',
        '$2b$10$AGpT5m9T3WedKoH8f1AgHOLEsZHD6mctxcQ.lh5apxBMqLNDbGu2u',
        'Test User',
        'ACTIVE',
        GETDATE()
    );

    SET @uid1 = SCOPE_IDENTITY();

    INSERT INTO wallets (user_id, balance)
    VALUES (@uid1, 5000000);

    DECLARE @wid1 BIGINT = SCOPE_IDENTITY();

    INSERT INTO wallet_transactions (wallet_id, type, amount, status, referenceId, createdAt)
    VALUES (@wid1, 'DEPOSIT', 5000000, 'SUCCESS', 'SEED_INIT', GETDATE());

    INSERT INTO user_roles (user_id, role_id)
    VALUES (@uid1, 1);  -- ROLE_USER

    PRINT 'Created: testuser / user123 (ROLE_USER, 5,000,000 VND)';
END
ELSE
    PRINT 'SKIPPED: testuser already exists';

-- ============================================================
-- 2. TÀI KHOẢN PUBLISHER
-- Username: publisher1 | Password: publisher123
-- Balance: 10,000,000 VND
-- Roles: ROLE_USER + ROLE_PUBLISHER
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'publisher1')
BEGIN
    DECLARE @pubId BIGINT;

    INSERT INTO users (username, email, password, fullName, status, createdAt)
    VALUES (
        'publisher1',
        'publisher1@gamestore.local',
        '$2b$10$ABYOizGyXkd5ALzds3vFq.8G1b2AZCYUXih7qEtnWgCIfDKGfmlii',
        'Publisher One',
        'ACTIVE',
        GETDATE()
    );

    SET @pubId = SCOPE_IDENTITY();

    INSERT INTO wallets (user_id, balance)
    VALUES (@pubId, 10000000);

    DECLARE @pubWid BIGINT = SCOPE_IDENTITY();

    INSERT INTO wallet_transactions (wallet_id, type, amount, status, referenceId, createdAt)
    VALUES (@pubWid, 'DEPOSIT', 10000000, 'SUCCESS', 'SEED_INIT', GETDATE());

    INSERT INTO user_roles (user_id, role_id)
    VALUES (@pubId, 1);  -- ROLE_USER

    INSERT INTO user_roles (user_id, role_id)
    VALUES (@pubId, 2);  -- ROLE_PUBLISHER

    INSERT INTO publisher_profiles (user_id, companyName, website, supportEmail)
    VALUES (@pubId, 'GameForge Studios', 'https://gamestore.example', 'publisher1@gamestore.local');

    PRINT 'Created: publisher1 / publisher123 (ROLE_PUBLISHER + ROLE_USER, 10,000,000 VND)';
END
ELSE
    PRINT 'SKIPPED: publisher1 already exists';

PRINT '';
PRINT '=== DONE ===';
