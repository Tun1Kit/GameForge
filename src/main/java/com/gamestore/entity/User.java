package com.gamestore.entity;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import javax.persistence.*;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    @NotBlank(message = "Email không được để trống")
    @Size(max = 100, message = "Email không được vượt quá 100 ký tự")
    private String email;

    @Column(unique = true, nullable = false, length = 100)
    @NotBlank(message = "Username không được để trống")
    @Size(min = 3, max = 50, message = "Username phải từ 3 đến 50 ký tự")
    @Pattern(regexp = "^[a-zA-Z0-9_.-]+$", message = "Username chỉ chấp nhận chữ cái không dấu, số, gạch dưới, gạch nối và dấu chấm")
    private String username;

    @Column(nullable = false)
    @NotBlank(message = "Mật khẩu không được để trống")
    private String password;

    @Column(length = 100)
    @Size(max = 100, message = "Họ tên không được vượt quá 100 ký tự")
    @org.hibernate.annotations.Nationalized
    private String fullName;

    @Column(length = 500)
    @Size(max = 500, message = "Avatar URL không được vượt quá 500 ký tự")
    private String avatar;
    private String status;

    private LocalDateTime createdAt;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<Role>();

    public User() {}

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (status == null) status = "ACTIVE";
        if (avatar == null) avatar = "default-avatar.png";
    }

    public boolean hasRole(String roleCode) {
        if (roles == null) return false;
        for (Role role : roles) {
            if (roleCode.equals(role.getCode())) return true;
        }
        return false;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("MM/yyyy"));
    }

    public Set<Role> getRoles() { return roles; }
    public void setRoles(Set<Role> roles) { this.roles = roles; }
}
