# Danh sách Kiểm tra Trạng thái Sạch — Harness Template

> Template bậc 1. Copy ra root, đổi tên thành `clean-state-checklist.md`.

---

## PHẦN 1: PRE-COMMIT CHECKLIST

### 1.1 Baseline Integrity — Bắt buộc pass

```
□ Đường dẫn khởi động chuẩn vẫn hoạt động
  → Chạy: ./init.sh hoặc init.bat
  → Kết quả mong đợi: Tất cả bước PASS

□ Repository vẫn build được
  → Chạy: mvn compile (Java) / npm run build (JS) / ...
  → Kết quả mong đợi: Không có lỗi compile

□ Không có lỗi runtime nghiêm trọng
  → Kiểm tra: log file gần nhất không có SEVERE/ERROR
  → Database connection vẫn OK
```

### 1.2 Feature Progress — Tính năng đang làm

```
□ Tiến độ hiện tại được ghi lại trong nhật ký tiến độ
  → claude-progress.md đã cập nhật nhật ký phiên mới nhất

□ Trạng thái tính năng phản ánh thực tế
  → feature_list.json: status đúng (passing/blocked/not_started/in_progress)
  → không có feature đang in_progress quá lâu mà không cập nhật

□ Không có bước làm dở nào bị bỏ lại mà không ghi
  → Tất cả half-done work đều có ghi trong notes hoặc blockers

□ Verification evidence đã được ghi
  → Screenshot / log / test output / API response đã lưu
  → Reference đến evidence trong feature_list.json
```

### 1.3 Code Quality — Không có rủi ro trong code

```
□ Không có TODO/FIXME bị quên (trừ khi có tracked issue)
  → Tìm: TODO|FIXME|HACK|XXX trong code
  → Nếu có: phải có issue tương ứng hoặc fix ngay

□ Không có debug print/log bị bỏ lại
  → Tìm: console\.log|System\.out\.print|print\(|logger\.debug
  → Production code không có debug output

□ Không có commented-out code lớn
  → Code đã xóa: xóa hẳn, không comment
  → Code tạm thời: phải có issue tracking

□ Không có magic number/string không có constant
  → Số 0, 1, -1 có thể là magic number
  → Chuỗi như "ADMIN", "ACTIVE" nên là enum/constant
```

### 1.4 Credentials — Không leak

```
□ Không commit credentials hoặc secrets
  → Tìm: password|secret|api_key|token.*=.*["']
  → File config chứa secret đã có trong .gitignore

□ Không có hardcoded URL/endpoint staging prod
  → URL staging/prod không có trong code
  → Dùng config/env variable

□ Không có test credential trong code
  → Không có user test/password test hardcoded
```

### 1.5 Documentation — Tài liệu đồng bộ

```
□ feature_list.json đã cập nhật (status, verification, evidence)
  → Feature vừa xong có status = passing
  → Verification steps đã liệt kê
  → Evidence references đã ghi

□ claude-progress.md đã cập nhật (phiên mới)
  → Nhật ký phiên ghi đủ thông tin
  → Baseline status up-to-date

□ AGENTS.md đã phản ánh thay đổi (nếu có luật mới)
  → Không có rule mới mà chưa ghi

□ README đã cập nhật nếu có thay đổi build process
  → New dependency → cập nhật prerequisite
  → New env variable → cập nhật README
```

### 1.6 Repository Cleanliness

```
□ Không có file không theo dõi (untracked) bị bỏ lại
  → git status — chỉ có thay đổi có chủ đích
  → Không có .class, .jar, node_modules, target/

□ Không có file không cần thiết trong working directory
  → *.log, *.bak, *~ , .DS_Store, Thumbs.db

□ Commit message mô tả rõ ràng
  → Format: [TICKET-ID] Mo ta ngắn gọn
  → Không commit nhiều features không liên quan cùng lúc
```

---

## PHẦN 2: ĐIỀU KIỆN ĐỂ COMMIT

```
Repository được coi là "sạch" để commit khi TẤT CẢ check ở PHẦN 1 đều pass.

□ Baseline Integrity:       PASS
□ Feature Progress:        PASS
□ Code Quality:           PASS
□ Credentials:            PASS
□ Documentation:          PASS
□ Repository Cleanliness: PASS

→ TẤT CẢ PASS → Có thể commit
→ BẤT KỲ FAIL nào → KHÔNG commit → sửa trước
```

