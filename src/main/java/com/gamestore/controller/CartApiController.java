package com.gamestore.controller;

import com.gamestore.entity.User;
import com.gamestore.entity.CartItem;
import org.hibernate.Session;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@Controller
@RequestMapping("/api/cart")
@Transactional
public class CartApiController {

    @Autowired
    private org.hibernate.SessionFactory sessionFactory;

    @PostMapping("/add")
    public void addToCart(@RequestParam("gameId") Long gameId,
                          HttpSession session,
                          HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("ERROR=Vui lòng đăng nhập.");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();

        CartItem existing = hqSession.createQuery(
                "FROM CartItem WHERE user.id = :userId AND game.id = :gameId", CartItem.class)
                .setParameter("userId", currentUser.getId())
                .setParameter("gameId", gameId)
                .uniqueResult();

        if (existing != null) {
            out.print("ERROR=Game đã có trong giỏ hàng.");
            return;
        }

        // Kiểm tra xem user đã sở hữu game này chưa — tránh lỗi mua trùng
        String libHql = "FROM LibraryItem WHERE user.id = :userId AND game.id = :gameId AND status = 'ACTIVE'";
        List<?> ownedItems = hqSession.createQuery(libHql)
                .setParameter("userId", currentUser.getId())
                .setParameter("gameId", gameId)
                .getResultList();
        if (!ownedItems.isEmpty()) {
            out.print("ERROR=Bạn đã sở hữu game này rồi. Hãy vào thư viện để tải về!");
            return;
        }

        Object gameObj = hqSession.get("com.gamestore.entity.Game", gameId);
        if (gameObj == null) {
            out.print("ERROR=Game không tồn tại.");
            return;
        }

        CartItem item = new CartItem();
        item.setUser(currentUser);
        item.setGame((com.gamestore.entity.Game) gameObj);
        item.setQuantity(1);
        hqSession.save(item);

        Long count = hqSession
                .createQuery("SELECT COUNT(c) FROM CartItem c WHERE c.user.id = :userId", Long.class)
                .setParameter("userId", currentUser.getId())
                .uniqueResult();

        out.print("OK=Đã thêm vào giỏ hàng.&COUNT=" + (count != null ? count : 0));
    }

    @GetMapping("/count")
    public void getCartCount(HttpSession session, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("COUNT=0");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();
        Long count = hqSession
                .createQuery("SELECT COUNT(c) FROM CartItem c WHERE c.user.id = :userId", Long.class)
                .setParameter("userId", currentUser.getId())
                .uniqueResult();

        out.print("COUNT=" + (count != null ? count : 0));
    }

    @GetMapping("/items")
    public void getCartItems(HttpSession session, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("COUNT=0&IDS=");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();
        List<CartItem> items = hqSession
                .createQuery("SELECT c FROM CartItem c WHERE c.user.id = :userId", CartItem.class)
                .setParameter("userId", currentUser.getId())
                .getResultList();

        StringBuilder ids = new StringBuilder();
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) ids.append(",");
            ids.append(items.get(i).getGame().getId());
        }

        out.print("COUNT=" + items.size() + "&IDS=" + ids.toString());
    }

    @PostMapping("/remove")
    public void removeCartItem(@RequestParam("itemId") Long cartItemId,
                               HttpSession session,
                               HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = (User) session.getAttribute("currentUser");
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

        Long count = hqSession
                .createQuery("SELECT COUNT(c) FROM CartItem c WHERE c.user.id = :userId", Long.class)
                .setParameter("userId", currentUser.getId())
                .uniqueResult();

        out.print("OK=Đã xóa khỏi giỏ hàng.&COUNT=" + (count != null ? count : 0));
    }



    @PostMapping("/remove-by-game")
    public void removeByGame(@RequestParam("gameId") Long gameId,
                             HttpSession session,
                             HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.print("ERROR=Vui lòng đăng nhập.");
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();

        CartItem item = hqSession.createQuery(
                "FROM CartItem WHERE user.id = :userId AND game.id = :gameId", CartItem.class)
                .setParameter("userId", currentUser.getId())
                .setParameter("gameId", gameId)
                .uniqueResult();

        if (item == null) {
            out.print("ERROR=Sản phẩm không có trong giỏ.");
            return;
        }

        if (!item.getUser().getId().equals(currentUser.getId())) {
            out.print("ERROR=Bạn không có quyền xóa sản phẩm này.");
            return;
        }

        hqSession.delete(item);

        Long count = hqSession
                .createQuery("SELECT COUNT(c) FROM CartItem c WHERE c.user.id = :userId", Long.class)
                .setParameter("userId", currentUser.getId())
                .uniqueResult();

        out.print("OK=Đã xóa khỏi giỏ hàng.&COUNT=" + (count != null ? count : 0));
    }
}
