package com.gamestore.controller;

import com.gamestore.dao.OrderDAO;
import com.gamestore.dao.OrderItemDAO;
import com.gamestore.dao.WalletTransactionDAO;
import com.gamestore.dto.TransactionDTO;
import com.gamestore.entity.Order;
import com.gamestore.entity.OrderItem;
import com.gamestore.entity.User;
import com.gamestore.entity.WalletTransaction;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@Controller
@Transactional
public class LibraryController {

    @Autowired
    private WalletService walletService;

    @Autowired
    private com.gamestore.dao.LibraryItemDAO libraryItemDAO;

    @Autowired
    private OrderItemDAO orderItemDAO;

    @Autowired
    private OrderDAO orderDAO;

    @Autowired
    private WalletTransactionDAO walletTransactionDAO;

    @Autowired
    private UserContextService userContextService;

    @GetMapping("/library")
    public String showLibrary(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        BigDecimal walletBalance = walletService.getBalance(currentUser);

        List<com.gamestore.entity.LibraryItem> libraryItems =
                libraryItemDAO.findActiveByUserIdWithDetails(currentUser.getId());

        List<OrderItem> pendingItems = orderItemDAO.findPendingKeyOrderItems(currentUser.getId());

        model.addAttribute("walletBalance", walletBalance);
        model.addAttribute("libraryItems", libraryItems);
        model.addAttribute("pendingItems", pendingItems);

        return "library";
    }

    @GetMapping("/transactions")
    public String showTransactions(HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        BigDecimal walletBalance = walletService.getBalance(currentUser);

        List<Order> orders = orderDAO.findPaidByUserIdWithItems(currentUser.getId());
        List<WalletTransaction> recharges = walletTransactionDAO.findRechargesByUserId(currentUser.getId());

        List<TransactionDTO> dtos = new ArrayList<>();
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        for (Order o : orders) {
            TransactionDTO dto = new TransactionDTO();
            dto.setId("ORD_" + o.getId());
            dto.setCode(o.getOrderCode());
            dto.setRawDate(o.getCreatedAt());
            dto.setDateFormatted(o.getCreatedAt().format(dtf));
            dto.setType("PURCHASE");
            dto.setAmount(o.getTotalAmount());
            dto.setStatus(o.getStatus());
            dto.setPaymentMethod(o.getPaymentMethod());

            StringBuilder sb = new StringBuilder("Mua game: ");
            for (int i = 0; i < o.getItems().size(); i++) {
                if (i > 0) sb.append(", ");
                sb.append(o.getItems().get(i).getGame().getTitle());
            }
            dto.setDescription(sb.toString());
            dtos.add(dto);
        }

        for (WalletTransaction tx : recharges) {
            TransactionDTO dto = new TransactionDTO();
            dto.setId("TXN_" + tx.getId());
            dto.setCode(tx.getReferenceId() != null ? tx.getReferenceId() : "RECH" + tx.getId());
            dto.setRawDate(tx.getCreatedAt());
            dto.setDateFormatted(tx.getCreatedAt().format(dtf));
            dto.setType("RECHARGE");
            dto.setAmount(tx.getAmount());
            dto.setStatus(tx.getStatus());
            dto.setDescription("Nạp tiền ví GameForge");
            dtos.add(dto);
        }

        Collections.sort(dtos, new Comparator<TransactionDTO>() {
            @Override
            public int compare(TransactionDTO a, TransactionDTO b) {
                return b.getRawDate().compareTo(a.getRawDate());
            }
        });

        BigDecimal current = walletBalance;
        for (TransactionDTO dto : dtos) {
            dto.setRunningBalance(current);
            if ("PURCHASE".equals(dto.getType())) {
                boolean isWalletPurchase = "WALLET".equals(dto.getPaymentMethod()) || "GAMEFORGE".equals(dto.getPaymentMethod());
                if (isWalletPurchase) {
                    current = current.add(dto.getAmount());
                }
            } else if ("RECHARGE".equals(dto.getType())) {
                current = current.subtract(dto.getAmount());
            }
        }

        LocalDateTime now = LocalDateTime.now();
        int curMonth = now.getMonthValue();
        int curYear = now.getYear();

        BigDecimal totalSpentThisMonth = BigDecimal.ZERO;
        int transactionCountThisMonth = 0;

        for (TransactionDTO dto : dtos) {
            if (dto.getRawDate().getMonthValue() == curMonth && dto.getRawDate().getYear() == curYear) {
                transactionCountThisMonth++;
                if ("PURCHASE".equals(dto.getType())) {
                    totalSpentThisMonth = totalSpentThisMonth.add(dto.getAmount());
                }
            }
        }

        model.addAttribute("walletBalance", walletBalance);
        model.addAttribute("totalSpentThisMonth", totalSpentThisMonth);
        model.addAttribute("transactionCountThisMonth", transactionCountThisMonth);
        model.addAttribute("currentMonthYear", String.format("Tháng %02d/%d", curMonth, curYear));
        model.addAttribute("transactions", dtos);

        return "transactions";
    }
}
