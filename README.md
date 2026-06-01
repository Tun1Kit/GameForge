# GameForge Store

Digital game marketplace — Spring MVC + Hibernate + SQL Server.

## Tech Stack

| Component | Technology |
|---|---|
| Framework | Spring MVC 5.3.20 |
| ORM | Hibernate 5.6.9 (SQLServer2012Dialect) |
| Database | SQL Server (localhost\SQLEXPRESS, `GameStore`) |
| Auth | BCrypt via Spring Security Crypto |
| Build | Maven (Java 1.8, WAR packaging) |
| View | JSP + JSTL 1.2 + Bootstrap 5 |
| UI | Neo-Brutalism design, dark/light theme |

## Prerequisites

```
- JDK 8+
- Maven 3.6+
- SQL Server (localhost\SQLEXPRESS instance)
- Apache Tomcat 8.5+ or 9.0+
```

## Database Setup

```sql
-- 1. Chạy Store.sql để tạo database và schema
-- 2. Chạy migration scripts trong plan/ nếu cần
--    - plan/migrate-add-username.sql
--    - plan/migrate-add-original-price.sql
```

Cấu hình kết nối trong `src/main/resources/database.properties`:

```properties
jdbc.url=jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=GameStore;encrypt=false;trustServerCertificate=true
jdbc.username=sa
jdbc.password=123456
```

## Build & Run

```bash
# Build WAR
mvn clean package -DskipTests

# Deploy: copy WAR vào Tomcat webapps
cp target/gamestore.war $CATALINA_HOME/webapps/

# Hoặc chạy trực tiếp (dev mode)
mvn tomcat7:run
```

## App URLs

| URL | Description |
|---|---|
| http://localhost:8080/gamestore/ | Trang chủ (game listing) |
| http://localhost:8080/gamestore/login | Đăng nhập / Đăng ký |
| http://localhost:8080/gamestore/dashboard | Dashboard (cần login) |
| http://localhost:8080/gamestore/checkout | Thanh toán (cần login) |
| http://localhost:8080/gamestore/library | Thư viện game (cần login) |
| http://localhost:8080/gamestore/recharge | Nạp tiền ví (cần login) |
| http://localhost:8080/gamestore/transactions | Lịch sử giao dịch (cần login) |

## Test Accounts

```
User:    demouser      / 123
Admin:   demoadmin     / 123
```

Password đã được hash BCrypt. Dùng `PasswordEncoderUtil.encode("123")` để tạo hash mới.

## Harness System

```
Thư mục gốc chứa 5 file harness cho agent:
  AGENTS.md               — Luật chặn lỗi (13 sections)
  feature_list.json        — Ma trận tính năng (12 features)
  claude-progress.md       — Nhật ký tiến độ + baseline
  quality-document.md      — Chấm điểm A (85/100)
  clean-state-checklist.md — Checklist Tomcat/SQL Server

Thư mục templates/ chứa generic harness templates:
  templates/AGENTS.md, templates/feature_list.json, ...
  (copy ra root khi bắt đầu project mới)
```

## Project Structure

```
src/main/java/com/gamestore/
├── config/         GlobalExceptionHandler
├── controller/     9 Controllers (Auth, Cart, Checkout, Dashboard,
│                  Game, Library, Promo, Profile, Recharge)
├── dao/           BaseDAO, CartItemDAO, UserDAO
├── entity/        12 Entities
├── service/       EmailService
├── util/          PasswordEncoderUtil
└── test/          DbTest

src/main/webapp/
├── assets/css/    7 CSS files (Neo-Brutalism)
├── assets/js/     7 JS files
└── WEB-INF/views/ 8 JSP files
```
