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
                    .createQuery(
                            "SELECT DISTINCT u " +
                            "FROM User u " +
                            "LEFT JOIN FETCH u.roles " +
                            "WHERE u.email = :email " +
                            "AND u.status = 'ACTIVE'",
                            User.class)
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
                    .createQuery(
                            "SELECT DISTINCT u " +
                            "FROM User u " +
                            "LEFT JOIN FETCH u.roles " +
                            "WHERE u.username = :username " +
                            "AND u.status = 'ACTIVE'",
                            User.class)
                    .setParameter("username", username)
                    .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }

    @Transactional(readOnly = true)
    public User findById(Long id) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT u " +
                        "FROM User u " +
                        "LEFT JOIN FETCH u.roles " +
                        "WHERE u.id = :id",
                        User.class)
                .setParameter("id", id)
                .uniqueResult();
    }

    @Transactional(readOnly = true)
    public boolean existsByUsername(String username) {
        try {
            Long count = sessionFactory.getCurrentSession()
                    .createQuery(
                            "SELECT COUNT(u) FROM User u WHERE u.username = :username",
                            Long.class)
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
                .createQuery(
                        "SELECT DISTINCT u " +
                        "FROM User u " +
                        "LEFT JOIN FETCH u.roles " +
                        "ORDER BY u.createdAt DESC",
                        User.class)
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