---

## PHẦN 3: KHẮC PHỤC NHANH CÁC LỖI THƯỜNG GẶP

### 3.1 Baseline không boot

```
1. Xem log lỗi chi tiết nhất
2. Kiểm tra dependency đã install chưa
3. Kiểm tra database/server có chạy không
4. Kiểm tra config file đúng không
5. Rollback thay đổi gần nhất nếu cần: git diff HEAD~1
```

### 3.2 Test fail

```
1. Chạy test riêng để xác định test nào fail: mvn test -Dtest=ClassName
2. Đọc error message chi tiết
3. Kiểm tra test fail do code mới hay test đã cũ
4. Nếu do code mới → sửa code
5. Nếu do test cũ → cập nhật test hoặc ghi vào blockers
```

### 3.3 Credential leak

```
1. Tìm file: git log --all -p | grep -i "password\|secret\|key.*=.*"
2. Xóa khỏi git history: git filter-branch hoặc BFG Repo-Cleaner
3. Thêm vào .gitignore
4. Commit lại với credential thay bằng placeholder
```

### 3.4 Build fail sau khi merge

```
1. Kiểm tra dependency conflict: mvn dependency:tree
2. Kiểm tra classpath có đúng version
3. Clean build: mvn clean compile
4. Nếu có conflict → resolve bằng cách giữ code của 1 bên + thêm phần còn thiếu
```

---

## PHẦN 4: PRE-DEPLOYMENT CHECKLIST (Neu co deploy)

### 4.1 Database

```
□ Database migration đã chạy thành công
  → Chạy: migrate script trên production DB
  → Verify: schema đúng sau migration

□ Backup database trước khi deploy
  → Tạo backup: mysqldump / pg_dump / SQL Server backup

□ Data integrity check sau migration
  → SELECT COUNT(*) từ các bảng chính
  → Verify không có data loss
```

### 4.2 Application

```
□ Build thành công: mvn clean package -DskipTests
□ WAR/JAR file size hợp lý (không thiếu, không thừa dependency)
□ Không có hardcoded credentials trong build artifact
□ Health check endpoint hoạt động
```

### 4.3 Configuration

```
□ Config production đúng environment
□ Database connection: production host/port/database
□ API keys: production keys (đã rotate nếu cần)
□ Feature flags: chỉ bật features đã stable
```

---

## PHẦN 5: HANDOFF CHO PHIÊN TIẾP

```
Phiên tiếp theo có thể tiếp tục mà KHÔNG cần sửa tay khi:

□ Init script chạy được — không lỗi
□ Baseline boot thành công
□ Tất cả blockers đã được document
□ Nhật ký tiến độ đầy đủ

→ Nếu bất kỳ điều kiện nào KHÔNG thỏa
  → BÁO BLOCKER TRƯỚC. Không tự ý sửa.
```

---

## PHẦN 6: DÀNH CHO PROJECT GAMEFORGE

(Các check đặc thù cho dự án này — xóa phần này khi dùng cho project khác)

### 6.1 SQL Server specific

```
□ SQL Server (SQLEXPRESS) đang chạy
  → Get-Service *SQL*SQLEXPRESS* | Select Name, Status

□ TCP/IP protocol enabled cho SQL Server
  → SQL Server Configuration Manager → Protocols → TCP/IP Enabled

□ Database GameStore tồn tại
  → sqlcmd -S localhost\SQLEXPRESS -U sa -P 123456 -d GameStore -Q "SELECT 1"

□ JDBC driver (mssql-jdbc) có trong WAR
  → unzip -l target/gamestore.war | grep mssql
```

### 6.2 Tomcat specific

```
□ Tomcat port 8080 không bị conflict
  → netstat -ano | findstr :8080

□ WAR file deployed đúng
  → Kiểm tra: $CATALINA_HOME/webapps/gamestore.war

□ catalina.out không có SEVERE
  → Select-String catalina.out -Pattern "SEVERE|ERROR|Exception"
```

### 6.3 Java/Build specific

```
□ Java version đúng (JDK 8+)
  → java -version

□ Maven đúng version
  → mvn -version

□ Hibernate dialect: SQLServer2012Dialect
  → Kiểm tra trong spring-servlet.xml
```
