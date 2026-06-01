package com.gamestore.controller;

import com.gamestore.entity.PromoCode;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@Controller
@RequestMapping("/api/promo")
@Transactional
public class PromoApiController {

    @Autowired
    private org.hibernate.SessionFactory sessionFactory;

    /**
     * Lấy danh sách promo codes theo game IDs trong giỏ hàng
     */
    @GetMapping("/by-games")
    public void getPromosByGames(
            @RequestParam("gameIds") String gameIds,
            HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (gameIds == null || gameIds.trim().isEmpty()) {
            out.print("[]");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();

        List<PromoCode> promos = hqSession
                .createQuery("FROM PromoCode WHERE gameId IN (:gameIds) AND status = 'ACTIVE'", PromoCode.class)
                .setParameterList("gameIds", parseGameIds(gameIds))
                .getResultList();

        // Filter expired
        promos.removeIf(p ->
            p.getExpiryDate() != null && p.getExpiryDate().isBefore(java.time.LocalDateTime.now())
        );

        // Filter usage limit
        promos.removeIf(p ->
            p.getUsageLimit() != null && p.getCurrentUsage() >= p.getUsageLimit()
        );

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < promos.size(); i++) {
            PromoCode p = promos.get(i);
            if (i > 0) json.append(",");
            json.append("{")
                .append("\"code\":\"").append(escapeJson(p.getCode())).append("\",")
                .append("\"gameId\":").append(p.getGameId()).append(",")
                .append("\"discountPercentage\":").append(p.getDiscountPercentage())
                .append("}");
        }
        json.append("]");
        out.print(json.toString());
    }

    private List<Long> parseGameIds(String gameIds) {
        java.util.List<Long> result = new java.util.ArrayList<>();
        for (String id : gameIds.split(",")) {
            try {
                result.add(Long.parseLong(id.trim()));
            } catch (NumberFormatException e) {
                // skip invalid
            }
        }
        return result;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
