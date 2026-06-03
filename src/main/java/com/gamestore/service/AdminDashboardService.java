package com.gamestore.service;

import com.gamestore.dto.AdminStatsDTO;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@Transactional(readOnly = true)
public class AdminDashboardService {

    @Autowired
    private SessionFactory sessionFactory;

    public AdminStatsDTO getStats() {
        AdminStatsDTO stats = new AdminStatsDTO();

        // Users
        stats.setTotalUsers(count("SELECT COUNT(u.id) FROM User u"));
        stats.setActiveUsers(count("SELECT COUNT(u.id) FROM User u WHERE u.status = 'ACTIVE'"));
        stats.setLockedUsers(count("SELECT COUNT(u.id) FROM User u WHERE u.status = 'LOCKED'"));
        stats.setTotalPublishers(count(
                "SELECT COUNT(DISTINCT u.id) FROM User u JOIN u.roles r WHERE r.code = 'ROLE_PUBLISHER'"));

        // Games
        stats.setTotalGames(count("SELECT COUNT(g.id) FROM Game g"));
        stats.setActiveGames(count("SELECT COUNT(g.id) FROM Game g WHERE g.status = 'ACTIVE'"));

        // Orders
        stats.setTotalOrders(count("SELECT COUNT(o.id) FROM Order o"));
        stats.setCompletedOrders(count("SELECT COUNT(o.id) FROM Order o WHERE o.status = 'PAID'"));

        // Revenue
        BigDecimal totalRevenue = querySingle(
                "SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.status = 'PAID'",
                BigDecimal.class);
        stats.setTotalRevenue(totalRevenue != null ? totalRevenue : BigDecimal.ZERO);

        BigDecimal platformRevenue = querySingle(
                "SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.status = 'PAID'",
                BigDecimal.class);
        stats.setPlatformRevenue(platformRevenue != null ? platformRevenue : BigDecimal.ZERO);

        // KYC & Payout
        stats.setPendingKyc(count("SELECT COUNT(k.id) FROM KycRequest k WHERE k.status = 'PENDING'"));
        stats.setPendingPayouts(count("SELECT COUNT(p.id) FROM PayoutRequest p WHERE p.status = 'PENDING'"));

        // Wallet
        stats.setTotalWalletTransactions(count("SELECT COUNT(wt.id) FROM WalletTransaction wt"));
        BigDecimal totalBalance = querySingle(
                "SELECT COALESCE(SUM(w.balance), 0) FROM Wallet w", BigDecimal.class);
        stats.setTotalWalletBalance(totalBalance != null ? totalBalance : BigDecimal.ZERO);

        // Orders today
        stats.setOrdersToday(countOrdersToday());

        return stats;
    }

    private Long count(String hql) {
        Long result = sessionFactory.getCurrentSession()
                .createQuery(hql, Long.class)
                .uniqueResult();
        return result == null ? 0L : result;
    }

    private <T> T querySingle(String hql, Class<T> type) {
        return sessionFactory.getCurrentSession()
                .createQuery(hql, type)
                .uniqueResult();
    }

    private Long countOrdersToday() {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime startOfTomorrow = startOfDay.plusDays(1);

        Long result = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT COUNT(o.id) " +
                        "FROM Order o " +
                        "WHERE o.createdAt >= :startOfDay " +
                        "AND o.createdAt < :startOfTomorrow " +
                        "AND o.status = :status",
                        Long.class)
                .setParameter("startOfDay", startOfDay)
                .setParameter("startOfTomorrow", startOfTomorrow)
                .setParameter("status", "PAID")
                .uniqueResult();

        return result == null ? 0L : result;
    }
}