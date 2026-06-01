# GameForge — Clean State Checklist

> Cập nhật: 2026-06-01 | Harness Engineer: Claude Agent | Project: GameForge (Spring MVC + Hibernate + SQL Server)

**Purpose:** Bộ checklist kiểm tra lỗi crash Tomcat và kết nối SQL Server đặc thù của dự án GameForge.

---

## PHẦN 1: PRE-DEPLOYMENT CHECKLIST (Trước khi deploy lên Tomcat)

### 1.1 Database Connectivity (SQL Server)

```
□ Kiểm tra SQL Server đang chạy
    PowerShell: Get-Service -Name *SQL*
    Hoặc: services.msc → tìm "SQL Server (SQLEXPRESS)"

□ Kiểm tra SQL Server Browser service
    PowerShell: Get-Service -Name "SQL Server Browser"
    Required cho named instance (SQLEXPRESS)

□ Verify connection string trong database.properties
    jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=GameStore
    Port mặc định: 1433 (TCP/IP phải enabled)

□ Test kết nối bằng SSMS hoặc sqlcmd
    sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -Q "SELECT 1"

□ Kiểm tra database "GameStore" tồn tại
    sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -Q "SELECT name FROM sys.databases WHERE name = 'GameStore'"

□ Kiểm tra tất cả tables đã được tạo (12 tables)
    sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -Q "SELECT name FROM sys.tables ORDER BY name"

□ Verify JDBC driver compatibility
    mssql-jdbc 9.4.1.jre8 — JDK 8 compatible
    Nếu dùng JDK 11+: upgrade lên mssql-jdbc 12.x
```

### 1.2 Tomcat Setup

```
□ Tomcat version compatibility
    Java 1.8 → Tomcat 8.5.x hoặc 9.0.x
    Java 11+  → Tomcat 9.0.x hoặc 10.0.x
    Check: java -version

□ CATALINA_HOME environment variable
    PowerShell: $env:CATALINA_HOME

□ webapps directory có quyền ghi
    Verify: Test-Path "$env:CATALINA_HOME\webapps"

□ port không bị conflict
    Mặc định: 8080 — kiểm tra: netstat -ano | findstr :8080
    Nếu conflict: sửa server.xml → <Connector port="8081">

□ Context path: /gamestore
    WAR file phải đặt tên: gamestore.war
    Hoặc trong server.xml: <Context path="/gamestore" ...>
```

### 1.3 Maven Build

```
□ Build không có lỗi
    mvn clean package -DskipTests
    Xem output: target/gamestore.war phải tồn tại

□ WAR file size hợp lý
    Không nên < 5MB (có thể thiếu dependencies)
    Không nên > 100MB (có thể duplicate jars)

□ Kiểm tra WEB-INF/lib trong WAR
   unzip -l target/gamestore.war | findstr "WEB-INF/lib"

□ Verify pom.xml không có missing dependencies
    Check: mvn dependency:tree -Dincludes=com.microsoft.sqlserver
```

### 1.4 Spring Configuration

```
□ spring-servlet.xml không có lỗi XML syntax
    Validate bằng: [System.Xml.XmlDocument] hoặc online validator

□ Package scan path đúng: com.gamestore
    Kiểm tra tất cả @Controller, @Service, @Repository đúng package

□ DataSource bean không có typo
    driverClassName = com.microsoft.sqlserver.jdbc.SQLServerDriver
    URL phải match database.properties

□ Hibernate dialect: SQLServer2012Dialect
    Không dùng MySQLDialect hoặc PostgreSQLDialect

□ Transaction manager bean name: transactionManager
    @EnableTransactionManagement phải reference đúng tên
```

---

## PHẦN 2: TOMCAT STARTUP FAILURE — CHẨN ĐOÁN NHANH

### Lỗi 2.1: `ClassNotFoundException` — SQL Server Driver

