package com.gamestore.dao;

import com.gamestore.entity.CartItem;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class CartItemDAO extends BaseDAO<CartItem> {

    public CartItemDAO() {
        setClazz(CartItem.class);
    }

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

    /**
     * Lấy danh sách CartItem kèm Game đã fetch sẵn.
     */
    @Transactional(readOnly = true)
    public List<CartItem> getCartItems(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId", CartItem.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    /**
     * Đếm số item trong giỏ hàng.
     */
    @Transactional(readOnly = true)
    public long getCartCount(Long userId) {
        Long count = sessionFactory.getCurrentSession()
                .createQuery("SELECT COUNT(c) FROM CartItem c WHERE c.user.id = :userId", Long.class)
                .setParameter("userId", userId)
                .uniqueResult();
        return count != null ? count : 0L;
    }

    /**
     * Lấy danh sách game ID trong giỏ hàng.
     */
    @Transactional(readOnly = true)
    public List<Long> getCartGameIds(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery("SELECT c.game.id FROM CartItem c WHERE c.user.id = :userId", Long.class)
                .setParameter("userId", userId)
                .getResultList();
    }
}
