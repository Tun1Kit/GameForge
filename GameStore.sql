USE [master]
GO

-- 1. Nếu trên máy đã có một database GameStore chạy lỗi trước đó, xóa sạch để làm lại từ đầu
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'GameStore')
BEGIN
    ALTER DATABASE [GameStore] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [GameStore];
END
GO

-- 2. TẠO MỚI: Để SQL Server tự động cấp phát file theo thư mục mặc định trên máy bạn, không ép cứng ổ C hay D
CREATE DATABASE [GameStore];
GO

-- 3. CHUYỂN BỐI CẢNH VÀO GAMESTORE (Chặn tuyệt đối việc tạo bảng nhầm vào DB hệ thống master)
USE [GameStore]
GO
/****** Object:  Table [dbo].[cart_items]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cart_items](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[game_id] [bigint] NOT NULL,
	[quantity] [int] NOT NULL,
	[addedAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[categories]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[categories](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[slug] [varchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[game_categories]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[game_categories](
	[game_id] [bigint] NOT NULL,
	[category_id] [bigint] NOT NULL,
 CONSTRAINT [PK_game_categories] PRIMARY KEY CLUSTERED 
(
	[game_id] ASC,
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[game_media]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[game_media](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[game_id] [bigint] NOT NULL,
	[mediaType] [varchar](50) NOT NULL,
	[mediaUrl] [nvarchar](500) NOT NULL,
	[isPrimary] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[games]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[games](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[publisher_id] [bigint] NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[slug] [varchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
	[price] [decimal](15, 2) NOT NULL,
	[developer] [nvarchar](255) NULL,
	[releaseDate] [date] NULL,
	[minimumRequirements] [nvarchar](max) NULL,
	[recommendedRequirements] [nvarchar](max) NULL,
	[status] [varchar](50) NOT NULL,
	[createdAt] [datetime2](0) NOT NULL,
	[original_price] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[kyc_requests]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[kyc_requests](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[documentUrl] [nvarchar](500) NULL,
	[taxId] [nvarchar](100) NULL,
	[status] [varchar](50) NOT NULL,
	[submittedAt] [datetime2](0) NOT NULL,
	[processedAt] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[library_items]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[library_items](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[game_id] [bigint] NOT NULL,
	[license_key_id] [bigint] NOT NULL,
	[status] [varchar](50) NOT NULL,
	[acquiredAt] [datetime2](0) NOT NULL,
	[order_item_entity_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[license_keys]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[license_keys](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[game_id] [bigint] NOT NULL,
	[keyString] [varchar](255) NOT NULL,
	[order_item_id] [bigint] NULL,
	[owner_id] [bigint] NULL,
	[status] [varchar](50) NOT NULL,
	[createdAt] [datetime2](0) NOT NULL,
	[assignedAt] [datetime2](0) NULL,
	[order_item_entity_id] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[order_items]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[order_items](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[order_id] [bigint] NOT NULL,
	[game_id] [bigint] NOT NULL,
	[unitPrice] [decimal](15, 2) NOT NULL,
	[discountAmount] [decimal](15, 2) NOT NULL,
	[paidAmount] [decimal](15, 2) NOT NULL,
	[quantity] [int] NOT NULL,
	[status] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[orders]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orders](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[subtotalAmount] [decimal](15, 2) NOT NULL,
	[discountAmount] [decimal](15, 2) NOT NULL,
	[totalAmount] [decimal](15, 2) NOT NULL,
	[promo_code_id] [bigint] NULL,
	[status] [varchar](50) NOT NULL,
	[createdAt] [datetime2](0) NOT NULL,
	[paidAt] [datetime2](0) NULL,
	[paymentMethod] [varchar](50) NULL,
	[fullName] [nvarchar](255) NULL,
	[phone] [nvarchar](50) NULL,
	[address] [nvarchar](500) NULL,
	[province] [nvarchar](100) NULL,
	[district] [nvarchar](100) NULL,
	[ward] [nvarchar](100) NULL,
	[notes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[patch_notes]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[patch_notes](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[game_id] [bigint] NOT NULL,
	[version] [varchar](100) NOT NULL,
	[content] [nvarchar](max) NOT NULL,
	[publishedAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[payout_requests]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payout_requests](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[publisher_id] [bigint] NOT NULL,
	[amount] [decimal](15, 2) NOT NULL,
	[bankAccountInfo] [nvarchar](max) NULL,
	[status] [varchar](50) NOT NULL,
	[requestedAt] [datetime2](0) NOT NULL,
	[processedAt] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[promo_codes]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[promo_codes](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[publisher_id] [bigint] NULL,
	[game_id] [bigint] NULL,
	[code] [varchar](100) NOT NULL,
	[discountPercentage] [decimal](5, 2) NOT NULL,
	[expiryDate] [datetime2](0) NULL,
	[usageLimit] [int] NULL,
	[currentUsage] [int] NOT NULL,
	[status] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[publisher_profiles]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[publisher_profiles](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[companyName] [nvarchar](255) NULL,
	[website] [nvarchar](255) NULL,
	[supportEmail] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[refund_requests]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_requests](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[order_id] [bigint] NOT NULL,
	[order_item_id] [bigint] NOT NULL,
	[user_id] [bigint] NOT NULL,
	[amount] [decimal](15, 2) NOT NULL,
	[reason] [nvarchar](max) NULL,
	[status] [varchar](50) NOT NULL,
	[requestedAt] [datetime2](0) NOT NULL,
	[processedAt] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reviews]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reviews](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[game_id] [bigint] NOT NULL,
	[user_id] [bigint] NOT NULL,
	[rating] [int] NOT NULL,
	[comment] [nvarchar](max) NULL,
	[publisherReply] [nvarchar](max) NULL,
	[createdAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[roles]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[roles](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[description] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[system_settings]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[system_settings](
	[setting_key] [varchar](100) NOT NULL,
	[setting_value] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[setting_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ticket_messages]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ticket_messages](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ticket_id] [bigint] NOT NULL,
	[sender_id] [bigint] NOT NULL,
	[message] [nvarchar](max) NOT NULL,
	[sentAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tickets]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tickets](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[related_game_id] [bigint] NULL,
	[related_order_id] [bigint] NULL,
	[subject] [nvarchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
	[status] [varchar](50) NOT NULL,
	[createdAt] [datetime2](0) NOT NULL,
	[updatedAt] [datetime2](0) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user_roles]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_roles](
	[user_id] [bigint] NOT NULL,
	[role_id] [bigint] NOT NULL,
 CONSTRAINT [PK_user_roles] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[email] [nvarchar](255) NOT NULL,
	[password] [nvarchar](255) NOT NULL,
	[fullName] [nvarchar](255) NULL,
	[avatar] [nvarchar](500) NULL,
	[status] [varchar](50) NOT NULL,
	[createdAt] [datetime2](0) NOT NULL,
	[username] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[wallet_transactions]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wallet_transactions](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[wallet_id] [bigint] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[amount] [decimal](15, 2) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[referenceId] [nvarchar](255) NULL,
	[createdAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[wallets]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wallets](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[balance] [decimal](15, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[wishlists]    Script Date: 6/1/2026 10:45:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wishlists](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[game_id] [bigint] NOT NULL,
	[addedAt] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[cart_items] ON 

INSERT [dbo].[cart_items] ([id], [user_id], [game_id], [quantity], [addedAt]) VALUES (46, 6, 1, 1, CAST(N'2026-05-28T23:42:14.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[cart_items] OFF
GO
SET IDENTITY_INSERT [dbo].[categories] ON 

INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (1, N'Action', N'action', N'Game hành động')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (2, N'RPG', N'rpg', N'Game nhập vai')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (3, N'Strategy', N'strategy', N'Game chiến thuật')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (4, N'Adventure', N'adventure', N'Game phiêu lưu')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (5, N'Simulation', N'simulation', N'Game mô phỏng')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (6, N'Sports', N'sports', N'Game thể thao')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (7, N'Horror', N'horror', N'Game kinh dị')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (8, N'Racing', N'racing', N'Game đua xe')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (9, N'Casual', N'casual', N'Game giải trí nhẹ nhàng')
INSERT [dbo].[categories] ([id], [name], [slug], [description]) VALUES (10, N'Fighting', N'fighting', N'Game chiến đấu')
SET IDENTITY_INSERT [dbo].[categories] OFF
GO
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (4, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (4, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (5, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (5, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (6, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (6, 3)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (8, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (9, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (9, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (10, 6)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (10, 10)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (11, 8)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (12, 10)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (13, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (13, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (14, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (14, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (15, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (15, 7)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (16, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (16, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (17, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (17, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (18, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (18, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (19, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (19, 7)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (20, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (20, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (21, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (21, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (22, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (22, 5)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (23, 6)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (24, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (24, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (25, 1)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (25, 10)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (26, 5)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (26, 9)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (27, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (27, 9)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (28, 2)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (28, 4)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (29, 3)
INSERT [dbo].[game_categories] ([game_id], [category_id]) VALUES (29, 5)
GO
SET IDENTITY_INSERT [dbo].[game_media] ON 

INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (1, 1, N'IMAGE', N'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1139900/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 2, N'IMAGE', N'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/671860/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (3, 3, N'IMAGE', N'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/292030/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (4, 4, N'IMAGE', N'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (5, 5, N'IMAGE', N'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2358720/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (6, 6, N'IMAGE', N'https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (7, 1, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (8, 2, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/2358720/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (9, 3, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1086940/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (10, 4, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1091500/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (11, 5, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (12, 6, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1086940/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (14, 8, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/553850/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (15, 9, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1145350/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (16, 10, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1778820/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (17, 11, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1551360/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (18, 12, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (19, 13, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1174180/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (20, 14, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1623730/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (21, 15, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/2050650/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (22, 16, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/271590/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (23, 17, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1593500/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (24, 18, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/292030/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (25, 19, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/782330/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (26, 20, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/582010/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (27, 21, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/990080/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (28, 22, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/275850/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (29, 23, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/2669320/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (30, 24, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1172620/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (31, 25, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1971870/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (32, 26, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/413150/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (33, 27, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1868140/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (34, 28, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/1716740/header.jpg', 1)
INSERT [dbo].[game_media] ([id], [game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (35, 29, N'IMAGE', N'https://cdn.cloudflare.steamstatic.com/steam/apps/949230/header.jpg', 1)
SET IDENTITY_INSERT [dbo].[game_media] OFF

-- ==========================================================
-- THÊM MEDIA LOCAL CHO GAME PIXEL WAR (ID = 2) TỪ GGGG
-- Xóa ảnh Steam CDN của game_id=2 và thay bằng local assets
-- ==========================================================
DELETE FROM [dbo].[game_media] WHERE [game_id] = 2;
GO

INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'IMAGE', '/assets/images/games/pixel-war/thumb.jpg', 1);
INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'IMAGE', '/assets/images/games/pixel-war/pixel-war-1.jpg', 0);
INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'IMAGE', '/assets/images/games/pixel-war/pixel-war-2.jpg', 0);
INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'IMAGE', '/assets/images/games/pixel-war/pixel-war-3.jpg', 0);
INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'IMAGE', '/assets/images/games/pixel-war/pixel-war-4.jpg', 0);
INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'IMAGE', '/assets/images/games/pixel-war/pixel-war-1.gif', 0);
INSERT INTO [dbo].[game_media] ([game_id], [mediaType], [mediaUrl], [isPrimary]) VALUES (2, 'VIDEO_TRAILER', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 0);
GO
GO
SET IDENTITY_INSERT [dbo].[games] ON 

INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (1, 1, N'Cyber Quest', N'cyber-quest', N'Game mẫu để test cart, checkout, license key và refund.', CAST(150000.00 AS Decimal(15, 2)), N'Demo Studio', NULL, NULL, NULL, N'ACTIVE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), CAST(187500.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (2, 1, N'Pixel War', N'pixel-war', N'Chào mừng bạn đến với thế giới của Pixel War! Đây là tựa game hành động phong cách cổ điển kết hợp lối chơi bắn súng sinh tồn kịch tính. Bạn sẽ nhập vai chiến binh pixel cuối cùng phòng thủ trước làn sóng quái vật không giới hạn. Hãy thu thập tài nguyên, nâng cấp vũ khí tối tân và thiết lập kỷ lục thế giới mới ngay hôm nay!', CAST(99000.00 AS Decimal(15, 2)), N'Demo Studio', NULL, N'{"os": "Windows 10 (64-bit)", "cpu": "Intel Core i3-6100 / AMD Ryzen 3 1200", "ram": "4 GB RAM", "gpu": "NVIDIA GTX 750 Ti / AMD RX 550", "storage": "2 GB dung lượng khả dụng"}', N'{"os": "Windows 10/11 (64-bit)", "cpu": "Intel Core i5-8400 / AMD Ryzen 5 2600", "ram": "8 GB RAM", "gpu": "NVIDIA GTX 1060 6GB / AMD RX 580", "storage": "2 GB dung lượng khả dụng"}', N'ACTIVE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), CAST(123750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (3, 1, N'Mystic RPG', N'mystic-rpg', N'Game mẫu để test cart, checkout, license key và refund.', CAST(250000.00 AS Decimal(15, 2)), N'Demo Studio', NULL, NULL, NULL, N'ACTIVE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), CAST(312500.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (4, 1, N'Elden Ring', N'elden-ring', N'Hành trình trở thành Elden Lord trong vùng đất Lands Between.', CAST(59.99 AS Decimal(15, 2)), N'FromSoftware', NULL, NULL, NULL, N'ACTIVE', CAST(N'2026-05-11T23:51:38.0000000' AS DateTime2), CAST(74.99 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (5, 1, N'Black Myth: Wukong', N'black-myth-wukong', N'Game hành động nhập vai lấy cảm hứng từ Tây Du Ký.', CAST(50.00 AS Decimal(15, 2)), N'Game Science', NULL, NULL, NULL, N'ACTIVE', CAST(N'2026-05-11T23:51:38.0000000' AS DateTime2), CAST(62.50 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (6, 1, N'Cyberpunk 2077', N'cyberpunk-2077', N'Khám phá thành phố tương lai Night City.', CAST(29.99 AS Decimal(15, 2)), N'CD Projekt Red', NULL, NULL, NULL, N'ACTIVE', CAST(N'2026-05-11T23:51:38.0000000' AS DateTime2), CAST(37.49 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (8, 1, N'Helldivers 2', N'helldivers-2', N'Game bắn súng hợp tác nổ tung màn hình, chiến đấu bảo vệ Dân Chủ siêu nhiên!', CAST(899000.00 AS Decimal(15, 2)), N'Arrowhead Game Studios', CAST(N'2024-02-08' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(1123750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (9, 1, N'Hades II', N'hades-2', N'Roguelite xuất sắc từ Supergiant — chương tiếp theo của Hades huyền thoại.', CAST(399000.00 AS Decimal(15, 2)), N'Supergiant Games', CAST(N'2024-05-06' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(498750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (10, 1, N'Tekken 8', N'tekken-8', N'Vua fighting game trở lại với đồ hoạ đỉnh cao và lối chơi cân bằng.', CAST(1199000.00 AS Decimal(15, 2)), N'Bandai Namco Entertainment', CAST(N'2024-01-26' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(1498750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (11, 1, N'Forza Horizon 5', N'forza-horizon-5', N'Game đua xe open-world bối cảnh Mexico đẹp mắt nhất thế hệ.', CAST(449000.00 AS Decimal(15, 2)), N'Playground Games', CAST(N'2021-11-09' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(561250.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (12, 1, N'Street Fighter 6', N'street-fighter-6', N'Tựa game fighting thế hệ mới của Capcom với World Tour và Battle Hub.', CAST(899000.00 AS Decimal(15, 2)), N'Capcom', CAST(N'2023-06-02' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(1123750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (13, 1, N'Red Dead Redemption 2', N'red-dead-redemption-2', N'Kiệt tác thế giới mở của Rockstar, câu chuyện Arthur Morgan xúc động.', CAST(599000.00 AS Decimal(15, 2)), N'Rockstar Games', CAST(N'2019-11-05' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(748750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (14, 1, N'Palworld', N'palworld', N'Game sinh tồn bắt Pal kết hợp crafting và bắn súng cực kỳ hấp dẫn.', CAST(429000.00 AS Decimal(15, 2)), N'Pocketpair', CAST(N'2024-01-19' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(536250.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (15, 1, N'Resident Evil 4', N'resident-evil-4', N'Bản remake hoàn hảo của kiệt tác kinh dị hành động — Leon Kennedy trở lại.', CAST(799000.00 AS Decimal(15, 2)), N'Capcom', CAST(N'2023-03-24' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(998750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (16, 1, N'GTA V Premium', N'gta-v', N'Thế giới Los Santos rộng lớn, câu chuyện 3 nhân vật và GTA Online vô tận.', CAST(199000.00 AS Decimal(15, 2)), N'Rockstar Games', CAST(N'2015-04-14' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(248750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (17, 1, N'God of War', N'god-of-war', N'Kratos và Atreus phiêu lưu qua thần thoại Bắc Âu — hành trình đầy cảm xúc.', CAST(349000.00 AS Decimal(15, 2)), N'Santa Monica Studio', CAST(N'2022-01-14' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(436250.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (18, 1, N'The Witcher 3', N'the-witcher-3', N'RPG thế giới mở vĩ đại nhất mọi thời đại — Geralt truy tìm Ciri.', CAST(299000.00 AS Decimal(15, 2)), N'CD Projekt Red', CAST(N'2015-05-19' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(373750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (19, 1, N'DOOM Eternal', N'doom-eternal', N'Bắn súng FPS nhanh nhất và bạo lực nhất, tiêu diệt quỷ dữ không nghỉ.', CAST(399000.00 AS Decimal(15, 2)), N'id Software', CAST(N'2020-03-20' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(498750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (20, 1, N'Monster Hunter: World', N'monster-hunter-world', N'Săn quái vật đẳng cấp thế giới với hệ thống vũ khí phong phú và co-op 4 người.', CAST(349000.00 AS Decimal(15, 2)), N'Capcom', CAST(N'2018-08-09' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(436250.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (21, 1, N'Hogwarts Legacy', N'hogwarts-legacy', N'Khám phá thế giới phép thuật thế kỷ 19, xây dựng phép và giải bí ẩn Hogwarts.', CAST(699000.00 AS Decimal(15, 2)), N'Avalanche Software', CAST(N'2023-02-10' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(873750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (22, 1, N'No Man''s Sky', N'no-mans-sky', N'Khám phá vũ trụ vô tận với hàng triệu hành tinh procedural sinh tồn và multiplayer.', CAST(499000.00 AS Decimal(15, 2)), N'Hello Games', CAST(N'2016-08-12' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(623750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (23, 1, N'EA Sports FC 25', N'ea-fc-25', N'Game bóng đá hàng đầu thế giới với Ultimate Team và chế độ Career Mode chi tiết.', CAST(899000.00 AS Decimal(15, 2)), N'EA Sports', CAST(N'2024-09-27' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(1123750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (24, 1, N'Sea of Thieves', N'sea-of-thieves', N'Game cướp biển co-op cùng bạn bè, săn kho báu và chiến đấu trên biển cả.', CAST(499000.00 AS Decimal(15, 2)), N'Rare Ltd', CAST(N'2018-03-20' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(623750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (25, 1, N'Mortal Kombat 1', N'mortal-kombat-1', N'Reboot của thương hiệu fighting huyền thoại với Kameo System và Invasions mới.', CAST(999000.00 AS Decimal(15, 2)), N'NetherRealm Studios', CAST(N'2023-09-19' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(1248750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (26, 1, N'Stardew Valley', N'stardew-valley', N'Game nông trại pixel art siêu thư giãn, xây dựng trang trại và tình bạn.', CAST(179000.00 AS Decimal(15, 2)), N'ConcernedApe', CAST(N'2016-02-26' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(223750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (27, 1, N'Dave the Diver', N'dave-the-diver', N'Indie đặc sắc — ban ngày lặn biển, ban đêm quản lý nhà hàng sushi tuyệt vời.', CAST(259000.00 AS Decimal(15, 2)), N'MINTROCKET', CAST(N'2023-06-28' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(323750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (28, 1, N'Starfield', N'starfield', N'RPG không gian bom tấn của Bethesda — khám phá 1000+ hành tinh.', CAST(1099000.00 AS Decimal(15, 2)), N'Bethesda Game Studios', CAST(N'2023-09-06' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(1373750.00 AS Decimal(18, 2)))
INSERT [dbo].[games] ([id], [publisher_id], [title], [slug], [description], [price], [developer], [releaseDate], [minimumRequirements], [recommendedRequirements], [status], [createdAt], [original_price]) VALUES (29, 1, N'Cities: Skylines II', N'cities-skylines-2', N'Game xây dựng thành phố thế hệ mới với kinh tế thực tế và giao thông phức tạp.', CAST(699000.00 AS Decimal(15, 2)), N'Colossal Order', CAST(N'2023-10-24' AS Date), NULL, NULL, N'ACTIVE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(873750.00 AS Decimal(18, 2)))
SET IDENTITY_INSERT [dbo].[games] OFF
GO
SET IDENTITY_INSERT [dbo].[library_items] ON 

INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (1, 1, 3, 8, N'ACTIVE', CAST(N'2026-05-28T09:33:35.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (6, 1, 9, 25, N'ACTIVE', CAST(N'2026-05-28T17:04:16.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (7, 1, 8, 22, N'ACTIVE', CAST(N'2026-05-28T17:04:16.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (8, 1, 6, 16, N'ACTIVE', CAST(N'2026-05-28T17:04:16.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (9, 1, 5, 13, N'ACTIVE', CAST(N'2026-05-28T17:04:16.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (46, 5, 2, 6, N'ACTIVE', CAST(N'2026-05-29T15:16:15.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (48, 5, 1, 2, N'ACTIVE', CAST(N'2026-05-29T15:21:22.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (49, 5, 4, 10, N'ACTIVE', CAST(N'2026-05-29T15:22:24.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (56, 5, 3, 9, N'ACTIVE', CAST(N'2026-05-29T17:50:32.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (57, 5, 8, 23, N'ACTIVE', CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (58, 5, 17, 49, N'ACTIVE', CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2), NULL)
INSERT [dbo].[library_items] ([id], [user_id], [game_id], [license_key_id], [status], [acquiredAt], [order_item_entity_id]) VALUES (59, 5, 13, 37, N'ACTIVE', CAST(N'2026-06-01T21:50:29.0000000' AS DateTime2), NULL)
SET IDENTITY_INSERT [dbo].[library_items] OFF
GO
SET IDENTITY_INSERT [dbo].[license_keys] ON 

INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (2, 1, N'CYBER_QUEST-KEY-0002', 52, 5, N'SOLD', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), CAST(N'2026-05-29T15:21:22.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (3, 1, N'CYBER_QUEST-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (6, 2, N'PIXEL_WAR-KEY-0003', 50, 5, N'SOLD', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), CAST(N'2026-05-29T15:16:15.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (8, 3, N'MYSTIC_RPG-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (9, 3, N'MYSTIC_RPG-KEY-0003', 60, 5, N'SOLD', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), CAST(N'2026-05-29T17:50:32.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (10, 4, N'CYBERPUNK-2077-KEY-0001', 53, 5, N'SOLD', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(N'2026-05-29T15:22:24.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (11, 4, N'CYBERPUNK-2077-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (12, 4, N'CYBERPUNK-2077-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (13, 5, N'ELDEN-RING-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (14, 5, N'ELDEN-RING-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (15, 5, N'ELDEN-RING-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (16, 6, N'BALDURS-GATE-3-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (17, 6, N'BALDURS-GATE-3-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (18, 6, N'BALDURS-GATE-3-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (22, 8, N'HELLDIVERS-2-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (23, 8, N'HELLDIVERS-2-KEY-0002', 61, 5, N'SOLD', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (24, 8, N'HELLDIVERS-2-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (25, 9, N'HADES-2-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (26, 9, N'HADES-2-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (27, 9, N'HADES-2-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (28, 10, N'TEKKEN-8-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (29, 10, N'TEKKEN-8-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (30, 10, N'TEKKEN-8-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (31, 11, N'FORZA-H5-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (32, 11, N'FORZA-H5-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (33, 11, N'FORZA-H5-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (34, 12, N'SF6-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (35, 12, N'SF6-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (36, 12, N'SF6-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (37, 13, N'RDR2-KEY-0001', 63, 5, N'SOLD', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(N'2026-06-01T21:50:29.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (38, 13, N'RDR2-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (39, 13, N'RDR2-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (40, 14, N'PALWORLD-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (41, 14, N'PALWORLD-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (42, 14, N'PALWORLD-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (43, 15, N'RE4-REMAKE-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (44, 15, N'RE4-REMAKE-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (45, 15, N'RE4-REMAKE-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (46, 16, N'GTAV-PREMIUM-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (47, 16, N'GTAV-PREMIUM-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (48, 16, N'GTAV-PREMIUM-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (49, 17, N'GOW-2018-KEY-0001', 62, 5, N'SOLD', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2), NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (50, 17, N'GOW-2018-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (51, 17, N'GOW-2018-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (52, 18, N'WITCHER3-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (53, 18, N'WITCHER3-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (54, 18, N'WITCHER3-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (55, 19, N'DOOM-ETERNAL-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (56, 19, N'DOOM-ETERNAL-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (57, 19, N'DOOM-ETERNAL-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (58, 20, N'MHW-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (59, 20, N'MHW-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (60, 20, N'MHW-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (61, 21, N'HOGWARTS-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (62, 21, N'HOGWARTS-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (63, 21, N'HOGWARTS-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (64, 22, N'NMS-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (65, 22, N'NMS-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (66, 22, N'NMS-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (67, 23, N'EAFC25-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (68, 23, N'EAFC25-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (69, 23, N'EAFC25-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (70, 24, N'SOT-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (71, 24, N'SOT-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (72, 24, N'SOT-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (73, 25, N'MK1-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (74, 25, N'MK1-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (75, 25, N'MK1-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (76, 26, N'STARDEW-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (77, 26, N'STARDEW-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (78, 26, N'STARDEW-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (79, 27, N'DAVE-DIVER-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (80, 27, N'DAVE-DIVER-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (81, 27, N'DAVE-DIVER-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (82, 28, N'STARFIELD-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (83, 28, N'STARFIELD-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (84, 28, N'STARFIELD-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (85, 29, N'CITIES-SL2-KEY-0001', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (86, 29, N'CITIES-SL2-KEY-0002', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
INSERT [dbo].[license_keys] ([id], [game_id], [keyString], [order_item_id], [owner_id], [status], [createdAt], [assignedAt], [order_item_entity_id]) VALUES (87, 29, N'CITIES-SL2-KEY-0003', NULL, NULL, N'AVAILABLE', CAST(N'2026-05-01T00:00:00.0000000' AS DateTime2), NULL, NULL)
SET IDENTITY_INSERT [dbo].[license_keys] OFF
GO
SET IDENTITY_INSERT [dbo].[order_items] ON 

INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (50, 43, 2, CAST(99000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(99000.00 AS Decimal(15, 2)), 1, N'PAID')
INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (52, 45, 1, CAST(150000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(150000.00 AS Decimal(15, 2)), 1, N'PAID')
INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (53, 46, 4, CAST(59.99 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(59.99 AS Decimal(15, 2)), 1, N'PAID')
INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (60, 53, 3, CAST(250000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(250000.00 AS Decimal(15, 2)), 1, N'PAID')
INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (61, 54, 8, CAST(899000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(899000.00 AS Decimal(15, 2)), 1, N'PAID')
INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (62, 54, 17, CAST(349000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(349000.00 AS Decimal(15, 2)), 1, N'PAID')
INSERT [dbo].[order_items] ([id], [order_id], [game_id], [unitPrice], [discountAmount], [paidAmount], [quantity], [status]) VALUES (63, 55, 13, CAST(599000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(599000.00 AS Decimal(15, 2)), 1, N'PAID')
SET IDENTITY_INSERT [dbo].[order_items] OFF
GO
SET IDENTITY_INSERT [dbo].[orders] ON 

INSERT [dbo].[orders] ([id], [user_id], [subtotalAmount], [discountAmount], [totalAmount], [promo_code_id], [status], [createdAt], [paidAt], [paymentMethod], [fullName], [phone], [address], [province], [district], [ward], [notes]) VALUES (43, 5, CAST(99000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(99000.00 AS Decimal(15, 2)), NULL, N'PAID', CAST(N'2026-05-29T15:16:15.0000000' AS DateTime2), CAST(N'2026-05-29T15:16:15.0000000' AS DateTime2), N'WALLET', N'Nguyễn Thành Vinh', N'0000000000', N'a a a a a', N'12387|Tỉnh Hà Tĩnh', N'', N'Xã Cẩm Trung', N'')
INSERT [dbo].[orders] ([id], [user_id], [subtotalAmount], [discountAmount], [totalAmount], [promo_code_id], [status], [createdAt], [paidAt], [paymentMethod], [fullName], [phone], [address], [province], [district], [ward], [notes]) VALUES (45, 5, CAST(150000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(150000.00 AS Decimal(15, 2)), NULL, N'PAID', CAST(N'2026-05-29T15:21:22.0000000' AS DateTime2), CAST(N'2026-05-29T15:21:22.0000000' AS DateTime2), N'WALLET', N'Nguyễn Thành Vinh', N'0000000000', N'a a a a a', N'12387|Tỉnh Hà Tĩnh', N'', N'Xã Yên Hòa', N'')
INSERT [dbo].[orders] ([id], [user_id], [subtotalAmount], [discountAmount], [totalAmount], [promo_code_id], [status], [createdAt], [paidAt], [paymentMethod], [fullName], [phone], [address], [province], [district], [ward], [notes]) VALUES (46, 5, CAST(59.99 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(59.99 AS Decimal(15, 2)), NULL, N'PAID', CAST(N'2026-05-29T15:22:24.0000000' AS DateTime2), CAST(N'2026-05-29T15:22:24.0000000' AS DateTime2), N'WALLET', N'Nguyễn Thành Vinh', N'0000000000', N'a a a a a', N'12386|Tỉnh Nghệ An', N'', N'Xã Minh Châu', N'')
INSERT [dbo].[orders] ([id], [user_id], [subtotalAmount], [discountAmount], [totalAmount], [promo_code_id], [status], [createdAt], [paidAt], [paymentMethod], [fullName], [phone], [address], [province], [district], [ward], [notes]) VALUES (53, 5, CAST(250000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(250000.00 AS Decimal(15, 2)), NULL, N'PAID', CAST(N'2026-05-29T17:50:32.0000000' AS DateTime2), CAST(N'2026-05-29T17:50:32.0000000' AS DateTime2), N'BANK', N'Nguyễn Thành Vinh', N'0000000000', N'a a a a a', N'12387|Tỉnh Hà Tĩnh', N'', N'Xã Yên Hòa', N'')
INSERT [dbo].[orders] ([id], [user_id], [subtotalAmount], [discountAmount], [totalAmount], [promo_code_id], [status], [createdAt], [paidAt], [paymentMethod], [fullName], [phone], [address], [province], [district], [ward], [notes]) VALUES (54, 5, CAST(1248000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(1248000.00 AS Decimal(15, 2)), NULL, N'PAID', CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2), CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2), N'WALLET', N'Nguyễn Thành Vinh', N'0000000000', N'a a a a a', N'12388|Tỉnh Quảng Trị', N'', N'Xã Tuyên Bình', N'')
INSERT [dbo].[orders] ([id], [user_id], [subtotalAmount], [discountAmount], [totalAmount], [promo_code_id], [status], [createdAt], [paidAt], [paymentMethod], [fullName], [phone], [address], [province], [district], [ward], [notes]) VALUES (55, 5, CAST(599000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)), CAST(599000.00 AS Decimal(15, 2)), NULL, N'PAID', CAST(N'2026-06-01T21:50:29.0000000' AS DateTime2), CAST(N'2026-06-01T21:50:29.0000000' AS DateTime2), N'WALLET', N'Nguyễn Thành Vinh', N'0000000000', N'a a a a a', N'12394|Tỉnh Đắk Lắk', N'', N'Phường Phú Yên', N'')
SET IDENTITY_INSERT [dbo].[orders] OFF
GO
SET IDENTITY_INSERT [dbo].[promo_codes] ON 

INSERT [dbo].[promo_codes] ([id], [publisher_id], [code], [discountPercentage], [expiryDate], [usageLimit], [currentUsage], [status]) VALUES (1, NULL, N'SALE10', CAST(10.00 AS Decimal(5, 2)), NULL, 100, 0, N'ACTIVE')
SET IDENTITY_INSERT [dbo].[promo_codes] OFF
GO
SET IDENTITY_INSERT [dbo].[publisher_profiles] ON 

INSERT [dbo].[publisher_profiles] ([id], [user_id], [companyName], [website], [supportEmail]) VALUES (1, 2, N'Demo Studio', NULL, N'publisher@test.com')
INSERT [dbo].[publisher_profiles] ([id], [user_id], [companyName], [website], [supportEmail]) VALUES (2, 1, N'Ubisoft Entertainment', N'https://ubisoft.com', NULL)
INSERT [dbo].[publisher_profiles] ([id], [user_id], [companyName], [website], [supportEmail]) VALUES (3, 8, N'GameForge Studios', N'https://gamestore.example', N'publisher1@gamestore.local')
SET IDENTITY_INSERT [dbo].[publisher_profiles] OFF
GO
SET IDENTITY_INSERT [dbo].[roles] ON 

INSERT [dbo].[roles] ([id], [code], [description]) VALUES (1, N'ROLE_USER', N'Người dùng bình thường')
INSERT [dbo].[roles] ([id], [code], [description]) VALUES (2, N'ROLE_PUBLISHER', N'Nhà phát hành')
INSERT [dbo].[roles] ([id], [code], [description]) VALUES (3, N'ROLE_ADMIN', N'Quản trị viên')
SET IDENTITY_INSERT [dbo].[roles] OFF
GO
INSERT [dbo].[system_settings] ([setting_key], [setting_value]) VALUES (N'PLATFORM_COMMISSION_PERCENTAGE', N'10.0')
INSERT [dbo].[system_settings] ([setting_key], [setting_value]) VALUES (N'PLATFORM_COMMISSION_RATE', N'10.00')
GO
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (1, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (2, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (3, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (3, 2)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (5, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (6, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (7, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (8, 1)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (8, 2)
INSERT [dbo].[user_roles] ([user_id], [role_id]) VALUES (11, 1)
GO
SET IDENTITY_INSERT [dbo].[users] ON 

INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (1, N'user@test.com', N'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.wEfmFGpXRa3T.AzGKy', N'Demo User', N'default-avatar.png', N'ACTIVE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), N'demouser')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (2, N'publisher@test.com', N'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.wEfmFGpXRa3T.AzGKy', N'Demo Publisher', N'default-avatar.png', N'ACTIVE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), N'demopublisher')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (3, N'admin@test.com', N'$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.wEfmFGpXRa3T.AzGKy', N'Demo Admin', N'default-avatar.png', N'ACTIVE', CAST(N'2026-04-27T18:29:19.0000000' AS DateTime2), N'demoadmin')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (5, N'konguvinh@gmail.com', N'$2a$10$La9cfwUvN0aBa/IN51.ASOPkBooVjgEiMAk3S2fkwqtOfimW6ckqm', N'Vih60seconds', NULL, N'ACTIVE', CAST(N'2026-05-28T22:36:12.0000000' AS DateTime2), N'Vih60seconds')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (6, N'hooahoahuyenhoa@gmail.com', N'$2a$10$5n2Oo3Y/x9eeSp1kHFlRFOlmK5.9Ps/eqxccLlwLvHHcGWA.3yZjC', N'Hà Thái Tuệ', NULL, N'ACTIVE', CAST(N'2026-05-28T23:09:02.0000000' AS DateTime2), N'user')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (7, N'testuser@gamestore.local', N'\\\.lh5apxBMqLNDbGu2u', N'Test User', N'default-avatar.png', N'ACTIVE', CAST(N'2026-06-01T21:57:27.0000000' AS DateTime2), N'testuser')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (8, N'publisher1@gamestore.local', N'\\\.8G1b2AZCYUXih7qEtnWgCIfDKGfmlii', N'Publisher One', N'default-avatar.png', N'ACTIVE', CAST(N'2026-06-01T21:58:11.0000000' AS DateTime2), N'publisher1')
INSERT [dbo].[users] ([id], [email], [password], [fullName], [avatar], [status], [createdAt], [username]) VALUES (11, N'trin48500@gmail.com', N'$2a$10$mz05ZymkuObkALP7eet/L.uauNJEQJjBQSE6HZ5WSZwRNzI2NLNGK', N'Tueeeeeeee', N'default-avatar.png', N'ACTIVE', CAST(N'2026-06-01T22:41:22.0000000' AS DateTime2), N'TueIoT')
SET IDENTITY_INSERT [dbo].[users] OFF
GO
SET IDENTITY_INSERT [dbo].[wallet_transactions] ON 

INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (10, 5, N'DEPOSIT', CAST(200000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780034377307', CAST(N'2026-05-29T12:59:37.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (11, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780035518461', CAST(N'2026-05-29T13:18:38.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (12, 5, N'DEPOSIT', CAST(200000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780035662908', CAST(N'2026-05-29T13:21:03.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (13, 5, N'DEPOSIT', CAST(200000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780036294105', CAST(N'2026-05-29T13:31:34.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (15, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780036372716', CAST(N'2026-05-29T13:32:53.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (16, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780037147056', CAST(N'2026-05-29T13:45:47.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (20, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780038148114', CAST(N'2026-05-29T14:02:28.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (22, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780039013432', CAST(N'2026-05-29T14:16:53.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (35, 5, N'PURCHASE', CAST(99000.00 AS Decimal(15, 2)), N'SUCCESS', N'ORDER_1780042575292', CAST(N'2026-05-29T15:16:15.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (37, 5, N'PURCHASE', CAST(150000.00 AS Decimal(15, 2)), N'SUCCESS', N'ORDER_1780042882063', CAST(N'2026-05-29T15:21:22.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (38, 5, N'PURCHASE', CAST(59.99 AS Decimal(15, 2)), N'SUCCESS', N'ORDER_1780042944013', CAST(N'2026-05-29T15:22:24.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (39, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780049912102', CAST(N'2026-05-29T17:18:32.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (44, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780051881211', CAST(N'2026-05-29T17:51:21.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (45, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780070355949', CAST(N'2026-05-29T22:59:16.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (46, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780071186558', CAST(N'2026-05-29T23:13:07.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (47, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780071771181', CAST(N'2026-05-29T23:22:51.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (48, 5, N'PURCHASE', CAST(1248000.00 AS Decimal(15, 2)), N'SUCCESS', N'ORDER_1780071792251', CAST(N'2026-05-29T23:23:12.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (49, 5, N'DEPOSIT', CAST(100000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780324671476', CAST(N'2026-06-01T21:37:51.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (50, 5, N'DEPOSIT', CAST(530000.00 AS Decimal(15, 2)), N'SUCCESS', N'RECH_1780325360869', CAST(N'2026-06-01T21:49:21.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (51, 5, N'PURCHASE', CAST(599000.00 AS Decimal(15, 2)), N'SUCCESS', N'ORDER_1780325428787', CAST(N'2026-06-01T21:50:29.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (53, 6, N'DEPOSIT', CAST(5000000.00 AS Decimal(15, 2)), N'SUCCESS', N'SEED', CAST(N'2026-06-01T21:58:00.0000000' AS DateTime2))
INSERT [dbo].[wallet_transactions] ([id], [wallet_id], [type], [amount], [status], [referenceId], [createdAt]) VALUES (54, 7, N'DEPOSIT', CAST(10000000.00 AS Decimal(15, 2)), N'SUCCESS', N'SEED', CAST(N'2026-06-01T21:58:11.0000000' AS DateTime2))
SET IDENTITY_INSERT [dbo].[wallet_transactions] OFF
GO
SET IDENTITY_INSERT [dbo].[wallets] ON 

INSERT [dbo].[wallets] ([id], [user_id], [balance]) VALUES (4, 6, CAST(0.00 AS Decimal(15, 2)))
INSERT [dbo].[wallets] ([id], [user_id], [balance]) VALUES (5, 5, CAST(133940.01 AS Decimal(15, 2)))
INSERT [dbo].[wallets] ([id], [user_id], [balance]) VALUES (6, 7, CAST(5000000.00 AS Decimal(15, 2)))
INSERT [dbo].[wallets] ([id], [user_id], [balance]) VALUES (7, 8, CAST(10000000.00 AS Decimal(15, 2)))
INSERT [dbo].[wallets] ([id], [user_id], [balance]) VALUES (10, 11, CAST(0.00 AS Decimal(15, 2)))
SET IDENTITY_INSERT [dbo].[wallets] OFF
GO
/****** Object:  Index [UQ_cart_items_user_game]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[cart_items] ADD  CONSTRAINT [UQ_cart_items_user_game] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[game_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__categori__32DD1E4C1E20BC85]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[categories] ADD UNIQUE NONCLUSTERED 
(
	[slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__categori__72E12F1B5E63AC46]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[categories] ADD UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__games__32DD1E4CAE8E39EE]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[games] ADD UNIQUE NONCLUSTERED 
(
	[slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__library___A9027E2219F9BC57]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[library_items] ADD UNIQUE NONCLUSTERED 
(
	[license_key_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_library_items_user_game]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[library_items] ADD  CONSTRAINT [UQ_library_items_user_game] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[game_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__license___71C28F6A8EC00D47]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[license_keys] ADD UNIQUE NONCLUSTERED 
(
	[keyString] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UX_license_keys_order_item_id]    Script Date: 6/1/2026 10:45:35 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_license_keys_order_item_id] ON [dbo].[license_keys]
(
	[order_item_id] ASC
)
WHERE ([order_item_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_order_items_order_game]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[order_items] ADD  CONSTRAINT [UQ_order_items_order_game] UNIQUE NONCLUSTERED 
(
	[order_id] ASC,
	[game_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__promo_co__357D4CF99E9273B5]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[promo_codes] ADD UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__publishe__B9BE370E4AEC9F92]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[publisher_profiles] ADD UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__refund_r__3764B6BDD0FF42E9]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[refund_requests] ADD UNIQUE NONCLUSTERED 
(
	[order_item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_reviews_user_game]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[reviews] ADD  CONSTRAINT [UQ_reviews_user_game] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[game_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__roles__357D4CF9D928433D]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[roles] ADD UNIQUE NONCLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__users__AB6E61647EE7170F]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[users] ADD UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_users_email]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [UQ_users_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__wallets__B9BE370E3EECF565]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[wallets] ADD UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_wishlists_user_game]    Script Date: 6/1/2026 10:45:35 PM ******/