```
Dấu hiệu:
    SEVERE: Servlet.service() for servlet [spring-mvc] threw exception
    java.lang.ClassNotFoundException: com.microsoft.sqlserver.jdbc.SQLServerDriver

Nguyên nhân:
    - mssql-jdbc.jar không có trong WEB-INF/lib của WAR
    - Hoặc driver version không tương thích với JDK

Fix:
    1. Verify pom.xml có dependency:
       <dependency>
           <groupId>com.microsoft.sqlserver</groupId>
           <artifactId>mssql-jdbc</artifactId>
           <version>9.4.1.jre8</version>
       </dependency>

    2. Rebuild: mvn clean package -DskipTests

    3. Nếu dùng external Tomcat lib:
       copy target\gamestore\WEB-INF\lib\* %CATALINA_HOME%\lib\

    4. Kiểm tra version compatibility:
       JDK 8     → mssql-jdbc 9.4.1.jre8
       JDK 11+   → mssql-jdbc 12.x.jre11
```

### Lỗi 2.2: `NoSuchBeanDefinitionException` — DataSource

```
Dấu hiệu:
    org.springframework.beans.factory.NoSuchBeanDefinitionException:
    No bean named 'dataSource' available

Nguyên nhân:
    - spring-servlet.xml không define dataSource bean
    - Bean name mismatch: @Qualifier("dataSource") khác tên bean trong XML

Fix:
    1. Verify spring-servlet.xml có:
       <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
           <property name="driverClassName" value="${jdbc.driverClassName}" />
           ...
       </bean>

    2. Verify context:property-placeholder load đúng:
       <context:property-placeholder location="classpath:database.properties" />

    3. Verify database.properties nằm trong src/main/resources/
```

### Lỗi 2.3: `Could not open Hibernate Session for transaction`

```
Dấu hiệu:
    org.hibernate.HibernateException: Could not open Hibernate Session for transaction
    java.sql.SQLException: No suitable driver found

Nguyên nhân:
    - JDBC driver không registered
    - Connection string syntax sai

Fix:
    1. Verify driver class name trong spring-servlet.xml:
       <property name="driverClassName" value="com.microsoft.sqlserver.jdbc.SQLServerDriver" />

    2. Verify connection URL syntax:
       jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=GameStore;encrypt=false;trustServerCertificate=true

    3. Test với simple Java class:
       Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
       Connection conn = DriverManager.getConnection(url, user, pass);

    4. Enable TCP/IP in SQL Server Configuration Manager
       SQL Server Network Configuration → Protocols for SQLEXPRESS → TCP/IP → Enabled
```

### Lỗi 2.4: `SQLServerException: Login failed` — Authentication Error

```
Dấu hiệu:
    com.microsoft.sqlserver.jdbc.SQLServerException: Login failed for user 'sa'.
    The password for the user is not correctly specified.

Nguyên nhân:
    - Sai password trong database.properties
    - SQL Server authentication mode chưa enable
    - Password expired

Fix:
    1. Verify password:
       Kiểm tra database.properties: jdbc.password=123456

    2. Test login bằng SSMS:
       Server: localhost\SQLEXPRESS
       Auth: SQL Server Authentication
       Login: sa
       Password: 123456

    3. Nếu SSMS cũng fail → reset password:
       ALTER LOGIN [sa] WITH PASSWORD = '123456';
       GO
       ALTER LOGIN [sa] WITH CHECK_POLICY = OFF;

    4. Enable Mixed Authentication Mode:
       SSMS → Server Properties → Security → SQL Server and Windows Authentication mode

    5. Restart SQL Server service sau khi đổi auth mode
```

### Lỗi 2.5: `SQLServerException: Cannot open database 'GameStore'`

```
Dấu hiệu:
    com.microsoft.sqlserver.jdbc.SQLServerException: Cannot open database 'GameStore'
    requested by the login. The login failed.

Nguyên nhân:
    - Database GameStore chưa được tạo
    - Database name sai trong connection string

Fix:
    1. Tạo database:
       CREATE DATABASE GameStore;
       GO

    2. Verify database exists:
       SELECT name FROM sys.databases WHERE name = 'GameStore';

    3. Check connection string trong spring-servlet.xml:
       databaseName=GameStore (chính xác case-sensitive)

    4. Verify user có quyền truy cập database:
       USE GameStore;
       GO
       ALTER LOGIN [sa] WITH DEFAULT_DATABASE = GameStore;
```

### Lỗi 2.6: `SQLServerException: TCP/IP connection` — Named Instance

