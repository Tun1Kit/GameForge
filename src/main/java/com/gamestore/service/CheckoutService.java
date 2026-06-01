package com.gamestore.service;

import com.gamestore.dao.GameDAO;
import com.gamestore.dao.LibraryItemDAO;
import com.gamestore.dao.LicenseKeyDAO;
import com.gamestore.dao.OrderDAO;
import com.gamestore.dao.OrderItemDAO;
import com.gamestore.entity.Game;
import com.gamestore.entity.LibraryItem;
import com.gamestore.entity.LicenseKey;
import com.gamestore.entity.Order;
import com.gamestore.entity.OrderItem;
import com.gamestore.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Service
@Transactional
public class CheckoutService {

    @Autowired
    private GameDAO gameDAO;

    @Autowired
    private OrderDAO orderDAO;

    @Autowired
    private OrderItemDAO orderItemDAO;

    @Autowired
    private LicenseKeyDAO licenseKeyDAO;

    @Autowired
    private LibraryItemDAO libraryItemDAO;

    @Autowired
    private WalletService walletService;

    @Autowired
    private SystemSettingService systemSettingService;

    public Order buyGame(User buyer, Long gameId) {
        if (buyer == null) {
            throw new IllegalArgumentException("Bạn cần đăng nhập để mua game.");
        }

        Game game = gameDAO.findById(gameId);
        if (game == null || !"ACTIVE".equals(game.getStatus())) {
            throw new IllegalArgumentException("Game không tồn tại hoặc không còn được bán.");
        }

        if (libraryItemDAO.existsActiveByUserAndGame(buyer.getId(), gameId)) {
            throw new IllegalArgumentException("Bạn đã sở hữu game này trong thư viện.");
        }

        LicenseKey licenseKey = licenseKeyDAO.findAvailableByGameId(gameId);
        if (licenseKey == null) {
            throw new IllegalArgumentException("Game này hiện đã hết license key.");
        }

        BigDecimal price = game.getPrice();
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Giá game không hợp lệ.");
        }

        Order order = new Order();
        order.setUser(buyer);
        order.setSubtotalAmount(price);
        order.setDiscountAmount(BigDecimal.ZERO);
        order.setTotalAmount(price);
        order.setStatus("PENDING");
        orderDAO.save(order);

        OrderItem orderItem = new OrderItem();
        orderItem.setOrder(order);
        orderItem.setGame(game);
        orderItem.setUnitPrice(price);
        orderItem.setDiscountAmount(BigDecimal.ZERO);
        orderItem.setPaidAmount(price);
        orderItem.setQuantity(1);
        orderItem.setStatus("PAID");
        orderItemDAO.save(orderItem);

        String orderReference = "ORDER_" + order.getId();

        walletService.purchase(buyer, price, orderReference);

        licenseKey.assignTo(buyer, orderItem);
        licenseKeyDAO.update(licenseKey);

        LibraryItem libraryItem = new LibraryItem();
        libraryItem.setUser(buyer);
        libraryItem.setGame(game);
        libraryItem.setLicenseKey(licenseKey);
        libraryItem.setOrderItem(orderItem);
        libraryItem.setStatus("ACTIVE");
        libraryItemDAO.save(libraryItem);

        creditPublisherRevenueIfPossible(game, price, orderReference);

        order.setStatus("PAID");
        order.setPaidAt(LocalDateTime.now());
        orderDAO.update(order);

        return order;
    }

    private void creditPublisherRevenueIfPossible(Game game, BigDecimal paidAmount, String orderReference) {
        if (game.getPublisher() == null || game.getPublisher().getUser() == null) return;

        BigDecimal commissionRate = systemSettingService.getPlatformCommissionRate();
        BigDecimal commissionAmount = paidAmount
                .multiply(commissionRate)
                .divide(new BigDecimal("100"));
        BigDecimal publisherRevenue = paidAmount.subtract(commissionAmount);

        if (publisherRevenue.compareTo(BigDecimal.ZERO) > 0) {
            walletService.creditPublisherRevenue(
                    game.getPublisher().getUser(), publisherRevenue, orderReference);
        }
    }
}
