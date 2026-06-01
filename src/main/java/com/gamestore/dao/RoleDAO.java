package com.gamestore.dao;

import com.gamestore.entity.Role;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class RoleDAO extends BaseDAO<Role> {

    public RoleDAO() {
        setClazz(Role.class);
    }

    @Transactional(readOnly = true)
    public Role findByCode(String code) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM Role WHERE code = :code", Role.class)
                    .setParameter("code", code)
                    .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }
}
