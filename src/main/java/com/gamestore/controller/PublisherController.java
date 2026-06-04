package com.gamestore.controller;

import com.gamestore.dao.GameDAO;
import com.gamestore.dao.CategoryDAO;
import com.gamestore.dao.PatchNoteDAO;
import com.gamestore.dao.PublisherProfileDAO;
import com.gamestore.entity.*;
import com.gamestore.service.PayoutService;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.gamestore.dao.KycRequestDAO;
import com.gamestore.dao.PublisherProfileDAO;
import com.gamestore.dao.NotificationDAO;
import com.gamestore.entity.KycRequest;
import com.gamestore.entity.PublisherProfile;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@Controller
@Transactional
public class PublisherController {

    private static final int PAGE_SIZE = 10;
    private static final BigDecimal MIN_PAYOUT_AMOUNT = new BigDecimal("10000");

    @Autowired
    private PayoutService payoutService;

    @Autowired
    private WalletService walletService;

    @Autowired
    private UserContextService userContextService;
    @Autowired
    private KycRequestDAO kycRequestDAO;

    @Autowired
    private PublisherProfileDAO publisherProfileDAO;
    @GetMapping("/publisher")
    public String publisherHome() {
        return "redirect:/publisher/dashboard";
    }

    @Autowired
    private GameDAO gameDAO;

    @Autowired
    private CategoryDAO categoryDAO;

    @Autowired
    private PatchNoteDAO patchNoteDAO;

    @Autowired
    private NotificationDAO notificationDAO;

    @Autowired
    private SessionFactory sessionFactory;

    @Value("${webapp.source.path:}")
    private String webappSourcePath;

    @GetMapping("/publisher/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        model.addAttribute("currentUser", currentUser);

        return "publisher/dashboard";
    }
    @GetMapping("/publisher/kyc")
    @Transactional(readOnly = true)
    public String publisherKyc(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        KycRequest latestKyc = kycRequestDAO.findLatestByUserId(currentUser.getId());
        PublisherProfile publisherProfile = publisherProfileDAO.findByUserId(currentUser.getId());

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("latestKyc", latestKyc);
        model.addAttribute("publisherProfile", publisherProfile);

        return "publisher/kyc";
    }
    @GetMapping("/publisher/payouts")
    public String payouts(@RequestParam(value = "page", required = false, defaultValue = "1") Integer page,
                          HttpSession session,
                          Model model) {

        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        loadPayoutPageData(currentUser, page, model);

        return "publisher/payouts";
    }

    /*
     * Hỗ trợ cả 2 URL:
     * - /publisher/payouts/request: URL đúng nên dùng trong form
     * - /publisher/payouts: giữ lại để tránh lỗi "POST not supported" nếu JSP/JS cũ vẫn gọi URL này
     */
    @PostMapping({"/publisher/payouts/request", "/publisher/payouts"})
    public String createPayoutRequest(@RequestParam(value = "amount", required = false) BigDecimal amount,
                                      @RequestParam(value = "bankAccountInfo", required = false) String bankAccountInfo,
                                      HttpSession session) {

        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        try {
            if (amount == null) {
                throw new IllegalArgumentException("Vui lòng nhập số tiền muốn rút.");
            }

            if (amount.compareTo(MIN_PAYOUT_AMOUNT) < 0) {
                throw new IllegalArgumentException("Số tiền rút tối thiểu là 10.000đ.");
            }

            if (bankAccountInfo == null || bankAccountInfo.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập thông tin tài khoản ngân hàng.");
            }

            payoutService.createPayoutRequest(currentUser, amount, bankAccountInfo.trim());

            session.setAttribute("payoutSuccess", "Gửi yêu cầu rút tiền thành công. Vui lòng chờ Admin duyệt.");

            return "redirect:/publisher/payouts";

        } catch (IllegalArgumentException e) {
            session.setAttribute("payoutError", e.getMessage());
            return "redirect:/publisher/payouts";
        } catch (Exception e) {
            session.setAttribute("payoutError", "Có lỗi xảy ra khi gửi yêu cầu rút tiền: " + e.getMessage());
            return "redirect:/publisher/payouts";
        }
    }

