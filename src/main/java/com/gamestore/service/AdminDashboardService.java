package com.gamestore.service;

import com.gamestore.dto.AdminStatsDTO;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@Transactional(readOnly = true)
public class AdminDashboardService {

    @Autowired
    private SessionFactory sessionFactory;

    public AdminStatsDTO getStats() {
        AdminStatsDTO stats = new AdminStatsDTO();

        stats.setTotalUsers(count("SELECT COUNT(u.id) FROM User u"));
        stats.setActiveUsers(count("SELECT COUNT(u.id) FROM User u WHERE u.status = 'ACTIVE'"));
        stats.setLockedUsers(count("SELECT COUNT(u.id) FROM User u WHERE u.status = 'LOCKED'"));
        stats.setTotalPublishers(count(
                "SELECT COUNT(DISTINCT u.id) FROM User u JOIN u.roles r WHERE r.code = 'ROLE_PUBLISHER'"));
        stats.setTotalWalletTransactions(count("SELECT COUNT(wt.id) FROM WalletTransaction wt"));
        stats.setPendingKycRequests(count("SELECT COUNT(k.id) FROM KycRequest k WHERE k.status = 'PENDING'"));
        stats.setPendingPayoutRequests(count("SELECT COUNT(p.id) FROM PayoutRequest p WHERE p.status = 'PENDING'"));

        BigDecimal totalBalance = sessionFactory.getCurrentSession()
                .createQuery("SELECT COALESCE(SUM(w.balance), 0) FROM Wallet w", BigDecimal.class)
                .uniqueResult();
        stats.setTotalWalletBalance(totalBalance == null ? BigDecimal.ZERO : totalBalance);

        return stats;
    }

    private Long count(String hql) {
        Long result = sessionFactory.getCurrentSession()
                .createQuery(hql, Long.class)
                .uniqueResult();
        return result == null ? 0L : result;
    }
}
