package com.gamestore.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gamestore.dao.CartItemDAO;
import com.gamestore.entity.*;
import com.gamestore.service.EmailService;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Transactional
public class CheckoutController {

    @Autowired
    private SessionFactory sessionFactory;

    @Autowired
    private CartItemDAO cartItemDAO;

    @Autowired
    private EmailService emailService;

    /**
     * HIỂN THỊ TRANG THANH TOÁN & GIỎ HÀNG
     */
    @GetMapping("/checkout")
    public String showCheckoutPage(
            @RequestParam(value = "error", required = false) String error,
            HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        String hql = "FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId";
        List<CartItem> cartItems = sessionFactory.getCurrentSession()
                .createQuery(hql, CartItem.class)
                .setParameter("userId", currentUser.getId())
                .getResultList();

        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            if (item.getGame() == null || item.getGame().getPrice() == null) continue;
            BigDecimal price = item.getGame().getPrice();
            BigDecimal originalPrice = item.getGame().getOriginalPrice();
            subtotal = subtotal.add(originalPrice != null ? originalPrice : price);
            if (originalPrice != null && price.compareTo(originalPrice) < 0) {
                totalDiscount = totalDiscount.add(originalPrice.subtract(price));
            }
        }
        BigDecimal total = subtotal.subtract(totalDiscount);

        BigDecimal walletBalance = BigDecimal.ZERO;
        String hqlWallet = "SELECT w.balance FROM Wallet w WHERE w.user.id = :userId";
        try {
            BigDecimal result = sessionFactory.getCurrentSession()
                    .createQuery(hqlWallet, BigDecimal.class)
                    .setParameter("userId", currentUser.getId())
                    .uniqueResult();
            if (result != null) {
                walletBalance = result;
            }
        } catch (Exception e) {
            // User chưa có ví trong bảng wallets
        }

        if (error != null) {
            if ("wallet_not_found".equals(error)) {
                model.addAttribute("error", "Bạn chưa có ví GameForge. Vui lòng nạp tiền trước.");
            } else if ("insufficient_balance".equals(error)) {
                model.addAttribute("error", "Số dư ví không đủ. Vui lòng nạp thêm tiền.");
            }
        }

        model.addAttribute("cartItems", cartItems);
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("discount", totalDiscount);
        model.addAttribute("total", total);
        model.addAttribute("walletBalance", walletBalance);