```
Dấu hiệu:
    com.microsoft.sqlserver.jdbc.SQLServerException: TCP/IP connection to the host
    localhost, port 1433 has failed.

Nguyên nhên:
    - TCP/IP protocol disabled cho SQL Server
    - SQL Server Browser service không chạy
    - Port 1433 bị block bởi firewall

Fix:
    1. Mở SQL Server Configuration Manager
       → SQL Server Network Configuration
       → Protocols for SQLEXPRESS
       → Enable TCP/IP

    2. Set TCP Port = 1433 (nếu dynamic port → set static)

    3. Start SQL Server Browser service:
       net start "SQL Server Browser"

    4. Restart SQL Server:
       net stop "SQL Server (SQLEXPRESS)"
       net start "SQL Server (SQLEXPRESS)"

    5. Verify firewall:
       netsh advfirewall firewall show rule name="SQL Server"

    6. Test connection:
       telnet localhost 1433
```

### Lỗi 2.7: `UnsatisfiedDependencyException` — SessionFactory

```
Dấu hiệu:
    org.springframework.beans.factory.UnsatisfiedDependencyException:
    Error creating bean with name 'sessionFactory'

Nguyên nhân:
    - DataSource bean không inject được vào SessionFactory
    - packagesToScan path sai

Fix:
    1. Verify packagesToScan:
       <property name="packagesToScan" value="com.gamestore.entity" />

    2. Verify entity classes có @Entity annotation:
       @Entity
       @Table(name = "Users")  // hoặc để Hibernate tự infer

    3. Check Hibernate version compatibility:
       Hibernate 5.6.9.Final + Spring 5.3.20 → compatible
```

### Lỗi 2.8: `BeanCreationException` — DispatcherServlet

```
Dấu hiệu:
    org.springframework.beans.factory.BeanCreationException:
    Error creating bean with name 'org.springframework.web.servlet.mvc.method.annotation
    .RequestMappingHandlerMapping'

Nguyên nhân:
    - Duplicate @RequestMapping
    - Circular dependency giữa beans
    - Controller class có syntax error

Fix:
    1. Kiểm tra tất cả Controller có @Controller annotation (không @Service)

    2. Verify không có duplicate route:
       grep -r "@RequestMapping" src/main/java/com/gamestore/controller/

    3. Kiểm tra imports đúng:
       import org.springframework.stereotype.Controller;
       import org.springframework.web.bind.annotation.RequestMapping;

    4. Rebuild toàn bộ:
       mvn clean compile
```

---

## PHẦN 3: RUNTIME ERRORS (Sau khi deploy thành công)

### Lỗi 3.1: NullPointerException khi đăng nhập

```
Dấu hiệu:
    java.lang.NullPointerException
    at com.gamestore.controller.AuthController.loginPost()

Nguyên nhân thường gặp:
    - session.getAttribute("user") trả về null → cast NullPointerException
    - User đã có trong session nhưng wallet = null

Fix:
    1. Thêm null check trong AuthController.loginPost():
       User user = userDAO.findByUsername(username);
       if (user == null) { ... }

    2. Verify auto-create wallet logic:
       if (user.getWallet() == null) {
           Wallet wallet = new Wallet();
           wallet.setBalance(BigDecimal.ZERO);
           user.setWallet(wallet);
           userDAO.update(user);
       }

    3. Check User entity có @OneToOne mapping với Wallet:
       @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
       private Wallet wallet;
```

### Lỗi 3.2: Checkout failed — Insufficient Balance

```
Dấu hiệu:
    "Insufficient wallet balance" dù user có đủ tiền

Nguyên nhân:
    - Wallet balance không sync (stale data từ Hibernate session)
    - Transaction không flush kịp

Fix:
    1. Trong CheckoutController.processOrder():
       - Sau khi trừ wallet, force flush:
         session.flush();
         session.refresh(wallet);

    2. Verify balance được update đúng:
       Wallet wallet = baseDAO.findById(user.getWallet().getId());
       if (wallet.getBalance().compareTo(totalPrice) < 0) { ... }
```

### Lỗi 3.3: HTTP 500 khi thêm vào giỏ hàng

