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
    public List<PayoutRequest> findAllOrderByNewest() {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM PayoutRequest p ORDER BY p.requestedAt DESC", PayoutRequest.class)
                .list();
    }

    @Transactional(readOnly = true)
    public List<PayoutRequest> findByPublisherId(Long publisherId) {
        return sessionFactory.getCurrentSession()
                .createQuery(
                        "FROM PayoutRequest p WHERE p.publisher.id = :publisherId ORDER BY p.requestedAt DESC",
                        PayoutRequest.class)
                .setParameter("publisherId", publisherId)
                .list();
    }
}
