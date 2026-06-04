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

    @Transactional(readOnly = true)
    public long countDownloadsByGameId(Long gameId) {
        Long count = sessionFactory.getCurrentSession()
                .createQuery("SELECT COUNT(li) FROM LibraryItem li WHERE li.game.id = :gameId", Long.class)
                .setParameter("gameId", gameId)
                .uniqueResult();
        return count != null ? count : 0L;
    }

    @Transactional(readOnly = true)
    public LibraryItem findByUserAndGame(Long userId, Long gameId) {
        String libHql = "FROM LibraryItem WHERE user.id = :userId AND game.id = :gameId";
        List<LibraryItem> existingLibs = sessionFactory.getCurrentSession()
                .createQuery(libHql, LibraryItem.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .getResultList();
        return existingLibs.isEmpty() ? null : existingLibs.get(0);
    }

    @Transactional(readOnly = true)
    public List<LibraryItem> findNonRefundedByGameIdWithDetails(Long gameId) {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM LibraryItem li JOIN FETCH li.user u LEFT JOIN FETCH li.orderItem oi WHERE li.game.id = :gameId AND li.status != 'REFUNDED'", LibraryItem.class)
                .setParameter("gameId", gameId)
                .list();
    }

    @Transactional(readOnly = true)
    public List<Object[]> getSalesCountGroupByGame() {
        return sessionFactory.getCurrentSession()
                .createQuery("SELECT li.game.id, COUNT(li) FROM LibraryItem li WHERE li.status != 'REFUNDED' GROUP BY li.game.id", Object[].class)
                .list();
    }
}