```
Dấu hiệu:
    HTTP Status 500 — Internal Server Error
    at com.gamestore.controller.CartApiController.addToCart()

Nguyên nhân:
    - Game không tồn tại trong DB
    - CartItem insert fail (FK constraint)

Fix:
    1. Verify game tồn tại:
       Game game = baseDAO.findById(gameId);
       if (game == null) {
           response.getWriter().print("{\"success\":false,\"message\":\"Game not found\"}");
           return;
       }

    2. Check CartItem entity có đúng FK mapping:
       @ManyToOne
       @JoinColumn(name = "userId")
       private User user;

       @ManyToOne
       @JoinColumn(name = "gameId")
       private Game game;
```

### Lỗi 3.4: `LazyInitializationException`

```
Dấu hiệu:
    org.hibernate.LazyInitializationException:
    could not initialize proxy - no Session

Nguyên nhân:
    - Game entity có EAGER fetch → KHÔNG xảy ra với Game
    - NHƯNG các entity khác (LicenseKey, LibraryItem) dùng LAZY
    - Truy cập lazy field sau khi session đóng

Fix:
    1. Trong LibraryController:
       - Dùng Hibernate.initialize() trong transaction:
         @Transactional
         public String getLibrary(Model model, HttpSession session) {
             Hibernate.initialize(user.getLibraryItems()); // Force load
             return "library";
         }

    2. Hoặc dùng JOIN FETCH trong HQL:
       "FROM LibraryItem li JOIN FETCH li.game JOIN FETCH li.licenseKey WHERE li.user = :user"
```

### Lỗi 3.5: Duplicate Order khi refresh trang

```
Dấu hiệu:
    User refresh /checkout/process → tạo thêm order mới

Nguyên nhân:
    - POST request không có redirect sau khi xử lý
    - Không có idempotency token

Fix:
    1. Trong CheckoutController.processOrder():
       - Sau khi tạo order thành công:
         return "redirect:/checkout/success?orderId=" + orderId;

    2. Hoặc dùng PRG (Post-Redirect-Get) pattern cho form submission

    3. Check order success page:
       - Hiển thị order details
       - Không re-submit form khi refresh
```

### Lỗi 3.6: Promo code validate thất bại liên tục

```
Dấu hiệu:
    {"success":false,"message":"Mã không hợp lệ"}

Nguyên nhân:
    - Promo code đã hết hạn (expiryDate < now)
    - Promo code đã đạt usage limit
    - Promo code không áp dụng cho game được chọn

Fix:
    1. Debug trong PromoApiController.validatePromo():
       System.out.println("Expiry: " + promo.getExpiryDate());
       System.out.println("Now: " + new Date());
       System.out.println("Usage: " + promo.getUsageCount() + "/" + promo.getMaxUsage());

    2. Verify database có dữ liệu promo:
       SELECT code, expiryDate, maxUsage, usageCount FROM PromoCode;

    3. Check PromoCode entity:
       @Temporal(TemporalType.TIMESTAMP)
       private Date expiryDate;
```

### Lỗi 3.7: Recharge không cộng tiền vào wallet

```
Dấu hiệu:
    Wallet balance không tăng sau khi recharge thành công

Nguyên nhân:
    - Hibernate cache — balance chưa được flush
    - Transaction không commit

Fix:
    1. Trong RechargeController.processRecharge():
       session.save(walletTransaction);
       session.flush();  // Force write to DB
       session.refresh(wallet);  // Sync balance về session

    2. Verify @Transactional annotation có:
       @Transactional
       public String processRecharge(...) {
           // ...
       }

    3. Check transactionManager bean trong spring-servlet.xml:
       <bean id="transactionManager" class="...HibernateTransactionManager">
           <property name="sessionFactory" ref="sessionFactory" />
       </bean>
```

### Lỗi 3.8: License Key không hiển thị trong Library

```
Dấu hiệu:
    Library page không hiển thị license key

Nguyên nhân:
    - LibraryItem không có licenseKeyId
    - LicenseKey bị null (chưa được assign)

Fix:
    1. Debug trong LibraryController:
       List<LibraryItem> items = user.getLibraryItems();
       for (LibraryItem item : items) {
           System.out.println("Key: " + item.getLicenseKey());
       }

    2. Verify LibraryItem có @OneToOne với LicenseKey:
       @OneToOne
       @JoinColumn(name = "licenseKeyId")
       private LicenseKey licenseKey;

    3. Check checkout flow tạo LicenseKey trước LibraryItem:
       LicenseKey key = new LicenseKey();
       session.save(key);

       LibraryItem libraryItem = new LibraryItem();
       libraryItem.setLicenseKey(key);
       session.save(libraryItem);
```

