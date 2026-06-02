package com.gamestore.service;

import com.gamestore.dao.CartItemDAO;
import com.gamestore.dao.LibraryItemDAO;
import com.gamestore.entity.CartItem;
import com.gamestore.entity.Game;
import com.gamestore.entity.User;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class CartService {

    @Autowired
    private CartItemDAO cartItemDAO;

    @Autowired
    private LibraryItemDAO libraryItemDAO;

    @Autowired
    private SessionFactory sessionFactory;

    /**
     * Lấy danh sách cart items kèm game đã fetch sẵn.
     * Thay thế 8 đoạn trùng lặp trong DashboardController, CheckoutController, CartApiController.
     */
    @Transactional(readOnly = true)
    public List<CartItem> getCartItems(Long userId) {
        return cartItemDAO.getCartItems(userId);
    }

    /**
     * Đếm số item trong giỏ hàng.
     */
    @Transactional(readOnly = true)
    public long getCartCount(Long userId) {
        return cartItemDAO.getCartCount(userId);
    }

    /**
     * Lấy danh sách game ID trong giỏ hàng.
     */
    @Transactional(readOnly = true)
    public List<Long> getCartGameIds(Long userId) {
        return cartItemDAO.getCartGameIds(userId);
    }

    /**
     * Tính tổng giá trị giỏ hàng.
     */
    @Transactional(readOnly = true)
    public java.math.BigDecimal getCartTotal(Long userId) {
        List<CartItem> items = cartItemDAO.getCartItems(userId);
        java.math.BigDecimal total = java.math.BigDecimal.ZERO;
        for (CartItem item : items) {
            if (item.getGame() != null && item.getGame().getPrice() != null) {
                total = total.add(item.getGame().getPrice());
            }
        }
        return total;
    }

    /**
     * Thêm game vào giỏ hàng.
     * Kiểm tra: đã có trong giỏ chưa, đã sở hữu chưa, game có tồn tại không.
     * Trả về: null nếu thành công, message lỗi nếu thất bại.
     */
    public String addToCart(Long userId, Long gameId) {
        if (cartItemDAO.findByUserAndGame(userId, gameId) != null) {
            return "Game đã có trong giỏ hàng.";
        }

        if (libraryItemDAO.existsActiveByUserAndGame(userId, gameId)) {
            return "Bạn đã sở hữu game này rồi.";
        }

        Object gameObj = sessionFactory.getCurrentSession().get("com.gamestore.entity.Game", gameId);
        if (gameObj == null) {
            return "Game không tồn tại.";
        }

        CartItem item = new CartItem();
        item.setUser(new com.gamestore.entity.User());
        item.getUser().setId(userId);
        item.setGame((Game) gameObj);
        item.setQuantity(1);
        sessionFactory.getCurrentSession().save(item);

        return null;
    }

    /**
     * Xóa cart item theo ID.
     * Kiểm tra quyền sở hữu trước khi xóa.
     * Trả về: null nếu thành công, message lỗi nếu thất bại.
     */
    public String removeCartItem(Long userId, Long cartItemId) {
        CartItem item = sessionFactory.getCurrentSession().get(CartItem.class, cartItemId);
        if (item == null) {
            return "Sản phẩm không có trong giỏ.";
        }
        if (!item.getUser().getId().equals(userId)) {
            return "Bạn không có quyền xóa sản phẩm này.";
        }
        sessionFactory.getCurrentSession().delete(item);
        return null;
    }

    /**
     * Xóa cart item theo gameId.
     * Kiểm tra quyền sở hữu trước khi xóa.
     * Trả về: null nếu thành công, message lỗi nếu thất bại.
     */
    public String removeByGameId(Long userId, Long gameId) {
        CartItem item = cartItemDAO.findByUserAndGame(userId, gameId);
        if (item == null) {
            return "Sản phẩm không có trong giỏ.";
        }
        if (!item.getUser().getId().equals(userId)) {
            return "Bạn không có quyền xóa sản phẩm này.";
        }
        sessionFactory.getCurrentSession().delete(item);
        return null;
    }
}
