package com.gamestore.entity;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List; // Phải là java.util.List
import java.util.Set;
import javax.persistence.*;

@Entity
@Table(name = "games")
public class Game {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String slug;
    
    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    private BigDecimal price;

    @Column(name = "original_price")
    private BigDecimal originalPrice;

    private String developer;

    @Column(name = "releaseDate")
    @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd")
    private java.time.LocalDate releaseDate;

    @Column(name = "minimumRequirements", columnDefinition = "NVARCHAR(MAX)")
    private String minimumRequirements;

    @Column(name = "recommendedRequirements", columnDefinition = "NVARCHAR(MAX)")
    private String recommendedRequirements;

    @Column(name = "createdAt", nullable = false)
    private java.time.LocalDateTime createdAt;

    private String status;

    @Column(name = "badges", columnDefinition = "VARCHAR(MAX)")
    private String badges;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "publisher_id")
    private PublisherProfile publisher;

    @Column(name = "approvedAt")
    private java.time.LocalDateTime approvedAt;

    @Column(name = "approvedBy")
    private String approvedBy;

    // Sửa lại: Dùng List<GameMedia> và thêm FetchType.EAGER để load ảnh nhanh
    @OneToMany(mappedBy = "game", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private List<GameMedia> mediaList;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "game_categories",
        joinColumns = @JoinColumn(name = "game_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private Set<Category> categories = new HashSet<>();

    // --- BẮT BUỘC: Bạn phải chuột phải chọn Source -> Generate Getters and Setters... 
    // để tạo lại cho biến mediaList mới này nhé! ---
    
    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = java.time.LocalDateTime.now();
        if (status == null) status = "ACTIVE";
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public BigDecimal getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }
    
    public String getDeveloper() { return developer; }
    public void setDeveloper(String developer) { this.developer = developer; }
    public java.time.LocalDate getReleaseDate() { return releaseDate; }
    public void setReleaseDate(java.time.LocalDate releaseDate) { this.releaseDate = releaseDate; }
    public String getMinimumRequirements() { return minimumRequirements; }
    public void setMinimumRequirements(String minimumRequirements) { this.minimumRequirements = minimumRequirements; }
    public String getRecommendedRequirements() { return recommendedRequirements; }
    public void setRecommendedRequirements(String recommendedRequirements) { this.recommendedRequirements = recommendedRequirements; }
    public java.time.LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.time.LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getBadges() { return badges; }
    public void setBadges(String badges) { this.badges = badges; }
    public List<GameMedia> getMediaList() { return mediaList; }
    public void setMediaList(List<GameMedia> mediaList) { this.mediaList = mediaList; }
    public Set<Category> getCategories() { return categories; }
    public void setCategories(Set<Category> categories) { this.categories = categories; }

    public PublisherProfile getPublisher() { return publisher; }
    public void setPublisher(PublisherProfile publisher) { this.publisher = publisher; }

    public java.time.LocalDateTime getApprovedAt() { return approvedAt; }
    public void setApprovedAt(java.time.LocalDateTime approvedAt) { this.approvedAt = approvedAt; }

    public String getApprovedBy() { return approvedBy; }
    public void setApprovedBy(String approvedBy) { this.approvedBy = approvedBy; }
}