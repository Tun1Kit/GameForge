package com.gamestore.controller;

import com.gamestore.entity.User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import javax.servlet.http.HttpSession;

@Controller
public class ErrorPageController {

    @GetMapping("/access-denied")
    public String accessDenied(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");

        String homeUrl = "/login";
        String homeLabel = "Đăng nhập";

        if (currentUser != null) {
            if (currentUser.hasRole("ROLE_ADMIN")) {
                homeUrl = "/admin/dashboard";
                homeLabel = "Về Admin Dashboard";
            } else if (currentUser.hasRole("ROLE_PUBLISHER")) {
                homeUrl = "/publisher/dashboard";
                homeLabel = "Về Publisher Dashboard";
            } else {
                homeUrl = "/";
                homeLabel = "Về trang chủ";
            }
        }

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("homeUrl", homeUrl);
        model.addAttribute("homeLabel", homeLabel);

        return "access-denied";
    }
}