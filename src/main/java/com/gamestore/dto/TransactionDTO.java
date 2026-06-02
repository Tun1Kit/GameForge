package com.gamestore.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TransactionDTO {
    private String id;
    private String code;
    private LocalDateTime rawDate;
    private String dateFormatted;
    private String description;
    private String type;
    private BigDecimal amount;
    private BigDecimal runningBalance;
    private String status;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDateTime getRawDate() { return rawDate; }
    public void setRawDate(LocalDateTime rawDate) { this.rawDate = rawDate; }
    public String getDateFormatted() { return dateFormatted; }
    public void setDateFormatted(String dateFormatted) { this.dateFormatted = dateFormatted; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public BigDecimal getRunningBalance() { return runningBalance; }
    public void setRunningBalance(BigDecimal runningBalance) { this.runningBalance = runningBalance; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
