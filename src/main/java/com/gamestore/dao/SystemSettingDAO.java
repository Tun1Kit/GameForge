package com.gamestore.dao;

import com.gamestore.entity.SystemSetting;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional
public class SystemSettingDAO extends BaseDAO<SystemSetting> {

    public SystemSettingDAO() {
        setClazz(SystemSetting.class);
    }

    @Transactional(readOnly = true)
    public SystemSetting findByKey(String key) {
        return sessionFactory.getCurrentSession().get(SystemSetting.class, key);
    }

    public void saveOrUpdate(SystemSetting setting) {
        sessionFactory.getCurrentSession().saveOrUpdate(setting);
    }
}
