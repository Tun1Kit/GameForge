USE [GameStore]
GO

-- Tạo bảng roles nếu chưa có
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
BEGIN
    PRINT 'roles table already exists - skipping'
END
GO
