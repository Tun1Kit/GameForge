package com.gamestore.dao;

import com.gamestore.entity.LicenseKey;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class LicenseKeyDAO extends BaseDAO<LicenseKey> {

    public LicenseKeyDAO() {
        setClazz(LicenseKey.class);
    }

    @Transactional(readOnly = true)
    public LicenseKey findAvailableByGameId(Long gameId) {
        List<LicenseKey> keys = sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM LicenseKey lk WHERE lk.game.id = :gameId AND lk.status = 'AVAILABLE' ORDER BY lk.createdAt ASC",
                        LicenseKey.class)
                .setParameter("gameId", gameId)
                .setMaxResults(1)
                .list();
        return keys.isEmpty() ? null : keys.get(0);
    }

    @Transactional(readOnly = true)
    public Long countAvailableByGameId(Long gameId) {
        Long result = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT COUNT(lk.id) FROM LicenseKey lk WHERE lk.game.id = :gameId AND lk.status = 'AVAILABLE'",
                        Long.class)
                .setParameter("gameId", gameId)
                .uniqueResult();
        return result == null ? 0L : result;
    }
}
