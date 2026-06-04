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

    @Transactional(readOnly = true)
    public List<PatchNote> findActiveByGameId(Long gameId) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM PatchNote pn WHERE pn.game.id = :gameId AND pn.status = 'ACTIVE' ORDER BY pn.publishedAt DESC", PatchNote.class)
                    .setParameter("gameId", gameId)
                    .list();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Transactional(readOnly = true)
    public List<PatchNote> findPendingPatchNotes() {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM PatchNote pn JOIN FETCH pn.game g LEFT JOIN FETCH g.publisher p WHERE pn.status = 'PENDING' ORDER BY pn.publishedAt DESC", PatchNote.class)
                .list();
    }

    @Transactional
    public void rejectOlderPendingPatchNotes(Long gameId, Long noteId) {
        sessionFactory.getCurrentSession()
                .createQuery("UPDATE PatchNote pn SET pn.status = 'REJECTED' WHERE pn.game.id = :gameId AND pn.status = 'PENDING' AND pn.id < :noteId")
                .setParameter("gameId", gameId)
                .setParameter("noteId", noteId)
                .executeUpdate();
    }
}
