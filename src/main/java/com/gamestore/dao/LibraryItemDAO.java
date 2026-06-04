package com.gamestore.dao;

import com.gamestore.entity.LibraryItem;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class LibraryItemDAO extends BaseDAO<LibraryItem> {

    public LibraryItemDAO() {
        setClazz(LibraryItem.class);
    }

    @Transactional(readOnly = true)
    public List<LibraryItem> findByUserId(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM LibraryItem li WHERE li.user.id = :userId ORDER BY li.acquiredAt DESC",
                        LibraryItem.class)
                .setParameter("userId", userId)
                .list();
    }

    @Transactional(readOnly = true)
    public boolean existsActiveByUserAndGame(Long userId, Long gameId) {
        Long count = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT COUNT(li.id) FROM LibraryItem li " +
                        "WHERE li.user.id = :userId AND li.game.id = :gameId AND li.status = 'ACTIVE'",
                        Long.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .uniqueResult();
        return count != null && count > 0;
    }

    /**
     * Lấy danh sách library items kèm game và license key đã fetch sẵn.
     */
    @Transactional(readOnly = true)
    public List<LibraryItem> findActiveByUserIdWithDetails(Long userId) {
        List<LibraryItem> items = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT li FROM LibraryItem li " +
                        "JOIN FETCH li.game g " +
                        "LEFT JOIN FETCH li.licenseKey k " +
                        "WHERE li.user.id = :userId AND li.status = 'ACTIVE' " +
                        "ORDER BY li.acquiredAt DESC",
                        LibraryItem.class)
                .setParameter("userId", userId)
                .getResultList();

        for (LibraryItem item : items) {
            if (item.getGame() != null && item.getGame().getCategories() != null) {
                item.getGame().getCategories().size();
            }
        }
        return items;
    }

    /**
     * Lấy danh sách game ID mà user đã sở hữu (ACTIVE).
     * Dùng cho GameController hiển thị trạng thái "Đã sở hữu" trên trang chủ.
     */
    @Transactional(readOnly = true)
    public List<Long> findOwnedGameIds(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT li.game.id FROM LibraryItem li " +
                        "WHERE li.user.id = :userId AND li.status = 'ACTIVE'",
                        Long.class)
                .setParameter("userId", userId)
                .getResultList();
    }
}
