package com.gamestore.dao;

import java.util.List;

import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;

public abstract class BaseDAO<T> {
    @Autowired
    protected SessionFactory sessionFactory;

    private Class<T> clazz;

    public void setClazz(Class<T> clazz) {
        this.clazz = clazz;
    }

    public List<T> findAll() {
        return sessionFactory.getCurrentSession()
                             .createQuery("from " + clazz.getName(), clazz)
                             .list();
    }

    public T findById(Long id) {
        return sessionFactory.getCurrentSession().get(clazz, id);
    }
    
    public void save(T entity) {
        sessionFactory.getCurrentSession().save(entity);
    }
    // Thêm các hàm save, update, delete dùng chung ở đây
}