    private void loadPayoutPageData(User currentUser, Integer page, Model model) {
        Wallet wallet = walletService.getOrCreateWallet(currentUser);
        List<PayoutRequest> requests = payoutService.getRequestsByPublisherUser(currentUser.getId());

        if (requests == null) {
            requests = new ArrayList<>();
        }

        BigDecimal walletBalance = BigDecimal.ZERO;

        if (wallet != null && wallet.getBalance() != null) {
            walletBalance = wallet.getBalance();
        }

        BigDecimal pendingAmount = calculatePendingAmount(requests);
        BigDecimal availableAmount = walletBalance.subtract(pendingAmount);

        if (availableAmount.compareTo(BigDecimal.ZERO) < 0) {
            availableAmount = BigDecimal.ZERO;
        }

        Map<String, Object> pageResult = buildPageResult(requests, page, PAGE_SIZE);

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("wallet", wallet);
        model.addAttribute("requests", requests);
        model.addAttribute("pendingAmount", pendingAmount);
        model.addAttribute("availableAmount", availableAmount);
        model.addAttribute("pageResult", pageResult);
    }

    // ==========================================
    // GAME CRUD & MEDIA UPLOADS
    // ==========================================

    @GetMapping("/publisher/games")
    public String viewPublisherGames(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) {
            // Chưa có KYC / Publisher Profile, chuyển hướng kêu đi nạp KYC
            return "redirect:/kyc?error=need-kyc";
        }

        List<Game> games = gameDAO.findByPublisherId(profile.getId());

