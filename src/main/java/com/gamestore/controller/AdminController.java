package com.gamestore.controller;

import com.gamestore.dao.UserDAO;
import com.gamestore.dto.AdminStatsDTO;
import com.gamestore.entity.PayoutRequest;
import com.gamestore.entity.User;
import com.gamestore.entity.Game;
import com.gamestore.entity.Notification;
import com.gamestore.service.AdminDashboardService;
import com.gamestore.service.KycService;
import com.gamestore.service.PayoutService;
import com.gamestore.service.SystemSettingService;
import com.gamestore.service.UserContextService;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.gamestore.service.EmailService;
import com.gamestore.service.WalletService;
import com.gamestore.entity.PatchNote;
import com.gamestore.entity.LibraryItem;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import com.gamestore.controller.StoreController.Badge;
import java.io.File;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Controller
public class AdminController {

    @Autowired
    private SessionFactory sessionFactory;

    @Autowired
    private AdminDashboardService adminDashboardService;

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private KycService kycService;

    @Autowired
    private PayoutService payoutService;

    @Autowired
    private SystemSettingService systemSettingService;

    @Autowired
    private UserContextService userContextService;

    @Autowired
    private ServletContext servletContext;

    @Autowired
    private EmailService emailService;

    @Autowired
    private WalletService walletService;

    @Value("${webapp.source.path:}")
    private String webappSourcePath;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper();

    @GetMapping("/admin")
    public String adminRoot() {
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/admin/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        AdminStatsDTO stats = adminDashboardService.getStats();
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("stats", stats);
        return "admin/dashboard";
    }

    @GetMapping("/admin/users")
    public String users(Model model) {
        List<User> users = userDAO.findAllUsers();
        model.addAttribute("users", users);
        return "admin/users";
    }

