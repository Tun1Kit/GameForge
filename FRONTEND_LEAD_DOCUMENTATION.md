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
10. [HỆ THỐNG RÀNG BUỘC DỮ LIỆU ĐẦU VÀO (INPUT VALIDATION CONSTRAINTS)](#10-hệ-thống-ràng-buộc-dữ-liệu-đầu-vào-input-validation-constraints)
11. [KỊCH BẢN HỎI VẶN NÂNG CAO CỦA GIÁO VIÊN (TEACHER Q&A)](#11-kịch-bản-hỏi-vặn-nâng-cao-của-giáo-viên-teacher-qa)

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
    *   **Tìm kiếm:** Lắng nghe sự kiện `input` trên ô tìm kiếm, chuẩn hóa chữ tiếng Việt có dấu về dạng không dấu qua hàm `norm(value)` tại [index.js dòng 54-56](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/assets/js/index.js#L54-L56):
        ```javascript
        function norm(value) {
          return String(value || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
        }
        ```
        Lọc danh sách trên RAM và render dropdown gợi ý qua hàm `updateSearchSuggestions(query)` tại [index.js dòng 611-653](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/assets/js/index.js#L611-L653):
        ```javascript
        function updateSearchSuggestions(query) {
          const wrapper = document.getElementById('searchSuggestions');
          if (!wrapper) return;

          const val = norm(query);
          if (!val) {
            wrapper.classList.add('d-none');
            return;
          }

          if (allGamesCached.length === 0) {
            cacheAllGames();
          }

          const matches = allGamesCached.filter(function(g) {
            return g.normTitle.includes(val) || g.normCategory.includes(val);
          });

          if (matches.length === 0) {
            wrapper.innerHTML = '<div class="text-center py-2 fw-semibold text-secondary small">Không tìm thấy game nào</div>';
            wrapper.classList.remove('d-none');
            return;
          }

          let html = '<div class="d-flex flex-column gap-1">';
          matches.forEach(function(g) {
            html += '<a href="' + contextPath + '/game/' + g.slug + '" class="d-flex align-items-center gap-2 p-2 rounded-2 text-decoration-none text-dark" onmouseover="..." onmouseout="...">';
            if (g.imgUrl) {
              html += '<img src="' + g.imgUrl + '" alt="' + g.title + '" style="width: 48px; height: 28px; object-fit: cover; border-radius: 4px; border: 1.5px solid #000;">';
            }
            html += '<div class="flex-grow-1 min-width-0">';
            html += '<div class="small fw-bold text-truncate">' + g.title + '</div>';
            html += '<div class="text-success fw-black small" style="font-size: 11px;">' + g.priceText + '</div>';
            html += '</div>';
            html += '</a>';
          });
          html += '</div>';

          wrapper.innerHTML = html;
          wrapper.classList.remove('d-none');
        }
        ```
    *   **Bộ lọc:** Lọc các thẻ game hiển thị trên trang chủ bằng JavaScript qua hàm `matchesFilters(item)` tại [index.js dòng 316-355](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/assets/js/index.js#L316-L355). Lọc đồng thời 3 tiêu chí: Khoảng giá, Thể loại, và dung lượng RAM:
        ```javascript
        function matchesFilters(item) {
          // 1. Search text filter
          const title = norm(item.dataset.title);
          const allCategories = item.dataset.categories || '';
          const matchesSearch = !searchText || title.includes(norm(searchText)) || allCategories.includes(norm(searchText));
          if (!matchesSearch) return false;

          // 2. Category select filter
          const filterCat = document.getElementById('filterCategory');
          const catVal = filterCat ? filterCat.value : 'all';
          if (catVal !== 'all') {
            const categoriesStr = allCategories.trim().split(/\s+/);
            const searchCat = catVal.toLowerCase();
            if (!categoriesStr.includes(searchCat)) {
              return false;
            }
          }

          // 3. Price select filter
          const filterPrice = document.getElementById('filterPrice');
          const priceVal = filterPrice ? filterPrice.value : 'all';
          if (priceVal !== 'all') {
            const price = parseFloat(item.dataset.price || '0');
            if (priceVal === 'under-100k' && price >= 100000) return false;
            if (priceVal === '100k-500k' && (price < 100000 || price > 500000)) return false;
            if (priceVal === 'over-500k' && price <= 500000) return false;
          }

          // 4. RAM requirement filter
          const filterRam = document.getElementById('filterRam');
          const ramVal = filterRam ? filterRam.value : 'all';
          if (ramVal !== 'all') {
            const minReq = item.dataset.minReq || '';
            const parsedRam = parseRam(minReq);
            if (ramVal === 'ram-8' && parsedRam > 8) return false;
            if (ramVal === 'ram-16' && parsedRam > 16) return false;
          }

          return true;
        }
        ```
*   **Tương tác Database ngầm bên dưới:**
    Khi người dùng truy cập trang chủ, `GameController.index()` tại [GameController.java dòng 48](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/GameController.java#L48) gọi `gameDAO.findActiveGames()`. Hibernate thực hiện truy vấn nạp dữ liệu từ HQL định nghĩa tại [GameDAO.java dòng 31-37](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/GameDAO.java#L31-L37):
    ```java
    @Transactional(readOnly = true)
    public List<Game> findActiveGames() {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM Game g WHERE g.status = 'ACTIVE' ORDER BY g.id DESC",
                        Game.class)
                .list();
    }
    ```
    Từ câu lệnh HQL trên, SQL Server sẽ thực thi câu lệnh SQL thực tế sau:
    ```sql
    SELECT id, title, slug, price, badges, publisher_id FROM games WHERE status = 'ACTIVE';
    ```
    Mỗi game có quan hệ **Nhiều - Nhiều (ManyToMany)** với các thể loại. Hibernate tự động thực hiện truy vấn JOIN qua bảng trung gian (Junction Table) được cấu hình tại [Game.java dòng 67-73](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Game.java#L67-L73):
    ```java
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "game_categories",
        joinColumns = @JoinColumn(name = "game_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private Set<Category> categories = new HashSet<>();
    ```
    Câu lệnh SQL Server thực hiện ngầm dưới database để nạp các thể loại:
    ```sql
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
    1. JavaScript ngay lập tức cập nhật trạng thái trên giao diện và `localStorage` thông qua hàm `toggleFavorite(event, id)` tại [index.js dòng 141-215](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/assets/js/index.js#L141-L215).
    2. Gửi một yêu cầu Fetch API (AJAX) không đồng bộ tới backend thông qua API `/api/wishlist/toggle`.
    3. Nếu API thất bại (trả về `ERROR` hoặc lỗi mạng), JavaScript tự động khôi phục lại trạng thái cũ trên UI và `localStorage` (Rollback) tại [index.js dòng 180-207](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/assets/js/index.js#L180-L207):
        ```javascript
        if (params.ERROR) {
          // Rollback optimistic update
          if (wasFavorite) {
            favorites.add(gameId);
          } else {
            favorites.delete(gameId);
          }
          saveState();
          alert(params.ERROR);
        }
        ```
*   **Backend & Tầng CSDL:**
    Hàm xử lý chính nằm ở `toggleWishlist` tại [StoreController.java dòng 260-292](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L260-L292):
    ```java
    @RequestMapping(value = "/api/wishlist/toggle", method = RequestMethod.POST)
    public void toggleWishlist(@RequestParam("gameId") Long gameId,
                               HttpSession session,
                               HttpServletResponse response) throws IOException {
        ...
        WishlistItem existing = wishlistItemDAO.findByUserAndGame(currentUser.getId(), gameId);
        if (existing != null) {
            wishlistItemDAO.deleteById(existing.getId());
            long count = wishlistItemDAO.getWishlistCount(currentUser.getId());
            out.print("STATUS=REMOVED&COUNT=" + count);
        } else {
            Game game = gameDAO.findById(gameId);
            if (game == null) {
                out.print("ERROR=Game không tồn tại.");
                return;
            }

            WishlistItem newItem = new WishlistItem();
            newItem.setUser(currentUser);
            newItem.setGame(game);
            wishlistItemDAO.save(newItem);

            long count = wishlistItemDAO.getWishlistCount(currentUser.getId());
            out.print("STATUS=ADDED&COUNT=" + count);
        }
    }
    ```
    Truy vấn HQL `findByUserAndGame` tại [WishlistItemDAO.java dòng 20-31](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/WishlistItemDAO.java#L20-L31):
    ```java
    @Transactional(readOnly = true)
    public WishlistItem findByUserAndGame(Long userId, Long gameId) {
        try {
            return sessionFactory.getCurrentSession()
                .createQuery("FROM WishlistItem w WHERE w.user.id = :userId AND w.game.id = :gameId", WishlistItem.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }
    ```
    Hàm xóa thực thể `deleteById` và lưu thực thể `save` kế thừa từ lớp cơ sở [BaseDAO.java dòng 31-33 và 43-48](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/BaseDAO.java#L31-L33):
    ```java
    public void save(T entity) {
        sessionFactory.getCurrentSession().save(entity);
    }
    public void deleteById(Long id) {
        sessionFactory.getCurrentSession()
                      .createQuery("delete from " + clazz.getName() + " where id = :id")
                      .setParameter("id", id)
                      .executeUpdate();
    }
    ```
    *   **SQL ngầm bên dưới:**
        Lệnh kiểm tra tồn tại tương ứng với HQL trong `findByUserAndGame` tại dòng 23-26 của `WishlistItemDAO.java`; câu lệnh INSERT/DELETE tương ứng với `BaseDAO.java` dòng 31-33 và 43-48:
        ```sql
        -- Kiểm tra sự tồn tại trong wishlist
        SELECT id FROM wishlists WHERE user_id = 5 AND game_id = 12;
        -- Nếu tồn tại -> Xóa
        DELETE FROM wishlists WHERE id = ?;
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
Hàm chính xử lý việc hiển thị thông tin chi tiết game nằm ở `viewGameDetail` tại [StoreController.java dòng 150-241](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L150-L241):
```java
@RequestMapping(value = "/game/{gameSlug}", method = RequestMethod.GET)
public String viewGameDetail(@PathVariable("gameSlug") String gameSlug, HttpSession session, Model model) {

    // Truy vấn dữ liệu thực tế từ SQL Server
    Game game = gameDAO.findBySlug(gameSlug);

    // Nếu gõ sai đường dẫn hoặc game không tồn tại, trả về trang lỗi 404
    if (game == null) {
        return "errors/404";
    }

    model.addAttribute("game", game);

    // Nạp Đánh giá thực tế từ Database
    List<Review> reviews = reviewDAO.findByGame(game.getId());
    model.addAttribute("reviews", reviews);

    // Tính điểm trung bình và số lượng đánh giá
    Object[] ratingInfo = reviewDAO.getAverageRatingAndCount(game.getId());
    Double avgRating = (Double) ratingInfo[0];
    Long ratingCount = (Long) ratingInfo[1];

    model.addAttribute("averageRating", avgRating != null ? avgRating : 5.0);
    model.addAttribute("reviewsCount", ratingCount != null ? ratingCount : 0L);
    ...
```
*   **Video Trailer nhúng:** Game lưu liên kết nhúng dạng chuỗi (cột `trailerUrl`). Giao diện JSP hiển thị thông qua phần tử `<iframe>` giúp phát video trailer trực tiếp.
*   **Gallery ảnh (GameMedia):** Game lưu danh sách các ảnh chụp màn hình trong bảng `game_media`. Giao diện JSP hiển thị ảnh chính (Primary Image) ở khung lớn và danh sách các ảnh phụ.
*   **CSDL ngầm bên dưới:**
    Truy vấn thông tin game bằng HQL `findBySlug` tại [GameDAO.java dòng 18-28](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/GameDAO.java#L18-L28):
    ```java
    @Transactional(readOnly = true)
    public Game findBySlug(String slug) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM Game g WHERE g.slug = :slug", Game.class)
                    .setParameter("slug", slug)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    ```
    Các hình ảnh game media được nạp Eager Load bằng cấu hình `@OneToMany` tại [Game.java dòng 64-65](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Game.java#L64-L65):
    ```java
    @OneToMany(mappedBy = "game", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private List<GameMedia> mediaList;
    ```
    Từ các cấu hình ORM và HQL trên, SQL Server sẽ thực thi câu lệnh SQL thực tế sau dưới database:
    ```sql
    -- Lấy thông tin game theo slug đường dẫn độc nhất
    SELECT * FROM games WHERE slug = 'elden-ring';
    
    -- Lấy danh sách ảnh chụp màn hình của game
    SELECT * FROM game_media WHERE game_id = 5;
    ```
*   **Thiết kế quan hệ bảng:**
    *   Mối quan hệ giữa `games` và `game_media` là quan hệ **Một-Nhiều (OneToMany)**. Một game có thể có hàng chục ảnh chụp màn hình và video giới thiệu để tăng độ hấp dẫn. Cột `game_id` đóng vai trò làm Khóa Ngoại (Foreign Key) tham chiếu từ bảng `game_media` về bảng `games`.

### 4.3 Ràng Buộc & Transaction
*   **Ràng buộc:** Nếu game có trạng thái không phải `ACTIVE` (ví dụ: `PENDING`, `REJECTED`, `PENDING_DELETE`), hệ thống sẽ kiểm tra quyền người dùng hiện tại tại [StoreController.java dòng 210-214](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L210-L214):
    ```java
    boolean isGamePublisher = false;
    if (currentUser != null && game.getPublisher() != null && game.getPublisher().getUser() != null) {
        isGamePublisher = game.getPublisher().getUser().getId().equals(currentUser.getId());
    }
    ```
    Nếu không phải Admin hoặc Publisher sở hữu game đó, hệ thống lập tức chặn truy cập và chuyển hướng về trang lỗi `errors/404` (tại [StoreController.java dòng 157-159](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L157-L159)).
*   **Giao dịch:** Phương thức `viewGameDetail` được đánh dấu `@Transactional(readOnly = true)` tại [StoreController.java dòng 151](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L151). Việc thiết lập thuộc tính `readOnly = true` là cực kỳ quan trọng giúp Hibernate tối ưu hóa bộ nhớ đệm (FlushMode = MANUAL), bỏ qua việc kiểm tra thay đổi thực thể (dirty checking), từ đó giảm thiểu độ trễ tải trang.


---

## 5. BẢNG ĐIỀU KHIỂN NHÀ PHÁT HÀNH (PUBLISHER DASHBOARD)

### 5.1 Các Chức Năng Chính
*   **Đăng/Sửa Game (CRUD):** Giao diện biểu mẫu (Form) điền thông tin chi tiết, chọn thể loại từ danh sách checkbox, cấu hình yêu cầu cấu hình máy tính. Khi hoàn tất, game được lưu trữ với trạng thái mặc định là `PENDING` để gửi yêu cầu phê duyệt tới Admin.
*   **Upload Media:** Cho phép tải lên tệp ảnh bìa (Cover Image) và các tệp ảnh chụp màn hình game (Screenshots) đồng thời.
*   **Patch Notes (Ghi Chú Bản Vá):** Cho phép nhà phát triển cập nhật ghi chú về phiên bản cập nhật sửa lỗi của game dạng văn bản định dạng HTML để hiển thị ở trang chi tiết sản phẩm sau khi Admin phê duyệt.

### 5.2 Phân tích Code & Tầng Database
Các phương thức chính nằm ở [PublisherController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java):
*   **Xử lý Slug độc nhất:** Khi tạo mới hoặc sửa game, nếu người dùng không điền slug, hệ thống tự động gọi hàm `toSlug(String title)` định nghĩa tại [PublisherController.java dòng 678-689](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L678-L689) để chuyển đổi tên game thành chuỗi chữ thường không dấu kết nối bằng dấu gạch ngang:
    ```java
    private String toSlug(String title) {
        if (title == null) return "";
        String normalized = java.text.Normalizer.normalize(title, java.text.Normalizer.Form.NFD);
        String result = normalized.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        result = result.toLowerCase()
                .replaceAll("[đĐ]", "d")
                .replaceAll("[^a-z0-9\\s-]", "")
                .replaceAll("\\s+", "-")
                .replaceAll("-+", "-")
                .trim();
        return result;
    }
    ```
*   **Cơ chế lưu ảnh vĩnh viễn:** Khi người dùng upload ảnh, hàm `saveGameMediaFile` định nghĩa tại [PublisherController.java dòng 641-676](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L641-L676) sẽ xử lý:
    1. Lưu ảnh vào thư mục triển khai tạm thời của Tomcat server (`/assets/images/games/...`) để hiển thị ngay lập tức.
    2. Đồng thời sao chép tệp ảnh về thư mục source code vật lý `webappSourcePath` (dòng 657-673).
    ```java
    private String saveGameMediaFile(MultipartFile file, String gameSlug, HttpSession session) throws Exception {
        if (file == null || file.isEmpty()) return null;

        String uploadDirPath = session.getServletContext().getRealPath("/assets/images/games/" + gameSlug);
        File uploadDir = new File(uploadDirPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String originalName = file.getOriginalFilename();
        String extension = "";
        if (originalName != null && originalName.contains(".")) {
            extension = originalName.substring(originalName.lastIndexOf("."));
        }
        String fileName = "media_" + UUID.randomUUID().toString() + extension;
        File destination = new File(uploadDir, fileName);
        file.transferTo(destination);

        // Cũng lưu vào thư mục source code (vĩnh viễn)
        String targetSourcePath = webappSourcePath;
        if (targetSourcePath == null || targetSourcePath.trim().isEmpty()) {
            targetSourcePath = "c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp";
        }

        try {
            File srcDir = new File(targetSourcePath, "assets/images/games/" + gameSlug);
            if (!srcDir.exists()) srcDir.mkdirs();
            File srcDest = new File(srcDir, fileName);
            try (java.io.InputStream in = file.getInputStream()) {
                java.nio.file.Files.copy(in, srcDest.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }
            System.out.println("[Upload] Đã lưu vĩnh viễn: " + srcDest.getAbsolutePath());
        } catch (Exception e) {
            System.err.println("[Upload] Lỗi copy về source: " + e.getMessage());
        }

        return "/assets/images/games/" + gameSlug + "/" + fileName;
    }
    ```
*   **Tương tác Database ngầm bên dưới:**
    (Lệnh INSERT game mới chạy trong phương thức `addGame` tại [PublisherController.java dòng 242-375](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L242-L375); các lệnh INSERT media chạy tại dòng 315-356):
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
    *   **Frontend (JS/HTML5):** Biểu mẫu [game-form.jsp](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/WEB-INF/views/publisher/game-form.jsp) quy định các ô nhập liệu bắt buộc (`required`), tên game có độ dài tối đa 150 ký tự (dòng 162), giá bán tối thiểu là 0 (dòng 173), ngày phát hành giới hạn từ 1970 đến 2100 (dòng 185). Định dạng file tải lên bắt buộc phải là ảnh `accept="image/*"` (dòng 298, 319).
    *   **Backend (Spring MVC):**
        *   **Xử lý lỗi Binding và trùng lặp Slug trong `addGame` tại [PublisherController.java dòng 257-288](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L257-L288):**
            ```java
            // Kiểm tra lỗi binding (ví dụ: ngày phát hành không hợp lệ)
            if (bindingResult.hasErrors()) {
                String errorMsg = "Dữ liệu không hợp lệ: ";
                if (bindingResult.hasFieldErrors("releaseDate")) {
                    errorMsg = "Ngày phát hành không hợp lệ! Vui lòng nhập đúng định dạng (ví dụ: 2024-01-15).";
                } else {
                    errorMsg += bindingResult.getAllErrors().get(0).getDefaultMessage();
                }
                model.addAttribute("error", errorMsg);
                model.addAttribute("categories", categoryDAO.findAll());
                model.addAttribute("actionUrl", "/publisher/games/add");
                model.addAttribute("isEdit", false);
                return "publisher/game-form";
            }

            try {
                // Slug handling
                if (game.getSlug() == null || game.getSlug().trim().isEmpty()) {
                    game.setSlug(toSlug(game.getTitle()));
                } else {
                    game.setSlug(toSlug(game.getSlug()));
                }

                // Kiểm tra slug trùng lặp
                Game existing = gameDAO.findBySlug(game.getSlug());
                if (existing != null) {
                    model.addAttribute("error", "Slug đường dẫn đã tồn tại trên hệ thống!");
                    model.addAttribute("categories", categoryDAO.findAll());
                    model.addAttribute("actionUrl", "/publisher/games/add");
                    model.addAttribute("isEdit", false);
                    return "publisher/game-form";
                }
            ```
        *   **Xử lý lỗi Binding trong `editGame` tại [PublisherController.java dòng 413-433](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L413-L433):**
            ```java
            // Kiểm tra lỗi binding (ví dụ: ngày phát hành không hợp lệ)
            if (bindingResult.hasErrors()) {
                String errorMsg = "Dữ liệu không hợp lệ: ";
                if (bindingResult.hasFieldErrors("releaseDate")) {
                    errorMsg = "Ngày phát hành không hợp lệ! Vui lòng nhập đúng định dạng (ví dụ: 2024-01-15).";
                } else {
                    errorMsg += bindingResult.getAllErrors().get(0).getDefaultMessage();
                }
                model.addAttribute("error", errorMsg);
                model.addAttribute("categories", categoryDAO.findAll());
                model.addAttribute("actionUrl", "/publisher/games/edit/" + id);
                model.addAttribute("isEdit", true);
                return "publisher/game-form";
            }

            Game game = gameDAO.findById(id);
            if (game == null || !game.getPublisher().getId().equals(profile.getId())) {
                return "redirect:/publisher/games?error=not-authorized";
            }
            ```

### 5.4 Xử lý Ngoại lệ & Transaction
*   **Giao dịch:** Phương thức `addGame` (dòng 242-375) và `editGame` (dòng 397-524) được quản lý bởi annotation `@Transactional` cấp class của `PublisherController.java`. Nếu quá trình ghi tệp vật lý bị lỗi gây ra ngoại lệ `IOException`, Spring Transaction sẽ tự động can thiệp và Rollback toàn bộ dữ liệu đã thay đổi trong Database trước đó để tránh tình trạng lưu thiếu thông tin.

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
*   **Logic Verified Purchase:** Kiểm tra xem tài khoản hiện tại đã thực sự mua game và sở hữu bản quyền game đó chưa thì mới cho phép tạo form đánh giá.
    *   Hàm kiểm tra nằm ở [LibraryItemDAO.java dòng 27-38](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/LibraryItemDAO.java#L27-L38):
        ```java
        @Transactional(readOnly = true)
        public boolean existsActiveByUserAndGame(Long userId, Long gameId) {
            Long count = sessionFactory.getCurrentSession()
                    .createQuery(
                            "SELECT COUNT(li.id) FROM LibraryItem li JOIN li.game g " +
                            "WHERE li.user.id = :userId AND li.game.id = :gameId AND li.status = 'ACTIVE' AND g.status != 'DELETED'",
                            Long.class)
                    .setParameter("userId", userId)
                    .setParameter("gameId", gameId)
                    .uniqueResult();
            return count != null && count > 0;
        }
        ```
    *   Gọi và kiểm tra tại [StoreController.java dòng 333-336](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L333-L336):
        ```java
        boolean owned = libraryItemDAO.existsActiveByUserAndGame(currentUser.getId(), gameId);
        if (!owned) {
            return "redirect:/game/" + game.getSlug() + "?error=not-owned";
        }
        ```
*   **Khóa cứng Đánh giá gốc (Review Lock):** Ngăn chặn tuyệt đối việc người dùng sửa đổi đánh giá ban đầu sau khi đã nhấn lưu để bảo vệ tính công bằng.
    *   Hàm tìm đánh giá cũ nằm tại [ReviewDAO.java dòng 31-40](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/ReviewDAO.java#L31-L40):
        ```java
        @Transactional(readOnly = true)
        public Review findByUserAndGame(Long userId, Long gameId) {
            try {
                return sessionFactory.getCurrentSession()
                        .createQuery("FROM Review r WHERE r.user.id = :userId AND r.game.id = :gameId", Review.class)
                        .setParameter("userId", userId)
                        .setParameter("gameId", gameId)
                        .uniqueResult();
            } catch (Exception e) {
                return null;
            }
        }
        ```
    *   Gọi chặn trùng lặp tại [StoreController.java dòng 347-350](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L347-L350):
        ```java
        Review existing = reviewDAO.findByUserAndGame(currentUser.getId(), gameId);
        if (existing != null) {
            return "redirect:/game/" + game.getSlug() + "?error=already-reviewed";
        }
        ```
*   **Hệ thống Phản hồi (Reply) & Ghi Đè:** Nhà phát triển sở hữu game hoặc Admin có quyền phản hồi đánh giá thông qua hàm `replyToReview` tại [StoreController.java dòng 374-409](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L374-L409):
    ```java
    @RequestMapping(value = "/api/reviews/reply", method = RequestMethod.POST)
    public String replyToReview(@RequestParam("reviewId") Long reviewId,
                                @RequestParam("replyText") String replyText,
                                HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        Review review = reviewDAO.findById(reviewId);
        if (review == null) {
            return "redirect:/";
        }

        // --- Server-side validation ---
        if (replyText == null || replyText.trim().isEmpty() || replyText.length() > 1000) {
            return "redirect:/game/" + review.getGame().getSlug();
        }

        // Kiểm tra quyền: Chỉ Admin hoặc chính Publisher sở hữu game này mới được phản hồi
        boolean isAdmin = currentUser.hasRole("ROLE_ADMIN");
        boolean isPublisher = false;
        if (review.getGame().getPublisher() != null && review.getGame().getPublisher().getUser() != null) {
            isPublisher = review.getGame().getPublisher().getUser().getId().equals(currentUser.getId());
        }

        if (isAdmin || isPublisher) {
            sessionFactory.getCurrentSession()
                .createQuery("UPDATE Review r SET r.publisherReply = :replyText WHERE r.id = :reviewId")
                .setParameter("replyText", replyText)
                .setParameter("reviewId", reviewId)
                .executeUpdate();
        }

        return "redirect:/game/" + review.getGame().getSlug();
    }
    ```
*   **Đánh giá bổ sung (User Follow-up):** Sau khi nhận được phản hồi từ Nhà phát triển/Admin, người dùng có quyền phản hồi lại **1 lần duy nhất** qua phương thức `addFollowUp` tại [StoreController.java dòng 443-498](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L443-L498):
    ```java
    @RequestMapping(value = "/api/reviews/followup", method = RequestMethod.POST)
    public String addFollowUp(@RequestParam("reviewId") Long reviewId,
                              @RequestParam("followUpText") String followUpText,
                              @RequestParam("followUpRating") Integer followUpRating,
                              HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        Review review = reviewDAO.findById(reviewId);
        if (review == null) {
            return "redirect:/";
        }

        // --- Server-side validation ---
        if (followUpRating == null || followUpRating < 1 || followUpRating > 5) {
            return "redirect:/game/" + review.getGame().getSlug();
        }
        if (followUpText == null || followUpText.trim().isEmpty() || followUpText.length() > 1000) {
            return "redirect:/game/" + review.getGame().getSlug();
        }

        // Phải có phản hồi từ Admin/Publisher mới được bổ sung
        if (review.getPublisherReply() == null || review.getPublisherReply().trim().isEmpty()) {
            return "redirect:/game/" + review.getGame().getSlug() + "?error=no-reply-yet";
        }

        // Chỉ được bổ sung duy nhất 1 lần
        if ((review.getUserFollowUp() != null && !review.getUserFollowUp().trim().isEmpty()) || review.getUserFollowUpRating() != null) {
            return "redirect:/game/" + review.getGame().getSlug() + "?error=already-followed-up";
        }

        // Kiểm tra quyền: Chỉ chính chủ nhân của review mới được bổ sung
        if (review.getUser().getId().equals(currentUser.getId())) {
            sessionFactory.getCurrentSession()
                .createQuery("UPDATE Review r SET r.userFollowUp = :text, r.userFollowUpRating = :rating WHERE r.id = :reviewId")
                .setParameter("text", followUpText)
                .setParameter("rating", followUpRating)
                .setParameter("reviewId", reviewId)
                .executeUpdate();

            // Notify Publisher
            if (review.getGame().getPublisher() != null && review.getGame().getPublisher().getUser() != null) {
                Notification notif = new Notification();
                notif.setTitle("Đánh giá bổ sung");
                notif.setContent("Người dùng @" + currentUser.getUsername() + " đã thêm ý kiến bổ sung " + followUpRating + "★ cho game '" + review.getGame().getTitle() + "'");
                notif.setType("REVIEW");
                notif.setTargetUrl("/game/" + review.getGame().getSlug());
                notif.setUser(review.getGame().getPublisher().getUser());
                notificationDAO.save(notif);
            }
        }

        return "redirect:/game/" + review.getGame().getSlug();
    }
    ```
*   **Tính điểm đánh giá trung bình động:** Khi hiển thị điểm số trung bình của game trên trang chi tiết sản phẩm, hệ thống sử dụng câu lệnh HQL thông minh với hàm `COALESCE` để tự động ưu tiên lấy điểm số sao sau khi bổ sung (nếu có), nếu không có thì lấy điểm đánh giá gốc.
    *   Truy vấn lấy điểm trong [ReviewDAO.java dòng 48-58](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/ReviewDAO.java#L48-L58):
        ```java
        @Transactional(readOnly = true)
        public Object[] getAverageRatingAndCount(Long gameId) {
            try {
                return (Object[]) sessionFactory.getCurrentSession()
                        .createQuery("SELECT AVG(CAST(coalesce(r.userFollowUpRating, r.rating) as double)), COUNT(r) FROM Review r WHERE r.game.id = :gameId")
                        .setParameter("gameId", gameId)
                        .uniqueResult();
            } catch (Exception e) {
                return new Object[]{0.0, 0L};
            }
        }
        ```
    *   **SQL Server thực thi ngầm dưới database:**
        ```sql
        SELECT AVG(CAST(COALESCE(r.userFollowUpRating, r.rating) AS double)) as avgRating, COUNT(r.id) as count 
        FROM reviews r WHERE r.game_id = ?;
        ```

### 6.3 Thiết Kế Tầng CSDL (Database Layer)
*   **Cấu trúc bảng `reviews`:**
    *   Các cột được kiểm tra và tự động khởi tạo bằng câu lệnh DDL qua Native Query trong `afterPropertiesSet()` tại [StoreController.java dòng 82-107](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L82-L107):
        ```java
        @Override
        public void afterPropertiesSet() throws Exception {
            try {
                org.hibernate.Session hqSession = sessionFactory.openSession();
                hqSession.beginTransaction();
                hqSession.createNativeQuery(
                    "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('games') AND name = 'badges') " +
                    "ALTER TABLE games ADD badges VARCHAR(MAX) NULL;"
                ).executeUpdate();
                hqSession.createNativeQuery(
                    "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reviews') AND name = 'publisherReply') " +
                    "ALTER TABLE reviews ADD publisherReply NVARCHAR(MAX) NULL;"
                ).executeUpdate();
                hqSession.createNativeQuery(
                    "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reviews') AND name = 'userFollowUp') " +
                    "ALTER TABLE reviews ADD userFollowUp NVARCHAR(MAX) NULL;"
                ).executeUpdate();
                hqSession.createNativeQuery(
                    "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reviews') AND name = 'userFollowUpRating') " +
                    "ALTER TABLE reviews ADD userFollowUpRating INT NULL;"
                ).executeUpdate();
                hqSession.getTransaction().commit();
                hqSession.close();
            } catch (Exception e) {
                System.err.println(">>> GameForge Schema Warning: " + e.getMessage());
            }
        }
        ```
    *   Mẫu cấu trúc DDL đầy đủ của bảng `reviews` trong SQL Server:
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
    *   `reviews` có quan hệ **Nhiều - Một (ManyToOne)** với `games` (định nghĩa tại [Review.java dòng 17](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L17)) và `users` (dòng 21). 
    *   Trường phản hồi được lưu trực tiếp dạng cột (1-1) trong bảng `reviews` thay vì tách bảng riêng để tối giản hóa cấu trúc CSDL và giảm thiểu số lượng phép JOIN phức tạp khi hiển thị hàng chuyên sâu.

### 6.4 Ràng Buộc & Exception
*   **Validation:** Rating gốc và Follow-up rating bắt buộc phải thuộc đoạn từ `1` đến `5` (quy định bởi `@Max(value = 5)` tại [Review.java dòng 27 và 43](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L27) và check ở dòng 339, 459 trong `StoreController.java`). Nội dung đánh giá gốc không quá 2000 ký tự (quy định bởi `@Size(max = 2000)` dòng 31 của `Review.java`). Lời phản hồi và ý kiến bổ sung không quá 1000 ký tự (quy định bởi `@Size(max = 1000)` dòng 35 và 39 của `Review.java`).
*   **Exception & Transaction:** Nếu vi phạm ràng buộc UNIQUE (do lỗi đồng bộ phía client khiến user nhấn gửi 2 lần cùng lúc), SQL Server sẽ ném ra lỗi vi phạm khóa duy nhất (Constraint Violation Exception). Hibernate lập tức Rollback transaction hiện tại để bảo toàn cấu trúc dữ liệu trong sạch.

---

## 7. HỆ THỐNG HUY HIỆU SẢN PHẨM (BADGE SYSTEM)

### 7.1 Cơ Chế Hoạt Động & Lưu Trữ Tĩnh/Động
Hệ thống huy hiệu (Badge) được xây dựng bằng kiến trúc lai rất linh hoạt giữa CSDL và File cấu hình:
1.  **Mẫu cấu hình mẫu (Badge Definitions):** Các thuộc tính hiển thị tĩnh của huy hiệu (Mã ID, Tên tiêu đề, Tên biểu tượng Lucide Icon, Mã màu HEX, và Phân loại huy hiệu) được lưu trữ tập trung trong tệp cấu hình định dạng JSON tại đường dẫn `/WEB-INF/classes/badges_config.json`. Việc lưu trữ này hoạt động giống như một bộ nhớ đệm (Static Cache), giúp thay đổi giao diện huy hiệu trên toàn hệ thống mà không cần tạo bảng phức tạp trong Database hay chạy lại câu lệnh SQL.
2.  **Huy hiệu động (Dynamic Badge):** Có loại huy hiệu phân loại là `dynamic_downloads`. Huy hiệu này hiển thị tiêu đề chứa từ khóa `%COUNT% Lượt Tải`. Khi load trang chi tiết sản phẩm, hệ thống tự động đếm số lượng bản ghi trong bảng `library_items` của game đó và thay thế từ khóa `%COUNT%` bằng số lượng tải thực tế. Nếu số lượng tải bằng 0, hệ thống tự động hiển thị mặc định `"95+"` để giữ thẩm mỹ cho giao diện.
3.  **Lưu huy hiệu vào Game:** Admin có quyền tích chọn các huy hiệu phù hợp cho game. Danh sách các ID huy hiệu đã chọn được nối lại với nhau bằng dấu phẩy và lưu trữ trực tiếp dưới dạng chuỗi (cột `badges`) trong bảng `games` (Ví dụ: `"verified,hot"`).

### 7.2 Phân tích Code & Tầng Database
Các phương thức chính trong [StoreController.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java):
*   **Hàm Đọc/Ghi file cấu hình JSON tại [StoreController.java dòng 127-147](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L127-L147):**
    ```java
    // Đọc danh sách huy hiệu từ file JSON
    private List<Badge> loadAvailableBadges() {
        try {
            File file = new File(getBadgeFilePath());
            if (file.exists()) {
                return objectMapper.readValue(file, new TypeReference<List<Badge>>() {});
            }
        } catch (Exception e) {
            System.err.println(">>> Error loading badges JSON: " + e.getMessage());
        }
        return new ArrayList<>();
    }

    // Ghi danh sách huy hiệu vào file JSON
    private void saveAvailableBadges(List<Badge> list) {
        try {
            File file = new File(getBadgeFilePath());
            objectMapper.writeValue(file, list);
        } catch (Exception e) {
            System.err.println(">>> Error saving badges JSON: " + e.getMessage());
        }
    }
    ```
*   **API Gán Huy hiệu tích chọn cho Game tại [StoreController.java dòng 501-524](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L501-L524):**
    ```java
    @RequestMapping(value = "/api/admin/save-game-badges", method = RequestMethod.POST)
    public void saveGameBadges(@RequestParam("gameId") Long gameId,
                               @RequestParam(value = "badges", required = false) String badgesStr,
                               HttpSession session,
                               HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null || !currentUser.hasRole("ROLE_ADMIN")) {
            out.print("ERROR=Từ chối truy cập. Chỉ dành cho quản trị viên.");
            return;
        }

        Game game = gameDAO.findById(gameId);
        if (game == null) {
            out.print("ERROR=Game không tồn tại.");
            return;
        }

        game.setBadges(badgesStr != null ? badgesStr : "");
        gameDAO.update(game);
        out.print("OK");
    }
    ```
*   **API Tạo Huy hiệu mới tại [StoreController.java dòng 527-573](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L527-L573):**
    ```java
    @RequestMapping(value = "/api/admin/create-badge", method = RequestMethod.POST)
    public void createBadge(@RequestParam("title") String title,
                            @RequestParam("icon") String icon,
                            @RequestParam("color") String color,
                            @RequestParam("type") String type,
                            HttpSession session,
                            HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null || !currentUser.hasRole("ROLE_ADMIN")) {
            out.print("ERROR=Từ chối truy cập. Chỉ dành cho quản trị viên.");
            return;
        }

        // Chuẩn hóa tiêu đề dựa theo tính chất huy hiệu
        String finalTitle = title;
        if ("static".equals(type)) {
            finalTitle = title.replaceAll("(?i)%COUNT%", "").trim();
        } else if ("dynamic_downloads".equals(type)) {
            if (!title.toUpperCase().contains("%COUNT%")) {
                finalTitle = title + " (%COUNT%)";
            }
        }

        // Tạo an toàn ID bằng cách chuyển sang viết thường và bỏ khoảng cách
        String safeId = finalTitle.toLowerCase()
                .replaceAll("[^a-zA-Z0-9\\s]", "")
                .replaceAll("\\s+", "-");
        
        List<Badge> currentBadges = loadAvailableBadges();
        
        // Kiểm tra xem đã trùng ID chưa
        for (Badge b : currentBadges) {
            if (b.getId().equals(safeId)) {
                out.print("ERROR=Huy hiệu này đã tồn tại.");
                return;
            }
        }

        Badge newBadge = new Badge(safeId, finalTitle, icon, color, type);
        currentBadges.add(newBadge);
        saveAvailableBadges(currentBadges);

        out.print("OK");
    }
    ```
*   **API Cập nhật Huy hiệu đã có tại [StoreController.java dòng 576-624](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L576-L624):**
    ```java
    @RequestMapping(value = "/api/admin/edit-badge", method = RequestMethod.POST)
    public void editBadge(@RequestParam("id") String id,
                           @RequestParam("title") String title,
                           @RequestParam("icon") String icon,
                           @RequestParam("color") String color,
                           @RequestParam("type") String type,
                           HttpSession session,
                           HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null || !currentUser.hasRole("ROLE_ADMIN")) {
            out.print("ERROR=Từ chối truy cập. Chỉ dành cho quản trị viên.");
            return;
        }

        List<Badge> currentBadges = loadAvailableBadges();
        boolean found = false;
        
        // Chuẩn hóa tiêu đề dựa theo tính chất huy hiệu
        String finalTitle = title;
        if ("static".equals(type)) {
            finalTitle = title.replaceAll("(?i)%COUNT%", "").trim();
        } else if ("dynamic_downloads".equals(type)) {
            if (!title.toUpperCase().contains("%COUNT%")) {
                finalTitle = title + " (%COUNT%)";
            }
        }

        for (Badge b : currentBadges) {
            if (b.getId().equals(id)) {
                b.setTitle(finalTitle);
                b.setIcon(icon);
                b.setColor(color);
                b.setType(type);
                found = true;
                break;
            }
        }

        if (!found) {
            out.print("ERROR=Huy hiệu không tồn tại.");
            return;
        }

        saveAvailableBadges(currentBadges);
        out.print("OK");
    }
    ```
*   **CSDL ngầm bên dưới:**
    *   Lấy chuỗi badges lưu trong thực thể `Game` trường `badges` tại [Game.java dòng 49](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Game.java#L49):
        ```java
        @Column(name = "badges", length = 4000)
        private String badges;
        ```
    *   Lệnh cập nhật badges cho game chạy trong `saveGameBadges` tại [StoreController.java dòng 522](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L522):
        ```java
        gameDAO.update(game);
        ```
    *   Truy vấn đếm lượt tải thực tế của game trong hệ thống phục vụ cho huy hiệu động được định nghĩa tại [LibraryItemDAO.java dòng 80-86](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/LibraryItemDAO.java#L80-L86):
        ```java
        @Transactional(readOnly = true)
        public long countDownloadsByGameId(Long gameId) {
            Long count = sessionFactory.getCurrentSession()
                    .createQuery("SELECT COUNT(li.id) FROM LibraryItem li WHERE li.game.id = :gameId AND li.status != 'REFUNDED'", Long.class)
                    .setParameter("gameId", gameId)
                    .uniqueResult();
            return count != null ? count : 0L;
        }
        ```
    *   **SQL Server thực thi ngầm dưới database:**
        ```sql
        -- Lấy chuỗi huy hiệu được gán cho game
        SELECT badges FROM games WHERE id = 5;
        
        -- Đếm số lượt tải thực tế của game trong hệ thống để gán vào huy hiệu dynamic
        SELECT COUNT(id) FROM library_items WHERE game_id = 5 AND status != 'REFUNDED';
        
        -- Cập nhật danh sách huy hiệu được tích chọn cho game của Admin
        UPDATE games SET badges = 'verified,hot,top-downloaded' WHERE id = 5;
        ```
*   **Tại sao lại thiết kế lưu chuỗi ngăn cách bằng dấu phẩy thay vì bảng quan hệ Nhiều-Nhiều?**
    *   Huy hiệu là tính năng mang tính chất trang trí giao diện và lượng huy hiệu gán cho mỗi game rất ít (thường chỉ từ 1-3 cái).
    *   Việc lưu dạng chuỗi comma-separated giúp loại bỏ hoàn toàn việc phải tạo thêm bảng liên kết `game_badges` và giảm thiểu chi phí JOIN bảng khi hiển thị danh sách game ở trang chủ. Việc giải mã chuỗi được thực hiện trên bộ nhớ RAM bằng Java cực kỳ nhanh chóng.

### 7.3 Ràng Buộc & Validation
*   **Ràng buộc bảo mật:** Tất cả các API thay đổi mẫu huy hiệu (`/api/admin/create-badge` tại dòng 527-573, `/api/admin/edit-badge` tại dòng 576-624, `/api/admin/delete-badge` tại dòng 627-649 trong `StoreController.java`) và API gán huy hiệu cho game (`/api/admin/save-game-badges` tại dòng 501-524) bắt buộc phải kiểm tra quyền hạn tài khoản trong session. Nếu không có vai trò `ROLE_ADMIN`, API lập tức chặn và trả về lỗi `"ERROR=Từ chối truy cập"` (dòng 510-513, 538-541, 587-590, 634-638).
*   **Chuẩn hóa dữ liệu đầu vào:** Khi Admin tạo huy hiệu mới, tiêu đề huy hiệu tĩnh sẽ tự động loại bỏ từ khóa `%COUNT%` (dòng 545-546), còn huy hiệu động sẽ tự động nối thêm `%COUNT%` ở cuối nếu thiếu (dòng 547-551). ID của huy hiệu được tự động tạo sạch (`safeId`) tại [StoreController.java dòng 554-556](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L554-L556) bằng cách chuyển sang viết thường, bỏ dấu tiếng Việt và thay khoảng trắng bằng dấu gạch ngang.

---

## 8. HỆ THỐNG THÔNG BÁO & BỘ LỌC ĐIỀU HƯỚNG (NOTIFICATION & INTERCEPTOR)

### 8.1 Đồng Bộ Chấm Đỏ Thông Báo Qua Interceptor
Để hiển thị chấm đỏ báo hiệu có thông báo mới trên thanh điều hướng (Navbar Header) ở **tất cả các trang** mà không cần viết code đếm lặp đi lặp lại ở mỗi Controller, hệ thống sử dụng [AuthInterceptor.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/interceptor/AuthInterceptor.java):
*   Khi có bất kỳ request nào gửi lên, phương thức `preHandle` tại [AuthInterceptor.java dòng 17-68](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/interceptor/AuthInterceptor.java#L17-L68) sẽ được kích hoạt đầu tiên để đếm và tiêm số lượng thông báo vào `request`:
    ```java
    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser != null) {
            long unreadCount = 0;
            if (currentUser.hasRole("ROLE_ADMIN")) {
                unreadCount = notificationDAO.countUnreadForAdmins();
            } else if (currentUser.hasRole("ROLE_PUBLISHER")) {
                unreadCount = notificationDAO.countUnreadByUser(currentUser.getId());
            }
            request.setAttribute("unreadNotificationCount", unreadCount);
        }

        boolean adminPath = isAdminPath(uri, contextPath);
        boolean publisherPath = isPublisherPath(uri, contextPath);
        boolean userOnlyPath = isUserOnlyPath(uri, contextPath);

        if (currentUser == null && (adminPath || publisherPath || userOnlyPath)) {
            response.sendRedirect(contextPath + "/login");
            return false;
        }

        if (currentUser == null) {
            return true;
        }

        boolean isAdmin = currentUser.hasRole("ROLE_ADMIN");
        boolean isPublisher = currentUser.hasRole("ROLE_PUBLISHER");
        boolean isUser = currentUser.hasRole("ROLE_USER");

        if (adminPath && !isAdmin) {
            response.sendRedirect(contextPath + "/access-denied");
            return false;
        }

        if (publisherPath && !isPublisher) {
            response.sendRedirect(contextPath + "/access-denied");
            return false;
        }

        if (userOnlyPath && (isAdmin || isPublisher || !isUser)) {
            response.sendRedirect(contextPath + "/access-denied");
            return false;
        }

        return true;
    }
    ```
*   Các truy vấn đếm thông báo chưa đọc trong [NotificationDAO.java](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/NotificationDAO.java):
    *   Hàm đếm cho Publisher tại [NotificationDAO.java dòng 28-33](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/NotificationDAO.java#L28-L33):
        ```java
        public long countUnreadByUser(Long userId) {
            return sessionFactory.getCurrentSession()
                    .createQuery("SELECT COUNT(n.id) FROM Notification n WHERE n.user.id = :userId AND n.read = false", Long.class)
                    .setParameter("userId", userId)
                    .uniqueResult();
        }
        ```
    *   Hàm đếm cho Admin tại [NotificationDAO.java dòng 35-39](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/NotificationDAO.java#L35-L39):
        ```java
        public long countUnreadForAdmins() {
            return sessionFactory.getCurrentSession()
                    .createQuery("SELECT COUNT(n.id) FROM Notification n WHERE n.user IS NULL AND n.read = false", Long.class)
                    .uniqueResult();
        }
        ```

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
Mã nguồn xử lý nghiệp vụ chính nằm tại phương thức `approveGame` thuộc [AdminController.java dòng 466-568](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/AdminController.java#L466-L568):
```java
    @PostMapping("/admin/games/approve")
    @Transactional
    public String approveGame(@RequestParam("gameId") Long gameId, HttpSession session) {
        Game game = gameDAO.findById(gameId);
        if (game != null) {
            User currentUser = userContextService.getCurrentUser(session);
            String approvedBy = "Admin";
            if (currentUser != null) {
                approvedBy = currentUser.getFullName();
                if (approvedBy == null || approvedBy.trim().isEmpty()) {
                    approvedBy = currentUser.getUsername();
                }
            }

            if ("PENDING_DELETE".equals(game.getStatus())) {
                // Duyệt xóa game
                game.setStatus("DELETED");
                game.setApprovedAt(java.time.LocalDateTime.now());
                game.setApprovedBy(approvedBy);
                gameDAO.update(game);

                // Tìm tất cả các LibraryItem của game này mà chưa bị REFUNDED để hoàn tiền
                List<LibraryItem> items = libraryItemDAO.findNonRefundedByGameIdWithDetails(gameId);

                for (LibraryItem item : items) {
                    BigDecimal refundAmount = BigDecimal.ZERO;
                    if (item.getOrderItem() != null) {
                        refundAmount = item.getOrderItem().getPaidAmount();
                    } else {
                        refundAmount = game.getPrice();
                    }
                    
                    // Thực hiện hoàn tiền
                    walletService.refund(item.getUser(), refundAmount, "REFUND_DELETED_GAME_" + gameId);
                    
                    // Cập nhật trạng thái thư viện game
                    item.setStatus("REFUNDED");
                    libraryItemDAO.update(item);

                    // Gửi email thông báo hoàn tiền cho người dùng
                    try {
                        emailService.sendRefundEmail(item.getUser(), game, refundAmount);
                    } catch (Exception e) {
                        System.err.println("Lỗi gửi email hoàn tiền cho user " + item.getUser().getUsername() + ": " + e.getMessage());
                    }

                    // Thêm thông báo trên web cho người dùng
                    Notification notif = new Notification();
                    notif.setTitle("Thông báo hoàn tiền game");
                    notif.setContent("Tựa game '" + game.getTitle() + "' đã bị gỡ khỏi hệ thống. Bạn đã được hoàn lại số tiền " + refundAmount.setScale(0).toPlainString() + "đ vào ví.");
                    notif.setType("WALLET");
                    notif.setTargetUrl("/library");
                    notif.setUser(item.getUser());
                    notificationDAO.save(notif);
                }

                // Notify Publisher User
                if (game.getPublisher() != null && game.getPublisher().getUser() != null) {
                    Notification notif = new Notification();
                    notif.setTitle("Yêu cầu xóa game đã được duyệt");
                    notif.setContent("Yêu cầu xóa tựa game '" + game.getTitle() + "' của bạn đã được Admin phê duyệt. Hệ thống đã tiến hành hoàn tiền cho người mua.");
                    notif.setType("GAME_APPROVAL");
                    notif.setTargetUrl("/publisher/games");
                    notif.setUser(game.getPublisher().getUser());
                    notificationDAO.save(notif);
                }
                return "redirect:/admin/games?success=deleted-approved";
            } else {
                // Duyệt đăng game mới
                game.setStatus("ACTIVE");
                game.setApprovedAt(java.time.LocalDateTime.now());
                game.setApprovedBy(approvedBy);

                // Tổ chức lại các file ảnh vật lý
                organizeGameMediaFiles(game, servletContext);

                gameDAO.update(game);

                // Tự động tạo 100 license key cho game vừa được duyệt
                for (int i = 0; i < 100; i++) {
                    com.gamestore.entity.LicenseKey key = new com.gamestore.entity.LicenseKey();
                    key.setGame(game);
                    String uuid = java.util.UUID.randomUUID().toString().toUpperCase().replace("-", "");
                    String keyString = uuid.substring(0, 5) + "-" + uuid.substring(5, 10) + "-" + uuid.substring(10, 15);
                    key.setKeyString(keyString);
                    key.setStatus("AVAILABLE");
                    key.setCreatedAt(java.time.LocalDateTime.now());
                    licenseKeyDAO.save(key);
                }

                // Notify Publisher User
                if (game.getPublisher() != null && game.getPublisher().getUser() != null) {
                    Notification notif = new Notification();
                    notif.setTitle("Game được phê duyệt");
                    notif.setContent("Tựa game '" + game.getTitle() + "' của bạn đã được phê duyệt và hiển thị trên cửa hàng.");
                    notif.setType("GAME_APPROVAL");
                    notif.setTargetUrl("/" + game.getSlug());
                    notif.setUser(game.getPublisher().getUser());
                    notificationDAO.save(notif);
                }
                return "redirect:/admin/games?success=approved";
            }
        }
        return "redirect:/admin/games?error=not-found";
    }
```

*   **Truy vấn lấy danh sách Thư viện chưa hoàn tiền để duyệt xóa game:**
    Được viết bằng HQL tối ưu với `JOIN FETCH` tại [LibraryItemDAO.java dòng 100-105](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/dao/LibraryItemDAO.java#L100-L105):
    ```java
    @Transactional(readOnly = true)
    public List<LibraryItem> findNonRefundedByGameIdWithDetails(Long gameId) {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM LibraryItem li JOIN FETCH li.user u LEFT JOIN FETCH li.orderItem oi WHERE li.game.id = :gameId AND li.status != 'REFUNDED'", LibraryItem.class)
                .setParameter("gameId", gameId)
                .list();
    }
    ```

1.  **Duy trì tính nhất quán dữ liệu (Atomicity):** Phương thức được đánh dấu `@Transactional`. Toàn bộ chuỗi hành động gồm cập nhật trạng thái game, cộng tiền vào ví của hàng trăm khách hàng, ghi lịch sử giao dịch và thay đổi trạng thái thư viện game phải được thực thi trọn vẹn. Nếu xảy ra lỗi giữa chừng (ví dụ: máy chủ SQL Server mất kết nối khi đang hoàn tiền cho khách hàng thứ 50), Spring sẽ lập tức **Rollback** toàn bộ transaction. Số dư ví của 49 khách hàng trước đó sẽ được khôi phục lại như cũ, trạng thái game quay lại là `PENDING_DELETE` để đảm bảo không bị thất thoát tiền của hệ thống.
2.  **Tách biệt rủi ro truyền thông (Email Exception Handling):** Gửi email là tác vụ kết nối với SMTP Server bên ngoài thông qua mạng Internet, có thời gian trễ lớn và độ rủi ro thất bại cao (do mạng lag hoặc hòm thư lỗi). Do đó, tác vụ gửi email được bọc riêng trong một khối `try-catch` độc lập (tại dòng 504-508 của `AdminController.java`):
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

## 10. HỆ THỐNG RÀNG BUỘC DỮ LIỆU ĐẦU VÀO (INPUT VALIDATION CONSTRAINTS)

Để bảo đảm tính toàn vẹn dữ liệu từ Giao diện (Client-side) xuống Cơ sở dữ liệu (Database), hệ thống GameForce áp dụng cơ chế xác thực dữ liệu 2 lớp (Two-way Validation): Xác thực trực tiếp trên trình duyệt (HTML5/JavaScript) và Xác thực phía máy chủ (Bean Validation/Spring Controller/Database Constraints).

Dưới đây là chi tiết tất cả các trường nhập liệu thuộc phạm vi phụ trách của **Frontend Lead**:

### 10.1 Bảng Ràng Buộc Chi Tiết Các Trường Nhập Liệu

| Phân hệ / Biểu mẫu | Tên Trường | Ràng buộc Giao diện (Frontend) | Ràng buộc Máy chủ (Backend) | Kiểu dữ liệu / Database | Mô tả lỗi hiển thị / Ghi chú & File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Đăng / Sửa Game** *(Publisher)* | **Tên game** (`title`) | `required`, `maxlength="150"` | `@NotBlank` (gián tiếp check), chuẩn hóa qua hàm `toSlug()`. | `NVARCHAR(150)`, NOT NULL | Báo lỗi nếu trống. File [PublisherController.java dòng 274-275](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L274-L275). |
| | **Slug** (`slug`) | `maxlength="150"` | Tự tạo từ `title` nếu trống. Chuẩn hóa qua hàm `toSlug()`. Kiểm tra trùng lặp trong DB. | `VARCHAR(150)`, UNIQUE | "Slug đường dẫn đã tồn tại trên hệ thống!". [PublisherController.java dòng 280-288](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L280-L288). |
| | **Giá bán** (`price`) | `required`, `type="number"`, `min="0"` | Ràng buộc giá trị không âm. Gán tự động cho `originalPrice`. | `DECIMAL(15,2)`, NOT NULL | Giá game tối thiểu là 0đ (miễn phí). [PublisherController.java dòng 438-439](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L438-L439). |
| | **Nhà phát triển** (`developer`) | `required`, `maxlength="100"` | Bắt buộc có dữ liệu, không được null. | `NVARCHAR(100)`, NOT NULL | [PublisherController.java dòng 440](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L440). |
| | **Ngày phát hành** (`releaseDate`) | `required`, `type="date"`, `min="1970-01-01"`, `max="2100-12-31"` | `BindingResult` kiểm tra lỗi định dạng. Ràng buộc năm từ `1970` đến `2100`. | `DATE`, NOT NULL | "Ngày phát hành không hợp lệ! Năm phải từ 1970 đến 2100." [PublisherController.java dòng 257-265 và 290-295](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L257-L265). |
| | **Thể loại** (`categoryIds`) | Chọn checkbox từ danh sách | Chuyển đổi ID sang thực thể `Category`. Chặn lỗi null. | Quan hệ Nhiều-Nhiều (`game_categories`) | Game bắt buộc phải được gắn ít nhất một thể loại. [PublisherController.java dòng 446-453](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L446-L453). |
| | **Mô tả** (`description`) | `required`, `rows="5"` | Bắt buộc có dữ liệu. | `NVARCHAR(MAX)` | Giới thiệu chi tiết trò chơi. [PublisherController.java dòng 437](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L437). |
| | **Ảnh đại diện** (`coverImageFile`) | `required` (khi tạo mới), `accept="image/*"` | Phải là tệp hình ảnh hợp lệ, lưu trữ vật lý vĩnh viễn về source. | `VARCHAR(500)` (`isPrimary = 1` trong `game_media`) | "Ảnh đại diện game là bắt buộc khi đăng game mới!" [PublisherController.java dòng 306-313](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L306-L313). |
| | **Ảnh Screenshots** (`screenshotFiles`) | Tùy chọn, `accept="image/*"`, hỗ trợ `multiple` | Upload nhiều file ảnh chụp màn hình game. | `VARCHAR(500)` (`isPrimary = 0` trong `game_media`) | Tạo bộ sưu tập ảnh cho game. [PublisherController.java dòng 315-325](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L315-L325). |
| | **Video Trailer** (`trailerUrl`) | Tùy chọn, URL nhúng (embed) | Kiểm tra định dạng url nhúng phát được trực tiếp (iframe). | `VARCHAR(500)` (`mediaType = 'VIDEO'` trong `game_media`) | [PublisherController.java dòng 489-502](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L489-L502). |
| | **Cấu hình** (`minimumRequirements` & `recommendedRequirements`) | Nhập các trường OS, CPU, RAM, GPU riêng | Javascript tự động đóng gói thành chuỗi JSON khi Submit. | `NVARCHAR(MAX)` dạng JSON | [game-form.jsp dòng 215-288](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/WEB-INF/views/publisher/game-form.jsp#L215-L288). |
| **Đánh Giá Game** *(User)* | **Điểm đánh giá** (`rating`) | Bắt buộc chọn từ 1 đến 5 sao | `@NotNull`, `@Min(1)`, `@Max(5)` | `INT`, NOT NULL | Thang điểm từ 1 đến 5. Chặn đánh giá trùng lặp bằng `UNIQUE(game_id, user_id)`. [Review.java dòng 26-28](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L26-L28) và [StoreController.java dòng 339-341](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L339-L341). |
| | **Bình luận** (`comment`) | `maxlength="2000"` | `@Size(max = 2000)` | `NVARCHAR(MAX)` | Nhận xét không quá 2000 ký tự. [Review.java dòng 31-32](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L31-L32). |
| **Phản Hồi Đánh Giá** *(Publisher/Admin)* | **Phản hồi** (`publisherReply`) | `maxlength="1000"` | `@Size(max = 1000)` | `NVARCHAR(MAX)` | Lưu phản hồi chính thức của NPH hoặc Admin, tối đa 1000 ký tự. [Review.java dòng 35-36](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L35-L36) và [StoreController.java dòng 389-391](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L389-L391). |
| **Đánh Giá Bổ Sung** *(User)* | **Nội dung bổ sung** (`userFollowUp`) | `maxlength="1000"` | `@Size(max = 1000)` | `NVARCHAR(MAX)` | Phản hồi lại câu trả lời của NPH, tối đa 1000 ký tự. [Review.java dòng 39-40](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L39-L40). |
| | **Điểm bổ sung** (`userFollowUpRating`) | Chọn 1-5 sao | `@Max(5)`, `@Min(1)` (gián tiếp check) | `INT` | Điểm số sao mới sau khi trải nghiệm lại. [Review.java dòng 43-44](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L43-L44) và [StoreController.java dòng 459-461](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L459-L461). |
| **Hệ Thống Huy Hiệu** *(Admin)* | **Tiêu đề huy hiệu** (`title`) | Bắt buộc nhập | Tự động loại bỏ `%COUNT%` đối với loại tĩnh; tự động thêm `%COUNT%` nếu thiếu đối với loại động. | JSON cấu hình | [StoreController.java dòng 543-551](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L543-L551). |
| | **Biểu tượng** (`icon`) | Bắt buộc chọn | Nhận chuỗi biểu tượng Lucide. | JSON cấu hình | [StoreController.java dòng 529](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L529). |
| | **Màu sắc** (`color`) | Bắt buộc chọn | Nhận chuỗi màu HEX hoặc biến CSS. | JSON cấu hình | [StoreController.java dòng 530](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L530). |
| | **Phân loại** (`type`) | Bắt buộc chọn | Giá trị nhận vào là `static` hoặc `dynamic_downloads`. | JSON cấu hình | [StoreController.java dòng 531](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L531). |
| | **Gán Badge cho Game** (`badges`) | Tích chọn check-boxes | Chuỗi ID các huy hiệu nối nhau bằng dấu phẩy. Cập nhật thực thể Game. | `VARCHAR(MAX)` | [StoreController.java dòng 501-524](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L501-L524). |

---

### 10.2 Trích Dẫn Code Logic Xác Thực Ràng Buộc (Detailed Code Snippets)

#### A. Ràng buộc Game CRUD (Nhà phát triển đăng / sửa game)
*   **Xác thực Binding ngày phát hành và check Slug trùng lặp** trong [PublisherController.java dòng 257-288](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/PublisherController.java#L257-L288):
    ```java
    // Kiểm tra lỗi binding (ví dụ: ngày phát hành không hợp lệ)
    if (bindingResult.hasErrors()) {
        String errorMsg = "Dữ liệu không hợp lệ: ";
        if (bindingResult.hasFieldErrors("releaseDate")) {
            errorMsg = "Ngày phát hành không hợp lệ! Vui lòng nhập đúng định dạng (ví dụ: 2024-01-15).";
        } else {
            errorMsg += bindingResult.getAllErrors().get(0).getDefaultMessage();
        }
        model.addAttribute("error", errorMsg);
        model.addAttribute("categories", categoryDAO.findAll());
        model.addAttribute("actionUrl", "/publisher/games/add");
        model.addAttribute("isEdit", false);
        return "publisher/game-form";
    }

    try {
        // Slug handling
        if (game.getSlug() == null || game.getSlug().trim().isEmpty()) {
            game.setSlug(toSlug(game.getTitle()));
        } else {
            game.setSlug(toSlug(game.getSlug()));
        }

        // Kiểm tra slug trùng lặp
        Game existing = gameDAO.findBySlug(game.getSlug());
        if (existing != null) {
            model.addAttribute("error", "Slug đường dẫn đã tồn tại trên hệ thống!");
            model.addAttribute("categories", categoryDAO.findAll());
            model.addAttribute("actionUrl", "/publisher/games/add");
            model.addAttribute("isEdit", false);
            return "publisher/game-form";
        }
    ```

*   **Ràng buộc cấu hình tối thiểu và đề xuất** được Javascript đóng gói tự động thành JSON khi Submit biểu mẫu tại [game-form.jsp dòng 410-431](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/webapp/WEB-INF/views/publisher/game-form.jsp#L410-L431):
    ```javascript
    document.querySelector('form').addEventListener('submit', function(e) {
      const minReq = {
        os: document.getElementById('minOS').value.trim(),
        cpu: document.getElementById('minCPU').value.trim(),
        ram: document.getElementById('minRAM').value.trim(),
        gpu: document.getElementById('minGPU').value.trim(),
        dx: document.getElementById('minDX').value.trim(),
        storage: document.getElementById('minStorage').value.trim(),
        notes: document.getElementById('minNotes').value.trim()
      };
      const recReq = {
        os: document.getElementById('recOS').value.trim(),
        cpu: document.getElementById('recCPU').value.trim(),
        ram: document.getElementById('recRAM').value.trim(),
        gpu: document.getElementById('recGPU').value.trim(),
        dx: document.getElementById('recDX').value.trim(),
        storage: document.getElementById('recStorage').value.trim(),
        notes: document.getElementById('recNotes').value.trim()
      };
      document.getElementById('minimumRequirements').value = JSON.stringify(minReq);
      document.getElementById('recommendedRequirements').value = JSON.stringify(recReq);
    });
    ```

#### B. Ràng buộc Đánh giá & Phản hồi game
*   **Các annotations JSR-380 ràng buộc trong thực thể** tại [Review.java dòng 26-44](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/entity/Review.java#L26-L44):
    ```java
    @Column(nullable = false)
    @NotNull(message = "Rating không được để trống")
    @Max(value = 5, message = "Rating không được vượt quá 5 sao")
    private Integer rating;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    @Size(max = 2000, message = "Bình luận không được vượt quá 2000 ký tự")
    private String comment;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    @Size(max = 1000, message = "Phản hồi không được vượt quá 1000 ký tự")
    private String publisherReply;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    @Size(max = 1000, message = "Ý kiến bổ sung không được vượt quá 1000 ký tự")
    private String userFollowUp;

    @Column(name = "userFollowUpRating")
    @Max(value = 5, message = "Rating không được vượt quá 5 sao")
    private Integer userFollowUpRating;
    ```

*   **Xác thực Server-side chặt chẽ trong Controller** tại [StoreController.java dòng 338-344](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L338-L344) và [dòng 458-474](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L458-L474):
    ```java
    // 1. Kiểm tra đánh giá gốc
    if (rating == null || rating < 1 || rating > 5) {
        return "redirect:/game/" + game.getSlug();
    }
    if (comment == null || comment.trim().isEmpty() || comment.length() > 2000) {
        return "redirect:/game/" + game.getSlug();
    }
    
    // 2. Kiểm tra đánh giá bổ sung (Follow-up)
    if (followUpRating == null || followUpRating < 1 || followUpRating > 5) {
        return "redirect:/game/" + review.getGame().getSlug();
    }
    if (followUpText == null || followUpText.trim().isEmpty() || followUpText.length() > 1000) {
        return "redirect:/game/" + review.getGame().getSlug();
    }
    // Phải có phản hồi từ Admin/Publisher mới được bổ sung
    if (review.getPublisherReply() == null || review.getPublisherReply().trim().isEmpty()) {
        return "redirect:/game/" + review.getGame().getSlug() + "?error=no-reply-yet";
    }
    // Chỉ được bổ sung duy nhất 1 lần
    if ((review.getUserFollowUp() != null && !review.getUserFollowUp().trim().isEmpty()) || review.getUserFollowUpRating() != null) {
        return "redirect:/game/" + review.getGame().getSlug() + "?error=already-followed-up";
    }
    ```

#### C. Ràng buộc Hệ thống Huy hiệu (Badge System)
*   **Xác thực quyền Admin và chuẩn hóa tạo/sửa Badge** tại [StoreController.java dòng 537-566](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L537-L566):
    ```java
    User currentUser = userContextService.getCurrentUser(session);
    if (currentUser == null || !currentUser.hasRole("ROLE_ADMIN")) {
        out.print("ERROR=Từ chối truy cập. Chỉ dành cho quản trị viên.");
        return;
    }

    // Chuẩn hóa tiêu đề dựa theo tính chất huy hiệu
    String finalTitle = title;
    if ("static".equals(type)) {
        finalTitle = title.replaceAll("(?i)%COUNT%", "").trim();
    } else if ("dynamic_downloads".equals(type)) {
        if (!title.toUpperCase().contains("%COUNT%")) {
            finalTitle = title + " (%COUNT%)";
        }
    }

    // Tạo an toàn ID bằng cách chuyển sang viết thường và bỏ khoảng cách
    String safeId = finalTitle.toLowerCase()
            .replaceAll("[^a-zA-Z0-9\\s]", "")
            .replaceAll("\\s+", "-");
    
    List<Badge> currentBadges = loadAvailableBadges();
    
    // Kiểm tra xem đã trùng ID chưa
    for (Badge b : currentBadges) {
        if (b.getId().equals(safeId)) {
            out.print("ERROR=Huy hiệu này đã tồn tại.");
            return;
        }
    }
    ```

*   **Ràng buộc định dạng lưu gán badge cho Game** tại [StoreController.java dòng 509-522](file:///c:/Users/kitnef/Downloads/GameForce-main/GameForce-main/src/main/java/com/gamestore/controller/StoreController.java#L509-L522):
    ```java
    User currentUser = userContextService.getCurrentUser(session);
    if (currentUser == null || !currentUser.hasRole("ROLE_ADMIN")) {
        out.print("ERROR=Từ chối truy cập. Chỉ dành cho quản trị viên.");
        return;
    }

    Game game = gameDAO.findById(gameId);
    if (game == null) {
        out.print("ERROR=Game không tồn tại.");
        return;
    }

    game.setBadges(badgesStr != null ? badgesStr : "");
    gameDAO.update(game);
    ```

---

## 11. KỊCH BẢN HỎI VẶN NÂNG CAO CỦA GIÁO VIÊN (TEACHER Q&A)

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
*Tài liệu đã được tối ưu hóa 100% bằng Tiếng Việt, loại bỏ phần Giỏ hàng (Cart) không liên quan, làm nổi bật hệ thống Huy hiệu (Badge), Thông báo (Notification), Bảo mật điều hướng (Interceptor), bảng ràng buộc dữ liệu đầu vào (Validation Constraints) cùng kịch bản hỏi vặn chuyên sâu 3 bước.*
