package com.gamestore.controller;

import com.gamestore.entity.CartItem;
import com.gamestore.entity.Order;
import com.gamestore.entity.User;
import org.hibernate.SessionFactory;
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
    private SessionFactory sessionFactory;

    @GetMapping("/dashboard")
    public String showDashboard(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        // 1. Lấy số dư ví hiện tại
        BigDecimal walletBalance = BigDecimal.ZERO;
        try 
        {
            Object result = sessionFactory.getCurrentSession()
                    .createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
                    .setParameter("uid", currentUser.getId())
                    .uniqueResult();
            if (result != null) {
                walletBalance = (result instanceof BigDecimal)
                        ? (BigDecimal) result
                        : new BigDecimal(result.toString());
            }
        } 
        catch (Exception e) 
        {
            // Không có ví
        }

        // 2. Lấy danh sách giỏ hàng hiện tại
        String cartHql = "FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :uid";
        List<CartItem> cartItems = sessionFactory.getCurrentSession()
                .createQuery(cartHql, CartItem.class)
                .setParameter("uid", currentUser.getId())
                .getResultList();

        BigDecimal cartTotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) 
        {
            cartTotal = cartTotal.add(item.getGame().getPrice());
        }

        // 3. Lấy danh sách 3 đơn hàng gần nhất
        String orderHql = "FROM Order o WHERE o.user.id = :uid ORDER BY o.createdAt DESC";
        List<Order> recentOrders = sessionFactory.getCurrentSession()
                .createQuery(orderHql, Order.class)
                .setParameter("uid", currentUser.getId())
                .setMaxResults(3)
                .getResultList();

        model.addAttribute("walletBalance", walletBalance);
        model.addAttribute("cartItems", cartItems);
        model.addAttribute("cartTotal", cartTotal);
        model.addAttribute("recentOrders", recentOrders);

        return "dashboard";
    }
}