        return "checkout";
    }

    /**
     * XỬ LÝ THANH TOÁN ĐƠN HÀNG
     */
    @PostMapping("/checkout/process")
    public String processCheckout(
            @RequestParam("paymentMethod") String paymentMethod,
            @RequestParam("fullName") String fullName,
            @RequestParam("phone") String phone,
            @RequestParam("address") String address,
            @RequestParam("province") String province,
            @RequestParam("district") String district,
            @RequestParam("ward") String ward,
            @RequestParam(value = "notes", required = false) String notes,
            HttpSession session, Model model) {

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        Session hqSession = sessionFactory.getCurrentSession();
        // Load managed User to avoid Detached Entity or LazyInitializationException issues from login session
        User managedUser = hqSession.get(User.class, currentUser.getId());

        String hql = "FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId";
        List<CartItem> cartItems = hqSession
                .createQuery(hql, CartItem.class)
                .setParameter("userId", managedUser.getId())
                .getResultList();

        if (cartItems.isEmpty()) {
            return "redirect:/?error=empty_cart";
        }

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getGame().getPrice());
        }

        BigDecimal total = subtotal;

        // FIX BUG #4: Chỉ hỗ trợ thanh toán qua Ví GameForge tạm thời
        if (!"WALLET".equals(paymentMethod)) {
            List<CartItem> cartItemsForModel = hqSession
                    .createQuery("FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId", CartItem.class)
                    .setParameter("userId", managedUser.getId())
                    .getResultList();
            model.addAttribute("cartItems", cartItemsForModel);
            model.addAttribute("error", "Hiện tại chỉ hỗ trợ thanh toán qua Ví GameForge. Vui lòng chọn 'Ví điện tử'.");
            BigDecimal stForModel = BigDecimal.ZERO;
            for (CartItem ci : cartItemsForModel) stForModel = stForModel.add(ci.getGame().getPrice());
            model.addAttribute("subtotal", stForModel);
            model.addAttribute("discount", BigDecimal.ZERO);
            model.addAttribute("total", stForModel);
            BigDecimal wb = BigDecimal.ZERO;
            try {
                Object r = hqSession.createNativeQuery("SELECT balance FROM wallets WHERE user_id = :uid")
                        .setParameter("uid", managedUser.getId()).uniqueResult();
                if (r != null) wb = (r instanceof BigDecimal) ? (BigDecimal) r : new BigDecimal(r.toString());
            } catch (Exception ex) { /* no wallet */ }
            model.addAttribute("walletBalance", wb);
            return "checkout";
        }

        // ====== XỬ LÝ THANH TOÁN BẰNG VÍ ======
        if ("WALLET".equals(paymentMethod)) {
            Wallet wallet = hqSession
                        .createQuery("FROM Wallet WHERE user.id = :userId", Wallet.class)
                        .setParameter("userId", managedUser.getId())
                        .uniqueResult();

            if (wallet == null) {
                return "redirect:/checkout?error=wallet_not_found";
            }

            if (wallet.getBalance().compareTo(total) < 0) {
                return "redirect:/checkout?error=insufficient_balance";
            }

            wallet.setBalance(wallet.getBalance().subtract(total));
            hqSession.update(wallet);

            WalletTransaction tx = new WalletTransaction();
            tx.setWallet(wallet);
            tx.setType("PURCHASE");
            tx.setAmount(total);
            tx.setStatus("SUCCESS");
            tx.setReferenceId("ORDER_" + System.currentTimeMillis());
            hqSession.save(tx);
        }
        // ====== KẾT THÚC XỬ LÝ VÍ ======

        // Tạo đơn hàng
        Order order = new Order();
        order.setUser(managedUser);
        order.setSubtotalAmount(subtotal);
        order.setDiscountAmount(BigDecimal.ZERO);
        order.setTotalAmount(total);
        order.setStatus("PAID");
        order.setPaymentMethod(paymentMethod);
        order.setFullName(fullName);
        order.setPhone(phone);
        order.setAddress(address);
        order.setProvince(province);
        order.setDistrict(district);
        order.setWard(ward);
        order.setNotes(notes);
        order.setCreatedAt(LocalDateTime.now());
        order.setPaidAt(LocalDateTime.now());

        hqSession.save(order);

        List<Map<String, Object>> assignedKeys = new ArrayList<>();

        for (CartItem item : cartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setGame(item.getGame());
            orderItem.setUnitPrice(item.getGame().getPrice());
            orderItem.setDiscountAmount(item.getGame().getPrice().multiply(new BigDecimal("0.10")));
            orderItem.setPaidAmount(item.getGame().getPrice().subtract(orderItem.getDiscountAmount()));
            orderItem.setQuantity(1);
            orderItem.setStatus("PAID");

            hqSession.save(orderItem);
            hqSession.flush();

            // Tìm license key AVAILABLE cho game này
            String keyHql = "FROM LicenseKey k WHERE k.game.id = :gameId AND k.status = 'AVAILABLE' AND NOT EXISTS (FROM LibraryItem li WHERE li.licenseKey.id = k.id)";
            List<LicenseKey> keys = hqSession.createQuery(keyHql, LicenseKey.class)
                    .setParameter("gameId", item.getGame().getId())
                    .setMaxResults(1)
                    .getResultList();

            LicenseKey assignedKey = (!keys.isEmpty()) ? keys.get(0) : null;

            if (assignedKey != null) {
                // FIX BUG #1: Cập nhật key sang SOLD trước khi gán cho user
                assignedKey.setStatus("SOLD");
                assignedKey.setOrderItemId(orderItem.getId());
                assignedKey.setOwner(managedUser);
                assignedKey.setAssignedAt(LocalDateTime.now());
                hqSession.update(assignedKey);

                // Kiểm tra user đã sở hữu game này chưa — tránh trùng unique key (sử dụng list đề phòng duplicate lịch sử)
                String libHql = "FROM LibraryItem WHERE user.id = :userId AND game.id = :gameId";
                List<LibraryItem> existingLibs = hqSession.createQuery(libHql, LibraryItem.class)
                        .setParameter("userId", managedUser.getId())
                        .setParameter("gameId", item.getGame().getId())
                        .getResultList();
                LibraryItem existingLib = !existingLibs.isEmpty() ? existingLibs.get(0) : null;

                if (existingLib == null) {
                    LibraryItem libItem = new LibraryItem();
                    libItem.setUser(managedUser);
                    libItem.setGame(item.getGame());
                    libItem.setLicenseKey(assignedKey);
                    libItem.setStatus("ACTIVE");
                    libItem.setAcquiredAt(LocalDateTime.now());
                    hqSession.save(libItem);
                } else {
                    // Game đã có trong thư viện, chỉ cập nhật key
                    existingLib.setLicenseKey(assignedKey);
                    existingLib.setAcquiredAt(LocalDateTime.now());
                    hqSession.update(existingLib);
                }
            }

            // Ghi log key dù có hay không (cho trang success)
            Map<String, Object> keyInfo = new HashMap<>();
            keyInfo.put("gameTitle", item.getGame().getTitle());
            keyInfo.put("keyString", (assignedKey != null) ? assignedKey.getKeyString() : "[Đang chờ cấp phát]");
            keyInfo.put("hasKey", assignedKey != null);
            assignedKeys.add(keyInfo);

            hqSession.delete(item);
        }

        // Truyền 8 trường giao hàng qua session để hiển thị ở trang success
        Map<String, String> shippingInfo = new HashMap<>();
        shippingInfo.put("fullName", fullName);
        shippingInfo.put("phone", phone);
        shippingInfo.put("address", address);
        shippingInfo.put("province", province);
        shippingInfo.put("district", district);
        shippingInfo.put("ward", ward);
        shippingInfo.put("notes", notes);
        shippingInfo.put("paymentMethod", paymentMethod);
        session.setAttribute("shippingInfo", shippingInfo);
        session.setAttribute("assignedKeys", assignedKeys);

        // Gửi email hóa đơn & key kích hoạt tự động cho user
        try {
            emailService.sendOrderConfirmation(managedUser, order, assignedKeys);
        } catch (Exception e) {
            System.err.println("Gửi mail hóa đơn thất bại: " + e.getMessage());
        }

        return "redirect:/checkout/success?orderId=" + order.getId();
    }

    /**
     * TRANG HOÀN TẤT THÀNH CÔNG
     */
    @GetMapping("/checkout/success")
    public String orderSuccess(@RequestParam(value = "orderId", required = false) Long orderIdParam, Model model, HttpSession session) {
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/login";
        }

        Session hqSession = sessionFactory.getCurrentSession();

        // Lấy orderId từ request param hoặc từ session (do API endpoint đặt)
        Long orderId = orderIdParam;
        if (orderId == null) {
            Object sessionOrderId = session.getAttribute("lastOrderId");
            if (sessionOrderId instanceof Long) {
                orderId = (Long) sessionOrderId;
            } else if (sessionOrderId != null) {
                orderId = Long.parseLong(sessionOrderId.toString());
            }
        }

        if (orderId == null) {
            return "redirect:/?error=invalid_order";
        }

        Order order = hqSession.get(Order.class, orderId);

        if (order == null || !order.getUser().getId().equals(currentUser.getId())) {
            return "redirect:/?error=invalid_order";
        }

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> keys = (List<Map<String, Object>>) session.getAttribute("assignedKeys");
        if (keys == null) {
            keys = new ArrayList<>();
        }

        @SuppressWarnings("unchecked")
        Map<String, String> shippingInfo = (Map<String, String>) session.getAttribute("shippingInfo");
        if (shippingInfo == null) {
            shippingInfo = new HashMap<>();
        }

        model.addAttribute("order", order);
        model.addAttribute("keys", keys);
        model.addAttribute("shippingInfo", shippingInfo);

        session.removeAttribute("assignedKeys");
        session.removeAttribute("shippingInfo");

        return "order-success";
    }

    /**
     * API AJAX: XỬ LÝ THANH TOÁN ĐƠN HÀNG (QR / WALLET / BANK)
     * Trả về JSON thay vì redirect — dùng cho modal QR checkout
     */
    @PostMapping("/api/checkout/process")
    public void apiProcessCheckout(
            @RequestParam("paymentMethod") String paymentMethod,
            @RequestParam("fullName") String fullName,
            @RequestParam("phone") String phone,
            @RequestParam("address") String address,
            @RequestParam(value = "province", required = false) String province,
            @RequestParam(value = "district", required = false) String district,
            @RequestParam(value = "ward", required = false) String ward,
            @RequestParam(value = "notes", required = false) String notes,
            @RequestParam(value = "walletProvider", required = false) String walletProvider,
            HttpSession session,
            HttpServletResponse httpResponse) throws Exception {

        httpResponse.setContentType("application/json;charset=UTF-8");
        httpResponse.setCharacterEncoding("UTF-8");
        PrintWriter out = httpResponse.getWriter();
        ObjectMapper mapper = new ObjectMapper();

        Map<String, Object> response = new HashMap<>();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "Chưa đăng nhập.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();
        // Load managed User to avoid Detached Entity or LazyInitializationException issues from login session
        User managedUser = hqSession.get(User.class, currentUser.getId());

        String cartHql = "FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId";
        List<CartItem> cartItems = hqSession
                .createQuery(cartHql, CartItem.class)
                .setParameter("userId", managedUser.getId())
                .getResultList();

        if (cartItems.isEmpty()) {
            response.put("success", false);
            response.put("message", "Giỏ hàng trống.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            if (item.getGame() == null || item.getGame().getPrice() == null) {
                response.put("success", false);
                response.put("message", "Dữ liệu game không hợp lệ. Vui lòng liên hệ hỗ trợ.");
                out.print(mapper.writeValueAsString(response));
                return;
            }
            subtotal = subtotal.add(item.getGame().getPrice());
        }
        BigDecimal total = subtotal;

        if (!"WALLET".equals(paymentMethod) && !"BANK".equals(paymentMethod) && !"CARD".equals(paymentMethod)) {
            response.put("success", false);
            response.put("message", "Phương thức thanh toán không được hỗ trợ.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        try {
            boolean useGameForgeWallet = "WALLET".equals(paymentMethod) && "GAMEFORGE".equals(walletProvider);
            if (useGameForgeWallet) {
                Wallet wallet = hqSession
                        .createQuery("FROM Wallet WHERE user.id = :userId", Wallet.class)
                        .setParameter("userId", managedUser.getId())
                        .uniqueResult();

                if (wallet == null) {
                    response.put("success", false);
                    response.put("message", "Bạn chưa có ví GameForge. Vui lòng nạp tiền trước.");
                    out.print(mapper.writeValueAsString(response));
                    return;
                }

                if (wallet.getBalance().compareTo(total) < 0) {
                    response.put("success", false);
                    response.put("message", "Số dư ví không đủ (" + wallet.getBalance() + " VND).");
                    out.print(mapper.writeValueAsString(response));
                    return;
                }

                wallet.setBalance(wallet.getBalance().subtract(total));
                hqSession.update(wallet);

                WalletTransaction tx = new WalletTransaction();
                tx.setWallet(wallet);
                tx.setType("PURCHASE");
                tx.setAmount(total);
                tx.setStatus("SUCCESS");
                tx.setReferenceId("ORDER_" + System.currentTimeMillis());
                hqSession.save(tx);

                response.put("newBalance", wallet.getBalance());
            } else {
                response.put("newBalance", null);
            }

            Order order = new Order();
            order.setUser(managedUser);
            order.setSubtotalAmount(subtotal);
            order.setDiscountAmount(BigDecimal.ZERO);
            order.setTotalAmount(total);
            order.setStatus("PAID");
            order.setPaymentMethod(paymentMethod);
            order.setFullName(fullName);
            order.setPhone(phone);
            order.setAddress(address);
            order.setProvince(province);
            order.setDistrict(district);
            order.setWard(ward);
            order.setNotes(notes);
            order.setCreatedAt(LocalDateTime.now());
            order.setPaidAt(LocalDateTime.now());

            hqSession.save(order);

            List<Map<String, Object>> assignedKeys = new ArrayList<>();

            for (CartItem item : cartItems) {
                OrderItem orderItem = new OrderItem();
                orderItem.setOrder(order);
                orderItem.setGame(item.getGame());
                orderItem.setUnitPrice(item.getGame().getPrice());
                orderItem.setDiscountAmount(BigDecimal.ZERO);
                orderItem.setPaidAmount(item.getGame().getPrice());
                orderItem.setQuantity(1);
                orderItem.setStatus("PAID");

                hqSession.save(orderItem);
                hqSession.flush();

                String keyHql = "FROM LicenseKey k WHERE k.game.id = :gameId AND k.status = 'AVAILABLE' AND NOT EXISTS (FROM LibraryItem li WHERE li.licenseKey.id = k.id)";
                List<LicenseKey> keys = hqSession.createQuery(keyHql, LicenseKey.class)
                        .setParameter("gameId", item.getGame().getId())
                        .setMaxResults(1)
                        .getResultList();

                LicenseKey assignedKey = (!keys.isEmpty()) ? keys.get(0) : null;

                if (assignedKey != null) {
                    assignedKey.setStatus("SOLD");
                    assignedKey.setOrderItemId(orderItem.getId());
                    assignedKey.setOwner(managedUser);
                    assignedKey.setAssignedAt(LocalDateTime.now());
                    hqSession.update(assignedKey);

                    String libHql = "FROM LibraryItem WHERE user.id = :userId AND game.id = :gameId";
                    List<LibraryItem> existingLibs = hqSession.createQuery(libHql, LibraryItem.class)
                            .setParameter("userId", managedUser.getId())
                            .setParameter("gameId", item.getGame().getId())
                            .getResultList();
                    LibraryItem existingLib = !existingLibs.isEmpty() ? existingLibs.get(0) : null;

                    if (existingLib == null) {
                        LibraryItem libItem = new LibraryItem();
                        libItem.setUser(managedUser);
                        libItem.setGame(item.getGame());
                        libItem.setLicenseKey(assignedKey);
                        libItem.setStatus("ACTIVE");
                        libItem.setAcquiredAt(LocalDateTime.now());
                        hqSession.save(libItem);
                    } else {
                        existingLib.setLicenseKey(assignedKey);
                        existingLib.setAcquiredAt(LocalDateTime.now());
                        hqSession.update(existingLib);
                    }
                }

                Map<String, Object> keyInfo = new HashMap<>();
                keyInfo.put("gameTitle", item.getGame().getTitle());
                keyInfo.put("keyString", (assignedKey != null) ? assignedKey.getKeyString() : "[Đang chờ cấp phát]");
                keyInfo.put("hasKey", assignedKey != null);
                assignedKeys.add(keyInfo);

                hqSession.delete(item);
                hqSession.flush();
            }

            Map<String, String> shippingInfo = new HashMap<>();
            shippingInfo.put("fullName", fullName);
            shippingInfo.put("phone", phone);
            shippingInfo.put("address", address);
            shippingInfo.put("province", province);
            shippingInfo.put("district", district);
            shippingInfo.put("ward", ward);
            shippingInfo.put("notes", notes);
            shippingInfo.put("paymentMethod", paymentMethod);
            session.setAttribute("shippingInfo", shippingInfo);
            session.setAttribute("assignedKeys", assignedKeys);
            session.setAttribute("lastOrderId", order.getId());

            hqSession.flush();

            response.put("success", true);
            response.put("message", "Thanh toán thành công!");
            response.put("orderId", order.getId());
            out.print(mapper.writeValueAsString(response));
            return;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                org.springframework.transaction.interceptor.TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            } catch (Exception ex) {
                System.err.println("Không thể set rollback-only: " + ex.getMessage());
            }
            response.put("success", false);
            response.put("message", "Lỗi khi xử lý thanh toán: " + e.getMessage());
            out.print(mapper.writeValueAsString(response));
            return;
        }
    }

    /**
     * FIX BUG #2: Áp dụng mã khuyến mãi
     */
    private BigDecimal applyPromoCode(Session session, String promoCodeStr, BigDecimal subtotal) {
        if (promoCodeStr == null || promoCodeStr.trim().isEmpty()) {
            return BigDecimal.ZERO;
        }
        PromoCode promo = session
                .createQuery("FROM PromoCode WHERE UPPER(code) = :code AND status = 'ACTIVE'", PromoCode.class)
                .setParameter("code", promoCodeStr.trim().toUpperCase())
                .uniqueResult();
        if (promo == null) {
            return BigDecimal.ZERO;
        }
        if (promo.getExpiryDate() != null && promo.getExpiryDate().isBefore(LocalDateTime.now())) {
            return BigDecimal.ZERO;
        }
        if (promo.getUsageLimit() != null && promo.getCurrentUsage() >= promo.getUsageLimit()) {
            return BigDecimal.ZERO;
        }
        return subtotal.multiply(promo.getDiscountPercentage())
                .divide(new BigDecimal("100"), 2, java.math.RoundingMode.HALF_UP);
    }

    @GetMapping("/api/promo/validate")
    public void validatePromoCode(
            @RequestParam("code") String code,
            HttpSession session,
            HttpServletResponse httpResponse) throws Exception {

        httpResponse.setContentType("application/json;charset=UTF-8");
        httpResponse.setCharacterEncoding("UTF-8");
        PrintWriter out = httpResponse.getWriter();
        ObjectMapper mapper = new ObjectMapper();

        Map<String, Object> response = new HashMap<>();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "Vui lòng đăng nhập.");
            out.print(mapper.writeValueAsString(response));
            return;
        }
        Session hqSession = sessionFactory.getCurrentSession();
        String hql = "FROM CartItem c JOIN FETCH c.game WHERE c.user.id = :userId";
        List<CartItem> cartItems = hqSession
                .createQuery(hql, CartItem.class)
                .setParameter("userId", currentUser.getId())
                .getResultList();
        if (cartItems.isEmpty()) {
            response.put("success", false);
            response.put("message", "Giỏ hàng trống.");
            out.print(mapper.writeValueAsString(response));
            return;
        }
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            if (item.getGame() == null || item.getGame().getPrice() == null) {
                response.put("success", false);
                response.put("message", "Dữ liệu game không hợp lệ.");
                out.print(mapper.writeValueAsString(response));
                return;
            }
            subtotal = subtotal.add(item.getGame().getPrice());
        }
        BigDecimal discount = applyPromoCode(hqSession, code, subtotal);
        if (discount.compareTo(BigDecimal.ZERO) > 0) {
            response.put("success", true);
            response.put("discountAmount", discount);
            response.put("message", "Mã hợp lệ! Giảm " + discount + " VND.");
        } else {
            response.put("success", false);
            response.put("message", "Mã khuyến mãi không hợp lệ hoặc đã hết hạn.");
        }
        out.print(mapper.writeValueAsString(response));
    }

}
