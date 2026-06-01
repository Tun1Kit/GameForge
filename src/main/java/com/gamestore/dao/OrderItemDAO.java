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
}
