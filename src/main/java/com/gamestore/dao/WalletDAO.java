package com.gamestore.dao;

import com.gamestore.entity.Wallet;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class WalletDAO extends BaseDAO<Wallet> {

    public WalletDAO() {
        setClazz(Wallet.class);
    }

    @Transactional(readOnly = true)
    public Wallet findByUserId(Long userId) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM Wallet w WHERE w.user.id = :userId", Wallet.class)
                    .setParameter("userId", userId)
                    .uniqueResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
