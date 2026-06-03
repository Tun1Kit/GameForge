package com.gamestore.controller;

import com.gamestore.entity.PayoutRequest;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
import com.gamestore.service.PayoutService;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.gamestore.dao.KycRequestDAO;
import com.gamestore.dao.PublisherProfileDAO;
import com.gamestore.entity.KycRequest;
import com.gamestore.entity.PublisherProfile;
import org.springframework.transaction.annotation.Transactional;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class PublisherController {

    private static final int PAGE_SIZE = 10;
    private static final BigDecimal MIN_PAYOUT_AMOUNT = new BigDecimal("10000");

    @Autowired
    private PayoutService payoutService;

    @Autowired
    private WalletService walletService;

    @Autowired
    private UserContextService userContextService;
    @Autowired
    private KycRequestDAO kycRequestDAO;

    @Autowired
    private PublisherProfileDAO publisherProfileDAO;
    @GetMapping("/publisher")
    public String publisherHome() {
        return "redirect:/publisher/dashboard";
    }

    @GetMapping("/publisher/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        model.addAttribute("currentUser", currentUser);

        return "publisher/dashboard";
    }
    @GetMapping("/publisher/kyc")
    @Transactional(readOnly = true)
    public String publisherKyc(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        KycRequest latestKyc = kycRequestDAO.findLatestByUserId(currentUser.getId());
        PublisherProfile publisherProfile = publisherProfileDAO.findByUserId(currentUser.getId());

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("latestKyc", latestKyc);
        model.addAttribute("publisherProfile", publisherProfile);

        return "publisher/kyc";
    }
    @GetMapping("/publisher/payouts")
    public String payouts(@RequestParam(value = "page", required = false, defaultValue = "1") Integer page,
                          HttpSession session,
                          Model model) {

        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        loadPayoutPageData(currentUser, page, model);

        return "publisher/payouts";
    }

    /*
     * Hỗ trợ cả 2 URL:
     * - /publisher/payouts/request: URL đúng nên dùng trong form
     * - /publisher/payouts: giữ lại để tránh lỗi "POST not supported" nếu JSP/JS cũ vẫn gọi URL này
     */
    @PostMapping({"/publisher/payouts/request", "/publisher/payouts"})
    public String createPayoutRequest(@RequestParam(value = "amount", required = false) BigDecimal amount,
                                      @RequestParam(value = "bankAccountInfo", required = false) String bankAccountInfo,
                                      HttpSession session) {

        User currentUser = userContextService.getCurrentUser(session);

        if (currentUser == null) {
            return "redirect:/login";
        }

        try {
            if (amount == null) {
                throw new IllegalArgumentException("Vui lòng nhập số tiền muốn rút.");
            }

            if (amount.compareTo(MIN_PAYOUT_AMOUNT) < 0) {
                throw new IllegalArgumentException("Số tiền rút tối thiểu là 10.000đ.");
            }

            if (bankAccountInfo == null || bankAccountInfo.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng nhập thông tin tài khoản ngân hàng.");
            }

            payoutService.createPayoutRequest(currentUser, amount, bankAccountInfo.trim());

            session.setAttribute("payoutSuccess", "Gửi yêu cầu rút tiền thành công. Vui lòng chờ Admin duyệt.");

            return "redirect:/publisher/payouts";

        } catch (IllegalArgumentException e) {
            session.setAttribute("payoutError", e.getMessage());
            return "redirect:/publisher/payouts";
        } catch (Exception e) {
            session.setAttribute("payoutError", "Có lỗi xảy ra khi gửi yêu cầu rút tiền: " + e.getMessage());
            return "redirect:/publisher/payouts";
        }
    }

    private void loadPayoutPageData(User currentUser, Integer page, Model model) {
        Wallet wallet = walletService.getOrCreateWallet(currentUser);
        List<PayoutRequest> requests = payoutService.getRequestsByPublisherUser(currentUser.getId());

        if (requests == null) {
            requests = new ArrayList<>();
        }

        BigDecimal walletBalance = BigDecimal.ZERO;

        if (wallet != null && wallet.getBalance() != null) {
            walletBalance = wallet.getBalance();
        }

        BigDecimal pendingAmount = calculatePendingAmount(requests);
        BigDecimal availableAmount = walletBalance.subtract(pendingAmount);

        if (availableAmount.compareTo(BigDecimal.ZERO) < 0) {
            availableAmount = BigDecimal.ZERO;
        }

        Map<String, Object> pageResult = buildPageResult(requests, page, PAGE_SIZE);

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("wallet", wallet);
        model.addAttribute("requests", requests);
        model.addAttribute("pendingAmount", pendingAmount);
        model.addAttribute("availableAmount", availableAmount);
        model.addAttribute("pageResult", pageResult);
    }

    private BigDecimal calculatePendingAmount(List<PayoutRequest> requests) {
        BigDecimal total = BigDecimal.ZERO;

        if (requests == null) {
            return total;
        }

        for (PayoutRequest request : requests) {
            if (request == null) {
                continue;
            }

            String status = request.getStatus();

            if (status != null && "PENDING".equalsIgnoreCase(status.trim())) {
                BigDecimal amount = request.getAmount();

                if (amount != null) {
                    total = total.add(amount);
                }
            }
        }

        return total;
    }

    private Map<String, Object> buildPageResult(List<PayoutRequest> requests, Integer page, int pageSize) {
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