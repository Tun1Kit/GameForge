package com.gamestore.dao;

import com.gamestore.entity.GameMedia;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class GameMediaDAO extends BaseDAO<GameMedia> {
    public GameMediaDAO() {
        setClazz(GameMedia.class);
    }
}
