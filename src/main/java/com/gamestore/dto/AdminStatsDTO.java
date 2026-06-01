package com.gamestore.dto;

import java.math.BigDecimal;

public class AdminStatsDTO {

    private Long totalUsers;
    private Long activeUsers;
    private Long lockedUsers;
    private Long totalPublishers;
    private Long totalGames;
    private Long activeGames;
    private Long totalOrders;
    private Long completedOrders;
    private BigDecimal totalRevenue;
    private BigDecimal platformRevenue;
    private Long pendingKyc;
    private Long pendingPayouts;
    private Long totalWalletTransactions;
    private BigDecimal totalWalletBalance;
    private Long ordersToday;

    public AdminStatsDTO() {}

    public Long getTotalUsers() { return totalUsers; }
    public void setTotalUsers(Long totalUsers) { this.totalUsers = totalUsers; }

    public Long getActiveUsers() { return activeUsers; }
    public void setActiveUsers(Long activeUsers) { this.activeUsers = activeUsers; }

    public Long getLockedUsers() { return lockedUsers; }
    public void setLockedUsers(Long lockedUsers) { this.lockedUsers = lockedUsers; }

    public Long getTotalPublishers() { return totalPublishers; }
    public void setTotalPublishers(Long totalPublishers) { this.totalPublishers = totalPublishers; }

    public Long getTotalGames() { return totalGames != null ? totalGames : 0L; }
    public void setTotalGames(Long totalGames) { this.totalGames = totalGames; }

    public Long getActiveGames() { return activeGames != null ? activeGames : 0L; }
    public void setActiveGames(Long activeGames) { this.activeGames = activeGames; }

    public Long getTotalOrders() { return totalOrders != null ? totalOrders : 0L; }
    public void setTotalOrders(Long totalOrders) { this.totalOrders = totalOrders; }

    public Long getCompletedOrders() { return completedOrders != null ? completedOrders : 0L; }
    public void setCompletedOrders(Long completedOrders) { this.completedOrders = completedOrders; }

    public BigDecimal getTotalRevenue() { return totalRevenue != null ? totalRevenue : BigDecimal.ZERO; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public BigDecimal getPlatformRevenue() { return platformRevenue != null ? platformRevenue : BigDecimal.ZERO; }
    public void setPlatformRevenue(BigDecimal platformRevenue) { this.platformRevenue = platformRevenue; }

    public Long getPendingKyc() { return pendingKyc != null ? pendingKyc : 0L; }
    public void setPendingKyc(Long pendingKyc) { this.pendingKyc = pendingKyc; }

    public Long getPendingPayouts() { return pendingPayouts != null ? pendingPayouts : 0L; }
    public void setPendingPayouts(Long pendingPayouts) { this.pendingPayouts = pendingPayouts; }

    public Long getTotalWalletTransactions() { return totalWalletTransactions; }
    public void setTotalWalletTransactions(Long totalWalletTransactions) { this.totalWalletTransactions = totalWalletTransactions; }

    public BigDecimal getTotalWalletBalance() { return totalWalletBalance != null ? totalWalletBalance : BigDecimal.ZERO; }
    public void setTotalWalletBalance(BigDecimal totalWalletBalance) { this.totalWalletBalance = totalWalletBalance; }

    public Long getOrdersToday() { return ordersToday != null ? ordersToday : 0L; }
    public void setOrdersToday(Long ordersToday) { this.ordersToday = ordersToday; }
}
