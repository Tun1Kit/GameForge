package com.gamestore.entity;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "library_items")
public class LibraryItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "game_id", nullable = false)
    private Game game;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "license_key_id", unique = true)
    private LicenseKey licenseKey;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_item_entity_id")
    private OrderItem orderItem;

    @Column(nullable = false, length = 50)
    private String status = "ACTIVE";

    @Column(name = "acquiredAt", nullable = false)
    private LocalDateTime acquiredAt;

    @PrePersist
    public void prePersist() {
        if (acquiredAt == null) acquiredAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Game getGame() { return game; }
    public void setGame(Game game) { this.game = game; }

    public LicenseKey getLicenseKey() { return licenseKey; }
    public void setLicenseKey(LicenseKey licenseKey) { this.licenseKey = licenseKey; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getAcquiredAt() { return acquiredAt; }
    public void setAcquiredAt(LocalDateTime acquiredAt) { this.acquiredAt = acquiredAt; }

    public OrderItem getOrderItem() { return orderItem; }
    public void setOrderItem(OrderItem orderItem) { this.orderItem = orderItem; }
}
