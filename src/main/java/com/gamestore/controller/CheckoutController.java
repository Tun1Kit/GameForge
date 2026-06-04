package com.gamestore.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gamestore.dao.CartItemDAO;
import com.gamestore.entity.*;
import com.gamestore.service.EmailService;
import com.gamestore.service.UserContextService;
import com.gamestore.service.WalletService;
import com.gamestore.service.SystemSettingService;
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
import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

@Controller
@Transactional
public class CheckoutController {

    private final Validator validator;

    public CheckoutController() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        this.validator = factory.getValidator();
    }

    @Autowired
    private SessionFactory sessionFactory;

    @Autowired
    private CartItemDAO cartItemDAO;

    @Autowired
    private WalletService walletService;

    @Autowired
    private EmailService emailService;

    @Autowired
    private UserContextService userContextService;

    @Autowired
    private SystemSettingService systemSettingService;

    @GetMapping("/checkout")
    public String showCheckoutPage(
            @RequestParam(value = "error", required = false) String error,
            HttpSession session, Model model) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        List<CartItem> cartItems = cartItemDAO.getCartItems(currentUser.getId());

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

        BigDecimal walletBalance = walletService.getBalance(currentUser);

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

    private String buildCheckoutError(Model model, CartItemDAO dao, Long userId, String message) {
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : dao.getCartItems(userId)) {
            subtotal = subtotal.add(item.getGame().getPrice());
        }
        model.addAttribute("cartItems", dao.getCartItems(userId));
        model.addAttribute("error", message);
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("discount", BigDecimal.ZERO);
        model.addAttribute("total", subtotal);
        model.addAttribute("walletBalance", walletService.getBalanceById(userId));
        return "checkout";
    }

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

        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        // --- Server-side validation ---
        String phonePattern = "^0\\d{9,10}$";
        if (fullName == null || fullName.trim().isEmpty() || fullName.length() > 100) {
            return buildCheckoutError(model, cartItemDAO, currentUser.getId(), "Họ tên không được để trống và không vượt quá 100 ký tự.");
        }
        if (phone == null || !Pattern.matches(phonePattern, phone.trim())) {
            return buildCheckoutError(model, cartItemDAO, currentUser.getId(), "Số điện thoại không hợp lệ (phải là 10-11 chữ số, bắt đầu bằng 0).");
        }
        if (address == null || address.trim().isEmpty() || address.length() > 300) {
            return buildCheckoutError(model, cartItemDAO, currentUser.getId(), "Địa chỉ không được để trống và không vượt quá 300 ký tự.");
        }
        if (notes != null && notes.length() > 500) {
            return buildCheckoutError(model, cartItemDAO, currentUser.getId(), "Ghi chú không được vượt quá 500 ký tự.");
        }

        Session hqSession = sessionFactory.getCurrentSession();
        User managedUser = hqSession.get(User.class, currentUser.getId());

        List<CartItem> cartItems = cartItemDAO.getCartItems(managedUser.getId());

        if (cartItems.isEmpty()) {
            return "redirect:/?error=empty_cart";
        }

        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getGame().getPrice());
        }

        BigDecimal total = subtotal;

        if (!"WALLET".equals(paymentMethod)) {
            model.addAttribute("cartItems", cartItemDAO.getCartItems(managedUser.getId()));
            model.addAttribute("error", "Hiện tại chỉ hỗ trợ thanh toán qua Ví GameForge. Vui lòng chọn 'Ví điện tử'.");
            model.addAttribute("subtotal", subtotal);
            model.addAttribute("discount", BigDecimal.ZERO);
            model.addAttribute("total", subtotal);
            model.addAttribute("walletBalance", walletService.getBalance(managedUser));
            return "checkout";
        }

        if ("WALLET".equals(paymentMethod)) {
            Wallet wallet = walletService.getOrCreateWallet(managedUser);

            if (wallet.getBalance().compareTo(total) < 0) {
                return "redirect:/checkout?error=insufficient_balance";
            }

            walletService.purchase(managedUser, total, "ORDER_" + System.currentTimeMillis());
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
            orderItem.setDiscountAmount(item.getGame().getPrice().multiply(new BigDecimal("0.10")));
            orderItem.setPaidAmount(item.getGame().getPrice().subtract(orderItem.getDiscountAmount()));
            orderItem.setQuantity(1);
            orderItem.setStatus("PAID");

            hqSession.save(orderItem);
            hqSession.flush();

            // Cộng tiền doanh thu cho Publisher (khấu trừ hoa hồng platform)
            Game game = item.getGame();
            PublisherProfile pubProfile = game.getPublisher();
            if (pubProfile != null && pubProfile.getUser() != null) {
                BigDecimal paidAmount = orderItem.getPaidAmount();
                BigDecimal commissionRate = systemSettingService.getPlatformCommissionRate();
                BigDecimal commissionPercent = commissionRate.divide(new BigDecimal("100"), 4, java.math.RoundingMode.HALF_UP);
                BigDecimal multiplier = BigDecimal.ONE.subtract(commissionPercent);
                BigDecimal publisherRevenue = paidAmount.multiply(multiplier).setScale(2, java.math.RoundingMode.HALF_UP);
                walletService.creditPublisherRevenue(pubProfile.getUser(), publisherRevenue, "ORDER_ITEM_" + orderItem.getId());
            }

            LicenseKey assignedKey = assignLicenseKey(hqSession, managedUser.getId(), item.getGame().getId(), orderItem.getId());

            Map<String, Object> keyInfo = new HashMap<>();
            keyInfo.put("gameTitle", item.getGame().getTitle());
            keyInfo.put("keyString", (assignedKey != null) ? assignedKey.getKeyString() : "[Đang chờ cấp phát]");
            keyInfo.put("hasKey", assignedKey != null);
            assignedKeys.add(keyInfo);

            hqSession.delete(item);
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

        try {
            emailService.sendOrderConfirmation(managedUser, order, assignedKeys);
        } catch (Exception e) {
            System.err.println("Gửi mail hóa đơn thất bại: " + e.getMessage());
        }

        return "redirect:/checkout/success?orderId=" + order.getId();
    }

    @GetMapping("/checkout/success")
    public String orderSuccess(@RequestParam(value = "orderId", required = false) Long orderIdParam, Model model, HttpSession session) {
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            return "redirect:/login";
        }

        Session hqSession = sessionFactory.getCurrentSession();

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
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "Chưa đăng nhập.");
            out.print(mapper.writeValueAsString(response));
            return;
        }

        Session hqSession = sessionFactory.getCurrentSession();
        User managedUser = hqSession.get(User.class, currentUser.getId());

        List<CartItem> cartItems = cartItemDAO.getCartItems(managedUser.getId());

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
                Wallet wallet = walletService.getOrCreateWallet(managedUser);

                if (wallet.getBalance().compareTo(total) < 0) {
                    response.put("success", false);
                    response.put("message", "Số dư ví không đủ (" + wallet.getBalance() + " VND).");
                    out.print(mapper.writeValueAsString(response));
                    return;
                }

                walletService.purchase(managedUser, total, "ORDER_" + System.currentTimeMillis());

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

                // Cộng tiền doanh thu cho Publisher (khấu trừ hoa hồng platform)
                Game game = item.getGame();
                PublisherProfile pubProfile = game.getPublisher();
                if (pubProfile != null && pubProfile.getUser() != null) {
                    BigDecimal paidAmount = orderItem.getPaidAmount();
                    BigDecimal commissionRate = systemSettingService.getPlatformCommissionRate();
                    BigDecimal commissionPercent = commissionRate.divide(new BigDecimal("100"), 4, java.math.RoundingMode.HALF_UP);
                    BigDecimal multiplier = BigDecimal.ONE.subtract(commissionPercent);
                    BigDecimal publisherRevenue = paidAmount.multiply(multiplier).setScale(2, java.math.RoundingMode.HALF_UP);
                    walletService.creditPublisherRevenue(pubProfile.getUser(), publisherRevenue, "ORDER_ITEM_" + orderItem.getId());
                }

                LicenseKey assignedKey = assignLicenseKey(hqSession, managedUser.getId(), item.getGame().getId(), orderItem.getId());

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
        User currentUser = userContextService.getCurrentUser(session);
        if (currentUser == null) {
            response.put("success", false);
            response.put("message", "Vui lòng đăng nhập.");
            out.print(mapper.writeValueAsString(response));
            return;
        }
        Session hqSession = sessionFactory.getCurrentSession();
        List<CartItem> cartItems = cartItemDAO.getCartItems(currentUser.getId());
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

    private LicenseKey assignLicenseKey(Session hqSession, Long userId, Long gameId, Long orderItemId) {
        String keyHql = "FROM LicenseKey k WHERE k.game.id = :gameId AND k.status = 'AVAILABLE' AND NOT EXISTS (FROM LibraryItem li WHERE li.licenseKey.id = k.id)";
        List<LicenseKey> keys = hqSession.createQuery(keyHql, LicenseKey.class)
                .setParameter("gameId", gameId)
                .setMaxResults(1)
                .getResultList();

        LicenseKey assignedKey = (!keys.isEmpty()) ? keys.get(0) : null;

        // Nếu hết key available, tự động tạo 1 key mới
        if (assignedKey == null) {
            assignedKey = new LicenseKey();
            assignedKey.setGame(hqSession.get(Game.class, gameId));
            String uuid = java.util.UUID.randomUUID().toString().toUpperCase().replace("-", "");
            String keyString = uuid.substring(0, 5) + "-" + uuid.substring(5, 10) + "-" + uuid.substring(10, 15);
            assignedKey.setKeyString(keyString);
            assignedKey.setStatus("AVAILABLE");
            assignedKey.setCreatedAt(LocalDateTime.now());
            hqSession.save(assignedKey);
        }

        assignedKey.setStatus("SOLD");
        assignedKey.setOrderItemId(orderItemId);
        assignedKey.setOwner(hqSession.get(User.class, userId));
        assignedKey.setAssignedAt(LocalDateTime.now());
        hqSession.update(assignedKey);

        String libHql = "FROM LibraryItem WHERE user.id = :userId AND game.id = :gameId";
        List<LibraryItem> existingLibs = hqSession.createQuery(libHql, LibraryItem.class)
                .setParameter("userId", userId)
                .setParameter("gameId", gameId)
                .getResultList();
        LibraryItem existingLib = !existingLibs.isEmpty() ? existingLibs.get(0) : null;

        OrderItem oi = hqSession.get(OrderItem.class, orderItemId);

        if (existingLib == null) {
            LibraryItem libItem = new LibraryItem();
            libItem.setUser(hqSession.get(User.class, userId));
            libItem.setGame(hqSession.get(com.gamestore.entity.Game.class, gameId));
            libItem.setLicenseKey(assignedKey);
            libItem.setOrderItem(oi);
            libItem.setStatus("ACTIVE");
            libItem.setAcquiredAt(LocalDateTime.now());
            hqSession.save(libItem);
        } else {
            if (assignedKey != null) {
                existingLib.setLicenseKey(assignedKey);
            }
            existingLib.setOrderItem(oi);
            existingLib.setStatus("ACTIVE");
            existingLib.setAcquiredAt(LocalDateTime.now());
            hqSession.update(existingLib);
        }

        return assignedKey;
    }
}
