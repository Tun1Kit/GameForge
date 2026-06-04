package com.gamestore.dao;

import com.gamestore.entity.OrderItem;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class OrderItemDAO extends BaseDAO<OrderItem> {

    public OrderItemDAO() {
        setClazz(OrderItem.class);
    }

    @Transactional(readOnly = true)
    public List<OrderItem> findByOrderId(Long orderId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM OrderItem oi WHERE oi.order.id = :orderId",
                        OrderItem.class)
                .setParameter("orderId", orderId)
                .list();
    }

    @Transactional(readOnly = true)
    public boolean existsPaidOrderByUserAndGame(Long userId, Long gameId) {
        Long count = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT COUNT(oi.id) FROM OrderItem oi " +
                        "WHERE oi.order.user.id = :userId AND oi.game.id = :gameId AND oi.order.status = 'PAID'",
                        Long.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .uniqueResult();
        return count != null && count > 0;
    }

    @Transactional(readOnly = true)
    public List<Long> findPaidGameIds(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT oi.game.id FROM OrderItem oi " +
                        "WHERE oi.order.user.id = :userId AND oi.order.status = 'PAID'",
                        Long.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    @Transactional(readOnly = true)
    public List<OrderItem> findPendingKeyOrderItems(Long userId) {
        List<OrderItem> items = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT oi FROM OrderItem oi " +
                        "JOIN FETCH oi.game g " +
                        "JOIN FETCH oi.order o " +
                        "WHERE o.user.id = :userId AND o.status = 'PAID' " +
                        "AND NOT EXISTS (FROM LibraryItem li WHERE li.user.id = :userId AND li.game.id = oi.game.id) " +
                        "AND oi.id = (SELECT MIN(oi2.id) FROM OrderItem oi2 WHERE oi2.order.user.id = :userId AND oi2.game.id = oi.game.id AND oi2.order.status = 'PAID')",
                        OrderItem.class)
                .setParameter("userId", userId)
                .getResultList();

        for (OrderItem item : items) {
            if (item.getGame() != null && item.getGame().getCategories() != null) {
                item.getGame().getCategories().size();
            }
        }
        return items;
    }
}
