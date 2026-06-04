package com.gamestore.service;

import com.gamestore.dao.SystemSettingDAO;
import com.gamestore.entity.SystemSetting;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.InitializingBean;

import java.math.BigDecimal;

@Service
@Transactional
public class SystemSettingService implements InitializingBean {

    private static final String PLATFORM_COMMISSION_RATE = "PLATFORM_COMMISSION_RATE";

    @Autowired
    private SystemSettingDAO systemSettingDAO;

    @Autowired
    private SessionFactory sessionFactory;

    @Override
    public void afterPropertiesSet() throws Exception {
        initDatabaseColumns();
    }

    public void initDatabaseColumns() {
        org.hibernate.Session session = null;
        org.hibernate.Transaction tx = null;
        try {
            session = sessionFactory.openSession();
            tx = session.beginTransaction();
            
            // Check if notifications table exists and alter columns if they are varchar (system_type_id = 167)
            session.createNativeQuery(
                "IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('notifications') AND name = 'title' AND system_type_id = 167) " +
                "ALTER TABLE notifications ALTER COLUMN title NVARCHAR(255) NOT NULL"
            ).executeUpdate();
            
            session.createNativeQuery(
                "IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('notifications') AND name = 'content' AND system_type_id = 167) " +
                "ALTER TABLE notifications ALTER COLUMN content NVARCHAR(MAX) NOT NULL"
            ).executeUpdate();

            session.createNativeQuery(
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('patch_notes') AND name = 'status') " +
                "ALTER TABLE patch_notes ADD status NVARCHAR(50) NOT NULL DEFAULT 'PENDING'"
            ).executeUpdate();

            session.createNativeQuery(
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('games') AND name = 'approvedAt') " +
                "ALTER TABLE games ADD approvedAt DATETIME NULL"
            ).executeUpdate();

            session.createNativeQuery(
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('games') AND name = 'approvedBy') " +
                "ALTER TABLE games ADD approvedBy NVARCHAR(255) NULL"
            ).executeUpdate();

            // Loại bỏ check constraint status của bảng games nếu có để tránh chặn trạng thái PENDING_DELETE và DELETED
            session.createNativeQuery(
                "IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CK_games_status]') AND type = 'C') " +
                "ALTER TABLE games DROP CONSTRAINT CK_games_status"
            ).executeUpdate();

            // Promo codes columns
            session.createNativeQuery(
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('promo_codes') AND name = 'current_usage') " +
                "ALTER TABLE promo_codes ADD current_usage INT NOT NULL DEFAULT 0"
            ).executeUpdate();

            session.createNativeQuery(
                "IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('promo_codes') AND name = 'current_usage' AND is_nullable = 1) BEGIN " +
                "UPDATE promo_codes SET current_usage = 0 WHERE current_usage IS NULL; " +
                "ALTER TABLE promo_codes ALTER COLUMN current_usage INT NOT NULL; " +
                "END"
            ).executeUpdate();

            session.createNativeQuery(
                "IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('promo_codes') AND name = 'discount_percentage') " +
                "ALTER TABLE promo_codes ADD discount_percentage NUMERIC(5,2) NOT NULL DEFAULT 0"
            ).executeUpdate();

            session.createNativeQuery(
                "IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('promo_codes') AND name = 'discount_percentage' AND is_nullable = 1) BEGIN " +
                "UPDATE promo_codes SET discount_percentage = 0 WHERE discount_percentage IS NULL; " +
                "ALTER TABLE promo_codes ALTER COLUMN discount_percentage NUMERIC(5,2) NOT NULL; " +
                "END"
            ).executeUpdate();

            // Cho phép license_key_id nullable trong library_items
            session.createNativeQuery(
                "IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('library_items') AND name = 'license_key_id' AND is_nullable = 0) " +
                "ALTER TABLE library_items ALTER COLUMN license_key_id BIGINT NULL"
            ).executeUpdate();
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null) {
                try { tx.rollback(); } catch (Exception ex) {}
            }
            System.err.println("Lỗi tự động cập nhật cột notifications sang NVARCHAR: " + e.getMessage());
        } finally {
            if (session != null) {
                try { session.close(); } catch (Exception ex) {}
            }
        }
    }

    public BigDecimal getPlatformCommissionRate() {
        SystemSetting setting = systemSettingDAO.findByKey(PLATFORM_COMMISSION_RATE);
        if (setting == null || setting.getSettingValue() == null) {
            return new BigDecimal("10.00");
        }
        try {
            return new BigDecimal(setting.getSettingValue());
        } catch (NumberFormatException e) {
            return new BigDecimal("10.00");
        }
    }

    public void updatePlatformCommissionRate(BigDecimal rate) {
        if (rate == null) {
            throw new IllegalArgumentException("Tỷ lệ hoa hồng không được để trống.");
        }
        if (rate.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Tỷ lệ hoa hồng không được nhỏ hơn 0%.");
        }
        if (rate.compareTo(new BigDecimal("100")) > 0) {
            throw new IllegalArgumentException("Tỷ lệ hoa hồng không được lớn hơn 100%.");
        }
        SystemSetting setting = systemSettingDAO.findByKey(PLATFORM_COMMISSION_RATE);
        if (setting == null) {
            setting = new SystemSetting();
            setting.setSettingKey(PLATFORM_COMMISSION_RATE);
        }
        setting.setSettingValue(rate.toPlainString());
        systemSettingDAO.saveOrUpdate(setting);
    }
}
