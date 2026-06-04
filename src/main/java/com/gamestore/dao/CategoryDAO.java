package com.gamestore.dao;

import com.gamestore.entity.Category;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class CategoryDAO extends BaseDAO<Category> {

    public CategoryDAO() {
        setClazz(Category.class);
    }
}
