-- =============================================
-- Script: Thêm cột original_price cho bảng games
-- Chạy: Ctrl+A → F5
-- =============================================

-- Thêm cột original_price nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.games') AND name = 'original_price')
BEGIN
    ALTER TABLE [dbo].[games] ADD [original_price] [decimal](18,2) NULL;
END
GO

-- Cập nhật giá gốc = giá hiện tại × 1.25 cho các game có giá
-- (Game nào đã giảm giá rồi thì đặt original_price = price × 1.25)
UPDATE [dbo].[games] SET [original_price] = [price] * 1.25 WHERE [price] IS NOT NULL;

-- Kiểm tra
SELECT id, title, price, original_price FROM [dbo].[games];