ALTER TABLE [dbo].[wishlists] ADD  CONSTRAINT [UQ_wishlists_user_game] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[game_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cart_items] ADD  DEFAULT ((1)) FOR [quantity]
GO
ALTER TABLE [dbo].[cart_items] ADD  DEFAULT (sysdatetime()) FOR [addedAt]
GO
ALTER TABLE [dbo].[game_media] ADD  DEFAULT ((0)) FOR [isPrimary]
GO
ALTER TABLE [dbo].[games] ADD  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[games] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[games] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[kyc_requests] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[kyc_requests] ADD  DEFAULT (sysdatetime()) FOR [submittedAt]
GO
ALTER TABLE [dbo].[library_items] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[library_items] ADD  DEFAULT (sysdatetime()) FOR [acquiredAt]
GO
ALTER TABLE [dbo].[license_keys] ADD  DEFAULT ('AVAILABLE') FOR [status]
GO
ALTER TABLE [dbo].[license_keys] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[order_items] ADD  DEFAULT ((0)) FOR [discountAmount]
GO
ALTER TABLE [dbo].[order_items] ADD  DEFAULT ((0)) FOR [paidAmount]
GO
ALTER TABLE [dbo].[order_items] ADD  DEFAULT ((1)) FOR [quantity]
GO
ALTER TABLE [dbo].[order_items] ADD  DEFAULT ('PAID') FOR [status]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ((0)) FOR [subtotalAmount]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ((0)) FOR [discountAmount]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ((0)) FOR [totalAmount]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[patch_notes] ADD  DEFAULT (sysdatetime()) FOR [publishedAt]
GO
ALTER TABLE [dbo].[payout_requests] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[payout_requests] ADD  DEFAULT (sysdatetime()) FOR [requestedAt]
GO
ALTER TABLE [dbo].[promo_codes] ADD  DEFAULT ((0)) FOR [currentUsage]
GO
ALTER TABLE [dbo].[promo_codes] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[refund_requests] ADD  DEFAULT ((0)) FOR [amount]
GO
ALTER TABLE [dbo].[refund_requests] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[refund_requests] ADD  DEFAULT (sysdatetime()) FOR [requestedAt]
GO
ALTER TABLE [dbo].[reviews] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[ticket_messages] ADD  DEFAULT (sysdatetime()) FOR [sentAt]
GO
ALTER TABLE [dbo].[tickets] ADD  DEFAULT ('OPEN') FOR [status]
GO
ALTER TABLE [dbo].[tickets] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (N'default-avatar.png') FOR [avatar]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ('ACTIVE') FOR [status]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[wallet_transactions] ADD  DEFAULT (sysdatetime()) FOR [createdAt]
GO
ALTER TABLE [dbo].[wallets] ADD  DEFAULT ((0)) FOR [balance]
GO
ALTER TABLE [dbo].[wishlists] ADD  DEFAULT (sysdatetime()) FOR [addedAt]
GO
ALTER TABLE [dbo].[cart_items]  WITH CHECK ADD  CONSTRAINT [FK_cart_items_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[cart_items] CHECK CONSTRAINT [FK_cart_items_games]
GO
ALTER TABLE [dbo].[cart_items]  WITH CHECK ADD  CONSTRAINT [FK_cart_items_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[cart_items] CHECK CONSTRAINT [FK_cart_items_users]
GO
ALTER TABLE [dbo].[game_categories]  WITH CHECK ADD  CONSTRAINT [FK_game_categories_categories] FOREIGN KEY([category_id])
REFERENCES [dbo].[categories] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[game_categories] CHECK CONSTRAINT [FK_game_categories_categories]
GO
ALTER TABLE [dbo].[game_categories]  WITH CHECK ADD  CONSTRAINT [FK_game_categories_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[game_categories] CHECK CONSTRAINT [FK_game_categories_games]
GO
ALTER TABLE [dbo].[game_media]  WITH CHECK ADD  CONSTRAINT [FK_game_media_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[game_media] CHECK CONSTRAINT [FK_game_media_games]
GO
ALTER TABLE [dbo].[games]  WITH CHECK ADD  CONSTRAINT [FK_games_publishers] FOREIGN KEY([publisher_id])
REFERENCES [dbo].[publisher_profiles] ([id])
GO
ALTER TABLE [dbo].[games] CHECK CONSTRAINT [FK_games_publishers]
GO
ALTER TABLE [dbo].[kyc_requests]  WITH CHECK ADD  CONSTRAINT [FK_kyc_requests_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[kyc_requests] CHECK CONSTRAINT [FK_kyc_requests_users]
GO
ALTER TABLE [dbo].[library_items]  WITH CHECK ADD  CONSTRAINT [FK_library_items_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[library_items] CHECK CONSTRAINT [FK_library_items_games]
GO
ALTER TABLE [dbo].[library_items]  WITH CHECK ADD  CONSTRAINT [FK_library_items_license_keys] FOREIGN KEY([license_key_id])
REFERENCES [dbo].[license_keys] ([id])
GO
ALTER TABLE [dbo].[library_items] CHECK CONSTRAINT [FK_library_items_license_keys]
GO
ALTER TABLE [dbo].[library_items]  WITH CHECK ADD  CONSTRAINT [FK_library_items_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[library_items] CHECK CONSTRAINT [FK_library_items_users]
GO
ALTER TABLE [dbo].[license_keys]  WITH CHECK ADD  CONSTRAINT [FK_license_keys_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[license_keys] CHECK CONSTRAINT [FK_license_keys_games]
GO
ALTER TABLE [dbo].[license_keys]  WITH CHECK ADD  CONSTRAINT [FK_license_keys_order_items] FOREIGN KEY([order_item_id])
REFERENCES [dbo].[order_items] ([id])
GO
ALTER TABLE [dbo].[license_keys] CHECK CONSTRAINT [FK_license_keys_order_items]
GO
ALTER TABLE [dbo].[license_keys]  WITH CHECK ADD  CONSTRAINT [FK_license_keys_users] FOREIGN KEY([owner_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[license_keys] CHECK CONSTRAINT [FK_license_keys_users]
GO
ALTER TABLE [dbo].[order_items]  WITH CHECK ADD  CONSTRAINT [FK_order_items_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[order_items] CHECK CONSTRAINT [FK_order_items_games]
GO
ALTER TABLE [dbo].[order_items]  WITH CHECK ADD  CONSTRAINT [FK_order_items_orders] FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([id])
GO
ALTER TABLE [dbo].[order_items] CHECK CONSTRAINT [FK_order_items_orders]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [FK_orders_promo_codes] FOREIGN KEY([promo_code_id])
REFERENCES [dbo].[promo_codes] ([id])
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [FK_orders_promo_codes]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [FK_orders_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [FK_orders_users]
GO
ALTER TABLE [dbo].[patch_notes]  WITH CHECK ADD  CONSTRAINT [FK_patch_notes_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[patch_notes] CHECK CONSTRAINT [FK_patch_notes_games]
GO
ALTER TABLE [dbo].[payout_requests]  WITH CHECK ADD  CONSTRAINT [FK_payout_requests_publishers] FOREIGN KEY([publisher_id])
REFERENCES [dbo].[publisher_profiles] ([id])
GO
ALTER TABLE [dbo].[payout_requests] CHECK CONSTRAINT [FK_payout_requests_publishers]
GO
ALTER TABLE [dbo].[promo_codes]  WITH CHECK ADD  CONSTRAINT [FK_promo_codes_publishers] FOREIGN KEY([publisher_id])
REFERENCES [dbo].[publisher_profiles] ([id])
GO
ALTER TABLE [dbo].[promo_codes] CHECK CONSTRAINT [FK_promo_codes_publishers]
GO
ALTER TABLE [dbo].[promo_codes]  WITH CHECK ADD  CONSTRAINT [FK_promo_codes_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[promo_codes] CHECK CONSTRAINT [FK_promo_codes_games]
GO
ALTER TABLE [dbo].[publisher_profiles]  WITH CHECK ADD  CONSTRAINT [FK_publisher_profiles_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[publisher_profiles] CHECK CONSTRAINT [FK_publisher_profiles_users]
GO
ALTER TABLE [dbo].[refund_requests]  WITH CHECK ADD  CONSTRAINT [FK_refund_requests_order_items] FOREIGN KEY([order_item_id])
REFERENCES [dbo].[order_items] ([id])
GO
ALTER TABLE [dbo].[refund_requests] CHECK CONSTRAINT [FK_refund_requests_order_items]
GO
ALTER TABLE [dbo].[refund_requests]  WITH CHECK ADD  CONSTRAINT [FK_refund_requests_orders] FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([id])
GO
ALTER TABLE [dbo].[refund_requests] CHECK CONSTRAINT [FK_refund_requests_orders]
GO
ALTER TABLE [dbo].[refund_requests]  WITH CHECK ADD  CONSTRAINT [FK_refund_requests_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[refund_requests] CHECK CONSTRAINT [FK_refund_requests_users]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [FK_reviews_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [FK_reviews_games]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [FK_reviews_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [FK_reviews_users]
GO
ALTER TABLE [dbo].[ticket_messages]  WITH CHECK ADD  CONSTRAINT [FK_ticket_messages_tickets] FOREIGN KEY([ticket_id])
REFERENCES [dbo].[tickets] ([id])
GO
ALTER TABLE [dbo].[ticket_messages] CHECK CONSTRAINT [FK_ticket_messages_tickets]
GO
ALTER TABLE [dbo].[ticket_messages]  WITH CHECK ADD  CONSTRAINT [FK_ticket_messages_users] FOREIGN KEY([sender_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[ticket_messages] CHECK CONSTRAINT [FK_ticket_messages_users]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_games] FOREIGN KEY([related_game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_games]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_orders] FOREIGN KEY([related_order_id])
REFERENCES [dbo].[orders] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_orders]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [FK_tickets_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [FK_tickets_users]
GO
ALTER TABLE [dbo].[user_roles]  WITH CHECK ADD  CONSTRAINT [FK_user_roles_roles] FOREIGN KEY([role_id])
REFERENCES [dbo].[roles] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_roles]
GO
ALTER TABLE [dbo].[user_roles]  WITH CHECK ADD  CONSTRAINT [FK_user_roles_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[user_roles] CHECK CONSTRAINT [FK_user_roles_users]
GO
ALTER TABLE [dbo].[wallet_transactions]  WITH CHECK ADD  CONSTRAINT [FK_wallet_transactions_wallets] FOREIGN KEY([wallet_id])
REFERENCES [dbo].[wallets] ([id])
GO
ALTER TABLE [dbo].[wallet_transactions] CHECK CONSTRAINT [FK_wallet_transactions_wallets]
GO
ALTER TABLE [dbo].[wallets]  WITH CHECK ADD  CONSTRAINT [FK_wallets_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[wallets] CHECK CONSTRAINT [FK_wallets_users]
GO
ALTER TABLE [dbo].[wishlists]  WITH CHECK ADD  CONSTRAINT [FK_wishlists_games] FOREIGN KEY([game_id])
REFERENCES [dbo].[games] ([id])
GO
ALTER TABLE [dbo].[wishlists] CHECK CONSTRAINT [FK_wishlists_games]
GO
ALTER TABLE [dbo].[wishlists]  WITH CHECK ADD  CONSTRAINT [FK_wishlists_users] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[wishlists] CHECK CONSTRAINT [FK_wishlists_users]
GO
ALTER TABLE [dbo].[cart_items]  WITH CHECK ADD  CONSTRAINT [CK_cart_items_quantity] CHECK  (([quantity]=(1)))
GO
ALTER TABLE [dbo].[cart_items] CHECK CONSTRAINT [CK_cart_items_quantity]
GO
ALTER TABLE [dbo].[game_media]  WITH CHECK ADD  CONSTRAINT [CK_game_media_type] CHECK  (([mediaType]='VIDEO_TRAILER' OR [mediaType]='IMAGE'))
GO
ALTER TABLE [dbo].[game_media] CHECK CONSTRAINT [CK_game_media_type]
GO
ALTER TABLE [dbo].[games]  WITH CHECK ADD  CONSTRAINT [CK_games_price] CHECK  (([price]>=(0)))
GO
ALTER TABLE [dbo].[games] CHECK CONSTRAINT [CK_games_price]
GO
ALTER TABLE [dbo].[games]  WITH CHECK ADD  CONSTRAINT [CK_games_status] CHECK  (([status]='REJECTED' OR [status]='PENDING' OR [status]='COMING_SOON' OR [status]='INACTIVE' OR [status]='ACTIVE'))
GO
ALTER TABLE [dbo].[games] CHECK CONSTRAINT [CK_games_status]
GO
ALTER TABLE [dbo].[kyc_requests]  WITH CHECK ADD  CONSTRAINT [CK_kyc_requests_status] CHECK  (([status]='REJECTED' OR [status]='APPROVED' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[kyc_requests] CHECK CONSTRAINT [CK_kyc_requests_status]
GO
ALTER TABLE [dbo].[library_items]  WITH CHECK ADD  CONSTRAINT [CK_library_items_status] CHECK  (([status]='DISABLED' OR [status]='REFUNDED' OR [status]='ACTIVE'))
GO
ALTER TABLE [dbo].[library_items] CHECK CONSTRAINT [CK_library_items_status]
GO
ALTER TABLE [dbo].[license_keys]  WITH CHECK ADD  CONSTRAINT [CK_license_keys_status] CHECK  (([status]='DISABLED' OR [status]='REFUNDED' OR [status]='SOLD' OR [status]='RESERVED' OR [status]='AVAILABLE'))
GO
ALTER TABLE [dbo].[license_keys] CHECK CONSTRAINT [CK_license_keys_status]
GO
ALTER TABLE [dbo].[order_items]  WITH CHECK ADD  CONSTRAINT [CK_order_items_amounts] CHECK  (([unitPrice]>=(0) AND [discountAmount]>=(0) AND [paidAmount]>=(0) AND [discountAmount]<=[unitPrice]))
GO
ALTER TABLE [dbo].[order_items] CHECK CONSTRAINT [CK_order_items_amounts]
GO
ALTER TABLE [dbo].[order_items]  WITH CHECK ADD  CONSTRAINT [CK_order_items_quantity] CHECK  (([quantity]=(1)))
GO
ALTER TABLE [dbo].[order_items] CHECK CONSTRAINT [CK_order_items_quantity]
GO
ALTER TABLE [dbo].[order_items]  WITH CHECK ADD  CONSTRAINT [CK_order_items_status] CHECK  (([status]='REFUND_REJECTED' OR [status]='REFUNDED' OR [status]='REFUND_REQUESTED' OR [status]='PAID'))
GO
ALTER TABLE [dbo].[order_items] CHECK CONSTRAINT [CK_order_items_status]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [CK_orders_amounts] CHECK  (([subtotalAmount]>=(0) AND [discountAmount]>=(0) AND [totalAmount]>=(0) AND [discountAmount]<=[subtotalAmount]))
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [CK_orders_amounts]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD  CONSTRAINT [CK_orders_status] CHECK  (([status]='REFUNDED' OR [status]='PARTIALLY_REFUNDED' OR [status]='CANCELLED' OR [status]='FAILED' OR [status]='PAID' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[orders] CHECK CONSTRAINT [CK_orders_status]
GO
ALTER TABLE [dbo].[payout_requests]  WITH CHECK ADD  CONSTRAINT [CK_payout_requests_amount] CHECK  (([amount]>(0)))
GO
ALTER TABLE [dbo].[payout_requests] CHECK CONSTRAINT [CK_payout_requests_amount]
GO
ALTER TABLE [dbo].[payout_requests]  WITH CHECK ADD  CONSTRAINT [CK_payout_requests_status] CHECK  (([status]='PAID' OR [status]='REJECTED' OR [status]='APPROVED' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[payout_requests] CHECK CONSTRAINT [CK_payout_requests_status]
GO
ALTER TABLE [dbo].[promo_codes]  WITH CHECK ADD  CONSTRAINT [CK_promo_codes_discount] CHECK  (([discountPercentage]>=(0) AND [discountPercentage]<=(100)))
GO
ALTER TABLE [dbo].[promo_codes] CHECK CONSTRAINT [CK_promo_codes_discount]
GO
ALTER TABLE [dbo].[promo_codes]  WITH CHECK ADD  CONSTRAINT [CK_promo_codes_status] CHECK  (([status]='EXPIRED' OR [status]='INACTIVE' OR [status]='ACTIVE'))
GO
ALTER TABLE [dbo].[promo_codes] CHECK CONSTRAINT [CK_promo_codes_status]
GO
ALTER TABLE [dbo].[promo_codes]  WITH CHECK ADD  CONSTRAINT [CK_promo_codes_usage] CHECK  (([currentUsage]>=(0) AND ([usageLimit] IS NULL OR [currentUsage]<=[usageLimit])))
GO
ALTER TABLE [dbo].[promo_codes] CHECK CONSTRAINT [CK_promo_codes_usage]
GO
ALTER TABLE [dbo].[refund_requests]  WITH CHECK ADD  CONSTRAINT [CK_refund_requests_amount] CHECK  (([amount]>=(0)))
GO
ALTER TABLE [dbo].[refund_requests] CHECK CONSTRAINT [CK_refund_requests_amount]
GO
ALTER TABLE [dbo].[refund_requests]  WITH CHECK ADD  CONSTRAINT [CK_refund_requests_status] CHECK  (([status]='REJECTED' OR [status]='APPROVED' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[refund_requests] CHECK CONSTRAINT [CK_refund_requests_status]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [CK_reviews_rating] CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [CK_reviews_rating]
GO
ALTER TABLE [dbo].[tickets]  WITH CHECK ADD  CONSTRAINT [CK_tickets_status] CHECK  (([status]='CLOSED' OR [status]='RESOLVED' OR [status]='WAITING_USER' OR [status]='IN_PROGRESS' OR [status]='OPEN'))
GO
ALTER TABLE [dbo].[tickets] CHECK CONSTRAINT [CK_tickets_status]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CK_users_status] CHECK  (([status]='DELETED' OR [status]='LOCKED' OR [status]='ACTIVE'))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CK_users_status]
GO
ALTER TABLE [dbo].[wallet_transactions]  WITH CHECK ADD  CONSTRAINT [CK_wallet_transactions_amount] CHECK  (([amount]>(0)))
GO
ALTER TABLE [dbo].[wallet_transactions] CHECK CONSTRAINT [CK_wallet_transactions_amount]
GO
ALTER TABLE [dbo].[wallet_transactions]  WITH CHECK ADD  CONSTRAINT [CK_wallet_transactions_status] CHECK  (([status]='CANCELLED' OR [status]='FAILED' OR [status]='SUCCESS' OR [status]='PENDING'))
GO
ALTER TABLE [dbo].[wallet_transactions] CHECK CONSTRAINT [CK_wallet_transactions_status]
GO
ALTER TABLE [dbo].[wallet_transactions]  WITH CHECK ADD  CONSTRAINT [CK_wallet_transactions_type] CHECK  (([type]='ADJUSTMENT' OR [type]='PAYOUT' OR [type]='REFUND' OR [type]='PURCHASE' OR [type]='WITHDRAW' OR [type]='DEPOSIT'))
GO
ALTER TABLE [dbo].[wallet_transactions] CHECK CONSTRAINT [CK_wallet_transactions_type]
GO
ALTER TABLE [dbo].[wallets]  WITH CHECK ADD  CONSTRAINT [CK_wallets_balance] CHECK  (([balance]>=(0)))
GO
ALTER TABLE [dbo].[wallets] CHECK CONSTRAINT [CK_wallets_balance]
GO
USE [master]
GO
ALTER DATABASE [GameStore] SET  READ_WRITE 
GO
