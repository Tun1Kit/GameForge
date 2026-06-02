package com.gamestore.controller;

import com.gamestore.dao.GameDAO;
import com.gamestore.dao.ReviewDAO;
import com.gamestore.dao.WishlistItemDAO;
import com.gamestore.dao.LibraryItemDAO;
import com.gamestore.entity.Game;
import com.gamestore.entity.Review;
import com.gamestore.entity.User;
import com.gamestore.entity.WishlistItem;
import com.gamestore.service.UserContextService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.web.bind.annotation.*;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

@Controller
@Transactional
public class StoreController implements InitializingBean {

    @Autowired
    private GameDAO gameDAO;

    @Autowired
    private ReviewDAO reviewDAO;

    @Autowired
    private WishlistItemDAO wishlistItemDAO;

    @Autowired
    private LibraryItemDAO libraryItemDAO;

    @Autowired
    private UserContextService userContextService;

    @Autowired
    private org.hibernate.SessionFactory sessionFactory;

    @Autowired
    private ServletContext servletContext;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private String getBadgeFilePath() {
        if (servletContext != null) {
            String path = servletContext.getRealPath("/WEB-INF/classes/badges_config.json");
            if (path != null) return path;
        }
        return System.getProperty("user.home") + File.separator + "gamestore_badges.json";
    }

