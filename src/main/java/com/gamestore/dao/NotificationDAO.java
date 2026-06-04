package com.gamestore.dao;

import com.gamestore.entity.Notification;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Repository
@Transactional
public class NotificationDAO extends BaseDAO<Notification> {
    public NotificationDAO() {
        setClazz(Notification.class);
    }

    public List<Notification> findByUser(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM Notification n WHERE n.user.id = :userId ORDER BY n.createdAt DESC", Notification.class)
                .setParameter("userId", userId)
                .list();
    }

    public List<Notification> findAdmins() {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM Notification n WHERE n.user IS NULL ORDER BY n.createdAt DESC", Notification.class)
                .list();
    }

    public long countUnreadByUser(Long userId) {
        return sessionFactory.getCurrentSession()
                .createQuery("SELECT COUNT(n.id) FROM Notification n WHERE n.user.id = :userId AND n.read = false", Long.class)
                .setParameter("userId", userId)
                .uniqueResult();
    }

    public long countUnreadForAdmins() {
        return sessionFactory.getCurrentSession()
                .createQuery("SELECT COUNT(n.id) FROM Notification n WHERE n.user IS NULL AND n.read = false", Long.class)
                .uniqueResult();
    }
}
