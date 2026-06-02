package com.gamestore.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Controller
@Transactional
public class RechargeController {

    @Autowired
    private SessionFactory sessionFactory;

    @Autowired
    private WalletService walletService;

    @Autowired
    private UserContextService userContextService;

    @GetMapping("/recharge")
    public String showRechargePage(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        BigDecimal walletBalance = walletService.getBalance(currentUser);

        model.addAttribute("walletBalance", walletBalance);
        return "recharge";
    }

    @PostMapping("/api/recharge/process")
    public void processRecharge(
            @RequestParam("amount") BigDecimal amount,
            @RequestParam("method") String method,
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

        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            response.put("success", false);
            response.put("message", "Số tiền nạp không hợp lệ.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        try {
            BigDecimal bonus = BigDecimal.ZERO;
            if (amount.compareTo(new BigDecimal("500000")) == 0) {
                bonus = new BigDecimal("30000");
            } else if (amount.compareTo(new BigDecimal("1000000")) == 0) {
                bonus = new BigDecimal("80000");
            } else if (amount.compareTo(new BigDecimal("2000000")) == 0) {
                bonus = new BigDecimal("220000");
            }

            walletService.recharge(currentUser, amount, bonus);

            BigDecimal newBalance = walletService.getBalance(currentUser);

            response.put("success", true);
            response.put("amount", amount);
            response.put("bonus", bonus);
            response.put("totalReceived", amount.add(bonus));
            response.put("newBalance", newBalance);
            response.put("message", "Nạp tiền giả lập thành công!");

            out.print(mapper.writeValueAsString(response));
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "Lỗi CSDL khi thực hiện giao dịch ví: " + e.getMessage());
            out.print(mapper.writeValueAsString(response));
        }
    }
}
