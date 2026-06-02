package com.gamestore.dao;

import com.gamestore.entity.WishlistItem;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class WishlistItemDAO extends BaseDAO<WishlistItem> {

    public WishlistItemDAO() {
        setClazz(WishlistItem.class);
    }

    /**
     * Tìm WishlistItem theo User và Game.
     */
    @Transactional(readOnly = true)
    public WishlistItem findByUserAndGame(Long userId, Long gameId) {
        try {
            return sessionFactory.getCurrentSession()
                .createQuery("FROM WishlistItem w WHERE w.user.id = :userId AND w.game.id = :gameId", WishlistItem.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Lấy danh sách WishlistItem của User (Fetch kèm Game).
     */
    @Transactional(readOnly = true)
    public List<WishlistItem> findByUser(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM WishlistItem w JOIN FETCH w.game WHERE w.user.id = :userId ORDER BY w.addedAt DESC", WishlistItem.class)
                .setParameter("userId", userId)
                .getResultList();
    }

    /**
     * Đếm tổng số lượng game trong danh sách yêu thích.
     */
    @Transactional(readOnly = true)
    public long getWishlistCount(Long userId) {
        Long count = sessionFactory.getCurrentSession()
                .createQuery("SELECT COUNT(w) FROM WishlistItem w WHERE w.user.id = :userId", Long.class)
                .setParameter("userId", userId)
                .uniqueResult();
        return count != null ? count : 0L;
    }

    /**
     * Lấy danh sách Game ID được yêu thích bởi User.
     */
    @Transactional(readOnly = true)
    public List<Long> getWishlistGameIds(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery("SELECT w.game.id FROM WishlistItem w WHERE w.user.id = :userId", Long.class)
                .setParameter("userId", userId)
                .getResultList();
    }
}
