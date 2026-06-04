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
        return sessionFactory.getCurrentSession()
                             .createQuery("from " + clazz.getName() + " where id = :id", clazz)
                             .setParameter("id", id)
                             .uniqueResult();
    }
    
    public void save(T entity) {
        sessionFactory.getCurrentSession().save(entity);
    }

    public void update(T entity) {
        sessionFactory.getCurrentSession().update(entity);
    }

    public void saveOrUpdate(T entity) {
        sessionFactory.getCurrentSession().saveOrUpdate(entity);
    }

    public void deleteById(Long id) {
        sessionFactory.getCurrentSession()
                      .createQuery("delete from " + clazz.getName() + " where id = :id")
                      .setParameter("id", id)
                      .executeUpdate();
    }

    public void flush() {
        sessionFactory.getCurrentSession().flush();
    }
}