    // 1. TỰ ĐỘNG THÊM CỘT BADGES VÀO CSDL KHI KHỞI CHẠY KHÔNG GÂY LỖI
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
            hqSession.getTransaction().commit();
            hqSession.close();
            System.out.println(">>> GameForge Schema: Các cột [badges], [publisherReply], [userFollowUp] đã được kiểm tra/khởi tạo thành công!");
        } catch (Exception e) {
            System.err.println(">>> GameForge Schema Warning: " + e.getMessage());
        }

        // Khởi tạo tệp cấu hình huy hiệu nếu chưa tồn tại
        try {
            File file = new File(getBadgeFilePath());
            if (!file.exists()) {
                List<Badge> defaultBadges = new ArrayList<>();
                defaultBadges.add(new Badge("verified", "Được xác minh", "shield-check", "#94FFB4", "static"));
                defaultBadges.add(new Badge("hot", "Sản Phẩm Hot", "flame", "var(--gf-pink)", "static"));
                defaultBadges.add(new Badge("top-downloaded", "%COUNT% Lượt Tải", "download", "#FFFEE4", "dynamic_downloads"));
                defaultBadges.add(new Badge("award", "Game Award Prize", "trophy", "var(--gf-yellow)", "static"));
                objectMapper.writeValue(file, defaultBadges);
                System.out.println(">>> GameForge Badge: Đã khởi tạo tệp cấu hình badges_config.json!");
            }
        } catch (Exception e) {
            System.err.println(">>> GameForge Badge Warning: " + e.getMessage());
        }
    }

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

    // Cấu trúc URL động chuẩn hóa: /{gameSlug}
    @RequestMapping(value = "/{gameSlug}", method = RequestMethod.GET)
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

        // TRUY XUẤT VÀ GIẢI MÃ HUY HIỆU ĐỘNG CHO TRANG GAME DETAIL
        List<Badge> allBadges = loadAvailableBadges();
        model.addAttribute("allBadges", allBadges);

        List<Badge> resolvedBadges = new ArrayList<>();
        String gameBadgesStr = game.getBadges();
        
        // Nếu game chưa có cài đặt badges nào, cho hiển thị mặc định: verified, hot
        if (gameBadgesStr == null) {
            gameBadgesStr = "verified,hot";
        }

        List<String> activeBadgeIds = Arrays.asList(gameBadgesStr.split(","));
        model.addAttribute("activeBadgeIds", activeBadgeIds);

        // Đếm số lượng tải thực tế từ DB để gán cho các huy hiệu dynamic
        Long downloadCount = (Long) sessionFactory.getCurrentSession()
                .createQuery("SELECT COUNT(li) FROM LibraryItem li WHERE li.game.id = :gameId")
                .setParameter("gameId", game.getId())
                .uniqueResult();
        if (downloadCount == null) downloadCount = 0L;

        for (Badge badge : allBadges) {
            if (activeBadgeIds.contains(badge.getId())) {
                Badge resolved = new Badge(badge.getId(), badge.getTitle(), badge.getIcon(), badge.getColor(), badge.getType());
                if ("dynamic_downloads".equals(resolved.getType())) {
                    // Nếu downloadCount là 0, cho hiển thị 95+ cho đẹp và đầy đặn, ngược lại lấy thực tế
                    String countStr = (downloadCount > 0) ? String.valueOf(downloadCount) : "95+";
                    resolved.setTitle(resolved.getTitle().replace("%COUNT%", countStr));
                }
                resolvedBadges.add(resolved);
            }
        }
        model.addAttribute("resolvedBadges", resolvedBadges);

        // Trạng thái đăng nhập và kiểm tra đã đánh giá hay yêu thích
        User currentUser = userContextService.getCurrentUser(session);
        model.addAttribute("currentUser", currentUser);
        
        boolean isGamePublisher = false;
        if (currentUser != null && game.getPublisher() != null && game.getPublisher().getUser() != null) {
            isGamePublisher = game.getPublisher().getUser().getId().equals(currentUser.getId());
        }
        model.addAttribute("isGamePublisher", isGamePublisher);

        if (currentUser != null) {
            Review userReview = reviewDAO.findByUserAndGame(currentUser.getId(), game.getId());
            model.addAttribute("userReview", userReview);
            model.addAttribute("hasReviewed", userReview != null);

            WishlistItem wishItem = wishlistItemDAO.findByUserAndGame(currentUser.getId(), game.getId());
            model.addAttribute("isFavorited", wishItem != null);

            boolean owned = libraryItemDAO.existsActiveByUserAndGame(currentUser.getId(), game.getId());
            model.addAttribute("isOwned", owned);
        } else {
            model.addAttribute("hasReviewed", false);
            model.addAttribute("isFavorited", false);
            model.addAttribute("isOwned", false);
        }

        return "store/detail";
    }

    // 2. Trang Danh sách Yêu thích của người dùng: /wishlist
    @RequestMapping(value = "/wishlist", method = RequestMethod.GET)
    public String viewWishlist(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        List<WishlistItem> wishlistItems = wishlistItemDAO.findByUser(currentUser.getId());
        model.addAttribute("wishlistItems", wishlistItems);
        model.addAttribute("currentUser", currentUser);

        return "store/wishlist";
    }

    // 3. API Thêm/Xóa Game khỏi Wishlist bằng AJAX
    @RequestMapping(value = "/api/wishlist/toggle", method = RequestMethod.POST)
    public void toggleWishlist(@RequestParam("gameId") Long gameId,
                               HttpSession session,
                               HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("ERROR=Vui lòng đăng nhập.");
            return;
        }

        WishlistItem existing = wishlistItemDAO.findByUserAndGame(currentUser.getId(), gameId);
        if (existing != null) {
            sessionFactory.getCurrentSession().delete(existing);
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
            sessionFactory.getCurrentSession().save(newItem);

            long count = wishlistItemDAO.getWishlistCount(currentUser.getId());
            out.print("STATUS=ADDED&COUNT=" + count);
        }
    }

    // 4. API Đồng bộ danh sách ID game yêu thích khi load trang
    @RequestMapping(value = "/api/wishlist/items", method = RequestMethod.GET)
    public void getWishlistItems(HttpSession session, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("COUNT=0&IDS=");
            return;
        }

        List<Long> gameIds = wishlistItemDAO.getWishlistGameIds(currentUser.getId());
        StringBuilder idsStr = new StringBuilder();
        for (int i = 0; i < gameIds.size(); i++) {
            if (i > 0) idsStr.append(",");
            idsStr.append(gameIds.get(i));
        }

        out.print("COUNT=" + gameIds.size() + "&IDS=" + idsStr.toString());
    }

    // 5. Thêm/Cập nhật đánh giá thực tế của người dùng
    @RequestMapping(value = "/api/reviews/add", method = RequestMethod.POST)
    public String addOrUpdateReview(@RequestParam("gameId") Long gameId,
                                    @RequestParam("rating") Integer rating,
                                    @RequestParam("comment") String comment,
                                    HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        Game game = gameDAO.findById(gameId);
        if (game == null) {
            return "redirect:/";
        }

        // --- Server-side validation ---
        if (rating == null || rating < 1 || rating > 5) {
            return "redirect:/" + game.getSlug();
        }
        if (comment == null || comment.trim().isEmpty() || comment.length() > 2000) {
            return "redirect:/" + game.getSlug();
        }

        Review existing = reviewDAO.findByUserAndGame(currentUser.getId(), gameId);
        if (existing != null) {
            existing.setRating(rating);
            existing.setComment(comment);
            existing.setCreatedAt(java.time.LocalDateTime.now());
            sessionFactory.getCurrentSession().update(existing);
        } else {
            Review newReview = new Review();
            newReview.setUser(currentUser);
            newReview.setGame(game);
            newReview.setRating(rating);
            newReview.setComment(comment);
            sessionFactory.getCurrentSession().save(newReview);
        }

        return "redirect:/" + game.getSlug();
    }

    // 5b. API Nhà phát triển/Admin Phản hồi Đánh giá
    @RequestMapping(value = "/api/reviews/reply", method = RequestMethod.POST)
    public String replyToReview(@RequestParam("reviewId") Long reviewId,
                                @RequestParam("replyText") String replyText,
                                HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        Review review = (Review) sessionFactory.getCurrentSession().get(Review.class, reviewId);
        if (review == null) {
            return "redirect:/";
        }

        // --- Server-side validation ---
        if (replyText == null || replyText.trim().isEmpty() || replyText.length() > 1000) {
            return "redirect:/" + review.getGame().getSlug();
        }

        // Kiểm tra quyền: Chỉ Admin hoặc chính Publisher sở hữu game này mới được phản hồi
        boolean isAdmin = currentUser.hasRole("ROLE_ADMIN");
        boolean isPublisher = false;
        if (review.getGame().getPublisher() != null && review.getGame().getPublisher().getUser() != null) {
            isPublisher = review.getGame().getPublisher().getUser().getId().equals(currentUser.getId());
        }

        if (isAdmin || isPublisher) {
            review.setPublisherReply(replyText);
            sessionFactory.getCurrentSession().update(review);
        }

        return "redirect:/" + review.getGame().getSlug();
    }

    // 5c. API Người dùng Bổ sung Đánh giá (sau khi được phản hồi)
    @RequestMapping(value = "/api/reviews/followup", method = RequestMethod.POST)
    public String addFollowUp(@RequestParam("reviewId") Long reviewId,
                              @RequestParam("followUpText") String followUpText,
                              HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        Review review = (Review) sessionFactory.getCurrentSession().get(Review.class, reviewId);
        if (review == null) {
            return "redirect:/";
        }

        // --- Server-side validation ---
        if (followUpText == null || followUpText.trim().isEmpty() || followUpText.length() > 1000) {
            return "redirect:/" + review.getGame().getSlug();
        }

        // Kiểm tra quyền: Chỉ chính chủ nhân của review mới được bổ sung
        if (review.getUser().getId().equals(currentUser.getId())) {
            review.setUserFollowUp(followUpText);
            sessionFactory.getCurrentSession().update(review);
        }

        return "redirect:/" + review.getGame().getSlug();
    }

    // 6. ADMIN API: LƯU HUY HIỆU TÍCH CHỌN CHO GAME
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

    // 7. ADMIN API: TẠO HUY HIỆU HOÀN TOÀN MỚI
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

        // Tạo an toàn ID bằng cách chuyển sang viết thường và bỏ khoảng cách
        String safeId = title.toLowerCase()
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

        Badge newBadge = new Badge(safeId, title, icon, color, type);
        currentBadges.add(newBadge);
        saveAvailableBadges(currentBadges);

        out.print("OK");
    }

    // LỚP ĐỐI TƯỢNG HUY HIỆU
    public static class Badge {
        private String id;
        private String title;
        private String icon;
        private String color;
        private String type; // "static" hoặc "dynamic_downloads"

        public Badge() {}

        public Badge(String id, String title, String icon, String color, String type) {
            this.id = id;
            this.title = title;
            this.icon = icon;
            this.color = color;
            this.type = type;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public String getIcon() { return icon; }
        public void setIcon(String icon) { this.icon = icon; }

        public String getColor() { return color; }
        public void setColor(String color) { this.color = color; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
    }
}