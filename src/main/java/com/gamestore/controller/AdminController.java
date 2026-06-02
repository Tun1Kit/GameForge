package com.gamestore.controller;

import com.gamestore.dao.UserDAO;
import com.gamestore.dto.AdminStatsDTO;
import com.gamestore.entity.PayoutRequest;
import com.gamestore.entity.User;
import com.gamestore.service.AdminDashboardService;
import com.gamestore.service.KycService;
import com.gamestore.service.PayoutService;
import com.gamestore.service.SystemSettingService;
import com.gamestore.service.UserContextService;
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
public class AdminController {

    @Autowired
    private AdminDashboardService adminDashboardService;

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private KycService kycService;

    @Autowired
    private PayoutService payoutService;

    @Autowired
    private SystemSettingService systemSettingService;

    @Autowired
    private UserContextService userContextService;

    @GetMapping("/admin/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        AdminStatsDTO stats = adminDashboardService.getStats();
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("stats", stats);
        return "admin/dashboard";
    }

    @GetMapping("/admin/users")
    public String users(Model model) {
        List<User> users = userDAO.findAllUsers();
        model.addAttribute("users", users);
        return "admin/users";
    }

    @PostMapping("/admin/users/lock")
    public String lockUser(@RequestParam("userId") Long userId, HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser != null && currentUser.getId().equals(userId)) {
            return "redirect:/admin/users?error=self-lock";
        }
        userDAO.changeStatus(userId, "LOCKED");
        return "redirect:/admin/users?success=locked";
    }

    @PostMapping("/admin/users/unlock")
    public String unlockUser(@RequestParam("userId") Long userId) {
        userDAO.changeStatus(userId, "ACTIVE");
        return "redirect:/admin/users?success=unlocked";
    }

    @GetMapping("/admin/kyc")
    public String kycRequests(Model model) {
        model.addAttribute("requests", kycService.getAllRequests());
        return "admin/kyc";
    }

    @PostMapping("/admin/kyc/approve")
    public String approveKyc(@RequestParam("requestId") Long requestId) {
        try {
            kycService.approveRequest(requestId);
            return "redirect:/admin/kyc?success=approved";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/kyc?error=" + e.getMessage();
        }
    }

    @PostMapping("/admin/kyc/reject")
    public String rejectKyc(@RequestParam("requestId") Long requestId) {
        try {
            kycService.rejectRequest(requestId);
            return "redirect:/admin/kyc?success=rejected";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/kyc?error=" + e.getMessage();
        }
    }

    @GetMapping("/admin/settings")
    public String settings(Model model) {
        BigDecimal commissionRate = systemSettingService.getPlatformCommissionRate();
        model.addAttribute("commissionRate", commissionRate);
        return "admin/settings";
    }

    @PostMapping("/admin/settings/commission")
    public String updateCommissionRate(@RequestParam("commissionRate") BigDecimal commissionRate, Model model) {
        try {
            systemSettingService.updatePlatformCommissionRate(commissionRate);
            return "redirect:/admin/settings?success=commission-updated";
        } catch (IllegalArgumentException e) {
            model.addAttribute("commissionRate", commissionRate);
            model.addAttribute("error", e.getMessage());
            return "admin/settings";
        }
    }

    @GetMapping("/admin/payouts")
    public String payoutRequests(Model model) {
        List<PayoutRequest> requests = payoutService.getAllRequests();
        model.addAttribute("requests", requests);
        return "admin/payouts";
    }

    @PostMapping("/admin/payouts/approve")
    public String approvePayout(@RequestParam("requestId") Long requestId) {
        try {
            payoutService.approvePayout(requestId);
            return "redirect:/admin/payouts?success=approved";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/payouts?error=" + e.getMessage();
        }
    }

    @PostMapping("/admin/payouts/reject")
    public String rejectPayout(@RequestParam("requestId") Long requestId) {
        try {
            payoutService.rejectPayout(requestId);
            return "redirect:/admin/payouts?success=rejected";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/payouts?error=" + e.getMessage();
        }
    }
}