        model.addAttribute("games", games);
        model.addAttribute("currentUser", currentUser);
        return "publisher/games";
    }

    @GetMapping("/publisher/games/add")
    public String showAddGameForm(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

        Game game = new Game();
        String defaultDev = profile.getCompanyName();
        if (defaultDev == null || defaultDev.trim().isEmpty()) {
            defaultDev = currentUser.getFullName();
        }
        if (defaultDev == null || defaultDev.trim().isEmpty()) {
            defaultDev = currentUser.getUsername();
        }
        game.setDeveloper(defaultDev);

        model.addAttribute("game", game);
        model.addAttribute("categories", categoryDAO.findAll());
        model.addAttribute("actionUrl", "/publisher/games/add");
        model.addAttribute("isEdit", false);
        return "publisher/game-form";
    }

    @PostMapping("/publisher/games/add")
    public String addGame(@ModelAttribute("game") Game game,
                          org.springframework.validation.BindingResult bindingResult,
                          @RequestParam(value = "categoryIds", required = false) List<Long> categoryIds,
                          @RequestParam("coverImageFile") MultipartFile coverImageFile,
                          @RequestParam(value = "screenshotFiles", required = false) MultipartFile[] screenshotFiles,
                          @RequestParam(value = "trailerUrl", required = false) String trailerUrl,
                          HttpSession session,
                          Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

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

            // Validate ngày phát hành
            if (game.getReleaseDate() == null || game.getReleaseDate().getYear() < 1970 || game.getReleaseDate().getYear() > 2100) {
                model.addAttribute("error", "Ngày phát hành không hợp lệ! Năm phải từ 1970 đến 2100.");
                model.addAttribute("categories", categoryDAO.findAll());
                model.addAttribute("actionUrl", "/publisher/games/add");
                model.addAttribute("isEdit", false);
                return "publisher/game-form";
            }

            game.setPublisher(profile);
            game.setStatus("PENDING"); // Đăng xong chờ duyệt
            game.setCreatedAt(java.time.LocalDateTime.now());
            game.setOriginalPrice(game.getPrice());

            // Set categories
            Set<Category> cats = new HashSet<>();
            if (categoryIds != null) {
                for (Long cid : categoryIds) {
                    Category cat = categoryDAO.findById(cid);
                    if (cat != null) cats.add(cat);
                }
            }
            game.setCategories(cats);

            // Upload files
            List<GameMedia> mediaList = new ArrayList<>();

            // 1. Cover Image (Primary)
            String coverUrl = saveGameMediaFile(coverImageFile, game.getSlug(), session);
            if (coverUrl != null) {
                GameMedia cover = new GameMedia();
                cover.setGame(game);
                cover.setMediaType("IMAGE");
                cover.setMediaUrl(coverUrl);
                cover.setPrimary(true);
                mediaList.add(cover);
            } else {
                throw new IllegalArgumentException("Ảnh đại diện game là bắt buộc khi đăng game mới!");
            }

            // 2. Screenshots
            if (screenshotFiles != null) {
                for (MultipartFile file : screenshotFiles) {
                    String screenshotUrl = saveGameMediaFile(file, game.getSlug(), session);
                    if (screenshotUrl != null) {
                        GameMedia screen = new GameMedia();
                        screen.setGame(game);
                        screen.setMediaType("IMAGE");
                        screen.setMediaUrl(screenshotUrl);
                        screen.setPrimary(false);
                        mediaList.add(screen);
                    }
                }
            }

            // 3. Trailer (Link nhúng)
            if (trailerUrl != null && !trailerUrl.trim().isEmpty()) {
                GameMedia trailer = new GameMedia();
                trailer.setGame(game);
                trailer.setMediaType("VIDEO");
                trailer.setMediaUrl(trailerUrl.trim());
                trailer.setPrimary(false);
                mediaList.add(trailer);
            }

            game.setMediaList(mediaList);
            gameDAO.save(game);

            // Notify Admins
            Notification notif = new Notification();
            notif.setTitle("Yêu cầu duyệt game mới");
            notif.setContent("Nhà phát hành '" + profile.getCompanyName() + "' đã đăng game mới '" + game.getTitle() + "' và đang chờ duyệt.");
            notif.setType("GAME_APPROVAL");
            notif.setTargetUrl("/admin/games");
            notif.setUser(null); // Admin wide
            notificationDAO.save(notif);

            return "redirect:/publisher/games?success=added";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi lưu game: " + e.getMessage());
            model.addAttribute("categories", categoryDAO.findAll());
            model.addAttribute("actionUrl", "/publisher/games/add");
            model.addAttribute("isEdit", false);
            return "publisher/game-form";
        }
    }

    @GetMapping("/publisher/games/edit/{id}")
    public String showEditGameForm(@PathVariable("id") Long id, HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

        Game game = gameDAO.findById(id);
        if (game == null || !game.getPublisher().getId().equals(profile.getId())) {
            return "redirect:/publisher/games?error=not-authorized";
        }

        model.addAttribute("game", game);
        model.addAttribute("categories", categoryDAO.findAll());
        model.addAttribute("actionUrl", "/publisher/games/edit/" + id);
        model.addAttribute("isEdit", true);
        return "publisher/game-form";
    }

    @PostMapping("/publisher/games/edit/{id}")
    public String editGame(@PathVariable("id") Long id,
                           @ModelAttribute("game") Game gameData,
                           org.springframework.validation.BindingResult bindingResult,
                           @RequestParam(value = "categoryIds", required = false) List<Long> categoryIds,
                           @RequestParam(value = "coverImageFile", required = false) MultipartFile coverImageFile,
                           @RequestParam(value = "screenshotFiles", required = false) MultipartFile[] screenshotFiles,
                           @RequestParam(value = "trailerUrl", required = false) String trailerUrl,
                           HttpSession session,
                           Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

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

        try {
            // Update fields
            game.setTitle(gameData.getTitle());
            game.setSlug(toSlug(gameData.getSlug().trim().isEmpty() ? gameData.getTitle() : gameData.getSlug()));
            game.setDescription(gameData.getDescription());
            game.setPrice(gameData.getPrice());
            game.setOriginalPrice(gameData.getPrice());
            game.setDeveloper(gameData.getDeveloper());
            game.setReleaseDate(gameData.getReleaseDate());
            game.setMinimumRequirements(gameData.getMinimumRequirements());
            game.setRecommendedRequirements(gameData.getRecommendedRequirements());

            // Set categories
            Set<Category> cats = new HashSet<>();
            if (categoryIds != null) {
                for (Long cid : categoryIds) {
                    Category cat = categoryDAO.findById(cid);
                    if (cat != null) cats.add(cat);
                }
            }
            game.setCategories(cats);

            // Cover Image update (if uploaded)
            String coverUrl = saveGameMediaFile(coverImageFile, game.getSlug(), session);
            if (coverUrl != null) {
                // Delete previous primary cover if exists
                List<GameMedia> existingMedia = game.getMediaList();
                if (existingMedia != null) {
                    existingMedia.removeIf(m -> m.isPrimary());
                } else {
                    existingMedia = new ArrayList<>();
                    game.setMediaList(existingMedia);
                }
                GameMedia cover = new GameMedia();
                cover.setGame(game);
                cover.setMediaType("IMAGE");
                cover.setMediaUrl(coverUrl);
                cover.setPrimary(true);
                existingMedia.add(cover);
            }

            // Screenshots append (if uploaded)
            if (screenshotFiles != null) {
                for (MultipartFile file : screenshotFiles) {
                    String screenshotUrl = saveGameMediaFile(file, game.getSlug(), session);
                    if (screenshotUrl != null) {
                        GameMedia screen = new GameMedia();
                        screen.setGame(game);
                        screen.setMediaType("IMAGE");
                        screen.setMediaUrl(screenshotUrl);
                        screen.setPrimary(false);
                        game.getMediaList().add(screen);
                    }
                }
            }

            // Trailer update (if provided)
            if (trailerUrl != null && !trailerUrl.trim().isEmpty()) {
                // Remove old video trailer
                game.getMediaList().removeIf(m -> "VIDEO".equals(m.getMediaType()));
                
                GameMedia trailer = new GameMedia();
                trailer.setGame(game);
                trailer.setMediaType("VIDEO");
                trailer.setMediaUrl(trailerUrl.trim());
                trailer.setPrimary(false);
                game.getMediaList().add(trailer);
            } else if (trailerUrl != null && trailerUrl.trim().isEmpty()) {
                game.getMediaList().removeIf(m -> "VIDEO".equals(m.getMediaType()));
            }

            game.setStatus("PENDING");
            gameDAO.update(game);

            // Gửi thông báo cho Admin
            Notification notif = new Notification();
            notif.setTitle("Yêu cầu duyệt game chỉnh sửa");
            notif.setContent("Nhà phát hành '" + profile.getCompanyName() + "' đã cập nhật thông tin game '" + game.getTitle() + "' và đang chờ duyệt lại.");
            notif.setType("GAME_APPROVAL");
            notif.setTargetUrl("/admin/games");
            notif.setUser(null);
            notificationDAO.save(notif);

            return "redirect:/publisher/games?success=edited";
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi cập nhật game: " + e.getMessage());
            model.addAttribute("categories", categoryDAO.findAll());
            model.addAttribute("actionUrl", "/publisher/games/edit/" + id);
            model.addAttribute("isEdit", true);
            return "publisher/game-form";
        }
    }

    @PostMapping("/publisher/games/delete/{id}")
    public String deleteGame(@PathVariable("id") Long id, HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

        Game game = gameDAO.findById(id);
        if (game == null || !game.getPublisher().getId().equals(profile.getId())) {
            return "redirect:/publisher/games?error=not-authorized";
        }

        // Đổi sang PENDING_DELETE bằng HQL UPDATE trực tiếp để tránh các lỗi Hibernate validate/cascade
        gameDAO.updateStatus(id, "PENDING_DELETE");

        // Gửi thông báo cho Admin
        Notification notif = new Notification();
        notif.setTitle("Yêu cầu xóa game");
        notif.setContent("Nhà phát hành '" + profile.getCompanyName() + "' đã yêu cầu xóa game '" + game.getTitle() + "' và đang chờ duyệt hoàn tiền/xóa.");
        notif.setType("GAME_APPROVAL");
        notif.setTargetUrl("/admin/games");
        notif.setUser(null);
        notificationDAO.save(notif);

        return "redirect:/publisher/games?success=delete-requested";
    }

    // ==========================================
    // PATCH NOTES
    // ==========================================

    @GetMapping("/publisher/games/patch-notes/{id}")
    public String viewPatchNotes(@PathVariable("id") Long id, HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

        Game game = gameDAO.findById(id);
        if (game == null || !game.getPublisher().getId().equals(profile.getId())) {
            return "redirect:/publisher/games?error=not-authorized";
        }

        List<PatchNote> patchNotes = patchNoteDAO.findByGameId(id);
        model.addAttribute("game", game);
        model.addAttribute("patchNotes", patchNotes);
        return "publisher/patch-notes";
    }

    @PostMapping("/publisher/games/patch-notes/{id}/add")
    public String addPatchNote(@PathVariable("id") Long id,
                               @RequestParam("version") String version,
                               @RequestParam("content") String content,
                               HttpSession session,
                               Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        PublisherProfile profile = publisherProfileDAO.findByUserId(currentUser.getId());
        if (profile == null) return "redirect:/kyc?error=need-kyc";

        Game game = gameDAO.findById(id);
        if (game == null || !game.getPublisher().getId().equals(profile.getId())) {
            return "redirect:/publisher/games?error=not-authorized";
        }

        if (version == null || version.trim().isEmpty() || content == null || content.trim().isEmpty()) {
            return "redirect:/publisher/games/patch-notes/" + id + "?error=empty-fields";
        }

        PatchNote note = new PatchNote();
        note.setGame(game);
        note.setVersion(version);
        note.setContent(content);
        note.setPublishedAt(java.time.LocalDateTime.now());
        note.setStatus("PENDING");

        patchNoteDAO.save(note);

        // Gửi thông báo cho Admin
        Notification notif = new Notification();
        notif.setTitle("Yêu cầu duyệt patch note mới");
        notif.setContent("Nhà phát hành '" + profile.getCompanyName() + "' đã đăng patch note mới cho game '" + game.getTitle() + "' và đang chờ duyệt.");
        notif.setType("PATCH_NOTE_APPROVAL");
        notif.setTargetUrl("/admin/games");
        notif.setUser(null);
        notificationDAO.save(notif);

        return "redirect:/publisher/games/patch-notes/" + id + "?success=added";
    }

    // ==========================================
    // HELPERS
    // ==========================================

    private String saveUploadedFile(MultipartFile file, String subDir, HttpSession session) throws Exception {
        if (file == null || file.isEmpty()) return null;

        String uploadDirPath = session.getServletContext().getRealPath("/uploads/" + subDir);
        File uploadDir = new File(uploadDirPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String originalName = file.getOriginalFilename();
        String extension = "";
        if (originalName != null && originalName.contains(".")) {
            extension = originalName.substring(originalName.lastIndexOf("."));
        }
        String fileName = subDir + "_" + UUID.randomUUID().toString() + extension;
        File destination = new File(uploadDir, fileName);
        file.transferTo(destination);
        return "/uploads/" + subDir + "/" + fileName;
    }

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

    @GetMapping("/publisher/notifications")
    public String viewNotifications(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        List<Notification> list = notificationDAO.findByUser(currentUser.getId());
        model.addAttribute("notifications", list);
        model.addAttribute("currentUser", currentUser);
        return "publisher/notifications";
    }

    @PostMapping("/publisher/notifications/mark-read")
    public String markNotificationsAsRead(HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) return "redirect:/login";

        notificationDAO.markAllAsRead(currentUser.getId());
        return "redirect:/publisher/notifications";
    }

    private BigDecimal calculatePendingAmount(List<PayoutRequest> requests) {
        BigDecimal total = BigDecimal.ZERO;

        if (requests == null) {
            return total;
        }

        for (PayoutRequest request : requests) {
            if (request == null) {
                continue;
            }

            String status = request.getStatus();

            if (status != null && "PENDING".equalsIgnoreCase(status.trim())) {
                BigDecimal amount = request.getAmount();

                if (amount != null) {
                    total = total.add(amount);
                }
            }
        }

        return total;
    }

    private Map<String, Object> buildPageResult(List<PayoutRequest> requests, Integer page, int pageSize) {
        Map<String, Object> pageResult = new HashMap<>();

        if (requests == null) {
            requests = new ArrayList<>();
        }

        if (page == null || page < 1) {
            page = 1;
        }

        int totalElements = requests.size();
        int totalPages = (int) Math.ceil((double) totalElements / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (page > totalPages) {
            page = totalPages;
        }

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalElements);

        List<PayoutRequest> content = new ArrayList<>();

        if (fromIndex < toIndex) {
            content = requests.subList(fromIndex, toIndex);
        }

        pageResult.put("content", content);
        pageResult.put("totalElements", totalElements);
        pageResult.put("totalPages", totalPages);
        pageResult.put("currentPage", page);

        return pageResult;
    }
}
