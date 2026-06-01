-- ============================================================
-- MERGE-05: RBAC + Publisher + KYC Database Schema
-- Branch: feature/otp-auth-merge
-- Date: 2026-06-01
-- Description: Tạo các bảng mới từ module đồng nghiệp
-- ============================================================

USE [GameStore]
GO

-- ===== 1. ROLES =====
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'roles')
BEGIN
    CREATE TABLE [dbo].[roles](
        [id] [bigint] IDENTITY(1,1) NOT NULL,
        [code] [nvarchar](50) NOT NULL,
        [description] [nvarchar](255) NULL,
        CONSTRAINT [PK_roles] PRIMARY KEY CLUSTERED ([id] ASC)
    )
    ALTER TABLE [dbo].[roles] ADD CONSTRAINT [UQ_roles_code] UNIQUE ([code])
    PRINT 'Created roles table'
END
ELSE
    PRINT 'roles table already exists'
GO

-- ===== 2. USER_ROLES (junction) =====
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'user_roles')
BEGIN
    CREATE TABLE [dbo].[user_roles](
        [user_id] [bigint] NOT NULL,
        [role_id] [bigint] NOT NULL,
        CONSTRAINT [PK_user_roles] PRIMARY KEY CLUSTERED ([user_id] ASC, [role_id] ASC)
    )
    ALTER TABLE [dbo].[user_roles] WITH CHECK ADD CONSTRAINT [FK_user_roles_roles]
        FOREIGN KEY([role_id]) REFERENCES [dbo].[roles] ([id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[user_roles] WITH CHECK ADD CONSTRAINT [FK_user_roles_users]
        FOREIGN KEY([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_roles]
    ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_users]
    PRINT 'Created user_roles table'
END
ELSE
    PRINT 'user_roles table already exists'
GO

-- ===== 3. PUBLISHER_PROFILES =====
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'publisher_profiles')
BEGIN
    CREATE TABLE [dbo].[publisher_profiles](
        [id] [bigint] IDENTITY(1,1) NOT NULL,
        [user_id] [bigint] NOT NULL,
        [companyName] [nvarchar](255) NULL,
        [website] [nvarchar](255) NULL,
        [supportEmail] [nvarchar](255) NULL,
        CONSTRAINT [PK_publisher_profiles] PRIMARY KEY CLUSTERED ([id] ASC)
    )
    ALTER TABLE [dbo].[publisher_profiles] ADD CONSTRAINT [UQ_publisher_profiles_user]
        UNIQUE ([user_id])
    ALTER TABLE [dbo].[publisher_profiles] WITH CHECK ADD CONSTRAINT [FK_publisher_profiles_users]
        FOREIGN KEY([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[publisher_profiles] CHECK CONSTRAINT [FK_publisher_profiles_users]
    PRINT 'Created publisher_profiles table'
END
ELSE
    PRINT 'publisher_profiles table already exists'
GO

-- ===== 4. KYC_REQUESTS =====
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'kyc_requests')
BEGIN
    CREATE TABLE [dbo].[kyc_requests](
        [id] [bigint] IDENTITY(1,1) NOT NULL,
        [user_id] [bigint] NOT NULL,
        [documentUrl] [nvarchar](500) NULL,
        [taxId] [nvarchar](100) NULL,
        [status] [nvarchar](50) NOT NULL DEFAULT 'PENDING',
        [submittedAt] [datetime2] NULL,
        [processedAt] [datetime2] NULL,
        CONSTRAINT [PK_kyc_requests] PRIMARY KEY CLUSTERED ([id] ASC)
    )
    ALTER TABLE [dbo].[kyc_requests] WITH CHECK ADD CONSTRAINT [FK_kyc_requests_users]
        FOREIGN KEY([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[kyc_requests] CHECK CONSTRAINT [FK_kyc_requests_users]
    PRINT 'Created kyc_requests table'
END
ELSE
    PRINT 'kyc_requests table already exists'
GO

-- ===== 5. PAYOUT_REQUESTS =====
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'payout_requests')
BEGIN
    CREATE TABLE [dbo].[payout_requests](
        [id] [bigint] IDENTITY(1,1) NOT NULL,
        [publisher_id] [bigint] NOT NULL,
        [amount] [decimal](15, 2) NOT NULL,
        [bankAccountInfo] [nvarchar](max) NULL,
        [status] [nvarchar](50) NOT NULL DEFAULT 'PENDING',
        [requestedAt] [datetime2] NULL,
        [processedAt] [datetime2] NULL,
        CONSTRAINT [PK_payout_requests] PRIMARY KEY CLUSTERED ([id] ASC)
    )
    ALTER TABLE [dbo].[payout_requests] WITH CHECK ADD CONSTRAINT [FK_payout_requests_publisher]
        FOREIGN KEY([publisher_id]) REFERENCES [dbo].[publisher_profiles] ([id]) ON DELETE CASCADE
    ALTER TABLE [dbo].[payout_requests] CHECK CONSTRAINT [FK_payout_requests_publisher]
    PRINT 'Created payout_requests table'
END
ELSE
    PRINT 'payout_requests table already exists'
GO

-- ===== 6. SYSTEM_SETTINGS =====
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'system_settings')
BEGIN
    CREATE TABLE [dbo].[system_settings](
        [setting_key] [nvarchar](100) NOT NULL,
        [setting_value] [nvarchar](255) NULL,
        CONSTRAINT [PK_system_settings] PRIMARY KEY CLUSTERED ([setting_key] ASC)
    )
    PRINT 'Created system_settings table'
END
ELSE
    PRINT 'system_settings table already exists'
GO

-- ===== 7. ADD publisher_id TO games =====
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('games') AND name = 'publisher_id'
)
BEGIN
    ALTER TABLE [dbo].[games]
    ADD [publisher_id] [bigint] NULL

    ALTER TABLE [dbo].[games] WITH CHECK ADD CONSTRAINT [FK_games_publisher_profiles]
        FOREIGN KEY([publisher_id]) REFERENCES [dbo].[publisher_profiles] ([id])
    PRINT 'Added publisher_id to games table'
END
ELSE
    PRINT 'publisher_id already exists in games table'
GO

-- ===== 8. ADD order_item_entity_id TO license_keys =====
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('license_keys') AND name = 'order_item_entity_id'
)
BEGIN
    ALTER TABLE [dbo].[license_keys]
    ADD [order_item_entity_id] [bigint] NULL
    PRINT 'Added order_item_entity_id to license_keys table'
END
ELSE
    PRINT 'order_item_entity_id already exists in license_keys table'
GO

-- ===== 9. ADD order_item_entity_id TO library_items =====
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('library_items') AND name = 'order_item_entity_id'
)
BEGIN
    ALTER TABLE [dbo].[library_items]
    ADD [order_item_entity_id] [bigint] NULL
    PRINT 'Added order_item_entity_id to library_items table'
END
ELSE
    PRINT 'order_item_entity_id already exists in library_items table'
GO

PRINT ''
PRINT '========================================'
PRINT 'All new tables created successfully!'
PRINT 'Next: Run migrate-seed-roles.sql'
PRINT '========================================'
GO
