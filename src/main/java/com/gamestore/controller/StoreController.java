package com.gamestore.controller;

import com.gamestore.dao.GameDAO;
import com.gamestore.entity.Game;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("/game")
public class StoreController {

    @Autowired
    private GameDAO gameDAO;

    // Cấu trúc URL động chuẩn hóa theo nhánh game: /game/{gameSlug}
    @RequestMapping(value = "/{gameSlug}", method = RequestMethod.GET)
    public String viewGameDetail(@PathVariable("gameSlug") String gameSlug, Model model) {

        // Truy vấn dữ liệu thực tế từ SQL Server
        Game game = gameDAO.findBySlug(gameSlug);

        // Nếu gõ sai đường dẫn hoặc game không tồn tại, trả về trang lỗi 404 của Kiệt
        if (game == null) {
            return "errors/404";
        }

        // Đóng gói đối tượng chuyển tiếp sang detail.jsp
        model.addAttribute("game", game);

        return "store/detail";
    }
}