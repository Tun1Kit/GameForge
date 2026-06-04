package com.gamestore.controller;

import com.gamestore.dao.OrderDAO;
import com.gamestore.entity.Order;
import com.gamestore.entity.User;
import com.gamestore.service.CartService;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;

@Controller
@Transactional
public class DashboardController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private CartService cartService;

    @Autowired
    private UserContextService userContextService;

    @Autowired
    private OrderDAO orderDAO;

    @GetMapping("/dashboard")
    public String showDashboard(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        if (currentUser.hasRole("ROLE_ADMIN")) {
            return "redirect:/admin/dashboard";
        }

        if (currentUser.hasRole("ROLE_PUBLISHER")) {
            return "redirect:/publisher/dashboard";
        }

        BigDecimal walletBalance = walletService.getBalance(currentUser);

        List<?> cartItems = cartService.getCartItems(currentUser.getId());

        BigDecimal cartTotal = BigDecimal.ZERO;
        for (Object obj : cartItems) {
            com.gamestore.entity.CartItem item = (com.gamestore.entity.CartItem) obj;
            if (item.getGame() != null && item.getGame().getPrice() != null) {
                cartTotal = cartTotal.add(item.getGame().getPrice());
            }
        }

        List<Order> recentOrders = orderDAO.findRecentByUserId(currentUser.getId(), 3);

        model.addAttribute("walletBalance", walletBalance);
        model.addAttribute("cartItems", cartItems);
        model.addAttribute("cartTotal", cartTotal);
        model.addAttribute("recentOrders", recentOrders);

        return "dashboard";
    }
}
