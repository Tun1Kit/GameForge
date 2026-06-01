package com.gamestore.controller;

import com.gamestore.entity.PayoutRequest;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
import com.gamestore.service.PayoutService;
import com.gamestore.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;

@Controller
public class PublisherController {

    @Autowired
    private PayoutService payoutService;

    @Autowired
    private WalletService walletService;

    @GetMapping("/publisher/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        model.addAttribute("currentUser", currentUser);
        return "publisher/dashboard";
    }

    @GetMapping("/publisher/payouts")
    public String payouts(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        try {
            Wallet wallet = walletService.getOrCreateWallet(currentUser);
            List<PayoutRequest> requests = payoutService.getRequestsByPublisherUser(currentUser.getId());
            model.addAttribute("wallet", wallet);
            model.addAttribute("requests", requests);
            return "publisher/payouts";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "publisher/payouts";
        }
    }

    @PostMapping("/publisher/payouts/request")
    public String createPayoutRequest(@RequestParam("amount") BigDecimal amount,
                                      @RequestParam("bankAccountInfo") String bankAccountInfo,
                                      HttpSession session,
                                      Model model) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) return "redirect:/login";

        try {
            payoutService.createPayoutRequest(currentUser, amount, bankAccountInfo);
            return "redirect:/publisher/payouts?success=requested";
        } catch (IllegalArgumentException e) {
            Wallet wallet = walletService.getOrCreateWallet(currentUser);
            List<PayoutRequest> requests = payoutService.getRequestsByPublisherUser(currentUser.getId());
            model.addAttribute("wallet", wallet);
            model.addAttribute("requests", requests);
            model.addAttribute("error", e.getMessage());
            return "publisher/payouts";
        }
    }
}
