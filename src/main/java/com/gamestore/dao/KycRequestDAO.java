package com.gamestore.dao;

import com.gamestore.entity.KycRequest;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class KycRequestDAO extends BaseDAO<KycRequest> {

    public KycRequestDAO() {
        setClazz(KycRequest.class);
    }

    @Transactional(readOnly = true)
    public KycRequest findById(Long id) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT k " +
                        "FROM KycRequest k " +
                        "LEFT JOIN FETCH k.user " +
                        "WHERE k.id = :id",
                        KycRequest.class)
                .setParameter("id", id)
                .uniqueResult();
    }

    @Transactional(readOnly = true)
    public KycRequest findLatestByUserId(Long userId) {
        List<KycRequest> list = sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT k " +
                        "FROM KycRequest k " +
                        "LEFT JOIN FETCH k.user " +
                        "WHERE k.user.id = :userId " +
                        "ORDER BY k.submittedAt DESC",
                        KycRequest.class)
                .setParameter("userId", userId)
                .setMaxResults(1)
                .list();

        return list.isEmpty() ? null : list.get(0);
    }

    @Transactional(readOnly = true)
    public List<KycRequest> findAllOrderByNewest() {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT k " +
                        "FROM KycRequest k " +
                        "LEFT JOIN FETCH k.user " +
                        "ORDER BY k.submittedAt DESC",
                        KycRequest.class)
                .list();
    }

    @Transactional(readOnly = true)
    public List<KycRequest> findPendingRequests() {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT k " +
                        "FROM KycRequest k " +
                        "LEFT JOIN FETCH k.user " +
                        "WHERE UPPER(TRIM(k.status)) = 'PENDING' " +
                        "ORDER BY k.submittedAt DESC",
                        KycRequest.class)
                .list();
    }

    @Transactional(readOnly = true)
    public List<KycRequest> findByStatusOrderByNewest(String status) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT k " +
                        "FROM KycRequest k " +
                        "LEFT JOIN FETCH k.user " +
                        "WHERE UPPER(TRIM(k.status)) = UPPER(TRIM(:status)) " +
                        "ORDER BY k.submittedAt DESC",
                        KycRequest.class)
                .setParameter("status", status)
                .list();
    }
}