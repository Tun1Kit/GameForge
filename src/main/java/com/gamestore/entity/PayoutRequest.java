package com.gamestore.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import javax.persistence.*;

@Entity
@Table(name = "payout_requests")
public class PayoutRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "publisher_id", nullable = false)
    private PublisherProfile publisher;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(name = "bankAccountInfo")
    private String bankAccountInfo;

    @Column(nullable = false, length = 50)
    private String status;

    private LocalDateTime requestedAt;
    private LocalDateTime processedAt;

    public PayoutRequest() {}

    @PrePersist
    public void prePersist() {
        if (status == null) status = "PENDING";
        if (requestedAt == null) requestedAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public PublisherProfile getPublisher() { return publisher; }
    public void setPublisher(PublisherProfile publisher) { this.publisher = publisher; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getBankAccountInfo() { return bankAccountInfo; }
    public void setBankAccountInfo(String bankAccountInfo) { this.bankAccountInfo = bankAccountInfo; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }

    public LocalDateTime getProcessedAt() { return processedAt; }
    public void setProcessedAt(LocalDateTime processedAt) { this.processedAt = processedAt; }
}
