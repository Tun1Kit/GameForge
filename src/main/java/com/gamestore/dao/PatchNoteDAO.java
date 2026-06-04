package com.gamestore.dao;

import com.gamestore.entity.PatchNote;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class PatchNoteDAO extends BaseDAO<PatchNote> {

    public PatchNoteDAO() {
        setClazz(PatchNote.class);
    }

    @Transactional(readOnly = true)
    public List<PatchNote> findByGameId(Long gameId) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM PatchNote p WHERE p.game.id = :gameId ORDER BY p.publishedAt DESC", PatchNote.class)
                    .setParameter("gameId", gameId)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
