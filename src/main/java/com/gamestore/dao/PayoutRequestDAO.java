package com.gamestore.dao;

import com.gamestore.entity.PayoutRequest;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class PayoutRequestDAO extends BaseDAO<PayoutRequest> {

    public PayoutRequestDAO() {
        setClazz(PayoutRequest.class);
    }

    @Transactional(readOnly = true)
    public PayoutRequest findById(Long id) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT p " +
                        "FROM PayoutRequest p " +
                        "LEFT JOIN FETCH p.publisher pub " +
                        "LEFT JOIN FETCH pub.user " +
                        "WHERE p.id = :id",
                        PayoutRequest.class)
                .setParameter("id", id)
                .uniqueResult();
    }

    @Transactional(readOnly = true)
    public List<PayoutRequest> findAllOrderByNewest() {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT p " +
                        "FROM PayoutRequest p " +
                        "LEFT JOIN FETCH p.publisher pub " +
                        "LEFT JOIN FETCH pub.user " +
                        "ORDER BY p.requestedAt DESC",
                        PayoutRequest.class)
                .list();
    }

    @Transactional(readOnly = true)
    public List<PayoutRequest> findByPublisherId(Long publisherId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT p " +
                        "FROM PayoutRequest p " +
                        "LEFT JOIN FETCH p.publisher pub " +
                        "LEFT JOIN FETCH pub.user " +
                        "WHERE pub.id = :publisherId " +
                        "ORDER BY p.requestedAt DESC",
                        PayoutRequest.class)
                .setParameter("publisherId", publisherId)
                .list();
    }

    @Transactional(readOnly = true)
    public List<PayoutRequest> findByStatusOrderByNewest(String status) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "SELECT DISTINCT p " +
                        "FROM PayoutRequest p " +
                        "LEFT JOIN FETCH p.publisher pub " +
                        "LEFT JOIN FETCH pub.user " +
                        "WHERE UPPER(TRIM(p.status)) = UPPER(TRIM(:status)) " +
                        "ORDER BY p.requestedAt DESC",
                        PayoutRequest.class)
                .setParameter("status", status)
                .list();
    }
}