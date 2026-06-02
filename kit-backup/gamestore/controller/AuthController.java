package com.gamestore.controller;

import com.gamestore.dao.UserDAO;
import com.gamestore.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;

@Controller
public class AuthController {

    @Autowired
    private UserDAO userDAO;

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
    public String processLogin(@RequestParam("emailOrUsername") String email,
                               @RequestParam("password") String password,
                               HttpSession session,
                               Model model) {
        
        // Dùng UserDAO tìm kiếm trong CSDL
        User user = userDAO.findByEmail(email);
        
        // Kiểm tra xem user có tồn tại và mật khẩu có khớp không
        if (user != null && user.getPassword().equals(password)) {
            // ĐĂNG NHẬP THÀNH CÔNG: Lưu đối tượng user vào Session
            session.setAttribute("currentUser", user);
            // Chuyển hướng (Redirect) người dùng về trang chủ
            return "redirect:/"; 
        } else {
            // ĐĂNG NHẬP THẤT BẠI: Ném lỗi về lại giao diện
            model.addAttribute("error", "Sai email đăng nhập hoặc mật khẩu!");
            return "login";
        }
    }

    // 3. HỨNG VÀ XỬ LÝ FORM ĐĂNG KÝ
    @PostMapping("/register")
    public String processRegister(@RequestParam("fullName") String fullName,
                                  @RequestParam("email") String email,
                                  @RequestParam("password") String password,
                                  @RequestParam("confirmPassword") String confirmPassword,
                                  Model model) {
        
        // Bước kiểm tra 1: Mật khẩu xác nhận phải khớp
        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "Mật khẩu nhập lại không khớp!");
            return "login"; // Trả về kèm lỗi để JS hiện lại tab Register
        }
        
        // Bước kiểm tra 2: Tránh đăng ký trùng Email
        if (userDAO.findByEmail(email) != null) {
            model.addAttribute("error", "Email này đã được sử dụng!");
            return "login";
        }

        // Tạo mới tài khoản
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setPassword(password); // Thực chiến sẽ mã hóa BCrypt, ở đây ta lưu text thường để dễ test

        // Dùng BaseDAO để ghi xuống SQL Server
        userDAO.save(newUser);
        
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