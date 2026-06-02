package com.gamestore.dao;

import com.gamestore.entity.Game;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class GameDAO extends BaseDAO<Game> {
    
    public GameDAO() {
        setClazz(Game.class);
    }

    public Game findBySlug(String slug) {
        try {
            return sessionFactory.getCurrentSession()
                .createQuery("FROM Game g WHERE g.slug = :slug AND g.status = 'ACTIVE'", Game.class)
                .setParameter("slug", slug)
                .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}