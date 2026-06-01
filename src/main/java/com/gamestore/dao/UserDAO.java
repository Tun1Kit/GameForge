package com.gamestore.dao;

import com.gamestore.entity.User;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class UserDAO extends BaseDAO<User> {

    public UserDAO() {
        setClazz(User.class);
    }

    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM User WHERE email = :email AND status = 'ACTIVE'", User.class)
                    .setParameter("email", email)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Transactional(readOnly = true)
    public User findByUsername(String username) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM User WHERE username = :username AND status = 'ACTIVE'", User.class)
                    .setParameter("username", username)
                    .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }

    @Transactional(readOnly = true)
    public boolean existsByUsername(String username) {
        try {
            Long count = sessionFactory.getCurrentSession()
                    .createQuery("SELECT COUNT(u) FROM User u WHERE username = :username", Long.class)
                    .setParameter("username", username)
                    .uniqueResult();
            return count != null && count > 0;
        } catch (Exception e) {
            return false;
        }
    }

    @Transactional(readOnly = true)
    public List<User> findAllUsers() {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM User u ORDER BY u.createdAt DESC", User.class)
                .list();
    }

    @Transactional
    public void changeStatus(Long userId, String status) {
        User user = findById(userId);
        if (user != null) {
            user.setStatus(status);
            update(user);
        }
    }
}
