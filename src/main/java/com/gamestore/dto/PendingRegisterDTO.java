package com.gamestore.dto;

import java.time.LocalDateTime;

public class PendingRegisterDTO {

    private String username;
    private String fullName;
    private String email;
    private String encodedPassword;
    private String otp;
    private LocalDateTime expiredAt;

    public PendingRegisterDTO() {}

    public PendingRegisterDTO(String username, String fullName, String email,
                              String encodedPassword, String otp, LocalDateTime expiredAt) {
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.encodedPassword = encodedPassword;
        this.otp = otp;
        this.expiredAt = expiredAt;
    }

    public boolean isExpired() {
        return expiredAt == null || LocalDateTime.now().isAfter(expiredAt);
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getEncodedPassword() { return encodedPassword; }
    public void setEncodedPassword(String encodedPassword) { this.encodedPassword = encodedPassword; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public LocalDateTime getExpiredAt() { return expiredAt; }
    public void setExpiredAt(LocalDateTime expiredAt) { this.expiredAt = expiredAt; }
}
