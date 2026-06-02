package com.gamestore.entity;

import java.time.LocalDateTime;
import javax.persistence.*;
import javax.validation.constraints.Max;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Entity
@Table(name = "reviews")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "game_id", nullable = false)
    private Game game;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    @NotNull(message = "Rating không được để trống")
    @Max(value = 5, message = "Rating không được vượt quá 5 sao")
    private Integer rating;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    @Size(max = 2000, message = "Bình luận không được vượt quá 2000 ký tự")
    private String comment;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    @Size(max = 1000, message = "Phản hồi không được vượt quá 1000 ký tự")
    private String publisherReply;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    @Size(max = 1000, message = "Ý kiến bổ sung không được vượt quá 1000 ký tự")
    private String userFollowUp;

    @Column(name = "createdAt", nullable = false)
    private LocalDateTime createdAt;

    public Review() {}

    @PrePersist
    public void prePersist() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
    }

    // --- GETTERS & SETTERS ---
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Game getGame() { return game; }
    public void setGame(Game game) { this.game = game; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public String getPublisherReply() { return publisherReply; }
    public void setPublisherReply(String publisherReply) { this.publisherReply = publisherReply; }

    public String getUserFollowUp() { return userFollowUp; }
    public void setUserFollowUp(String userFollowUp) { this.userFollowUp = userFollowUp; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
