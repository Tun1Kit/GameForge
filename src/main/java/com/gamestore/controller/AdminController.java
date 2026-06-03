package com.gamestore.controller;

import com.gamestore.dao.UserDAO;
import com.gamestore.dto.AdminStatsDTO;
import com.gamestore.entity.KycRequest;
import com.gamestore.entity.PayoutRequest;
import com.gamestore.entity.Role;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class AdminController {

    private static final int PAGE_SIZE = 10;

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
    @GetMapping("/admin")
    public String adminHome() {
        return "redirect:/admin/dashboard";
    }
    @GetMapping("/admin/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        AdminStatsDTO stats = adminDashboardService.getStats();

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("stats", stats);

        return "admin/dashboard";
    }

    @GetMapping("/admin/users")
    public String users(@RequestParam(value = "search", required = false) String search,
                        @RequestParam(value = "status", required = false) String status,
                        @RequestParam(value = "role", required = false) String role,
                        @RequestParam(value = "page", required = false, defaultValue = "1") Integer page,
                        HttpSession session,
                        Model model) {

        User currentUser = userContextService.getCurrentUser(session);

        List<User> allUsers = userDAO.findAllUsers();
        List<User> filteredUsers = filterUsers(allUsers, search, status, role);
        Map<String, Object> pageResult = buildUserPageResult(filteredUsers, page, PAGE_SIZE);

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("users", filteredUsers);
        model.addAttribute("pageResult", pageResult);
        model.addAttribute("search", search);
        model.addAttribute("status", status);
        model.addAttribute("role", role);

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

    @PostMapping("/admin/users/{userId}/lock")
    @ResponseBody
    public Map<String, Object> lockUserAjax(@PathVariable("userId") Long userId,
                                            HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            User currentUser = userContextService.getCurrentUser(session);

            if (currentUser != null && currentUser.getId().equals(userId)) {
                response.put("success", false);
                response.put("message", "Không thể khóa chính tài khoản Admin đang đăng nhập.");
                return response;
            }

            userDAO.changeStatus(userId, "LOCKED");

            response.put("success", true);
            response.put("message", "Đã khóa tài khoản thành công.");
            return response;

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Lỗi khi khóa tài khoản: " + e.getMessage());
            return response;
        }
    }

    @PostMapping("/admin/users/{userId}/unlock")
    @ResponseBody
    public Map<String, Object> unlockUserAjax(@PathVariable("userId") Long userId) {
        Map<String, Object> response = new HashMap<>();

        try {
            userDAO.changeStatus(userId, "ACTIVE");

            response.put("success", true);
            response.put("message", "Đã mở khóa tài khoản thành công.");
            return response;

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Lỗi khi mở khóa tài khoản: " + e.getMessage());
            return response;
        }
    }

    @GetMapping("/admin/kyc")
    public String kycRequests(@RequestParam(value = "status", required = false) String status,
                              @RequestParam(value = "page", required = false, defaultValue = "1") Integer page,
                              HttpSession session,
                              Model model) {

        User currentUser = userContextService.getCurrentUser(session);

        List<KycRequest> allRequests = kycService.getAllRequests();
        Map<String, Long> stats = buildKycStats(allRequests);
        List<KycRequest> filteredRequests = filterKycRequests(allRequests, status);
        Map<String, Object> pageResult = buildKycPageResult(filteredRequests, page, PAGE_SIZE);

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("stats", stats);
        model.addAttribute("pageResult", pageResult);

        return "admin/kyc";
    }

    @PostMapping("/admin/kyc/approve")
    public String approveKyc(@RequestParam("requestId") Long requestId) {
        try {
            kycService.approveRequest(requestId);
            return "redirect:/admin/kyc?success=approved";
        } catch (Exception e) {
            return "redirect:/admin/kyc?error=process-failed";
        }
    }

    @PostMapping("/admin/kyc/reject")
    public String rejectKyc(@RequestParam("requestId") Long requestId) {
        try {
            kycService.rejectRequest(requestId);
            return "redirect:/admin/kyc?success=rejected";
        } catch (Exception e) {
            return "redirect:/admin/kyc?error=process-failed";
        }
    }

    @GetMapping("/admin/settings")
    public String settings(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        BigDecimal commissionRate = systemSettingService.getPlatformCommissionRate();

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("commissionRate", commissionRate);

        return "admin/settings";
    }

    @PostMapping("/admin/settings/commission")
    public String updateCommissionRate(@RequestParam(value = "commissionRate", required = false) String commissionRateRaw,
                                       HttpSession session) {
        try {
            if (commissionRateRaw == null || commissionRateRaw.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập tỷ lệ hoa hồng.");
            }

            String normalizedRate = commissionRateRaw
                    .trim()
                    .replace("%", "")
                    .replace(",", ".");

            BigDecimal commissionRate = new BigDecimal(normalizedRate);

            systemSettingService.updatePlatformCommissionRate(commissionRate);

            session.setAttribute("settingSuccess", "Cập nhật phí hoa hồng thành công.");
            return "redirect:/admin/settings";

        } catch (Exception e) {
            session.setAttribute("settingError", e.getMessage());
            return "redirect:/admin/settings";
        }
    }

    @GetMapping("/admin/payouts")
    public String payoutRequests(@RequestParam(value = "status", required = false) String status,
                                 @RequestParam(value = "page", required = false, defaultValue = "1") Integer page,
                                 HttpSession session,
                                 Model model) {

        User currentUser = userContextService.getCurrentUser(session);

        List<PayoutRequest> allRequests = payoutService.getAllRequests();

        if (allRequests == null) {
            allRequests = new ArrayList<>();
        }

        Map<String, Long> stats = buildPayoutStats(allRequests);
        List<PayoutRequest> filteredRequests = filterPayoutRequests(allRequests, status);
        Map<String, Object> pageResult = buildPayoutPageResult(filteredRequests, page, PAGE_SIZE);

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("requests", filteredRequests);
        model.addAttribute("stats", stats);
        model.addAttribute("pageResult", pageResult);
        model.addAttribute("status", status);

        return "admin/payouts";
    }

    @PostMapping("/admin/payouts/approve")
    public String approvePayout(@RequestParam("requestId") Long requestId) {
        try {
            payoutService.approvePayout(requestId);
            return "redirect:/admin/payouts?success=approved";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/payouts?error=process-failed";
        }
    }

    @PostMapping("/admin/payouts/reject")
    public String rejectPayout(@RequestParam("requestId") Long requestId) {
        try {
            payoutService.rejectPayout(requestId);
            return "redirect:/admin/payouts?success=rejected";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/payouts?error=process-failed";
        }
    }

    private List<User> filterUsers(List<User> users, String search, String status, String role) {
        List<User> result = new ArrayList<>();

        if (users == null) {
            return result;
        }

        String searchText = search == null ? "" : search.trim().toLowerCase();
        String statusText = status == null ? "" : status.trim();
        String roleText = role == null ? "" : role.trim();

        for (User user : users) {
            if (user == null) {
                continue;
            }

            boolean matchSearch = true;
            boolean matchStatus = true;
            boolean matchRole = true;

            if (!searchText.isEmpty()) {
                String username = user.getUsername() == null ? "" : user.getUsername().toLowerCase();
                String email = user.getEmail() == null ? "" : user.getEmail().toLowerCase();
                String fullName = user.getFullName() == null ? "" : user.getFullName().toLowerCase();

                matchSearch = username.contains(searchText)
                        || email.contains(searchText)
                        || fullName.contains(searchText);
            }

            if (!statusText.isEmpty()) {
                matchStatus = user.getStatus() != null
                        && statusText.equalsIgnoreCase(user.getStatus().trim());
            }

            if (!roleText.isEmpty()) {
                matchRole = false;

                if (user.getRoles() != null) {
                    for (Role userRole : user.getRoles()) {
                        if (userRole != null
                                && userRole.getCode() != null
                                && roleText.equalsIgnoreCase(userRole.getCode().trim())) {
                            matchRole = true;
                            break;
                        }
                    }
                }
            }

            if (matchSearch && matchStatus && matchRole) {
                result.add(user);
            }
        }

        return result;
    }

    private Map<String, Object> buildUserPageResult(List<User> users, Integer page, int pageSize) {
        Map<String, Object> pageResult = new HashMap<>();

        if (users == null) {
            users = new ArrayList<>();
        }

        if (page == null || page < 1) {
            page = 1;
        }

        int totalElements = users.size();
        int totalPages = (int) Math.ceil((double) totalElements / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (page > totalPages) {
            page = totalPages;
        }

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalElements);

        List<User> content = new ArrayList<>();

        if (fromIndex < toIndex) {
            content = users.subList(fromIndex, toIndex);
        }

        pageResult.put("content", content);
        pageResult.put("totalElements", totalElements);
        pageResult.put("totalPages", totalPages);
        pageResult.put("currentPage", page);

        return pageResult;
    }

    private Map<String, Long> buildKycStats(List<KycRequest> requests) {
        Map<String, Long> stats = new HashMap<>();

        long pending = 0L;
        long approved = 0L;
        long rejected = 0L;

        if (requests != null) {
            for (KycRequest request : requests) {
                if (request == null || request.getStatus() == null) {
                    continue;
                }

                String requestStatus = request.getStatus().trim();

                if ("PENDING".equalsIgnoreCase(requestStatus)) {
                    pending++;
                } else if ("APPROVED".equalsIgnoreCase(requestStatus)) {
                    approved++;
                } else if ("REJECTED".equalsIgnoreCase(requestStatus)) {
                    rejected++;
                }
            }
        }

        stats.put("pending", pending);
        stats.put("approved", approved);
        stats.put("rejected", rejected);

        return stats;
    }

    private List<KycRequest> filterKycRequests(List<KycRequest> requests, String status) {
        List<KycRequest> result = new ArrayList<>();

        if (requests == null) {
            return result;
        }

        if (status == null || status.trim().isEmpty()) {
            return requests;
        }

        String filterStatus = status.trim();

        for (KycRequest request : requests) {
            if (request != null
                    && request.getStatus() != null
                    && filterStatus.equalsIgnoreCase(request.getStatus().trim())) {
                result.add(request);
            }
        }

        return result;
    }

    private Map<String, Object> buildKycPageResult(List<KycRequest> requests, Integer page, int pageSize) {
        Map<String, Object> pageResult = new HashMap<>();

        if (requests == null) {
            requests = new ArrayList<>();
        }

        if (page == null || page < 1) {
            page = 1;
        }

        int totalElements = requests.size();
        int totalPages = (int) Math.ceil((double) totalElements / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (page > totalPages) {
            page = totalPages;
        }

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalElements);

        List<KycRequest> content = new ArrayList<>();

        if (fromIndex < toIndex) {
            content = requests.subList(fromIndex, toIndex);
        }

        pageResult.put("content", content);
        pageResult.put("totalElements", totalElements);
        pageResult.put("totalPages", totalPages);
        pageResult.put("currentPage", page);

        return pageResult;
    }

    private Map<String, Long> buildPayoutStats(List<PayoutRequest> requests) {
        Map<String, Long> stats = new HashMap<>();

        long pending = 0L;
        long approved = 0L;
        long rejected = 0L;
        long total = 0L;

        if (requests != null) {
            for (PayoutRequest request : requests) {
                if (request == null) {
                    continue;
                }

                total++;

                if (request.getStatus() == null) {
                    continue;
                }

                String requestStatus = request.getStatus().trim();

                if ("PENDING".equalsIgnoreCase(requestStatus)) {
                    pending++;
                } else if ("PAID".equalsIgnoreCase(requestStatus) || "APPROVED".equalsIgnoreCase(requestStatus)) {
                    approved++;
                } else if ("REJECTED".equalsIgnoreCase(requestStatus)) {
                    rejected++;
                }
            }
        }

        stats.put("pending", pending);
        stats.put("approved", approved);
        stats.put("rejected", rejected);
        stats.put("total", total);

        return stats;
    }

    private List<PayoutRequest> filterPayoutRequests(List<PayoutRequest> requests, String status) {
        List<PayoutRequest> result = new ArrayList<>();

        if (requests == null) {
            return result;
        }

        if (status == null || status.trim().isEmpty()) {
            return requests;
        }

        String filterStatus = status.trim();

        for (PayoutRequest request : requests) {
            if (request != null
                    && request.getStatus() != null
                    && filterStatus.equalsIgnoreCase(request.getStatus().trim())) {
                result.add(request);
            }
        }

        return result;
    }

    private Map<String, Object> buildPayoutPageResult(List<PayoutRequest> requests, Integer page, int pageSize) {
        Map<String, Object> pageResult = new HashMap<>();

        if (requests == null) {
            requests = new ArrayList<>();
        }

        if (page == null || page < 1) {
            page = 1;
        }

        int totalElements = requests.size();
        int totalPages = (int) Math.ceil((double) totalElements / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (page > totalPages) {
            page = totalPages;
        }

        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalElements);

        List<PayoutRequest> content = new ArrayList<>();

        if (fromIndex < toIndex) {
            content = requests.subList(fromIndex, toIndex);
        }

        pageResult.put("content", content);
        pageResult.put("totalElements", totalElements);
        pageResult.put("totalPages", totalPages);
        pageResult.put("currentPage", page);

        return pageResult;
    }
}