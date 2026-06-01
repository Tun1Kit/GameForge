package com.gamestore.dao;

import com.gamestore.entity.CartItem;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class CartItemDAO extends BaseDAO<CartItem> {
    
    public CartItemDAO() {
        setClazz(CartItem.class);
    }

    // Hàm kiểm tra xem 1 User đã có 1 Game cụ thể trong giỏ hàng chưa
    public CartItem findByUserAndGame(Long userId, Long gameId) {
        try {
            return sessionFactory.getCurrentSession()
                .createQuery("FROM CartItem c WHERE c.user.id = :userId AND c.game.id = :gameId", CartItem.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }
}