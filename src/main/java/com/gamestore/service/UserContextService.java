package com.gamestore.service;

import com.gamestore.entity.User;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;


@Service
public class UserContextService {


    public User getCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("currentUser");
    }


    public User requireLogin(HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            throw new IllegalStateException("Chưa đăng nhập.");
        }
        return user;
    }


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


    public void updateSessionUser(HttpSession session, User updatedUser) {
        if (session == null || updatedUser == null) {
            return;
        }
        session.setAttribute("currentUser", updatedUser);
    }
}
