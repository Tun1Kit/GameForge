package com.gamestore.entity;

import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "cart_items")
public class CartItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Liên kết với thực thể User
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Liên kết với thực thể Game
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "game_id", nullable = false)
    private Game game;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "addedAt", nullable = false)
    private LocalDateTime addedAt;

    public CartItem() {}

    // Tự động gán thời gian và số lượng mặc định trước khi INSERT
    @PrePersist
    public void prePersist() {
        if (this.addedAt == null) this.addedAt = LocalDateTime.now();
        if (this.quantity == null) this.quantity = 1;
    }

    // --- GETTERS & SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public Game getGame() { return game; }
    public void setGame(Game game) { this.game = game; }
    
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    
    public LocalDateTime getAddedAt() { return addedAt; }
    public void setAddedAt(LocalDateTime addedAt) { this.addedAt = addedAt; }
}
