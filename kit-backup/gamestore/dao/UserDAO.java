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
            return null; // Nếu không tìm thấy hoặc lỗi thì trả về null
        }
    }
}
