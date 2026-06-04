package com.gamestore.controller;

import com.gamestore.entity.User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;

@Controller
public class ErrorPageController {

    @RequestMapping("/access-denied")
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

    @RequestMapping("/errors/403")
    public String error403(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        model.addAttribute("currentUser", currentUser);
        
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
        model.addAttribute("homeUrl", homeUrl);
        model.addAttribute("homeLabel", homeLabel);
        return "errors/403";
    }

    @RequestMapping("/errors/404")
    public String error404(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        model.addAttribute("currentUser", currentUser);
        return "errors/404";
    }

    @RequestMapping("/errors/500")
    public String error500(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        model.addAttribute("currentUser", currentUser);
        return "errors/500";
    }
}