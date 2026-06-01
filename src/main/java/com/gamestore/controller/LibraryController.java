package com.gamestore.controller;

import com.gamestore.entity.LibraryItem;
import com.gamestore.entity.Order;
import com.gamestore.entity.WalletTransaction;
import com.gamestore.entity.User;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
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
    private SessionFactory sessionFactory;

    @GetMapping("/library")
    public String showLibrary(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        // 1. Lấy ví và số dư hiện tại của tài khoản
        BigDecimal walletBalance = BigDecimal.ZERO;
        try {
            Object result = sessionFactory.getCurrentSession()
                    .createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
                    .setParameter("uid", currentUser.getId())
                    .uniqueResult();
            if (result != null) {
                walletBalance = (result instanceof BigDecimal)
                        ? (BigDecimal) result
                        : new BigDecimal(result.toString());
            }
        } catch (Exception e) {
            // Không có ví
        }

        // 2. Lấy danh sách game đã mua từ thư viện của user
        String hql = "SELECT li FROM LibraryItem li " +
                     "JOIN FETCH li.game g " +
                     "LEFT JOIN FETCH li.licenseKey k " +
                     "WHERE li.user.id = :uid AND li.status = 'ACTIVE' " +
                     "ORDER BY li.acquiredAt DESC";
        
        List<LibraryItem> libraryItems = sessionFactory.getCurrentSession()
                .createQuery(hql, LibraryItem.class)
                .setParameter("uid", currentUser.getId())
                .getResultList();

        model.addAttribute("walletBalance", walletBalance);
        model.addAttribute("libraryItems", libraryItems);
        
        return "library";
    }

    /**
     * TRANG LỊCH SỬ GIAO DỊCH (TRANSACTION HISTORY)
     * Kết hợp cả Đơn hàng (Mua game - Biến động giảm) và WalletTransaction (Nạp tiền - Biến động tăng)
     */
    @GetMapping("/transactions")
    public String showTransactions(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        Session hqSession = sessionFactory.getCurrentSession();
        
        // 1. Lấy ví và số dư ví hiện tại
        BigDecimal walletBalance = BigDecimal.ZERO;
        try {
            Object result = hqSession
                    .createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
                    .setParameter("uid", currentUser.getId())
                    .uniqueResult();
            if (result != null) {
                walletBalance = (result instanceof BigDecimal)
                        ? (BigDecimal) result
                        : new BigDecimal(result.toString());
            }
        } catch (Exception e) {
            // Không có ví
        }

        // 2. Lấy danh sách Orders (Mua game) của user
        List<Order> orders = hqSession
                .createQuery("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.items i LEFT JOIN FETCH i.game WHERE o.user.id = :uid AND o.status = 'PAID' ORDER BY o.createdAt DESC", Order.class)
                .setParameter("uid", currentUser.getId())
                .getResultList();

        // 3. Lấy danh sách nạp tiền WalletTransaction của user
        List<WalletTransaction> recharges = hqSession
                .createQuery("SELECT tx FROM WalletTransaction tx JOIN FETCH tx.wallet w WHERE w.user.id = :uid AND tx.type IN ('RECHARGE', 'DEPOSIT') AND tx.status = 'SUCCESS' ORDER BY tx.createdAt DESC", WalletTransaction.class)
                .setParameter("uid", currentUser.getId())
                .getResultList();

        List<TransactionDTO> dtos = new ArrayList<>();
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        // Gộp các Order (Biến động giảm ví do mua game)
        for (Order o : orders) {
            TransactionDTO dto = new TransactionDTO();
            dto.setId("ORD_" + o.getId());
            dto.setCode(o.getOrderCode());
            dto.setRawDate(o.getCreatedAt());
            dto.setDateFormatted(o.getCreatedAt().format(dtf));
            dto.setType("PURCHASE");
            dto.setAmount(o.getTotalAmount());
            dto.setStatus(o.getStatus());
            
            // Xây dựng mô tả các tựa game mua
            StringBuilder sb = new StringBuilder("Mua game: ");
            for (int i = 0; i < o.getItems().size(); i++) {
                if (i > 0) sb.append(", ");
                sb.append(o.getItems().get(i).getGame().getTitle());
            }
            dto.setDescription(sb.toString());
            dtos.add(dto);
        }

        // Gộp các Nạp tiền WalletTransaction (Biến động tăng ví)
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

        // Sắp xếp theo thứ tự thời gian mới nhất lên đầu
        Collections.sort(dtos, new Comparator<TransactionDTO>() {
            @Override
            public int compare(TransactionDTO a, TransactionDTO b) {
                return b.getRawDate().compareTo(a.getRawDate());
            }
        });

        // Tính toán running balance (Số dư sau giao dịch) ngược từ thời điểm hiện tại về quá khứ
        BigDecimal current = walletBalance;
        for (TransactionDTO dto : dtos) {
            dto.setRunningBalance(current);
            if ("PURCHASE".equals(dto.getType())) {
                current = current.add(dto.getAmount());
            } else if ("RECHARGE".equals(dto.getType())) {
                current = current.subtract(dto.getAmount());
            }
        }

        // Tính toán chỉ số thống kê cho tháng hiện tại
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

    /**
     * DTO đại diện cho một bản ghi giao dịch hiển thị trên giao diện
     */
    public static class TransactionDTO {
        private String id;
        private String code;
        private LocalDateTime rawDate;
        private String dateFormatted;
        private String description;
        private String type; // "PURCHASE" or "RECHARGE"
        private BigDecimal amount;
        private BigDecimal runningBalance;
        private String status;

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getCode() { return code; }
        public void setCode(String code) { this.code = code; }
        public LocalDateTime getRawDate() { return rawDate; }
        public void setRawDate(LocalDateTime rawDate) { this.rawDate = rawDate; }
        public String getDateFormatted() { return dateFormatted; }
        public void setDateFormatted(String dateFormatted) { this.dateFormatted = dateFormatted; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public BigDecimal getAmount() { return amount; }
        public void setAmount(BigDecimal amount) { this.amount = amount; }
        public BigDecimal getRunningBalance() { return runningBalance; }
        public void setRunningBalance(BigDecimal runningBalance) { this.runningBalance = runningBalance; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
    }
}
