package com.gamestore.controller;

import com.gamestore.dao.RoleDAO;
import com.gamestore.dao.UserDAO;
import com.gamestore.dto.PendingRegisterDTO;
import com.gamestore.entity.Role;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
import com.gamestore.service.EmailService;
import com.gamestore.util.PasswordEncoderUtil;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Random;

@Controller
public class AuthController {

    public static final String[] PRESET_AVATARS = {
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Aiden",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Buster",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Coco",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Duke",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Ella",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Felix",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Ginger",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Harley",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Izzy",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Jax",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Kiki",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Loki",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Milo",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Nala",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Oscar",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Penny",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Rusty",
        "https://api.dicebear.com/7.x/pixel-art/svg?seed=Shadow"
    };

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private RoleDAO roleDAO;

    @Autowired
    private EmailService emailService;

    @Autowired
    private SessionFactory sessionFactory;

    // 1. HIỂN THỊ GIAO DIỆN
    @GetMapping("/login")
    public String showLoginPage(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null) {
            if (currentUser.hasRole("ROLE_ADMIN")) return "redirect:/admin/dashboard";
            if (currentUser.hasRole("ROLE_PUBLISHER")) return "redirect:/publisher/dashboard";
            return "redirect:/";
        }
        return "login";
    }

    @GetMapping("/register")
    public String showRegisterPage(HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null) return "redirect:/";
        return "login";
    }

    // 2. XỬ LÝ ĐĂNG NHẬP
    @PostMapping("/login")
    @Transactional
    public String processLogin(@RequestParam("emailOrUsername") String emailOrUsername,
                               @RequestParam("password") String password,
                               HttpServletRequest request,
                               HttpSession session,
                               Model model) {

        User user = userDAO.findByEmail(emailOrUsername);
        if (user == null) {
            user = userDAO.findByUsername(emailOrUsername);
        }

        if (user == null) {
            model.addAttribute("error", "Sai email đăng nhập hoặc mật khẩu!");
            return "login";
        }

        boolean passwordMatched = false;

        if (isBCryptHash(user.getPassword())) {
            passwordMatched = PasswordEncoderUtil.matches(password, user.getPassword());
        } else {
            passwordMatched = password.equals(user.getPassword());
            if (passwordMatched) {
                user.setPassword(PasswordEncoderUtil.encode(password));
                userDAO.update(user);
            }
        }

        if (!passwordMatched) {
            model.addAttribute("error", "Sai email đăng nhập hoặc mật khẩu!");
            return "login";
        }

        //tạo session mới sau khi đăng nhập
        session.invalidate();
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("currentUser", user);

        // Role-based redirect
        if (user.hasRole("ROLE_ADMIN")) return "redirect:/admin/dashboard";
        if (user.hasRole("ROLE_PUBLISHER")) return "redirect:/publisher/dashboard";
        return "redirect:/";
    }

    // 3. XỬ LÝ ĐĂNG KÝ — gửi OTP email → verify trước khi tạo tài khoản
    @PostMapping("/register")
    public String processRegister(@RequestParam("username") String username,
                                  @RequestParam("fullName") String fullName,
                                  @RequestParam("email") String email,
                                  @RequestParam("password") String password,
                                  @RequestParam("confirmPassword") String confirmPassword,
                                  HttpSession session,
                                  Model model) {

        // Validate
        if (username == null || username.trim().isEmpty()) {
            model.addAttribute("error", "Tên đăng nhập không được để trống!");
            return "login";
        }
        if (username.trim().length() > 50) {
            model.addAttribute("error", "Tên đăng nhập không được vượt quá 50 ký tự!");
            return "login";
        }
        if (!username.trim().matches("^[a-zA-Z0-9_.-]+$")) {
            model.addAttribute("error", "Tên đăng nhập chỉ chấp nhận chữ cái không dấu, số, gạch dưới, gạch nối và dấu chấm!");
            return "login";
        }
        if (fullName == null || fullName.trim().isEmpty()) {
            model.addAttribute("error", "Họ tên không được để trống!");
            return "login";
        }
        if (fullName.trim().length() > 100) {
            model.addAttribute("error", "Họ tên không được vượt quá 100 ký tự!");
            return "login";
        }
        if (email == null || email.trim().isEmpty()) {
            model.addAttribute("error", "Email không được để trống!");
            return "login";
        }
        if (email.trim().length() > 100) {
            model.addAttribute("error", "Email không được vượt quá 100 ký tự!");
            return "login";
        }
        if (password == null || password.length() < 6 || password.length() > 128) {
            model.addAttribute("error", "Mật khẩu phải từ 6 đến 128 ký tự!");
            return "login";
        }
        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "Mật khẩu nhập lại không khớp!");
            return "login";
        }
        if (userDAO.findByEmail(email.trim()) != null) {
            model.addAttribute("error", "Email này đã được sử dụng!");
            return "login";
        }
        if (userDAO.existsByUsername(username.trim())) {
            model.addAttribute("error", "Tên đăng nhập đã được sử dụng!");
            return "login";
        }

        try {
            String otp = generateOtp();
            String encodedPassword = PasswordEncoderUtil.encode(password);

            PendingRegisterDTO pendingRegister = new PendingRegisterDTO(
                    username.trim(),
                    fullName.trim(),
                    email.trim(),
                    encodedPassword,
                    otp,
                    LocalDateTime.now().plusMinutes(5)
            );

            session.setAttribute("pendingRegister", pendingRegister);

            emailService.sendOtpEmail(email.trim(), otp);

            model.addAttribute("email", email.trim());
            model.addAttribute("success", "Mã OTP đã được gửi đến email của bạn.");
            return "verify-otp";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "Không gửi được email OTP. Vui lòng thử lại.");
            return "login";
        }
    }

    // 4. TRANG XÁC THỰC OTP
    @GetMapping("/verify-otp")
    public String showVerifyOtpPage(HttpSession session, Model model) {
        PendingRegisterDTO pendingRegister =
                (PendingRegisterDTO) session.getAttribute("pendingRegister");
        if (pendingRegister == null) {
            return "redirect:/register";
        }
        model.addAttribute("email", pendingRegister.getEmail());
        return "verify-otp";
    }

    // 5. XỬ LÝ XÁC THỰC OTP — tạo tài khoản + wallet + gán ROLE_USER
    @PostMapping("/verify-otp")
    @Transactional
    public String processVerifyOtp(@RequestParam("otp") String otp,
                                   HttpSession session,
                                   Model model) {

        PendingRegisterDTO pendingRegister =
                (PendingRegisterDTO) session.getAttribute("pendingRegister");

        if (pendingRegister == null) {
            model.addAttribute("error", "Không tìm thấy phiên đăng ký. Vui lòng đăng ký lại.");
            return "login";
        }

        if (pendingRegister.isExpired()) {
            session.removeAttribute("pendingRegister");
            model.addAttribute("error", "Mã OTP đã hết hạn. Vui lòng đăng ký lại.");
            return "login";
        }

        if (!pendingRegister.getOtp().equals(otp)) {
            model.addAttribute("email", pendingRegister.getEmail());
            model.addAttribute("error", "Mã OTP không chính xác.");
            return "verify-otp";
        }

        // Tìm ROLE_USER
        Role userRole = roleDAO.findByCode("ROLE_USER");
        if (userRole == null) {
            model.addAttribute("error", "Database chưa có ROLE_USER.");
            return "login";
        }

        // Tạo User mới
        User newUser = new User();
        newUser.setUsername(pendingRegister.getUsername());
        newUser.setFullName(pendingRegister.getFullName());
        newUser.setEmail(pendingRegister.getEmail());
        newUser.setPassword(pendingRegister.getEncodedPassword());
        newUser.getRoles().add(userRole);
        newUser.setStatus("ACTIVE");
        newUser.setAvatar(PRESET_AVATARS[new Random().nextInt(PRESET_AVATARS.length)]);
        newUser.setCreatedAt(LocalDateTime.now());

        userDAO.save(newUser);

        // Tạo Wallet cho user mới
        Wallet wallet = new Wallet();
        wallet.setUser(newUser);
        wallet.setBalance(BigDecimal.ZERO);
        sessionFactory.getCurrentSession().save(wallet);

        session.removeAttribute("pendingRegister");

        model.addAttribute("success", "Xác thực OTP thành công! Bạn có thể đăng nhập.");
        return "login";
    }

    // 6. GỬI LẠI OTP
    @PostMapping("/resend-otp")
    @Transactional
    public String resendOtp(HttpSession session, Model model) {
        PendingRegisterDTO pendingRegister =
                (PendingRegisterDTO) session.getAttribute("pendingRegister");

        if (pendingRegister == null) {
            return "redirect:/register";
        }

        // Giới hạn 60 giây giữa 2 lần gửi
        Long lastSent = (Long) session.getAttribute("otpLastSentAt");
        if (lastSent != null && (System.currentTimeMillis() - lastSent) < 60_000) {
            long remaining = 60 - (System.currentTimeMillis() - lastSent) / 1000;
            model.addAttribute("error", "Vui lòng đợi " + remaining + "s trước khi gửi lại.");
            model.addAttribute("email", pendingRegister.getEmail());
            return "verify-otp";
        }

        String newOtp = generateOtp();
        pendingRegister.setOtp(newOtp);
        pendingRegister.setExpiredAt(LocalDateTime.now().plusMinutes(5));
        session.setAttribute("pendingRegister", pendingRegister);
        session.setAttribute("otpLastSentAt", System.currentTimeMillis());

        emailService.sendOtpEmail(pendingRegister.getEmail(), newOtp);

        model.addAttribute("email", pendingRegister.getEmail());
        model.addAttribute("success", "Mã OTP mới đã được gửi đến email của bạn.");
        return "verify-otp";
    }

    // 7. XỬ LÝ ĐĂNG XUẤT
    @GetMapping("/logout")
    public String processLogout(HttpSession session) {
        session.removeAttribute("currentUser");
        return "redirect:/";
    }

    // ===== PRIVATE HELPERS =====

    private boolean isBCryptHash(String password) {
        if (password == null) return false;
        return password.startsWith("$2a$") || password.startsWith("$2b$") || password.startsWith("$2y$");
    }

    private String generateOtp() {
        Random random = new Random();
        int number = 100000 + random.nextInt(900000);
        return String.valueOf(number);
    }
}
