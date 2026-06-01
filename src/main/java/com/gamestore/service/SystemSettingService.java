package com.gamestore.service;

import com.gamestore.dao.SystemSettingDAO;
import com.gamestore.entity.SystemSetting;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@Transactional
public class SystemSettingService {

    private static final String PLATFORM_COMMISSION_RATE = "PLATFORM_COMMISSION_RATE";

    @Autowired
    private SystemSettingDAO systemSettingDAO;

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