---

## PHẦN 4: HEALTH CHECK ENDPOINTS (Để verify sau deploy)

### 4.1 Database Connection Test

```bash
# PowerShell
[System.Data.SqlClient.SqlConnection]::new()
$conn = [System.Data.SqlClient.SqlConnection]::new("Server=localhost\SQLEXPRESS;Database=GameStore;User Id=sa;Password=123456;")
$conn.Open()
if ($conn.State -eq 'Open') { Write-Host "DB: OK" }
$conn.Close()
```

### 4.2 Tomcat Log Analysis

```powershell
# Tìm lỗi trong catalina.out
Select-String -Path "$env:CATALINA_HOME\logs\catalina.out" -Pattern "SEVERE|ERROR|Exception" -Context 2,0

# Tìm warnings về Hibernate
Select-String -Path "$env:CATALINA_HOME\logs\catalina.out" -Pattern "Hibernate|WARN" -Context 1,0
```

### 4.3 Quick Verification Script

```powershell
# ========== GameForge Health Check ==========
$ErrorActionPreference = "Continue"

Write-Host "`n=== GameForge Health Check ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)`n" -ForegroundColor Gray

# 1. Java Version
Write-Host "[1] Java Version:" -NoNewline
$javaVer = java -version 2>&1 | Select-Object -First 1
if ($javaVer -match "1\.8") { Write-Host " OK (Java 8)" -ForegroundColor Green }
else { Write-Host " WARNING (Expected Java 8)" -ForegroundColor Yellow }

# 2. Tomcat Process
Write-Host "[2] Tomcat Process:" -NoNewline
$tomcat = Get-Process -Name "tomcat*" -ErrorAction SilentlyContinue
if ($tomcat) { Write-Host " Running (PID: $($tomcat.Id))" -ForegroundColor Green }
else { Write-Host " NOT Running" -ForegroundColor Red }

# 3. SQL Server
Write-Host "[3] SQL Server (SQLEXPRESS):" -NoNewline
$sql = Get-Service -Name "*SQL*SQLEXPRESS*" -ErrorAction SilentlyContinue
if ($sql -and $sql.Status -eq "Running") { Write-Host " Running" -ForegroundColor Green }
else { Write-Host " NOT Running" -ForegroundColor Red }

# 4. Port 8080
Write-Host "[4] Port 8080:" -NoNewline
$port = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port) { Write-Host " LISTENING" -ForegroundColor Green }
else { Write-Host " NOT Listening" -ForegroundColor Red }

# 5. WAR deployed
$warPath = "$env:CATALINA_HOME\webapps\gamestore.war"
$warFolder = "$env:CATALINA_HOME\webapps\gamestore"
Write-Host "[5] GameForge WAR:" -NoNewline
if ((Test-Path $warPath) -or (Test-Path $warFolder)) {
    Write-Host " Deployed" -ForegroundColor Green
} else { Write-Host " NOT Deployed" -ForegroundColor Red }

# 6. Log errors
Write-Host "[6] Recent Errors in Log:" -NoNewline
if (Test-Path "$env:CATALINA_HOME\logs\catalina.out") {
    $errors = Get-Content "$env:CATALINA_HOME\logs\catalina.out" -Tail 100 |
              Select-String "SEVERE|Exception" -Quiet
    if ($errors) { Write-Host " FOUND errors" -ForegroundColor Red }
    else { Write-Host " No errors in last 100 lines" -ForegroundColor Green }
} else { Write-Host " Log file not found" -ForegroundColor Yellow }

# 7. WebApp response
Write-Host "[7] WebApp Response:" -NoNewline
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/gamestore/" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) { Write-Host " HTTP 200 OK" -ForegroundColor Green }
    else { Write-Host " HTTP $($response.StatusCode)" -ForegroundColor Yellow }
} catch {
    Write-Host " Connection Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Health Check Complete ===" -ForegroundColor Cyan
```

