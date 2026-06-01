package com.gamestore.dao;

import com.gamestore.entity.User;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class UserDAO extends BaseDAO<User> {
    
    public UserDAO() {
        setClazz(User.class);
    }

    // Truy vấn người dùng theo Email (Chỉ lấy tài khoản đang ACTIVE)
    public User findByEmail(String email) {
        try {
            return sessionFactory.getCurrentSession()
                .createQuery("FROM User WHERE email = :email AND status = 'ACTIVE'", User.class)
                .setParameter("email", email)
                .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }

    // Truy vấn người dùng theo Username (Chỉ lấy tài khoản đang ACTIVE)
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

    // Kiểm tra username đã tồn tại chưa
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
}
