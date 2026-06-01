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
}
