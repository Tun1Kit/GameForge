package com.gamestore.controller;

import com.gamestore.dao.LibraryItemDAO;
import com.gamestore.dao.OrderItemDAO;
import com.gamestore.entity.Game;
import com.gamestore.entity.User;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.List;

@Controller
@Transactional
public class GameController {

    @Autowired
    private SessionFactory sessionFactory;

    @Autowired
    private WalletService walletService;

    @Autowired
    private LibraryItemDAO libraryItemDAO;

    @Autowired
    private OrderItemDAO orderItemDAO;

    @Autowired
    private UserContextService userContextService;

    @RequestMapping(value = {"/", "/home"}, method = RequestMethod.GET)
    public String index(ModelMap model, HttpSession session) {
        List<Game> listGames = sessionFactory.getCurrentSession()
                .createQuery("from Game where status = 'ACTIVE'", Game.class)
                .list();
        model.addAttribute("games", listGames);

        User currentUser = userContextService.getCurrentUser(session);
        model.addAttribute("currentUser", currentUser);
        if (currentUser != null) {
            BigDecimal walletBalance = walletService.getBalance(currentUser);
            model.addAttribute("walletBalance", walletBalance);

            List<Long> ownedGameIds = libraryItemDAO.findOwnedGameIds(currentUser.getId());
            List<Long> paidGameIds = orderItemDAO.findPaidGameIds(currentUser.getId());
            java.util.Set<Long> uniqueOwnedIds = new java.util.HashSet<>(ownedGameIds);
            uniqueOwnedIds.addAll(paidGameIds);
            model.addAttribute("ownedGameIds", new java.util.ArrayList<>(uniqueOwnedIds));
        }

        return "index";
    }

    @RequestMapping(value = "/api/admin/generate-keys", method = RequestMethod.GET, produces = "text/plain;charset=UTF-8")
    @org.springframework.web.bind.annotation.ResponseBody
    public String generateKeys() {
        org.hibernate.Session hqSession = sessionFactory.getCurrentSession();
        List<Game> games = hqSession.createQuery("from Game", Game.class).list();
        int totalGenerated = 0;
        for (Game game : games) {
            for (int i = 0; i < 500; i++) {
                com.gamestore.entity.LicenseKey key = new com.gamestore.entity.LicenseKey();
                key.setGame(game);
                String uuid = java.util.UUID.randomUUID().toString().toUpperCase().replace("-", "");
                String keyString = uuid.substring(0,5) + "-" + uuid.substring(5,10) + "-" + uuid.substring(10,15);
                key.setKeyString(keyString);
                key.setStatus("AVAILABLE");
                key.setCreatedAt(java.time.LocalDateTime.now());
                hqSession.save(key);
                totalGenerated++;
            }
        }
        return "Tạo thành công " + totalGenerated + " keys cho " + games.size() + " tựa game!";
    }
}
