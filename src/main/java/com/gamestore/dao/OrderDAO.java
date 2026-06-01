package com.gamestore.dao;

import com.gamestore.entity.Order;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class OrderDAO extends BaseDAO<Order> {

    public OrderDAO() {
        setClazz(Order.class);
    }

    @Transactional(readOnly = true)
    public List<Order> findByUserId(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM Order o WHERE o.user.id = :userId ORDER BY o.createdAt DESC",
                        Order.class)
                .setParameter("userId", userId)
                .list();
    }

    @Transactional(readOnly = true)
    public Order findByIdAndUserId(Long orderId, Long userId) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery(
                            "FROM Order o WHERE o.id = :orderId AND o.user.id = :userId",
                            Order.class)
                    .setParameter("orderId", orderId)
                    .setParameter("userId", userId)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
