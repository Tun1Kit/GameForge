package com.gamestore.dao;

import com.gamestore.dao.BaseDAO;
import com.gamestore.dto.PageResult;
import com.gamestore.entity.WalletTransaction;
import org.hibernate.query.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
@Transactional
public class WalletTransactionDAO extends BaseDAO<WalletTransaction> {

    public WalletTransactionDAO() {
        setClazz(WalletTransaction.class);
    }

    @Transactional(readOnly = true)
    public List<WalletTransaction> findByWalletId(Long walletId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM WalletTransaction wt WHERE wt.wallet.id = :walletId ORDER BY wt.createdAt DESC",
                        WalletTransaction.class)
                .setParameter("walletId", walletId)
                .list();
    }

    @Transactional(readOnly = true)
    public PageResult<WalletTransaction> findByWalletIdFilteredPaged(
            Long walletId, String type, String status, int page, int size) {

        int safePage = Math.max(page, 1);
        int safeSize = Math.max(size, 5);

        StringBuilder baseHql = new StringBuilder(
                "FROM WalletTransaction wt WHERE wt.wallet.id = :walletId");
        Map<String, Object> params = new HashMap<>();
        params.put("walletId", walletId);

        if (type != null && !type.trim().isEmpty()) {
            baseHql.append(" AND wt.type = :type");
            params.put("type", type.trim());
        }
        if (status != null && !status.trim().isEmpty()) {
            baseHql.append(" AND wt.status = :status");
            params.put("status", status.trim());
        }

        String listHql = baseHql.toString() + " ORDER BY wt.createdAt DESC";
        String countHql = "SELECT COUNT(wt.id) " + baseHql.toString();

        Query<WalletTransaction> listQuery = sessionFactory.getCurrentSession()
                .createQuery(listHql, WalletTransaction.class);
        Query<Long> countQuery = sessionFactory.getCurrentSession()
                .createQuery(countHql, Long.class);

        for (Map.Entry<String, Object> entry : params.entrySet()) {
            listQuery.setParameter(entry.getKey(), entry.getValue());
            countQuery.setParameter(entry.getKey(), entry.getValue());
        }

        listQuery.setFirstResult((safePage - 1) * safeSize);
        listQuery.setMaxResults(safeSize);

        List<WalletTransaction> items = listQuery.list();
        Long totalItems = countQuery.uniqueResult();

        return new PageResult<>(items, totalItems == null ? 0L : totalItems, safePage, safeSize);
    }

    /**
     * Lấy danh sách giao dịch nạp tiền (RECHARGE/DEPOSIT) của user.
     * Dùng cho LibraryController.showTransactions().
     */
    @Transactional(readOnly = true)
    public List<WalletTransaction> findRechargesByUserId(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT tx FROM WalletTransaction tx " +
                        "JOIN tx.wallet w " +
                        "WHERE w.user.id = :userId " +
                        "AND tx.type IN ('RECHARGE', 'DEPOSIT') " +
                        "AND tx.status = 'SUCCESS' " +
                        "ORDER BY tx.createdAt DESC",
                        WalletTransaction.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    @Transactional(readOnly = true)
    public List<WalletTransaction> findAllTransactionsWithDetails() {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM WalletTransaction wt JOIN FETCH wt.wallet w JOIN FETCH w.user u ORDER BY wt.id DESC",
                        WalletTransaction.class)
                .list();
    }
}

