package com.gamestore.dao;

import com.gamestore.entity.PublisherProfile;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class PublisherProfileDAO extends BaseDAO<PublisherProfile> {

    public PublisherProfileDAO() {
        setClazz(PublisherProfile.class);
    }

    @Transactional(readOnly = true)
    public PublisherProfile findByUserId(Long userId) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery(
                            "FROM PublisherProfile p WHERE p.user.id = :userId",
                            PublisherProfile.class)
                    .setParameter("userId", userId)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
