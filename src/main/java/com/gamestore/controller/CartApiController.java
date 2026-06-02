package com.gamestore.controller;

import com.gamestore.dao.CartItemDAO;
import com.gamestore.dao.LibraryItemDAO;
import com.gamestore.entity.CartItem;
import com.gamestore.entity.Game;
import com.gamestore.entity.User;
import com.gamestore.service.UserContextService;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@Controller
@RequestMapping("/api/cart")
@Transactional
public class CartApiController {

    @Autowired
    private org.hibernate.SessionFactory sessionFactory;

    @Autowired
    private CartItemDAO cartItemDAO;

    @Autowired
    private LibraryItemDAO libraryItemDAO;

    @Autowired
    private UserContextService userContextService;

    private void setJsonContentType(HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
    }

    @PostMapping("/add")
    public void addToCart(@RequestParam("gameId") Long gameId,
                          HttpSession session,
                          HttpServletResponse response) throws IOException {
        setJsonContentType(response);
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("ERROR=Vui lòng đăng nhập.");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();

        if (cartItemDAO.findByUserAndGame(currentUser.getId(), gameId) != null) {
            out.print("ERROR=Game đã có trong giỏ hàng.");
            return;
        }

        if (libraryItemDAO.existsActiveByUserAndGame(currentUser.getId(), gameId)) {
            out.print("ERROR=Bạn đã sở hữu game này rồi. Hãy vào thư viện để tải về!");
            return;
        }

        Game game = hqSession.get(Game.class, gameId);
        if (game == null) {
            out.print("ERROR=Game không tồn tại.");
            return;
        }

        CartItem item = new CartItem();
        item.setUser(currentUser);
        item.setGame(game);
        item.setQuantity(1);
        hqSession.save(item);

        long count = cartItemDAO.getCartCount(currentUser.getId());

        out.print("OK=Đã thêm vào giỏ hàng.&COUNT=" + count);
    }

    @GetMapping("/count")
    public void getCartCount(HttpSession session, HttpServletResponse response) throws IOException {
        setJsonContentType(response);
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("COUNT=0");
            return;
        }

        long count = cartItemDAO.getCartCount(currentUser.getId());

        out.print("COUNT=" + count);
    }

    @GetMapping("/items")
    public void getCartItems(HttpSession session, HttpServletResponse response) throws IOException {
        setJsonContentType(response);
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("COUNT=0&IDS=");
            return;
        }

        java.util.List<Long> gameIds = cartItemDAO.getCartGameIds(currentUser.getId());

        StringBuilder ids = new StringBuilder();
        for (int i = 0; i < gameIds.size(); i++) {
            if (i > 0) ids.append(",");
            ids.append(gameIds.get(i));
        }

        out.print("COUNT=" + gameIds.size() + "&IDS=" + ids.toString());
    }

    @PostMapping("/remove")
    public void removeCartItem(@RequestParam("itemId") Long cartItemId,
                               HttpSession session,
                               HttpServletResponse response) throws IOException {
        setJsonContentType(response);
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("ERROR=Vui lòng đăng nhập.");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();

        CartItem item = hqSession.get(CartItem.class, cartItemId);

        if (item == null) {
            out.print("ERROR=Sản phẩm không có trong giỏ.");
            return;
        }

        if (!item.getUser().getId().equals(currentUser.getId())) {
            out.print("ERROR=Bạn không có quyền xóa sản phẩm này.");
            return;
        }

        hqSession.delete(item);

        long count = cartItemDAO.getCartCount(currentUser.getId());

        out.print("OK=Đã xóa khỏi giỏ hàng.&COUNT=" + count);
    }

    @PostMapping("/remove-by-game")
    public void removeByGame(@RequestParam("gameId") Long gameId,
                             HttpSession session,
                             HttpServletResponse response) throws IOException {
        setJsonContentType(response);
        PrintWriter out = response.getWriter();

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            out.print("ERROR=Vui lòng đăng nhập.");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();

        CartItem item = cartItemDAO.findByUserAndGame(currentUser.getId(), gameId);

        if (item == null) {
            out.print("ERROR=Sản phẩm không có trong giỏ.");
            return;
        }

        if (!item.getUser().getId().equals(currentUser.getId())) {
            out.print("ERROR=Bạn không có quyền xóa sản phẩm này.");
            return;
        }

        hqSession.delete(item);

        long count = cartItemDAO.getCartCount(currentUser.getId());

        out.print("OK=Đã xóa khỏi giỏ hàng.&COUNT=" + count);
    }
}
