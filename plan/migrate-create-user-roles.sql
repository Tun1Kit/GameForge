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

    PRINT 'Created user_roles table + FK constraints'
END
ELSE
BEGIN
    PRINT 'user_roles table already exists - skipping'
END
GO
