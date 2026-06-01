package com.gamestore.dao;

import com.gamestore.entity.Game;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class GameDAO extends BaseDAO<Game> {

    public GameDAO() {
        setClazz(Game.class);
    }

    @Transactional(readOnly = true)
    public Game findBySlug(String slug) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM Game g WHERE g.slug = :slug", Game.class)
                    .setParameter("slug", slug)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Transactional(readOnly = true)
    public List<Game> findActiveGames() {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM Game g WHERE g.status = 'ACTIVE' ORDER BY g.id DESC",
                        Game.class)
                .list();
    }

    @Transactional(readOnly = true)
    public Game findActiveById(Long id) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery(
                            "FROM Game g WHERE g.id = :id AND g.status = 'ACTIVE'",
                            Game.class)
                    .setParameter("id", id)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
