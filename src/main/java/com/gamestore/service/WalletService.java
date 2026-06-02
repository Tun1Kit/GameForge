package com.gamestore.service;

import com.gamestore.dao.WalletDAO;
import com.gamestore.dao.WalletTransactionDAO;
import com.gamestore.dto.PageResult;
import com.gamestore.entity.User;
import com.gamestore.entity.Wallet;
import com.gamestore.entity.WalletTransaction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional
public class WalletService {

    @Autowired
    private WalletDAO walletDAO;

    @Autowired
    private WalletTransactionDAO walletTransactionDAO;

    public Wallet getOrCreateWallet(User user) {
        Wallet wallet = walletDAO.findByUserId(user.getId());
        if (wallet == null) {
            wallet = new Wallet();
            wallet.setUser(user);
            wallet.setBalance(BigDecimal.ZERO);
            walletDAO.save(wallet);
        }
        return wallet;
    }

    /**
     * Lấy số dư ví của user. Trả về BigDecimal.ZERO nếu không có ví.
     * Dùng cho controller hiển thị balance — thay thế 7 đoạn trùng lặp:
     * DashboardController, GameController, LibraryController, CheckoutController.
     */
    @Transactional(readOnly = true)
    public BigDecimal getBalance(User user) {
        if (user == null) {
            return BigDecimal.ZERO;
        }
        return getBalanceById(user.getId());
    }

    /**
     * Lấy số dư ví theo userId. Trả về BigDecimal.ZERO nếu không có ví.
     */
    @Transactional(readOnly = true)
    public BigDecimal getBalanceById(Long userId) {
        if (userId == null) {
            return BigDecimal.ZERO;
        }
        Wallet wallet = walletDAO.findByUserId(userId);
        return wallet != null ? wallet.getBalance() : BigDecimal.ZERO;
    }

    public List<WalletTransaction> getTransactions(Long walletId) {
        return walletTransactionDAO.findByWalletId(walletId);
    }

    public PageResult<WalletTransaction> getTransactionsPaged(Long walletId, String type, String status, int page, int size) {
        return walletTransactionDAO.findByWalletIdFilteredPaged(walletId, type, status, page, size);
    }

    public void deposit(User user, BigDecimal amount) {
        credit(user, amount, "DEPOSIT", "USER_DEPOSIT");
    }

    public void withdraw(User user, BigDecimal amount) {
        debit(user, amount, "WITHDRAW", "USER_WITHDRAW");
    }

    public void purchase(User buyer, BigDecimal amount, String orderReference) {
        debit(buyer, amount, "PURCHASE", orderReference);
    }

    public void refund(User buyer, BigDecimal amount, String refundReference) {
        credit(buyer, amount, "REFUND", refundReference);
    }

    public void creditPublisherRevenue(User publisher, BigDecimal amount, String orderReference) {
        credit(publisher, amount, "ADJUSTMENT", "PUBLISHER_REVENUE_" + orderReference);
    }

    public void payoutToPublisher(User publisher, BigDecimal amount, String payoutReference) {
        debit(publisher, amount, "PAYOUT", payoutReference);
    }

    /**
     * Nạp tiền với bonus. Bonus được cộng vào số dư, tạo transaction ghi nhận tổng đã nhận.
     * Thay thế logic trong RechargeController.processRecharge().
     */
    public void recharge(User user, BigDecimal amount, BigDecimal bonus) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Số tiền nạp không hợp lệ.");
        }
        BigDecimal totalReceived = amount.add(bonus);
        Wallet wallet = getOrCreateWallet(user);
        wallet.setBalance(wallet.getBalance().add(totalReceived));
        walletDAO.update(wallet);
        createTransaction(wallet, "DEPOSIT", totalReceived, "SUCCESS", "RECH_" + System.currentTimeMillis());
    }

    private void credit(User user, BigDecimal amount, String type, String referenceId) {
        validateAmount(amount);
        Wallet wallet = getOrCreateWallet(user);
        wallet.setBalance(wallet.getBalance().add(amount));
        walletDAO.update(wallet);
        createTransaction(wallet, type, amount, "SUCCESS", referenceId);
    }

    private void debit(User user, BigDecimal amount, String type, String referenceId) {
        validateAmount(amount);
        Wallet wallet = getOrCreateWallet(user);
        if (wallet.getBalance().compareTo(amount) < 0) {
            createTransaction(wallet, type, amount, "FAILED", referenceId);
            throw new IllegalArgumentException("Số dư ví không đủ.");
        }
        wallet.setBalance(wallet.getBalance().subtract(amount));
        walletDAO.update(wallet);
        createTransaction(wallet, type, amount, "SUCCESS", referenceId);
    }

    private void createTransaction(Wallet wallet, String type, BigDecimal amount, String status, String referenceId) {
        WalletTransaction transaction = new WalletTransaction();
        transaction.setWallet(wallet);
        transaction.setType(type);
        transaction.setAmount(amount);
        transaction.setStatus(status);
        transaction.setReferenceId(referenceId);
        walletTransactionDAO.save(transaction);
    }

    private void validateAmount(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Số tiền phải lớn hơn 0.");
        }
    }
}