---

## PHẦN 5: LOGGING & DEBUGGING

### 5.1 Enable Hibernate SQL Logging

Trong `spring-servlet.xml`, section `hibernateProperties`:

```xml
<prop key="hibernate.show_sql">true</prop>
<prop key="hibernate.format_sql">true</prop>
<prop key="hibernate.use_sql_comments">true</prop>
```

### 5.2 SQL Server Query Profiler

```sql
-- Enable advanced options
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Enable profiler
EXEC sp_configure 'default trace enabled', 1;
RECONFIGURE;

-- View active queries
SELECT
    er.session_id,
    er.status,
    er.command,
    er.cpu_time,
    er.total_elapsed_time,
    st.text
FROM sys.dm_exec_requests er
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE er.status = 'running';
```

### 5.3 Common Log Patterns để Search

```powershell
# Tomcat crash patterns
Select-String -Path "$env:CATALINA_HOME\logs\catalina.out" -Pattern `
    "OutOfMemoryError",
    "NoClassDefFoundError",
    "ClassNotFoundException",
    "UnsatisfiedLinkError",
    "BindException"

# SQL connection issues
Select-String -Path "$env:CATALINA_HOME\logs\catalina.out" -Pattern `
    "SQLServerException",
    "Communications link failure",
    "Connection refused",
    "Login failed"

# Spring bean issues
Select-String -Path "$env:CATALINA_HOME\logs\catalina.out" -Pattern `
    "BeanCreationException",
    "NoSuchBeanDefinitionException",
    "Circular dependency"
```

---

## PHẦN 6: EMERGENCY ROLLBACK

### Nếu Deploy Thất Bại

```powershell
# 1. Stop Tomcat
& "$env:CATALINA_HOME\bin\shutdown.bat"

# 2. Remove failed deployment
Remove-Item -Recurse -Force "$env:CATALINA_HOME\webapps\gamestore"
Remove-Item -Force "$env:CATALINA_HOME\webapps\gamestore.war"

# 3. Restore previous version (nếu có backup)
Copy-Item "$env:CATALINA_HOME\backup\gamestore.war" "$env:CATALINA_HOME\webapps\"

# 4. Restart Tomcat
& "$env:CATALINA_HOME\bin\startup.bat"

# 5. Verify
Start-Sleep -Seconds 10
Invoke-WebRequest -Uri "http://localhost:8080/gamestore/" -TimeoutSec 10
```

---

## PHẦN 7: MÔI TRƯỜNG DEVELOPMENT

### Cấu hình cho local development (IntelliJ IDEA / Eclipse)

```
Database:
  Server: localhost\SQLEXPRESS
  Auth: SQL Server Authentication
  Login: sa
  Password: 123456
  Database: GameStore

Tomcat:
  CATALINA_HOME: C:\path\to\tomcat
  Port: 8080
  Context: /gamestore

Maven:
  mvn clean package -DskipTests
  Deploy: copy target\gamestore.war %CATALINA_HOME%\webapps\

Hot Reload:
  IntelliJ: Enable "Update classes and resources"
  Hoặc: dùng JRebel (paid)

Logging:
  Console Appender: chế độ DEBUG cho development
  File Appender: chế độ INFO cho production
```

---

## QUICK REFERENCE: Lỗi thường gặp

| Error | Nguyên nhân | Fix nhanh |
|---|---|---|
| `ClassNotFoundException: SQLServerDriver` | Missing JDBC jar | Rebuild Maven |
| `Login failed for user 'sa'` | Sai password | Check database.properties |
| `Cannot open database 'GameStore'` | DB chưa tạo | Tạo DB + tables |
| `TCP/IP connection failed` | SQL TCP/IP disabled | Enable in SS Config Manager |
| `LazyInitializationException` | Truy cập lazy field ngoài session | Dùng JOIN FETCH |
| `NullPointerException` login | User/wallet null | Thêm null check |
| `Insufficient balance` | Stale balance cache | session.flush() + refresh() |
| `Duplicate order` on refresh | Không có PRG | Redirect after POST |
| `HTTP 404` on assets | Resource mapping sai | Check mvc:resources trong spring-servlet.xml |
| `BeanCreationException` | Duplicate controller | Check package scan |
