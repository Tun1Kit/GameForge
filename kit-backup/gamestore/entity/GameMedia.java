package com.gamestore.entity;

import javax.persistence.*;

@Entity
@Table(name = "game_media")
public class GameMedia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "game_id")
    private Game game;

    @Column(name = "mediaType")
    private String mediaType; // IMAGE hoặc VIDEO_TRAILER

    @Column(name = "mediaUrl")
    private String mediaUrl;

    @Column(name = "isPrimary")
    private boolean isPrimary; // Khớp chuẩn xác với cột isPrimary (bit) trong SQL Server

    // ==========================================================
    // CÁC HÀM GETTER VÀ SETTER CHUẨN JAVABEAN
    // ==========================================================
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Game getGame() { return game; }
    public void setGame(Game game) { this.game = game; }

    public String getMediaType() { return mediaType; }
    public void setMediaType(String mediaType) { this.mediaType = mediaType; }

    public String getMediaUrl() { return mediaUrl; }
    public void setMediaUrl(String mediaUrl) { this.mediaUrl = mediaUrl; }

    // RẤT QUAN TRỌNG: Với kiểu dữ liệu boolean, hàm GET bắt buộc phải đặt tên là isPrimary() 
    // thì các biểu thức EL của JSP (${media.isPrimary}) mới nhận diện tự động được.
    public boolean isPrimary() {
        return isPrimary;
    }

    public void setPrimary(boolean isPrimary) {
        this.isPrimary = isPrimary;
    }
}