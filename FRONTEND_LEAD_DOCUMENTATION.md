# 📚 TÀI LIỆU HƯỚNG DẪN KỸ THUẬT & HỌC CODE CHI TIẾT
## Vai trò: Frontend Lead - Phụ trách: Giao Diện, Cửa Hàng & Sản Phẩm (Mai Tuấn Kiệt)
## Dự án: GameForce - Nền Tảng Phân Phối Game Trực Tuyến

---

## 📋 MỤC LỤC
1. [TỔNG QUAN VAI TRÒ & TECH STACK](#1-tổn-quan-vai-trò--tech-stack)
2. [THIẾT KẾ GIAO DIỆN & TEMPLATE TỔNG THỂ (LAYOUT SYSTEM)](#2-thiết-kế-giao-diện--template-tổng-thể-layout-system)
3. [PHÂN HỆ CỬA HÀNG (STOREFRONT) & WISHLIST](#3-phân-hệ-cửa-hàng-storefront--wishlist)
4. [TRANG CHI TIẾT SẢN PHẨM (GAME DETAIL PAGE)](#4-trang-chi-tiết-sản-phẩm-game-detail-page)
5. [BẢNG ĐIỀU KHIỂN NHÀ PHÁT HÀNH (PUBLISHER DASHBOARD)](#5-bảng-điều-khiển-nhà-phát-hành-publisher-dashboard)
6. [HỆ THỐNG ĐÁNH GIÁ & PHẢN HỒI ĐỘNG (REVIEW SYSTEM)](#6-hệ-thống-đánh-giá--phản-hồi-động-review-system)
7. [HỆ THỐNG HUY HIỆU SẢN PHẨM (BADGE SYSTEM)](#7-hệ-thống-huy-hiệu-sản-phẩm-badge-system)
8. [HỆ THỐNG THÔNG BÁO & BỘ LỌC ĐIỀU HƯỚNG (NOTIFICATION & INTERCEPTOR)](#8-hệ-thống-thông-báo--bộ-lọc-điều-hướng-notification--interceptor)
9. [LUỒNG NGHỆP VỤ ĐẶC BIỆT: XÓA SẢN PHẨM & HOÀN TIỀN VÍ (GAME DELETION & REFUND FLOW)](#9-luồng-nghiệp-vụ-đặc-biệt-xóa-sản-phẩm--hoàn-tiền-ví-game-deletion--refund-flow)

---

## 1. TỔNG QUAN VAI TRÒ & TECH STACK

### 1.1 Phạm vi Trách nhiệm
Tài liệu này được biên soạn dành riêng cho vị trí **Frontend Lead (Mai Tuấn Kiệt)**, tập trung 100% vào các tính năng và hàm số được giao thực hiện. Tài liệu **loại bỏ hoàn toàn** các phân hệ không thuộc phạm vi phụ trách (như tính năng Giỏ hàng - Cart, Thanh toán hóa đơn - Checkout, Nạp tiền ví - Recharge của User thường).

Các module chính do bạn nắm giữ bao gồm:
*   **Layout & Common Components:** Thiết kế giao diện khung JSP (Bootstrap 5), Header, Footer, Thanh điều hướng (Navigation Bar), Modal dùng chung, Toast notifications, Loading spinner, và các trang lỗi hệ thống (403, 404, 500).
*   **Storefront (Cửa hàng):** Trang chủ (Homepage), Thanh tìm kiếm thông minh (Autocomplete Client-side), Bộ lọc đa năng (Lọc theo Thể loại, Giá, RAM yêu cầu), Trang chi tiết game (Trailer, Gallery ảnh, Yêu cầu cấu hình), và Danh sách yêu thích (Wishlist).
*   **Publisher Dashboard (Quản lý Sản phẩm):** Giao diện đăng ký/chỉnh sửa game, Upload file đa phương tiện (Media), viết Patch Notes, và Xem danh sách thông báo dành riêng cho Publisher.
*   **Admin Dashboard (Mảng Sản phẩm & Huy hiệu):** Xét duyệt đăng game, xét duyệt yêu cầu xóa game, quản lý danh sách Huy hiệu (Badges) hệ thống, gán huy hiệu cho game và quản lý thông báo Admin.
*   **Review System (Đánh giá & Phản hồi):** Logic Verified Purchase, khóa đánh giá gốc, phản hồi đánh giá của Publisher/Admin (ghi đè), đánh giá bổ sung (User Follow-up) và tính điểm đánh giá trung bình.

### 1.2 Tech Stack Sử Dụng
*   **Frontend:** HTML5, CSS3 (Custom index.css theo phong cách hiện đại, Neo-brutalism/Glassmorphism), Bootstrap 5.3, Lucide Icons, Vanilla JavaScript (Không sử dụng Framework SPA để tối ưu SEO và tốc độ dựng trang SSR).
*   **Backend:** Java 11, Spring MVC framework (Spring Core, Web MVC, Bean Validation).
*   **Database & ORM:** SQL Server (T-SQL), Hibernate ORM (Session Factory quản lý Persistence Context).
*   **Template Engine:** JSP (JavaServer Pages) sử dụng JSTL (`c:forEach`, `c:if`, `fmt:formatNumber`, `fn:escapeXml`).

---

## 2. THIẾT KẾ GIAO DIỆN & TEMPLATE TỔNG THỂ (LAYOUT SYSTEM)

### 2.1 Cấu trúc Layout Tổng Thể
Giao diện dự án được xây dựng theo kiến trúc Responsive Grid của Bootstrap 5, tùy biến lại qua tệp `assets/css/index.css`. Phong cách Neo-brutalism đặc trưng bởi các đường viền dày màu đen (`border: 3px solid #000`), bóng đổ cứng (`box-shadow: 4px 4px 0px #000`), và các tông màu neon tương phản (Pink `#ff7171`, Green `#94FFB4`, Yellow, Blue).

Các component dùng chung được tách biệt ở Client-side:
*   **Toast Notification:** Tạo các thông báo trượt nhẹ góc màn hình để hiển thị trạng thái API thành công/thất bại mà không làm gián đoạn trải nghiệm người dùng.
*   **Modal & Loading Spinner:** Dùng để khóa màn hình khi upload file nặng (đăng game) hoặc hiển thị hộp thoại xác nhận (duyệt xóa game).

Trang lỗi hệ thống được quản lý tập trung bởi [ErrorPageController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/ErrorPageController.java):
*   `errors/403` & `/access-denied`: Trả về giao diện chặn truy cập kèm nút điều hướng động quay lại trang thích hợp dựa trên Role của tài khoản hiện tại.
*   `errors/404`: Trang hiển thị khi không tìm thấy game hoặc đường dẫn lỗi.
*   `errors/500`: Hiển thị lỗi hệ thống, ẩn chi tiết StackTrace để bảo mật cấu trúc mã nguồn với người dùng cuối.

---

## 3. PHÂN HỆ CỬA HÀNG (STOREFRONT) & WISHLIST

### 3.1 Flow Hoạt Động
```
[User truy cập trang chủ /]
      ↓
[GameController.index()] ──(Truy vấn DB)──> Lấy danh sách Game ACTIVE
      ↓
[Render index.jsp] ──> Tải dữ liệu vào client-side (games array)
      ↓
[JS: index.js] ──> Tự động đồng bộ số dư ví, danh sách Wishlist từ API
      ↓
[User tương tác] ──> Tìm kiếm (Client), Lọc (Client), Thêm Wishlist (Hybrid API + LocalStorage)
```

### 3.2 Phân tích Code & Tầng Database

#### **A. Tìm kiếm & Lọc Đa Năng (Search & Multi-Filter)**
*   **Phía Giao diện (Client-side):**
    *   **Tìm kiếm:** Lắng nghe sự kiện `input` trên ô tìm kiếm, chuẩn hóa chữ tiếng Việt có dấu về dạng không dấu (`norm(searchText)`), lọc mảng `games` trên RAM của trình duyệt và render danh sách dropdown tối đa 5 gợi ý.
    *   **Bộ lọc:** Lọc các thẻ game hiển thị trên trang chủ bằng JavaScript (`matchesFilters`). Lọc đồng thời 3 tiêu chí: Khoảng giá (Min/Max), Thể loại (categories lấy từ thuộc tính `data-categories` phân tách bằng dấu cách), và dung lượng RAM yêu cầu (từ thuộc tính `data-requires-ram`).
*   **Tương tác Database ngầm bên dưới:**
    Khi người dùng truy cập trang chủ, Hibernate thực hiện truy vấn nạp dữ liệu:
    ```sql
    -- Lấy danh sách tất cả các game có trạng thái ACTIVE hiển thị trên cửa hàng
    SELECT id, title, slug, price, badges, publisher_id FROM games WHERE status = 'ACTIVE';
    ```
    Mỗi game có quan hệ **Nhiều - Nhiều (ManyToMany)** với các thể loại. Hibernate tự động thực hiện truy vấn JOIN qua bảng trung gian (Junction Table):
    ```sql
    -- Nạp các danh mục thể loại của game
    SELECT c.id, c.name FROM categories c
    JOIN game_categories gc ON c.id = gc.category_id
    WHERE gc.game_id = ?;
    ```
*   **Tại sao lại thiết kế quan hệ bảng Nhiều-Nhiều (ManyToMany)?**
    *   Một Game có thể thuộc nhiều thể loại khác nhau (Ví dụ: *Elden Ring* vừa thuộc thể loại **Hành Động**, vừa thuộc thể loại **Nhập Vai**).
    *   Một thể loại (Ví dụ: **Hành Động**) chứa nhiều tựa game khác nhau.
    *   Do đó, cần một bảng liên kết trung gian là `game_categories` (`game_id`, `category_id`) để chuẩn hóa cơ sở dữ liệu ở dạng chuẩn 3 (3NF), tránh dư thừa dữ liệu và hỗ trợ truy vấn lọc nhanh chóng.

#### **B. Tính năng Wishlist (Danh Sách Yêu Thích)**
*   **Cơ chế Hybrid:**
    Khi người dùng nhấp vào biểu tượng trái tim:
    1. JavaScript ngay lập tức cập nhật trạng thái trên giao diện (Đổi màu trái tim sang đỏ/trắng) và lưu vào `localStorage` của trình duyệt. Việc này giúp giao diện phản hồi lập tức mà không phải chờ mạng phản hồi.
    2. JavaScript gửi một yêu cầu Fetch API (AJAX) không đồng bộ tới backend thông qua API `/api/wishlist/toggle`.
    3. Nếu API thất bại (lỗi mạng hoặc server sập), JavaScript sẽ tự động hoàn tác (Rollback) trạng thái trái tim trên giao diện và hiển thị thông báo lỗi.
*   **Backend & Tầng CSDL:**
    Hàm xử lý chính nằm ở `toggleWishlist` trong [StoreController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L258-L291) và [WishlistItemDAO.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/WishlistItemDAO.java):
    ```java
    WishlistItem existing = wishlistItemDAO.findByUserAndGame(currentUser.getId(), gameId);
    if (existing != null) {
        wishlistItemDAO.deleteById(existing.getId()); // Xóa khỏi danh sách yêu thích
    } else {
        WishlistItem newItem = new WishlistItem();
        newItem.setUser(currentUser);
        newItem.setGame(gameDAO.findById(gameId));
        wishlistItemDAO.save(newItem);    // Thêm vào danh sách yêu thích
    }
    ```
    *   **SQL ngầm bên dưới:**
        ```sql
        -- Kiểm tra sự tồn tại trong wishlist
        SELECT id FROM wishlists WHERE user_id = 5 AND game_id = 12;
        -- Nếu tồn tại -> Xóa
        DELETE FROM wishlists WHERE user_id = 5 AND game_id = 12;
        -- Nếu không tồn tại -> Thêm mới
        INSERT INTO wishlists (user_id, game_id, addedAt) VALUES (5, 12, GETDATE());
        ```
    *   **Thiết kế quan hệ bảng:** Bảng `wishlists` có mối quan hệ **Nhiều-Một (ManyToOne)** tới bảng `users` và `games`. Cấu trúc bảng bắt buộc phải có ràng buộc **Unique Constraint** trên hai cột `(user_id, game_id)` nhằm chặn tuyệt đối trường hợp dữ liệu bị trùng lặp ở tầng vật lý (1 người dùng không thể yêu thích 1 tựa game 2 lần).

### 3.3 Ràng Buộc (Validation)
| Tên Trường / Dữ Liệu | Ràng Buộc Giao Diện (FE JS/HTML5) | Ràng Buộc Backend (Spring/CSDL) |
|---|---|---|
| **Price Filter (Lọc giá)** | Input `type="number"`, bắt buộc số dương, min $\le$ max. | Reset filter nếu dữ liệu không hợp lệ. |
| **Wishlist Toggle** | Kiểm tra đăng nhập ở Client. Nếu chưa đăng nhập, chuyển hướng `/login`. | API kiểm tra user trong session. Nếu null, trả về chuỗi `"ERROR=Vui lòng đăng nhập."` |
| **Wishlist Unique** | Không cho phép bấm nút liên tục khi API đang xử lý (Lock button). | **Unique Constraint** `(user_id, game_id)` ở tầng Database phát hiện trùng lặp. |

### 3.4 Xử lý Ngoại lệ & Giao Dịch (Exception & Transaction)
*   **Giao dịch:** Phương thức `toggleWishlist` kế thừa cấu hình `@Transactional` cấp Class của `StoreController`. Toàn bộ quá trình kiểm tra và lưu/xóa được chạy trong một Transaction duy nhất.
*   **Ngoại lệ & Rollback:** Nếu xảy ra lỗi CSDL (ví dụ: lỗi mất kết nối SQL Server giữa chừng khi đang chạy lệnh INSERT), Hibernate sẽ bắt lấy ngoại lệ và kích hoạt cơ chế Rollback để khôi phục trạng thái. Client-side nhận được mã lỗi HTTP hoặc nội dung lỗi sẽ tự động xóa ID game ra khỏi `localStorage` để đưa giao diện về trạng thái đồng bộ ban đầu.

---

## 4. TRANG CHI TIẾT SẢN PHẨM (GAME DETAIL PAGE)

### 4.1 Flow Hoạt Động
```
[User nhấp vào Game Card] ──> Đường dẫn: /game/{gameSlug}
                                        ↓
                         [StoreController.viewGameDetail(gameSlug)]
                                        ↓
                         [Truy vấn DB: JOIN FETCH mediaList]
                                        ↓
                         [Render detail.jsp ra màn hình]
```

### 4.2 Phân tích Code & Tầng Database
Hàm chính xử lý việc hiển thị thông tin chi tiết game nằm ở `viewGameDetail` trong [StoreController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L142-L240):
*   **Video Trailer nhúng:** Game lưu liên kết nhúng dạng chuỗi (cột `trailerUrl`). Giao diện JSP hiển thị thông qua phần tử `<iframe>` có thuộc tính `allowfullscreen` giúp phát video trailer trực tiếp mà không cần lưu trữ tệp video nặng trên Server.
*   **Gallery ảnh (GameMedia):** Game lưu danh sách các ảnh chụp màn hình trong bảng `game_media`. Giao diện JSP hiển thị ảnh chính (Primary Image) ở khung lớn và danh sách các ảnh phụ dạng thumbnail bên dưới. Khi click vào thumbnail, hàm JS `updateMainImage` sẽ hoán đổi nguồn ảnh của khung hiển thị lớn.
*   **CSDL ngầm bên dưới:**
    ```sql
    -- Lấy thông tin game theo slug đường dẫn độc nhất
    SELECT * FROM games WHERE slug = 'elden-ring';
    
    -- Lấy danh sách ảnh chụp màn hình của game sắp xếp theo thứ tự hiển thị
    SELECT * FROM game_media WHERE game_id = 5 ORDER BY sortOrder;
    ```
*   **Thiết kế quan hệ bảng:**
    *   Mối quan hệ giữa `games` và `game_media` là quan hệ **Một-Nhiều (OneToMany)**. Một game có thể có hàng chục ảnh chụp màn hình và video giới thiệu để tăng độ hấp dẫn. Cột `game_id` đóng vai trò làm Khóa Ngoại (Foreign Key) tham chiếu từ bảng `game_media` về bảng `games`.

### 4.3 Ràng Buộc & Transaction
*   **Ràng buộc:** Nếu game có trạng thái không phải `ACTIVE` (ví dụ: `PENDING`, `REJECTED`, `PENDING_DELETE`), hệ thống sẽ kiểm tra quyền người dùng hiện tại. Nếu không phải Admin hoặc Publisher sở hữu game đó, hệ thống lập tức chặn truy cập và chuyển hướng về trang lỗi `errors/404`.
*   **Giao dịch:** Phương thức `viewGameDetail` được đánh dấu `@Transactional(readOnly = true)`. Việc thiết lập thuộc tính `readOnly = true` là cực kỳ quan trọng giúp Hibernate tối ưu hóa bộ nhớ đệm (FlushMode = MANUAL), bỏ qua việc kiểm tra thay đổi thực thể (dirty checking), từ đó giảm thiểu độ trễ tải trang.

---

## 5. BẢNG ĐIỀU KHIỂN NHÀ PHÁT HÀNH (PUBLISHER DASHBOARD)

### 5.1 Các Chức Năng Chính
*   **Đăng/Sửa Game (CRUD):** Giao diện biểu mẫu (Form) điền thông tin chi tiết, chọn thể loại từ danh sách checkbox, cấu hình yêu cầu cấu hình máy tính. Khi hoàn tất, game được lưu trữ với trạng thái mặc định là `PENDING` để gửi yêu cầu phê duyệt tới Admin.
*   **Upload Media:** Cho phép tải lên tệp ảnh bìa (Cover Image) và các tệp ảnh chụp màn hình game (Screenshots) đồng thời.
*   **Patch Notes (Ghi Chú Bản Vá):** Cho phép nhà phát triển cập nhật ghi chú về phiên bản cập nhật sửa lỗi của game dạng văn bản định dạng HTML để hiển thị ở trang chi tiết sản phẩm sau khi Admin phê duyệt.

### 5.2 Phân tích Code & Tầng Database
Các phương thức chính nằm ở [PublisherController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java):
*   **Xử lý Slug độc nhất:** Khi tạo mới hoặc sửa game, nếu người dùng không điền slug, hệ thống tự động gọi hàm `toSlug()` để chuyển đổi tên game thành chuỗi chữ thường không dấu, kết nối bằng dấu gạch ngang (Ví dụ: *Black Myth: Wukong* $\rightarrow$ `black-myth-wukong`).
*   **Cơ chế lưu ảnh vĩnh viễn:** Khi người dùng upload ảnh, hàm `saveGameMediaFile` sẽ xử lý:
    1. Lưu ảnh vào thư mục triển khai tạm thời của Tomcat server (`/assets/images/games/...`) để ảnh hiển thị ngay lập tức trên trình duyệt.
    2. Đồng thời sao chép (copy) tệp ảnh đó về thư mục mã nguồn vật lý (`webappSourcePath` trỏ đến thư mục source code local của bạn). Điều này đảm bảo khi bạn tắt server hoặc deploy lại dự án, các tệp ảnh do người dùng upload không bị biến mất vĩnh viễn.
*   **Tương tác Database ngầm bên dưới:**
    ```sql
    -- Thêm game mới với trạng thái PENDING
    INSERT INTO games (title, slug, price, status, publisher_id, releaseDate, minimumRequirements, recommendedRequirements) 
    VALUES (N'Game Mới', 'game-moi', 250000, 'PENDING', 3, '2024-06-04', N'RAM: 8GB', N'RAM: 16GB');
    
    -- Lưu thông tin ảnh bìa (Primary = 1) và ảnh screenshot (Primary = 0)
    INSERT INTO game_media (game_id, mediaType, filePath, sortOrder, isPrimary) 
    VALUES (105, 'IMAGE', '/assets/images/games/game-moi/cover.jpg', 0, 1);
    ```

### 5.3 Ràng Buộc (Validation)
*   **Kiểm tra tính hợp lệ dữ liệu đầu vào (Validation 2 đầu):**
    *   **Frontend (JS/HTML5):** Form quy định các ô nhập liệu bắt buộc (`required`), tên game có độ dài tối thiểu 3 ký tự, giá tiền phải lớn hơn 1000đ và chia hết cho 1000đ. Định dạng file tải lên bắt buộc phải là ảnh (`.jpg`, `.jpeg`, `.png`).
    *   **Backend (Spring MVC):**
        ```java
        // Kiểm tra lỗi binding (ví dụ định dạng ngày tháng bị sai từ Client gửi lên)
        if (bindingResult.hasErrors()) {
            if (bindingResult.hasFieldErrors("releaseDate")) {
                model.addAttribute("error", "Ngày phát hành không hợp lệ! Vui lòng nhập đúng định dạng (yyyy-MM-dd).");
            }
            return "publisher/game-form";
        }
        // Kiểm tra logic trùng lặp Slug
        Game existing = gameDAO.findBySlug(game.getSlug());
        if (existing != null && !existing.getId().equals(game.getId())) {
            model.addAttribute("error", "Đường dẫn slug này đã tồn tại trên hệ thống!");
            return "publisher/game-form";
        }
        ```

### 5.4 Xử lý Ngoại lệ & Transaction
*   **Giao dịch:** Phương thức `addGame` và `editGame` được quản lý bởi `@Transactional`. Nếu quá trình ghi tệp vật lý bị lỗi (như tràn bộ nhớ ổ cứng, sai phân quyền thư mục) gây ra ngoại lệ `IOException`, Spring Transaction sẽ tự động can thiệp và Rollback toàn bộ dữ liệu đã thay đổi trong Database trước đó để tránh tình trạng lưu thiếu thông tin.

---

## 6. HỆ THỐNG ĐÁNH GIÁ & PHẢN HỒI ĐỘNG (REVIEW SYSTEM)

### 6.1 Flow Hoạt Động & Cơ Chế Khóa Đánh Giá Gốc
```
[User đã sở hữu game] ──> Viết Đánh Giá Gốc (Rating & Comment) ──> Lưu DB (Khóa cứng, không cho sửa)
                                                                          ↓
                                                             [Publisher / Admin Reply]
                                                                          ↓
[User bổ sung Follow-up] <── Chỉ được thực hiện 1 lần duy nhất <──────────┘
```

### 6.2 Phân tích Code & Tầng Database
Hệ thống được thiết kế với cơ chế tương tác đa chiều rất chặt chẽ tại [StoreController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java):
*   **Logic Verified Purchase:** Kiểm tra xem tài khoản hiện tại đã thực sự mua game và sở hữu bản quyền game đó chưa thì mới cho phép tạo form đánh giá:
    ```java
    boolean owned = libraryItemDAO.existsActiveByUserAndGame(currentUser.getId(), gameId);
    if (!owned) {
        return "redirect:/game/" + game.getSlug() + "?error=not-owned";
    }
    ```
*   **Khóa cứng Đánh giá gốc:** Ngăn chặn tuyệt đối việc người dùng sửa đổi đánh giá ban đầu sau khi đã nhấn lưu để bảo vệ tính công bằng, tránh việc người dùng sửa rating tùy tiện khi có xích mích với nhà phát hành:
    ```java
    Review existing = reviewDAO.findByUserAndGame(currentUser.getId(), gameId);
    if (existing != null) {
        return "redirect:/game/" + game.getSlug() + "?error=already-reviewed";
    }
    ```
*   **Hệ thống Phản hồi (Reply) & Ghi Đè:** Nhà phát triển sở hữu game hoặc Admin có quyền phản hồi đánh giá thông qua hàm `replyToReview`. Do cơ sở dữ liệu chỉ thiết kế một trường `publisherReply` trong bảng `reviews` để lưu nội dung phản hồi, nên nếu cả hai cùng phản hồi trên một đánh giá, nội dung của người lưu sau cùng sẽ **ghi đè** lên nội dung của người trước đó.
*   **Đánh giá bổ sung (User Follow-up):** Sau khi nhận được phản hồi từ Nhà phát triển/Admin, người dùng có quyền phản hồi lại **1 lần duy nhất** (`addFollowUp`). Tại đây, họ có thể viết thêm ý kiến phản hồi mới (`userFollowUp`) và cập nhật số sao đánh giá mới (`userFollowUpRating`).
*   **Tính điểm đánh giá trung bình động:** Khi hiển thị điểm số trung bình của game trên trang chi tiết sản phẩm, hệ thống sử dụng câu lệnh HQL thông minh với hàm `COALESCE` để tự động ưu tiên lấy điểm số sao sau khi bổ sung (nếu có), nếu không có thì lấy điểm đánh giá gốc:
    ```java
    // Trích đoạn hàm getAverageRatingAndCount trong ReviewDAO
    sessionFactory.getCurrentSession()
        .createQuery("SELECT AVG(CAST(coalesce(r.userFollowUpRating, r.rating) as double)), COUNT(r) FROM Review r WHERE r.game.id = :gameId")
    ```
    *   **SQL ngầm bên dưới:**
        ```sql
        SELECT AVG(CAST(COALESCE(userFollowUpRating, rating) AS FLOAT)) as avgRating, COUNT(*) as count 
        FROM reviews WHERE game_id = 5;
        ```

### 6.3 Thiết Kế Tầng CSDL (Database Layer)
*   **Cấu trúc bảng `reviews`:**
    ```sql
    CREATE TABLE reviews (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        game_id BIGINT NOT NULL,
        user_id BIGINT NOT NULL,
        rating INT NOT NULL,                  -- Điểm đánh giá gốc (1-5)
        comment NVARCHAR(2000),                -- Nội dung đánh giá gốc
        publisherReply NVARCHAR(1000),        -- Lời phản hồi của Publisher/Admin
        userFollowUp NVARCHAR(1000),          -- Lời phản hồi bổ sung của User
        userFollowUpRating INT,               -- Điểm đánh giá bổ sung mới của User (1-5)
        createdAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (game_id) REFERENCES games(id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        UNIQUE(game_id, user_id)              -- Đảm bảo 1 user chỉ đánh giá 1 game 1 lần duy nhất
    );
    ```
*   **Thiết kế quan hệ:**
    *   `reviews` có quan hệ **Nhiều - Một (ManyToOne)** với `games` và `users`. 
    *   Trường phản hồi được lưu trực tiếp dạng cột (1-1) trong bảng `reviews` thay vì tách bảng riêng để tối giản hóa cấu trúc CSDL và giảm thiểu số lượng phép JOIN phức tạp khi hiển thị hàng trăm đánh giá trên giao diện trang chi tiết game.

### 6.4 Ràng Buộc & Exception
*   **Validation:** Rating gốc và Follow-up rating bắt buộc phải thuộc đoạn từ `1` đến `5`. Nội dung đánh giá gốc không quá 2000 ký tự, lời phản hồi không quá 1000 ký tự.
*   **Exception & Transaction:** Nếu vi phạm ràng buộc UNIQUE (do lỗi đồng bộ phía client khiến user nhấn gửi 2 lần cùng lúc), SQL Server sẽ ném ra lỗi vi phạm khóa duy nhất (Constraint Violation Exception). Hibernate lập tức Rollback transaction hiện tại để bảo toàn cấu trúc dữ liệu trong sạch.

---

## 7. HỆ THỐNG HUY HIỆU SẢN PHẨM (BADGE SYSTEM)

### 7.1 Cơ Chế Hoạt Động & Lưu Trữ Tĩnh/Động
Hệ thống huy hiệu (Badge) được xây dựng bằng kiến trúc lai rất linh hoạt giữa CSDL và File cấu hình:
1.  **Mẫu cấu hình mẫu (Badge Definitions):** Các thuộc tính hiển thị tĩnh của huy hiệu (Mã ID, Tên tiêu đề, Tên biểu tượng Lucide Icon, Mã màu HEX, và Phân loại huy hiệu) được lưu trữ tập trung trong tệp cấu hình định dạng JSON tại đường dẫn `/WEB-INF/classes/badges_config.json`. Việc lưu trữ này hoạt động giống như một bộ nhớ đệm (Static Cache), giúp thay đổi giao diện huy hiệu trên toàn hệ thống mà không cần tạo bảng phức tạp trong Database hay chạy lại câu lệnh SQL.
2.  **Huy hiệu động (Dynamic Badge):** Có loại huy hiệu phân loại là `dynamic_downloads`. Huy hiệu này hiển thị tiêu đề chứa từ khóa `%COUNT% Lượt Tải`. Khi load trang chi tiết sản phẩm, hệ thống tự động đếm số lượng bản ghi trong bảng `library_items` của game đó và thay thế từ khóa `%COUNT%` bằng số lượng tải thực tế. Nếu số lượng tải bằng 0, hệ thống tự động hiển thị mặc định `"95+"` để giữ thẩm mỹ cho giao diện.
3.  **Lưu huy hiệu vào Game:** Admin có quyền tích chọn các huy hiệu phù hợp cho game. Danh sách các ID huy hiệu đã chọn được nối lại với nhau bằng dấu phẩy và lưu trữ trực tiếp dưới dạng chuỗi (cột `badges`) trong bảng `games` (Ví dụ: `"verified,hot"`).

### 7.2 Phân tích Code & Tầng Database
Các phương thức chính trong [StoreController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L118-L139):
*   **Hàm Đọc/Ghi file cấu hình:**
    ```java
    private List<Badge> loadAvailableBadges() {
        File file = new File(getBadgeFilePath());
        return objectMapper.readValue(file, new TypeReference<List<Badge>>() {});
    }
    private void saveAvailableBadges(List<Badge> list) {
        File file = new File(getBadgeFilePath());
        objectMapper.writeValue(file, list);
    }
    ```
*   **CSDL ngầm bên dưới:**
    ```sql
    -- Lấy chuỗi huy hiệu được gán cho game
    SELECT badges FROM games WHERE id = 5;
    
    -- Đếm số lượt tải thực tế của game trong hệ thống để gán vào huy hiệu dynamic
    SELECT COUNT(id) FROM library_items WHERE game_id = 5;
    
    -- Cập nhật danh sách huy hiệu được tích chọn cho game của Admin
    UPDATE games SET badges = 'verified,hot,top-downloaded' WHERE id = 5;
    ```
*   **Tại sao lại thiết kế lưu chuỗi ngăn cách bằng dấu phẩy thay vì bảng quan hệ Nhiều-Nhiều?**
    *   Huy hiệu là tính năng mang tính chất trang trí giao diện và lượng huy hiệu gán cho mỗi game rất ít (thường chỉ từ 1-3 cái).
    *   Việc lưu dạng chuỗi comma-separated giúp loại bỏ hoàn toàn việc phải tạo thêm bảng liên kết `game_badges` và giảm thiểu chi phí JOIN bảng khi hiển thị danh sách game ở trang chủ. Việc giải mã chuỗi được thực hiện trên bộ nhớ RAM bằng Java cực kỳ nhanh chóng.

### 7.3 Ràng Buộc & Validation
*   **Ràng buộc bảo mật:** Tất cả các API thay đổi mẫu huy hiệu (`/api/admin/create-badge`, `/api/admin/edit-badge`, `/api/admin/delete-badge`) và API gán huy hiệu cho game (`/api/admin/save-game-badges`) bắt buộc phải kiểm tra quyền hạn tài khoản trong session. Nếu không có vai trò `ROLE_ADMIN`, API lập tức chặn và trả về lỗi `"ERROR=Từ chối truy cập"`.
*   **Chuẩn hóa dữ liệu đầu vào:** Khi Admin tạo huy hiệu mới, tiêu đề huy hiệu tĩnh sẽ tự động loại bỏ từ khóa `%COUNT%`, còn huy hiệu động sẽ tự động nối thêm `%COUNT%` ở cuối nếu thiếu. ID của huy hiệu được tự động tạo sạch (`safeId`) bằng cách chuyển sang viết thường, bỏ dấu tiếng Việt và thay khoảng trắng bằng dấu gạch ngang.

---

## 8. HỆ THỐNG THÔNG BÁO & BỘ LỌC ĐIỀU HƯỚNG (NOTIFICATION & INTERCEPTOR)

### 8.1 Đồng Bộ Chấm Đỏ Thông Báo Qua Interceptor
Để hiển thị chấm đỏ báo hiệu có thông báo mới trên thanh điều hướng (Navbar Header) ở **tất cả các trang** mà không cần viết code đếm lặp đi lặp lại ở mỗi Controller, hệ thống sử dụng [AuthInterceptor.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/interceptor/AuthInterceptor.java):
*   Khi có bất kỳ request nào gửi lên, phương thức `preHandle` sẽ được kích hoạt đầu tiên.
*   Nó kiểm tra người dùng đăng nhập trong Session.
*   Nếu là Admin, gọi `notificationDAO.countUnreadForAdmins()` để đếm số thông báo hệ thống chưa đọc.
*   Nếu là Publisher, gọi `notificationDAO.countUnreadByUser(userId)` để đếm số thông báo cá nhân chưa đọc.
*   Đặt giá trị đếm được vào thuộc tính request `unreadNotificationCount`. Các trang JSP chỉ cần đọc giá trị này từ request attribute để quyết định render chấm đỏ báo hiệu trên biểu tượng quả chuông thông báo.

### 8.2 Phân tích Code & Tầng Database
*   **Cấu trúc bảng `notifications`:**
    ```sql
    CREATE TABLE notifications (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        title NVARCHAR(255) NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        type VARCHAR(50),                     -- Phân loại: 'REVIEW', 'GAME_APPROVAL', 'WALLET', 'PATCH_NOTE_APPROVAL'
        targetUrl VARCHAR(255),               -- Đường dẫn chuyển hướng khi click xem thông báo
        is_read BIT NOT NULL DEFAULT 0,       -- Trạng thái đã đọc (1: Đã đọc, 0: Chưa đọc)
        createdAt DATETIME DEFAULT GETDATE(),
        user_id BIGINT NULL,                  -- Khóa ngoại liên kết bảng users (Nếu NULL đại diện cho thông báo gửi tới Admin)
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
    ```
*   **Tương tác Database ngầm bên dưới:**
    ```sql
    -- Đếm số thông báo chưa đọc của Nhà phát triển (user_id = 3)
    SELECT COUNT(id) FROM notifications WHERE user_id = 3 AND is_read = 0;
    
    -- Đếm số thông báo chưa đọc của Admin (user_id IS NULL)
    SELECT COUNT(id) FROM notifications WHERE user_id IS NULL AND is_read = 0;
    
    -- Đánh dấu tất cả thông báo của Admin là đã đọc
    UPDATE notifications SET is_read = 1 WHERE user_id IS NULL;
    ```
*   **Thiết kế quan hệ bảng:** Bảng `notifications` có mối quan hệ **Nhiều - Một (ManyToOne)** với bảng `users`. Trường `user_id` cho phép nhận giá trị `NULL`. Đây là một thiết kế đặc thù: khi `user_id` bằng `NULL`, thông báo đó đại diện cho một thông báo hệ thống gửi đến toàn bộ các tài khoản có quyền Admin duyệt bài (Admin-wide), tránh việc phải nhân bản hàng chục bản ghi thông báo giống nhau cho từng Admin.

---

## 9. LUỒNG NGHỆP VỤ ĐẶC BIỆT: XÓA SẢN PHẨM & HOÀN TIỀN VÍ (GAME DELETION & REFUND FLOW)

Đây là luồng nghiệp vụ phức tạp và quan trọng nhất trong dự án, đòi hỏi sự phối hợp chặt chẽ giữa nhiều bảng cơ sở dữ liệu, dịch vụ hoàn tiền ví, hệ thống gửi email và thông báo Web. Luồng được quản lý hoàn toàn tự động dưới sự giám sát của Spring Transaction.

### 9.1 Sơ Đồ Quy Trình Hoạt Động (Transaction Scope)
```
[Publisher gửi yêu cầu xóa game] ──> Status: 'PENDING_DELETE'
                                              ↓
[Admin duyệt yêu cầu xóa game] ────> Bắt đầu Transaction
                                              ↓
                                 Cập nhật game status = 'DELETED'
                                              ↓
                                 Truy vấn danh sách LibraryItem của game
                                 chưa hoàn tiền (status != 'REFUNDED')
                                              ↓
                                 Lặp qua từng người mua:
                                   ├─ Xác định số tiền hoàn (paidAmount của OrderItem hoặc game price)
                                   ├─ WalletService.refund(): Cộng tiền vào ví, cập nhật cột balance bảng wallets
                                   ├─ Ghi lịch sử giao dịch thành công ('SUCCESS') vào wallet_transactions
                                   ├─ Cập nhật trạng thái LibraryItem = 'REFUNDED' (Khóa quyền chơi game)
                                   ├─ Gửi Email thông báo hoàn tiền (Bọc trong try-catch riêng biệt)
                                   └─ Tạo thông báo Web ('WALLET') cho người mua
                                              ↓
                                 Tạo thông báo Web ('GAME_APPROVAL') cho Publisher
                                              ↓
                                 Commit Transaction (Lưu toàn bộ thay đổi vào DB)
```

### 9.2 Phân tích Chi tiết Giao dịch & Xử lý Ngoại lệ
Mã nguồn xử lý nghiệp vụ chính nằm tại phương thức `approveGame` thuộc [AdminController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/AdminController.java#L456-L565):
1.  **Duy trì tính nhất quán dữ liệu (Atomicity):** Phương thức được đánh dấu `@Transactional`. Toàn bộ chuỗi hành động gồm cập nhật trạng thái game, cộng tiền vào ví của hàng trăm khách hàng, ghi lịch sử giao dịch và thay đổi trạng thái thư viện game phải được thực thi trọn vẹn. Nếu xảy ra lỗi giữa chừng (ví dụ: máy chủ SQL Server mất kết nối khi đang hoàn tiền cho khách hàng thứ 50), Spring sẽ lập tức **Rollback** toàn bộ transaction. Số dư ví của 49 khách hàng trước đó sẽ được khôi phục lại như cũ, trạng thái game quay lại là `PENDING_DELETE` để đảm bảo không bị thất thoát tiền của hệ thống.
2.  **Tách biệt rủi ro truyền thông (Email Exception Handling):** Gửi email là tác vụ kết nối với SMTP Server bên ngoài thông qua mạng Internet, có thời gian trễ lớn và độ rủi ro thất bại cao (do mạng lag hoặc hòm thư lỗi). Do đó, tác vụ gửi email được bọc riêng trong một khối `try-catch` độc lập:
    ```java
    try {
        emailService.sendRefundEmail(item.getUser(), game, refundAmount);
    } catch (Exception e) {
        System.err.println("Lỗi gửi email hoàn tiền cho user " + item.getUser().getUsername() + ": " + e.getMessage());
    }
    ```
    Việc bọc try-catch này đảm bảo rằng nếu máy chủ gửi email bị sập, hệ thống chỉ ghi nhận nhật ký lỗi mà **không ném ra Exception làm Rollback transaction chính**. Nghiệp vụ hoàn tiền vào ví và xóa game vẫn hoàn tất thành công tốt đẹp, tránh việc khách hàng không được hoàn tiền chỉ vì lỗi gửi email.

### 9.3 Tương tác Cơ sở Dữ liệu (Database SQL Queries)
Dưới đây là chuỗi các câu lệnh SQL thực tế chạy dưới nền khi Admin nhấn duyệt xóa game:
```sql
-- 1. Cập nhật trạng thái game thành DELETED
UPDATE games SET status = 'DELETED', approvedAt = GETDATE(), approvedBy = N'AdminFullName' WHERE id = 5;

-- 2. Truy vấn danh sách người dùng đã mua game này mà chưa bị hoàn tiền
SELECT li.*, u.*, oi.* FROM library_items li
INNER JOIN users u ON li.user_id = u.id
LEFT JOIN order_items oi ON li.order_item_entity_id = oi.id
WHERE li.game_id = 5 AND li.status != 'REFUNDED';

-- 3. Thực hiện lặp qua từng người dùng (Ví dụ User ID = 10, Số tiền hoàn = 250,000đ):
-- 3a. Cộng tiền số dư ví của User
UPDATE wallets SET balance = balance + 250000 WHERE user_id = 10;

-- 3b. Ghi nhận giao dịch hoàn tiền thành công vào lịch sử giao dịch ví
INSERT INTO wallet_transactions (wallet_id, type, amount, status, referenceId, createdAt) 
VALUES (2, 'REFUND', 250000, 'SUCCESS', 'REFUND_DELETED_GAME_5', GETDATE());

-- 3c. Khóa quyền sở hữu game trong thư viện của User
UPDATE library_items SET status = 'REFUNDED' WHERE id = 12;

-- 3d. Tạo thông báo trên giao diện Web gửi cho User
INSERT INTO notifications (title, content, type, targetUrl, is_read, user_id, createdAt) 
VALUES (N'Thông báo hoàn tiền game', N'Tựa game Elden Ring đã bị gỡ khỏi hệ thống. Bạn đã được hoàn lại 250.000đ vào ví.', 'WALLET', '/library', 0, 10, GETDATE());

-- 4. Tạo thông báo trên giao diện Web gửi cho Publisher sở hữu game đó (Ví dụ Publisher User ID = 3)
INSERT INTO notifications (title, content, type, targetUrl, is_read, user_id, createdAt) 
VALUES (N'Yêu cầu xóa game đã được duyệt', N'Yêu cầu xóa tựa game Elden Ring của bạn đã được Admin phê duyệt. Hệ thống đã tiến hành hoàn tiền cho người mua.', 'GAME_APPROVAL', '/publisher/games', 0, 3, GETDATE());
```

---

## 10. KỊCH BẢN HỎI VẶN NÂNG CAO CỦA GIÁO VIÊN (TEACHER Q&A)

Dưới đây là danh sách các câu hỏi hóc búa nhất mà hội đồng 3 giáo viên thường sử dụng để chất vấn sinh viên trong buổi bảo vệ đồ án công nghệ thông tin phân hệ Java Web / Spring MVC. Mỗi câu hỏi được chia làm 3 phần rõ rệt để bạn chuẩn bị tâm lý và ghi điểm tuyệt đối.

### 📌 Nhóm 1: Câu hỏi về Luồng Nghiệp Vụ Hoàn Tiền & Xóa Game

#### **Q1.1: "Nếu hệ thống đang lặp qua hàng trăm người mua để hoàn tiền ví và xóa game, đột ngột bị sập mạng hoặc mất điện nửa chừng thì code của em xử lý thế nào? Có bị lỗi người thì được tiền người thì không không?"**
*   **Ý đồ thực sự:** Giáo viên đang kiểm tra hiểu biết sâu sắc của bạn về thuộc tính **ACID** của Giao dịch cơ sở dữ liệu (Database Transaction), đặc biệt là tính **Nguyên tử (Atomicity)** của Spring `@Transactional`.
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `Spring @Transactional` (Quản lý giao dịch tự động của Spring).
    *   `Atomicity (Tính nguyên tử)` (Tất cả cùng thành công hoặc tất cả cùng thất bại).
    *   `Rollback mechanism` (Cơ chế khôi phục trạng thái).
    *   `Hibernate Persistence Context` (Bộ quản lý thực thể của Hibernate).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, toàn bộ luồng duyệt xóa game và hoàn tiền ví trong hàm `approveGame` của em được bọc trong annotation `@Transactional`. Theo thuộc tính Atomicity (Tính nguyên tử) của giao dịch, toàn bộ các câu lệnh SQL cập nhật trạng thái game, cộng tiền vào ví, khóa thư viện game của hàng trăm người dùng chỉ được ghi nhận tạm thời trên bộ nhớ đệm (Persistence Context). 
    
    Nếu hệ thống bị sập giữa chừng, transaction sẽ không thể thực hiện lệnh `COMMIT`. Khi server hoạt động trở lại, hệ thống sẽ tự động kích hoạt cơ chế `ROLLBACK` để hủy bỏ toàn bộ các thay đổi dang dở, đưa số dư ví của tất cả người dùng và trạng thái game về nguyên vẹn trạng thái trước khi xóa. Vì vậy, hoàn toàn không thể xảy ra tình trạng người được hoàn tiền, người không, đảm bảo tính nhất quán dữ liệu tuyệt đối cho hệ thống tài chính ví."

#### **Q1.2: "Tại sao trong luồng xóa game, em lại tách việc gửi email ra khỏi transaction chính và bọc trong khối try-catch riêng? Nếu gửi email thất bại thì giao dịch có bị hủy không?"**
*   **Ý đồ thực sự:** Kiểm tra khả năng thiết kế hệ thống thực tế chống nghẽn nghẽn luồng (Blocking) và hiểu biết về các tác vụ ngoại vi (I/O Bound / External API).
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `Blocking operation` (Tác vụ gây nghẽn).
    *   `Exception propagation` (Sự lan truyền ngoại lệ).
    *   `Network Timeout` (Lỗi quá hạn kết nối mạng).
    *   `External SMTP Service` (Dịch vụ gửi thư điện tử ngoài).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, tác vụ gửi email thông qua SMTP Server bên ngoài là một tác vụ giao tiếp mạng ngoại vi, có tốc độ xử lý chậm và rất dễ gặp lỗi do mất kết nối mạng. Nếu em đưa việc gửi email vào luồng transaction chính mà không bọc `try-catch`, khi máy chủ mail bị lỗi, ngoại lệ ném ra sẽ lan truyền ngược lại làm sập luồng và kích hoạt `Rollback` toàn bộ quá trình hoàn tiền ví và xóa game trước đó. Điều này vô hình trung làm tê liệt nghiệp vụ chính của hệ thống chỉ vì một dịch vụ gửi thư điện tử phụ trợ gặp trục trặc.
    
    Vì thế, em đã chủ động tách việc gửi email ra, bọc riêng trong một khối `try-catch` độc lập. Nếu gửi email thất bại, hệ thống chỉ ghi lại log lỗi để kỹ thuật viên xử lý và vẫn tiếp tục thực hiện hoàn tất việc hoàn tiền và hạ game cho khách hàng, đảm bảo trải nghiệm nghiệp vụ chính diễn ra thông suốt."

---

### 📌 Nhóm 2: Câu hỏi về Đánh giá (Review System) & Đồng Bộ Giao Diện

#### **Q2.1: "Nếu cả Publisher của game đó và Admin hệ thống cùng gửi phản hồi trên một bài đánh giá của User thì CSDL lưu trữ ra sao và hiển thị thế nào?"**
*   **Ý đồ thực sự:** Giáo viên kiểm tra cấu trúc thiết kế cơ sở dữ liệu cột đơn (1-1) trong bảng đánh giá và cơ chế tranh chấp ghi đè dữ liệu (Data Overwrite).
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `Shared Column (publisherReply)` (Cột phản hồi dùng chung).
    *   `Overwrite Behavior` (Hành vi ghi đè dữ liệu).
    *   `Database normalization` (Chuẩn hóa cơ sở dữ liệu).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, trong bảng `reviews` của em, trường phản hồi được thiết kế trực tiếp thành một cột tên là `publisherReply` (quan hệ 1-1 gắn liền với bản ghi đánh giá). Cả Admin và Publisher của game đó đều có quyền gọi API để ghi phản hồi. 
    
    Do đó, nếu cả hai cùng phản hồi, hệ thống sẽ thực hiện cập nhật và ghi đè nội dung của người gửi sau lên cột `publisherReply` của bản ghi đó. Trên giao diện, người dùng sẽ chỉ nhìn thấy một lời phản hồi chính thức mới nhất. Thiết kế này giúp tối giản hóa cơ sở dữ liệu và tăng tốc độ tải trang vì không cần JOIN thêm một bảng phản hồi riêng biệt."

#### **Q2.2: "Tại sao khi user click vào nút thêm game vào danh sách yêu thích (Wishlist), em lại lưu hybrid vào cả localStorage và database? Nếu hai nơi này bị lệch dữ liệu thì sao?"**
*   **Ý đồ thực sự:** Giáo viên đánh giá tư duy tối ưu hóa trải nghiệm người dùng (UX) và tính nhất quán dữ liệu (Data Consistency) giữa Client-side và Server-side.
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `Optimistic UI update` (Cập nhật giao diện lạc quan).
    *   `Hybrid caching` (Bộ nhớ đệm lai).
    *   `Data synchronization` (Đồng bộ hóa dữ liệu).
    *   `Source of truth` (Nguồn sự thật tối cao - Database).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, việc lưu trữ hybrid nhằm giải quyết bài toán trải nghiệm người dùng. Khi user click yêu thích, nếu chỉ chờ gọi API về Database rồi mới đổi màu trái tim trên giao diện, người dùng sẽ cảm thấy ứng dụng bị khựng/lag khoảng vài trăm mili-giây do độ trễ của mạng. Lưu vào `localStorage` trước giúp giao diện thay đổi màu lập tức (cập nhật giao diện lạc quan). 
    
    Để giải quyết vấn đề lệch dữ liệu, hệ thống của em luôn coi **Database là Nguồn sự thật tối cao**. Mỗi khi người dùng tải lại trang chủ hoặc truy cập trang Wishlist, hệ thống sẽ tự động gọi API `/api/wishlist/items` để lấy danh sách ID game yêu thích thực tế từ Database về và ghi đè lại dữ liệu trong `localStorage`, đảm bảo dữ liệu ở Client luôn chính xác tuyệt đối theo Server."

---

### 📌 Nhóm 3: Câu hỏi về Tối ưu hóa Truy vấn & Kiến trúc Database

#### **Q3.1: "Em đã dùng JOIN FETCH ở những chỗ nào trong mã nguồn? Tại sao chỗ đó em lại dùng JOIN FETCH mà không để Hibernate tự động load dữ liệu (Lazy Loading)?"**
*   **Ý đồ thực sự:** Đây là câu hỏi rất kinh điển. Giáo viên muốn kiểm tra xem bạn có thực sự hiểu về hiệu năng truy vấn của Hibernate ORM và cách khắc phục lỗi hiệu năng kinh điển **N+1 Queries Problem** hay không.
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `N+1 queries problem` (Lỗi truy vấn N+1 câu lệnh).
    *   `JOIN FETCH` (Truy vấn nạp kèm thực thể liên quan).
    *   `Lazy Loading vs Eager Loading` (Nạp chậm vs nạp ngay lập tức).
    *   `Hibernate Session Factory` (Bộ quản lý phiên Hibernate).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, em sử dụng `JOIN FETCH` trong HQL ở các câu lệnh truy vấn nạp dữ liệu có liên kết, tiêu biểu là trong `WishlistItemDAO.findByUser` để nạp kèm thông tin của `Game` (`FROM WishlistItem w JOIN FETCH w.game`), và trong `AdminController.games` để nạp kèm thông tin của nhà phát hành (`FROM Game g LEFT JOIN FETCH g.publisher`).
    
    Nếu em không dùng `JOIN FETCH` mà sử dụng cơ chế mặc định Lazy Loading, khi em muốn hiển thị danh sách 10 game yêu thích kèm tên và giá của từng game, Hibernate đầu tiên sẽ chạy 1 câu lệnh để lấy danh sách 10 bản ghi Wishlist. Sau đó, với mỗi bản ghi Wishlist, khi giao diện gọi `item.getGame().getTitle()`, Hibernate lại phải chạy thêm 1 câu lệnh SQL phụ nữa xuống DB để nạp thông tin game đó. Tổng cộng hệ thống phải chạy tới $1 + 10 = 11$ câu lệnh SQL (Lỗi N+1). Bằng cách sử dụng `JOIN FETCH`, em gộp toàn bộ quá trình nạp thông tin thành **1 câu lệnh JOIN duy nhất** trong SQL Server, giúp giảm thiểu số lần kết nối mạng xuống DB và tối ưu hóa hiệu năng hệ thống lên gấp nhiều lần."

#### **Q3.2: "Tại sao trong bảng games, cột badges em lại chọn lưu trữ dạng chuỗi ngăn cách bằng dấu phẩy (VARCHAR) thay vì tạo bảng game_badges để thiết kế quan hệ Nhiều-Nhiều (ManyToMany)?"**
*   **Ý đồ thực sự:** Giáo viên kiểm tra tư duy thiết kế phi chuẩn hóa cơ sở dữ liệu (De-normalization) có chủ đích để tối ưu hóa hiệu năng đọc dữ liệu.
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `De-normalization` (Phi chuẩn hóa CSDL).
    *   `Comma-separated values` (Dữ liệu ngăn cách bằng dấu phẩy).
    *   `Read-heavy performance` (Hiệu năng của hệ thống đọc nhiều viết ít).
    *   `JSON static cache` (Bộ đệm cấu hình tĩnh dạng JSON).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, thông thường quan hệ giữa Game và Huy hiệu là Nhiều-Nhiều. Tuy nhiên, nghiệp vụ Huy hiệu (Badge) trong hệ thống của em có đặc thù là lượng huy hiệu gán cho mỗi game rất ít (chỉ khoảng 1-2 cái) và danh sách cấu hình huy hiệu cũng rất ít thay đổi (lưu trong file JSON tĩnh hoạt động như một static cache).
    
    Nếu em chuẩn hóa cơ sở dữ liệu bằng cách tạo thêm bảng liên kết `game_badges`, mỗi lần tải danh sách game ở trang chủ, hệ thống sẽ phải thực hiện câu lệnh JOIN rất phức tạp giữa 3 bảng: `games`, `game_badges` và `badges`. Việc lưu trực tiếp chuỗi comma-separated dạng `"verified,hot"` vào cột `badges` giúp loại bỏ hoàn toàn việc JOIN bảng này. Khi cần hiển thị, Java chỉ cần lấy chuỗi ra, sử dụng hàm `split(",")` rất đơn giản để ánh xạ sang file cấu hình JSON trên bộ nhớ RAM. Đây là giải pháp phi chuẩn hóa CSDL có chủ đích nhằm tối ưu tối đa hiệu năng cho trang chủ - nơi có lượng người đọc truy cập lớn nhất hệ thống."

#### **Q3.3: "Tại sao khi game bị xóa hoàn toàn khỏi hệ thống (status = 'DELETED'), em lại cần lọc thêm điều kiện g.status != 'DELETED' ở tầng DAO của LibraryItem mặc dù đã có trường status = 'REFUNDED' ở LibraryItem?"**
*   **Ý đồ thực sự:** Giáo viên muốn kiểm tra tính tư duy lập trình phòng thủ (Defensive Programming) và cách bạn xử lý tính nhất quán của dữ liệu (Data Integrity/Fallback check) trong các tình huống thực tế khi luồng nghiệp vụ cập nhật không đồng bộ.
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `Defensive Programming` (Lập trình phòng thủ).
    *   `Data integrity / Fallback check` (Bảo toàn dữ liệu / Kiểm tra dự phòng).
    *   `Asynchronous sync issue` (Lỗi đồng bộ không đồng thời).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, bình thường khi Admin duyệt xóa game, hệ thống sẽ thực hiện cập nhật `status = 'REFUNDED'` cho các `LibraryItem` của game đó để ẩn game đi. Tuy nhiên, để đảm bảo an toàn tuyệt đối theo nguyên lý Lập trình phòng thủ (Defensive Programming), em đã chủ động thêm điều kiện kết hợp `JOIN li.game g WHERE g.status != 'DELETED'` vào các câu lệnh SQL ở `LibraryItemDAO`.
    
    Điều này giúp giải quyết hai vấn đề: Thứ nhất, nếu có bất kỳ lỗi không đồng bộ nào xảy ra ở DB khiến bản ghi `LibraryItem` chưa kịp cập nhật trạng thái `REFUNDED`, hoặc game bị admin xóa thủ công trực tiếp từ SQL Server, hệ thống vẫn tự động ẩn game đó khỏi thư viện của người dùng ngay lập tức. Thứ hai, nó giúp dữ liệu hiển thị trên Client luôn nhất quán tuyệt đối với trạng thái bán thực tế của sản phẩm trên Store."

#### **Q3.4: "Tại sao sau khi xử lý gửi đánh giá hoặc phản hồi, các API của em lại redirect về đường dẫn chứa tiền tố /game/ thay vì đường dẫn root /?"**
*   **Ý đồ thực sự:** Đánh giá hiểu biết của bạn về cấu trúc định tuyến (Routing System) của Spring MVC và cách tổ chức URL trong hệ thống để tránh lỗi trang 404.
*   **Từ khóa kỹ thuật cần trả lời:**
    *   `Spring URL Path Mapping` (Ánh xạ đường dẫn URL của Spring).
    *   `Controller RequestMapping` (Định tuyến yêu cầu của Controller).
    *   `Redirect resolution` (Giải quyết chuyển hướng).
*   **Mẫu câu trả lời ghi điểm tuyệt đối:**
    "Dạ thưa thầy/cô, cấu trúc định tuyến chi tiết sản phẩm của hệ thống được khai báo trong `StoreController` là `@RequestMapping(value = "/game/{gameSlug}")`. Vì vậy, khi thực hiện các tác vụ như gửi đánh giá, phản hồi hoặc xóa phản hồi, Spring MVC cần chuyển hướng trình duyệt về đúng URL hiển thị chi tiết game. 
    
    Nếu em chỉ sử dụng `redirect:/` + slug (ví dụ: `redirect:/pixel-war`), trình duyệt sẽ cố gắng tải trang tại đường dẫn gốc `http://localhost:8080/pixel-war` - nơi không có bất kỳ Controller nào ánh xạ, dẫn đến lỗi 404. Việc sử dụng tiền tố `/game/` (ví dụ: `redirect:/game/pixel-war`) đảm bảo trình duyệt quay lại đúng trang chi tiết game để hiển thị các đánh giá mới nhất một cách chính xác."

---


### 📝 BẢNG THAM CHIẾU CÁC FILE QUAN TRỌNG

Để phục vụ cho quá trình học code và trả lời trực tiếp trước hội đồng, dưới đây là các tệp nguồn quan trọng nhất chứa các hàm logic chính do bạn thực hiện:

| Tên Tệp Nguồn | Vị Trí Đường Dẫn | Hàm Quan Trọng Cần Đọc | Chức Năng Chính |
|---|---|---|---|
| **StoreController.java** | [StoreController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java) | `viewGameDetail`, `toggleWishlist`, `addOrUpdateReview`, `replyToReview`, `addFollowUp`, `createBadge` | Hiển thị chi tiết game, wishlist, đánh giá phản hồi, và quản lý huy hiệu Admin. |
| **AdminController.java** | [AdminController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/AdminController.java) | `approveGame`, `rejectGame`, `badges`, `viewNotifications` | Xét duyệt đăng game, luồng duyệt xóa game hoàn tiền ví, quản lý huy hiệu và thông báo. |
| **PublisherController.java** | [PublisherController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java) | `addGame`, `editGame`, `deleteGame`, `addPatchNote`, `saveGameMediaFile` | Đăng game mới, sửa game, yêu cầu xóa game, thêm patch note, và upload media vĩnh viễn về source. |
| **AuthInterceptor.java** | [AuthInterceptor.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/interceptor/AuthInterceptor.java) | `preHandle` | Phân quyền truy cập các đường dẫn và tự động đếm số lượng thông báo chưa đọc tiêm lên Header. |
| **ErrorPageController.java**| [ErrorPageController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/ErrorPageController.java) | `accessDenied`, `error403`, `error404`, `error500` | Quản lý chuyển hướng và hiển thị các trang lỗi hệ thống. |
| **WishlistItemDAO.java** | [WishlistItemDAO.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/WishlistItemDAO.java) | `findByUserAndGame`, `findByUser` | Truy vấn danh sách yêu thích sử dụng JOIN FETCH tối ưu. |
| **ReviewDAO.java** | [ReviewDAO.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/ReviewDAO.java) | `findByUserAndGame`, `getAverageRatingAndCount` | Truy vấn kiểm tra đánh giá trùng lặp và tính điểm đánh giá trung bình động thông minh. |
| **index.js** | `src/main/webapp/assets/js/index.js` | `matchesFilters`, `applyFilters`, `toggleFavorite` | Xử lý lọc game trang chủ và tương tác hybrid wishlist phía giao diện Client. |
| **index.jsp** | `src/main/webapp/WEB-INF/views/index.jsp` | Navbar section, Search bar | Dựng khung HTML5 giao diện trang chủ và thanh tìm kiếm Autocomplete. |

---
**Tài Liệu Đã Hoàn Thành! 🎉**  
*Tài liệu đã được tối ưu hóa 100% bằng Tiếng Việt, loại bỏ phần Giỏ hàng (Cart) không liên quan, làm nổi bật hệ thống Huy hiệu (Badge), Thông báo (Notification), Bảo mật điều hướng (Interceptor) cùng kịch bản hỏi vặn chuyên sâu 3 bước.*
