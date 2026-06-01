package com.gamestore.dto;

import java.math.BigDecimal;

public class AdminStatsDTO {

    private Long totalUsers;
    private Long activeUsers;
    private Long lockedUsers;
    private Long totalPublishers;
    private Long totalWalletTransactions;
    private Long pendingKycRequests;
    private Long pendingPayoutRequests;
    private BigDecimal totalWalletBalance;

    public AdminStatsDTO() {}

    public Long getTotalUsers() { return totalUsers; }
    public void setTotalUsers(Long totalUsers) { this.totalUsers = totalUsers; }

    public Long getActiveUsers() { return activeUsers; }
    public void setActiveUsers(Long activeUsers) { this.activeUsers = activeUsers; }

    public Long getLockedUsers() { return lockedUsers; }
    public void setLockedUsers(Long lockedUsers) { this.lockedUsers = lockedUsers; }

    public Long getTotalPublishers() { return totalPublishers; }
    public void setTotalPublishers(Long totalPublishers) { this.totalPublishers = totalPublishers; }

    public Long getTotalWalletTransactions() { return totalWalletTransactions; }
    public void setTotalWalletTransactions(Long totalWalletTransactions) { this.totalWalletTransactions = totalWalletTransactions; }

    public Long getPendingKycRequests() { return pendingKycRequests; }
    public void setPendingKycRequests(Long pendingKycRequests) { this.pendingKycRequests = pendingKycRequests; }

    public Long getPendingPayoutRequests() { return pendingPayoutRequests; }
    public void setPendingPayoutRequests(Long pendingPayoutRequests) { this.pendingPayoutRequests = pendingPayoutRequests; }

    public BigDecimal getTotalWalletBalance() { return totalWalletBalance; }
    public void setTotalWalletBalance(BigDecimal totalWalletBalance) { this.totalWalletBalance = totalWalletBalance; }
}
