package com.gamestore.service;

import com.gamestore.entity.User;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;

/**
 * Tiện ích session/auth cho controller.
 * Thay thế ~20 đoạn trùng lặp: User currentUser = (User) session.getAttribute("currentUser"); if (currentUser == null) ...
 */
@Service
public class UserContextService {

    /**
     * Lấy user hiện tại từ session. Trả về null nếu chưa login.
     */
    public User getCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("currentUser");
    }

    /**
     * Lấy user hiện tại, ném IllegalStateException nếu chưa login.
     * Dùng khi cần chắc chắn user đã đăng nhập.
     */
    public User requireLogin(HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            throw new IllegalStateException("Chưa đăng nhập.");
        }
        return user;
    }

    /**
     * Lấy user hiện tại từ session. Trả về null nếu chưa login.
     * Hỗ trợ cả attribute "user" (legacy) lẫn "currentUser".
     */
    public User getCurrentUserSafe(HttpSession session) {
        if (session == null) {
            return null;
        }
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            user = (User) session.getAttribute("user");
        }
        return user;
    }

    /**
     * Cập nhật user trong session sau khi có thay đổi (vd: đổi fullName, avatar).
     * Giữ nguyên các attribute khác của session.
     */
    public void updateSessionUser(HttpSession session, User updatedUser) {
        if (session == null || updatedUser == null) {
            return;
        }
        session.setAttribute("currentUser", updatedUser);
    }
}
