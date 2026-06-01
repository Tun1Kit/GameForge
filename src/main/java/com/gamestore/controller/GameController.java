package com.gamestore.controller;

import java.util.List;
import javax.servlet.http.HttpSession;
import java.math.BigDecimal;

import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.gamestore.entity.Game;
import com.gamestore.entity.User;
import com.gamestore.entity.CartItem;
import com.gamestore.entity.Order;

@Controller
@Transactional
public class GameController {

    @Autowired
    private SessionFactory sessionFactory;

    @RequestMapping(value = {"/", "/home"}, method = RequestMethod.GET)
    public String index(ModelMap model, HttpSession session) {
        List<Game> listGames = sessionFactory.getCurrentSession()
                                             .createQuery("from Game where status = 'ACTIVE'", Game.class)
                                             .list();
        model.addAttribute("games", listGames);

        User currentUser = (User) session.getAttribute("currentUser");
        model.addAttribute("currentUser", currentUser);
        if (currentUser != null) {
            BigDecimal walletBalance = BigDecimal.ZERO;
            try {
                Object result = sessionFactory.getCurrentSession()
                        .createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
                        .setParameter("uid", currentUser.getId())
                        .uniqueResult();
                if (result != null) {
                    walletBalance = (result instanceof BigDecimal) 
                            ? (BigDecimal) result 
                            : new BigDecimal(result.toString());
                }
            } catch (Exception e) {
                // Wallet does not exist or SQL error
            }
            model.addAttribute("walletBalance", walletBalance);

            // Lấy danh sách ID các game đã sở hữu của user
            List<Long> ownedGameIds = sessionFactory.getCurrentSession()
                    .createQuery("SELECT li.game.id FROM LibraryItem li WHERE li.user.id = :uid AND li.status = 'ACTIVE'", Long.class)
                    .setParameter("uid", currentUser.getId())
                    .getResultList();
            model.addAttribute("ownedGameIds", ownedGameIds);
        }

        return "index";
    }

    @RequestMapping(value = "/api/admin/generate-keys", method = RequestMethod.GET, produces = "text/plain;charset=UTF-8")
    @org.springframework.web.bind.annotation.ResponseBody
    public String generateKeys() {
        org.hibernate.Session session = sessionFactory.getCurrentSession();
        List<Game> games = session.createQuery("from Game", Game.class).list();
        int totalGenerated = 0;
        for (Game game : games) {
            for (int i = 0; i < 500; i++) {
                com.gamestore.entity.LicenseKey key = new com.gamestore.entity.LicenseKey();
                key.setGame(game);
                // Create a realistic looking CD-Key format (e.g. A1B2C-D3E4F-G5H6I)
                String uuid = java.util.UUID.randomUUID().toString().toUpperCase().replace("-", "");
                String keyString = uuid.substring(0,5) + "-" + uuid.substring(5,10) + "-" + uuid.substring(10,15);
                key.setKeyString(keyString);
                key.setStatus("AVAILABLE");
                key.setCreatedAt(java.time.LocalDateTime.now());
                session.save(key);
                totalGenerated++;
            }
        }
        return "Tạo thành công " + totalGenerated + " keys cho " + games.size() + " tựa game!";
    }
}
