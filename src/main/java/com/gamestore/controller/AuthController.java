package com.gamestore.controller;

import com.gamestore.dao.UserDAO;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
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

@Controller
@Transactional
public class AuthController {

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private SessionFactory sessionFactory;

    // 1. HIỂN THỊ GIAO DIỆN
    @GetMapping("/login")
    public String showLoginPage() {
        return "login";
    }

    @GetMapping("/register")
    public String showRegisterPage() {
        return "login";
    }

    // 2. HỨNG VÀ XỬ LÝ FORM ĐĂNG NHẬP
    @PostMapping("/login")
    public String processLogin(@RequestParam("emailOrUsername") String emailOrUsername,
                               @RequestParam("password") String password,
                               HttpSession session,
                               HttpServletRequest request,
                               Model model) {

        // Tìm user bằng email trước, nếu không thấy thì thử username
        User user = userDAO.findByEmail(emailOrUsername);
        if (user == null) {
            user = userDAO.findByUsername(emailOrUsername);
        }

        // Dùng BCrypt để verify mật khẩu
        if (user != null && PasswordEncoderUtil.matches(password, user.getPassword())) {
            // FIX BUG #6: Ngăn chặn session fixation - tạo session mới sau khi đăng nhập
            session.invalidate();
            HttpSession newSession = request.getSession(true);
            newSession.setAttribute("currentUser", user);
            return "redirect:/";
        } else {
            // ĐĂNG NHẬP THẤT BẠI: Ném lỗi về lại giao diện
            model.addAttribute("error", "Sai email đăng nhập hoặc mật khẩu!");
            return "login";
        }
    }

    // 3. HỨNG VÀ XỬ LÝ FORM ĐĂNG KÝ
    @PostMapping("/register")
    public String processRegister(@RequestParam("username") String username,
                                  @RequestParam("fullName") String fullName,
                                  @RequestParam("email") String email,
                                  @RequestParam("password") String password,
                                  @RequestParam("confirmPassword") String confirmPassword,
                                  Model model) {

        // Bước kiểm tra 1: Mật khẩu xác nhận phải khớp
        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "Mật khẩu nhập lại không khớp!");
            return "login";
        }

        // Bước kiểm tra 2: Tránh đăng ký trùng Email
        if (userDAO.findByEmail(email) != null) {
            model.addAttribute("error", "Email này đã được sử dụng!");
            return "login";
        }

        // Bước kiểm tra 3: Trùng username không được phép
        if (userDAO.existsByUsername(username.trim())) {
            model.addAttribute("error", "Tên đăng nhập đã được sử dụng!");
            return "login";
        }

        // Tạo mới tài khoản
        User newUser = new User();
        newUser.setUsername(username.trim());
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setPassword(PasswordEncoderUtil.encode(password));

        // Dùng BaseDAO để ghi xuống SQL Server
        userDAO.save(newUser);

        // Khởi tạo ví cho tài khoản mới đăng ký
        Wallet wallet = new Wallet();
        wallet.setUser(newUser);
        wallet.setBalance(BigDecimal.ZERO);
        sessionFactory.getCurrentSession().save(wallet);

        // Báo thành công
        model.addAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
        return "login";
    }

    // 4. XỬ LÝ ĐĂNG XUẤT
    @GetMapping("/logout")
    public String processLogout(HttpSession session) {
        // Xóa thông tin user khỏi phiên làm việc hiện tại
        session.removeAttribute("currentUser");
        // Đẩy về trang chủ
        return "redirect:/";
    }
}