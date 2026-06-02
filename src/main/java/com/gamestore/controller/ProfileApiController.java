package com.gamestore.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gamestore.entity.User;
import com.gamestore.service.UserContextService;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@Controller
@Transactional
public class ProfileApiController {

    @Autowired
    private SessionFactory sessionFactory;

    @Autowired
    private UserContextService userContextService;

    @PostMapping("/api/profile/update")
    public void updateProfile(
            @RequestParam("fullName") String fullName,
            @RequestParam(value = "password", required = false) String password,
            @RequestParam(value = "avatar", required = false) String avatar,
            HttpSession session,
            HttpServletResponse httpResponse) throws Exception {

        httpResponse.setContentType("application/json;charset=UTF-8");
        httpResponse.setCharacterEncoding("UTF-8");
        PrintWriter out = httpResponse.getWriter();
        ObjectMapper mapper = new ObjectMapper();

        Map<String, Object> response = new HashMap<>();
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "Chưa đăng nhập.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Tên hiển thị không được để trống.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        try {
            User user = sessionFactory.getCurrentSession().get(User.class, currentUser.getId());
            if (user == null) {
                response.put("success", false);
                response.put("message", "Người dùng không tồn tại trong hệ thống.");
                out.print(mapper.writeValueAsString(response));
                return;
            }

            user.setFullName(fullName.trim());

            if (avatar != null && !avatar.trim().isEmpty()) {
                user.setAvatar(avatar.trim());
            } else {
                user.setAvatar(null);
            }

            if (password != null && !password.trim().isEmpty()) {
                user.setPassword(password.trim());
            }

            sessionFactory.getCurrentSession().update(user);
            sessionFactory.getCurrentSession().flush();

            userContextService.updateSessionUser(session, user);

            response.put("success", true);
            response.put("message", "Cập nhật hồ sơ cá nhân thành công!");
            out.print(mapper.writeValueAsString(response));
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "Lỗi máy chủ khi cập nhật thông tin: " + e.getMessage());
            out.print(mapper.writeValueAsString(response));
        }
    }
}
