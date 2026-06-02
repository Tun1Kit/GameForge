package com.gamestore.dao;

import com.gamestore.entity.Review;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
@Transactional
public class ReviewDAO extends BaseDAO<Review> {

    public ReviewDAO() {
        setClazz(Review.class);
    }

    /**
     * Lấy danh sách đánh giá của game, nạp kèm User để tránh N+1 queries.
     */
    @Transactional(readOnly = true)
    public List<Review> findByGame(Long gameId) {
        return sessionFactory.getCurrentSession()
                .createQuery("FROM Review r WHERE r.game.id = :gameId ORDER BY r.createdAt DESC", Review.class)
                .setParameter("gameId", gameId)
                .getResultList();
    }

    /**
     * Kiểm tra xem user đã review game này chưa.
     */
    @Transactional(readOnly = true)
    public Review findByUserAndGame(Long userId, Long gameId) {
        try {
            return sessionFactory.getCurrentSession()
                    .createQuery("FROM Review r WHERE r.user.id = :userId AND r.game.id = :gameId", Review.class)
                    .setParameter("userId", userId)
                    .setParameter("gameId", gameId)
                    .uniqueResult();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Lấy điểm đánh giá trung bình và số lượng của game.
     * Trả về mảng Object: [Double avgRating, Long count]
     */
    @Transactional(readOnly = true)
    public Object[] getAverageRatingAndCount(Long gameId) {
        try {
            return (Object[]) sessionFactory.getCurrentSession()
                    .createQuery("SELECT AVG(CAST(r.rating as double)), COUNT(r) FROM Review r WHERE r.game.id = :gameId")
                    .setParameter("gameId", gameId)
                    .uniqueResult();
        } catch (Exception e) {
            return new Object[]{0.0, 0L};
        }
    }
}
