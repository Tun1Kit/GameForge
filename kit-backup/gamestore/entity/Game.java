package com.gamestore.entity;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.persistence.*;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;

@Entity
@Table(name = "games")
public class Game {

    // ==========================================================
    // 1. CÁC THUỘC TÍNH CƠ BẢN (BASIC FIELDS)
    // ==========================================================
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String slug;
    private String developer;
    private String status;
    private BigDecimal price;

    @Column(columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "minimum_requirements", columnDefinition = "NVARCHAR(MAX)")
    private String minimumRequirements;

    @Column(name = "recommended_requirements", columnDefinition = "NVARCHAR(MAX)")
    private String recommendedRequirements;


    // ==========================================================
    // 2. CÁC MỐI QUAN HỆ ĐỘNG (RELATIONSHIPS & FETCH CONFIG)
    // ==========================================================
    
    // Tự động phân tách câu lệnh SELECT phụ để tránh lỗi MultipleBagFetchException
    @OneToMany(mappedBy = "game", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    @Fetch(FetchMode.SUBSELECT)
    private List<GameMedia> mediaList;

    @OneToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    @JoinColumn(name = "game_id")
    @Fetch(FetchMode.SUBSELECT)
    private List<GameSpecification> specifications;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "game_categories",
        joinColumns = @JoinColumn(name = "game_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private Set<Category> categories = new HashSet<>();


    // ==========================================================
    // 3. HÀM GETTER VÀ SETTER HỆ THỐNG
    // ==========================================================
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getDeveloper() { return developer; }
    public void setDeveloper(String developer) { this.developer = developer; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getMinimumRequirements() { return minimumRequirements; }
    public void setMinimumRequirements(String minimumRequirements) { this.minimumRequirements = minimumRequirements; }

    public String getRecommendedRequirements() { return recommendedRequirements; }
    public void setRecommendedRequirements(String recommendedRequirements) { this.recommendedRequirements = recommendedRequirements; }

    public List<GameMedia> getMediaList() { return mediaList; }
    public void setMediaList(List<GameMedia> mediaList) { this.mediaList = mediaList; }

    public List<GameSpecification> getSpecifications() { return specifications; }
    public void setSpecifications(List<GameSpecification> specifications) { this.specifications = specifications; }

    public Set<Category> getCategories() { return categories; }
    public void setCategories(Set<Category> categories) { this.categories = categories; }
}