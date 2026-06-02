package com.gamestore.controller;

import java.util.List;


import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.gamestore.entity.Game;

@Controller
@Transactional
public class GameController {

    @Autowired
    private SessionFactory sessionFactory;

    @RequestMapping(value = {"/", "/home"}, method = RequestMethod.GET)
    public String index(ModelMap model) {
        List<Game> listGames = sessionFactory.getCurrentSession()
                                             .createQuery("from Game where status = 'ACTIVE'", Game.class)
                                             .list();
        model.addAttribute("games", listGames);
        return "index";
    }
}