    @PostMapping("/admin/users/lock")
    public String lockUser(@RequestParam("userId") Long userId, HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser != null && currentUser.getId().equals(userId)) {
            return "redirect:/admin/users?error=self-lock";
        }
        userDAO.changeStatus(userId, "LOCKED");
        return "redirect:/admin/users?success=locked";
    }

    @PostMapping("/admin/users/unlock")
    public String unlockUser(@RequestParam("userId") Long userId) {
        userDAO.changeStatus(userId, "ACTIVE");
        return "redirect:/admin/users?success=unlocked";
    }

    @GetMapping("/admin/kyc")
    public String kycRequests(Model model) {
        model.addAttribute("requests", kycService.getAllRequests());
        return "admin/kyc";
    }

    @PostMapping("/admin/kyc/approve")
    public String approveKyc(@RequestParam("requestId") Long requestId) {
        try {
            kycService.approveRequest(requestId);
            return "redirect:/admin/kyc?success=approved";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/kyc?error=" + e.getMessage();
        }
    }

    @PostMapping("/admin/kyc/reject")
    public String rejectKyc(@RequestParam("requestId") Long requestId) {
        try {
            kycService.rejectRequest(requestId);
            return "redirect:/admin/kyc?success=rejected";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/kyc?error=" + e.getMessage();
        }
    }

    @GetMapping("/admin/settings")
    public String settings(Model model) {
        BigDecimal commissionRate = systemSettingService.getPlatformCommissionRate();
        model.addAttribute("commissionRate", commissionRate);
        return "admin/settings";
    }

    @PostMapping("/admin/settings/commission")
    public String updateCommissionRate(@RequestParam("commissionRate") BigDecimal commissionRate, Model model) {
        try {
            systemSettingService.updatePlatformCommissionRate(commissionRate);
            return "redirect:/admin/settings?success=commission-updated";
        } catch (IllegalArgumentException e) {
            model.addAttribute("commissionRate", commissionRate);
            model.addAttribute("error", e.getMessage());
            return "admin/settings";
        }
    }

    @GetMapping("/admin/payouts")
    public String payoutRequests(Model model) {
        List<PayoutRequest> requests = payoutService.getAllRequests();
        model.addAttribute("requests", requests);
        return "admin/payouts";
    }

    @PostMapping("/admin/payouts/approve")
    public String approvePayout(@RequestParam("requestId") Long requestId) {
        try {
            payoutService.approvePayout(requestId);
            return "redirect:/admin/payouts?success=approved";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/payouts?error=" + e.getMessage();
        }
    }

    @PostMapping("/admin/payouts/reject")
    public String rejectPayout(@RequestParam("requestId") Long requestId) {
        try {
            payoutService.rejectPayout(requestId);
            return "redirect:/admin/payouts?success=rejected";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/payouts?error=" + e.getMessage();
        }
    }

    @GetMapping("/admin/games")
    @Transactional
    public String games(Model model) {
        org.hibernate.Session session = sessionFactory.getCurrentSession();
        
        List<Game> pendingGames = session
                .createQuery("FROM Game g LEFT JOIN FETCH g.publisher p WHERE g.status = 'PENDING' ORDER BY g.id DESC", Game.class)
                .list();
                
        List<Game> pendingDeleteGames = session
                .createQuery("FROM Game g LEFT JOIN FETCH g.publisher p WHERE g.status = 'PENDING_DELETE' ORDER BY g.id DESC", Game.class)
                .list();
                
        List<PatchNote> pendingPatchNotes = session
                .createQuery("FROM PatchNote pn JOIN FETCH pn.game g LEFT JOIN FETCH g.publisher p WHERE pn.status = 'PENDING' ORDER BY pn.publishedAt DESC", PatchNote.class)
                .list();
                
        List<Game> allGames = session
                .createQuery("FROM Game g LEFT JOIN FETCH g.publisher p ORDER BY g.id DESC", Game.class)
                .list();

        List<com.gamestore.entity.WalletTransaction> walletTransactions = session
                .createQuery("FROM WalletTransaction wt JOIN FETCH wt.wallet w JOIN FETCH w.user u ORDER BY wt.id DESC", com.gamestore.entity.WalletTransaction.class)
                .list();

        List<Object[]> salesData = session
                .createQuery("SELECT li.game.id, COUNT(li) FROM LibraryItem li WHERE li.status != 'REFUNDED' GROUP BY li.game.id", Object[].class)
                .list();
        java.util.Map<Long, Long> salesCountMap = new java.util.HashMap<>();
        for (Object[] row : salesData) {
            Long gameId = (Long) row[0];
            Long count = (Long) row[1];
            salesCountMap.put(gameId, count);
        }

        model.addAttribute("pendingGames", pendingGames);
        model.addAttribute("pendingDeleteGames", pendingDeleteGames);
        model.addAttribute("pendingPatchNotes", pendingPatchNotes);
        model.addAttribute("allGames", allGames);
        model.addAttribute("walletTransactions", walletTransactions);
        model.addAttribute("salesCountMap", salesCountMap);
        
        return "admin/games";
    }

    private void organizeGameMediaFiles(Game game, ServletContext context) {
        List<com.gamestore.entity.GameMedia> mediaList = game.getMediaList();
        if (mediaList == null || mediaList.isEmpty()) {
            return;
        }

        String targetDirRel = "/assets/images/games/" + game.getSlug();
        String targetDirPath = context.getRealPath(targetDirRel);
        File targetDir = new File(targetDirPath);
        if (!targetDir.exists()) {
            targetDir.mkdirs();
        }

        // Thư mục source code thực tế (lưu vĩnh viễn)
        File sourceCodeDir = null;
        if (webappSourcePath != null && !webappSourcePath.trim().isEmpty()) {
            sourceCodeDir = new File(webappSourcePath, "assets/images/games/" + game.getSlug());
            if (!sourceCodeDir.exists()) {
                sourceCodeDir.mkdirs();
            }
        }

        int screenshotCounter = 1;
        List<com.gamestore.entity.GameMedia> mediaCopy = new ArrayList<>(mediaList);
        
        for (com.gamestore.entity.GameMedia media : mediaCopy) {
            if ("IMAGE".equalsIgnoreCase(media.getMediaType())) {
                String originalUrl = media.getMediaUrl();
                if (originalUrl == null || originalUrl.trim().isEmpty()) {
                    game.getMediaList().remove(media);
                    sessionFactory.getCurrentSession().delete(media);
                    continue;
                }
                
                // Tìm file nguồn: thử thư mục deploy trước, nếu không có thử thư mục source code
                String sourcePath = context.getRealPath(originalUrl);
                File sourceFile = (sourcePath != null) ? new File(sourcePath) : null;
                
                if ((sourceFile == null || !sourceFile.exists()) && sourceCodeDir != null) {
                    // Thử tìm trong thư mục source code
                    File altSource = new File(webappSourcePath, originalUrl);
                    if (altSource.exists()) {
                        sourceFile = altSource;
                    }
                }
                
                if (sourceFile == null || !sourceFile.exists()) {
                    game.getMediaList().remove(media);
                    sessionFactory.getCurrentSession().delete(media);
                    continue;
                }
                
                String ext = "jpg";
                String fileName = sourceFile.getName();
                int dotIdx = fileName.lastIndexOf('.');
                if (dotIdx > 0 && dotIdx < fileName.length() - 1) {
                    ext = fileName.substring(dotIdx + 1).toLowerCase();
                }
                
                String newFileName;
                if (media.isPrimary()) {
                    newFileName = "thumb." + ext;
                } else {
                    newFileName = screenshotCounter + "." + ext;
                    screenshotCounter++;
                }
                
                File destFile = new File(targetDir, newFileName);
                String newUrl = targetDirRel + "/" + newFileName;
                
                if (!sourceFile.getAbsolutePath().equalsIgnoreCase(destFile.getAbsolutePath())) {
                    try {
                        // Copy vào thư mục deploy Tomcat
                        java.nio.file.Files.copy(sourceFile.toPath(), destFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                    } catch (Exception e) {
                        System.err.println("Lỗi copy file tới deploy dir: " + e.getMessage());
                    }
                }
                
                // Copy vào thư mục source code (lưu vĩnh viễn)
                if (sourceCodeDir != null) {
                    try {
                        File destSourceFile = new File(sourceCodeDir, newFileName);
                        java.nio.file.Files.copy(sourceFile.toPath(), destSourceFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                        System.out.println("[GameMedia] Đã lưu vĩnh viễn: " + destSourceFile.getAbsolutePath());
                    } catch (Exception e) {
                        System.err.println("Lỗi copy file tới source dir: " + e.getMessage());
                    }
                }
                
                media.setMediaUrl(newUrl);
                sessionFactory.getCurrentSession().update(media);
            }
        }
        sessionFactory.getCurrentSession().flush();
    }

    @PostMapping("/admin/games/approve")
    @Transactional
    public String approveGame(@RequestParam("gameId") Long gameId, HttpSession session) {
        org.hibernate.Session hqSession = sessionFactory.getCurrentSession();
        Game game = hqSession.get(Game.class, gameId);
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
                hqSession.update(game);

                // Tìm tất cả các LibraryItem của game này mà chưa bị REFUNDED để hoàn tiền
                List<LibraryItem> items = hqSession.createQuery(
                        "FROM LibraryItem li JOIN FETCH li.user u LEFT JOIN FETCH li.orderItem oi WHERE li.game.id = :gameId AND li.status != 'REFUNDED'", 
                        LibraryItem.class)
                        .setParameter("gameId", gameId)
                        .list();

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
                    hqSession.update(item);

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
                    hqSession.save(notif);
                }

                // Notify Publisher User
                if (game.getPublisher() != null && game.getPublisher().getUser() != null) {
                    Notification notif = new Notification();
                    notif.setTitle("Yêu cầu xóa game đã được duyệt");
                    notif.setContent("Yêu cầu xóa tựa game '" + game.getTitle() + "' của bạn đã được Admin phê duyệt. Hệ thống đã tiến hành hoàn tiền cho người mua.");
                    notif.setType("GAME_APPROVAL");
                    notif.setTargetUrl("/publisher/games");
                    notif.setUser(game.getPublisher().getUser());
                    hqSession.save(notif);
                }
                return "redirect:/admin/games?success=deleted-approved";
            } else {
                // Duyệt đăng game mới
                game.setStatus("ACTIVE");
                game.setApprovedAt(java.time.LocalDateTime.now());
                game.setApprovedBy(approvedBy);

                // Tổ chức lại các file ảnh vật lý
                organizeGameMediaFiles(game, servletContext);

                hqSession.update(game);

                // Tự động tạo 100 license key cho game vừa được duyệt
                for (int i = 0; i < 100; i++) {
                    com.gamestore.entity.LicenseKey key = new com.gamestore.entity.LicenseKey();
                    key.setGame(game);
                    String uuid = java.util.UUID.randomUUID().toString().toUpperCase().replace("-", "");
                    String keyString = uuid.substring(0, 5) + "-" + uuid.substring(5, 10) + "-" + uuid.substring(10, 15);
                    key.setKeyString(keyString);
                    key.setStatus("AVAILABLE");
                    key.setCreatedAt(java.time.LocalDateTime.now());
                    hqSession.save(key);
                }

                // Notify Publisher User
                if (game.getPublisher() != null && game.getPublisher().getUser() != null) {
                    Notification notif = new Notification();
                    notif.setTitle("Game được phê duyệt");
                    notif.setContent("Tựa game '" + game.getTitle() + "' của bạn đã được phê duyệt và hiển thị trên cửa hàng.");
                    notif.setType("GAME_APPROVAL");
                    notif.setTargetUrl("/" + game.getSlug());
                    notif.setUser(game.getPublisher().getUser());
                    hqSession.save(notif);
                }
                return "redirect:/admin/games?success=approved";
            }
        }
        return "redirect:/admin/games?error=not-found";
    }

    @PostMapping("/admin/games/reject")
    @Transactional
    public String rejectGame(@RequestParam("gameId") Long gameId) {
        org.hibernate.Session session = sessionFactory.getCurrentSession();
        Game game = session.get(Game.class, gameId);
        if (game != null) {
            if ("PENDING_DELETE".equals(game.getStatus())) {
                // Từ chối xóa game, khôi phục lại trạng thái ACTIVE
                game.setStatus("ACTIVE");
                session.update(game);

                // Notify Publisher User
                if (game.getPublisher() != null && game.getPublisher().getUser() != null) {
                    Notification notif = new Notification();
                    notif.setTitle("Yêu cầu xóa game bị từ chối");
                    notif.setContent("Yêu cầu xóa tựa game '" + game.getTitle() + "' của bạn đã bị từ chối. Game vẫn tiếp tục được bán trên cửa hàng.");
                    notif.setType("GAME_APPROVAL");
                    notif.setTargetUrl("/publisher/games");
                    notif.setUser(game.getPublisher().getUser());
                    session.save(notif);
                }
                return "redirect:/admin/games?success=delete-rejected";
            } else {
                // Từ chối đăng game mới
                game.setStatus("REJECTED");
                session.update(game);

                // Notify Publisher User
                if (game.getPublisher() != null && game.getPublisher().getUser() != null) {
                    Notification notif = new Notification();
                    notif.setTitle("Game bị từ chối");
                    notif.setContent("Tựa game '" + game.getTitle() + "' đã bị từ chối phê duyệt. Vui lòng cập nhật lại thông tin.");
                    notif.setType("GAME_APPROVAL");
                    notif.setTargetUrl("/publisher/games");
                    notif.setUser(game.getPublisher().getUser());
                    session.save(notif);
                }
                return "redirect:/admin/games?success=rejected";
            }
        }
        return "redirect:/admin/games?error=not-found";
    }

    @PostMapping("/admin/patchnotes/approve")
    @Transactional
    public String approvePatchNote(@RequestParam("patchNoteId") Long patchNoteId) {
        org.hibernate.Session session = sessionFactory.getCurrentSession();
        PatchNote note = session.get(PatchNote.class, patchNoteId);
        if (note != null) {
            note.setStatus("ACTIVE");
            session.update(note);

            // Tự động từ chối (REJECTED) tất cả các patch note PENDING khác cũ hơn (ID nhỏ hơn) của cùng game này
            if (note.getGame() != null) {
                session.createQuery("UPDATE PatchNote pn SET pn.status = 'REJECTED' WHERE pn.game.id = :gameId AND pn.status = 'PENDING' AND pn.id < :noteId")
                        .setParameter("gameId", note.getGame().getId())
                        .setParameter("noteId", note.getId())
                        .executeUpdate();
            }
            
            // Notify Publisher
            if (note.getGame() != null && note.getGame().getPublisher() != null && note.getGame().getPublisher().getUser() != null) {
                Notification notif = new Notification();
                notif.setTitle("Patch note được duyệt");
                notif.setContent("Ghi chú cập nhật bản vá phiên bản " + note.getVersion() + " của game '" + note.getGame().getTitle() + "' đã được phê duyệt.");
                notif.setType("PATCH_NOTE_APPROVAL");
                notif.setTargetUrl("/publisher/games/patch-notes/" + note.getGame().getId());
                notif.setUser(note.getGame().getPublisher().getUser());
                session.save(notif);
            }
        }
        return "redirect:/admin/games?success=pn-approved";
    }

    @PostMapping("/admin/patchnotes/reject")
    @Transactional
    public String rejectPatchNote(@RequestParam("patchNoteId") Long patchNoteId) {
        org.hibernate.Session session = sessionFactory.getCurrentSession();
        PatchNote note = session.get(PatchNote.class, patchNoteId);
        if (note != null) {
            note.setStatus("REJECTED");
            session.update(note);
            
            // Notify Publisher
            if (note.getGame() != null && note.getGame().getPublisher() != null && note.getGame().getPublisher().getUser() != null) {
                Notification notif = new Notification();
                notif.setTitle("Patch note bị từ chối");
                notif.setContent("Ghi chú cập nhật bản vá phiên bản " + note.getVersion() + " của game '" + note.getGame().getTitle() + "' đã bị từ chối phê duyệt.");
                notif.setType("PATCH_NOTE_APPROVAL");
                notif.setTargetUrl("/publisher/games/patch-notes/" + note.getGame().getId());
                notif.setUser(note.getGame().getPublisher().getUser());
                session.save(notif);
            }
        }
        return "redirect:/admin/games?success=pn-rejected";
    }

    private String getBadgeFilePath() {
        if (servletContext != null) {
            String path = servletContext.getRealPath("/WEB-INF/classes/badges_config.json");
            if (path != null) return path;
        }
        return System.getProperty("user.home") + File.separator + "gamestore_badges.json";
    }

    private List<Badge> loadAvailableBadges() {
        try {
            File file = new File(getBadgeFilePath());
            if (file.exists()) {
                return objectMapper.readValue(file, new com.fasterxml.jackson.core.type.TypeReference<List<Badge>>() {});
            }
        } catch (Exception e) {
            System.err.println(">>> Error loading badges JSON in AdminController: " + e.getMessage());
        }
        return new ArrayList<>();
    }

    @GetMapping("/admin/badges")
    @Transactional
    public String badges(Model model) {
        org.hibernate.Session session = sessionFactory.getCurrentSession();
        List<Game> games = session
                .createQuery("FROM Game g WHERE g.status != 'DELETED' ORDER BY g.id DESC", Game.class)
                .list();
        List<Badge> allBadges = loadAvailableBadges();
        model.addAttribute("games", games);
        model.addAttribute("allBadges", allBadges);
        return "admin/badges";
    }

    // ADMIN NOTIFICATIONS VIEW
    @GetMapping("/admin/notifications")
    @Transactional
    public String viewNotifications(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        List<Notification> list = sessionFactory.getCurrentSession()
                .createQuery("FROM Notification n WHERE n.user IS NULL ORDER BY n.createdAt DESC", Notification.class)
                .list();
        model.addAttribute("notifications", list);
        model.addAttribute("currentUser", currentUser);
        return "admin/notifications";
    }

    @PostMapping("/admin/notifications/mark-read")
    @Transactional
    public String markNotificationsAsRead(HttpSession session) {
        sessionFactory.getCurrentSession()
                .createQuery("UPDATE Notification n SET n.read = true WHERE n.user IS NULL")
                .executeUpdate();
        return "redirect:/admin/notifications";
    }
}
