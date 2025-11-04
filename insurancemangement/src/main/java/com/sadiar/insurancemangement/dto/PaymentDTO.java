package com.sadiar.insurancemangement.dto;

import com.sadiar.insurancemangement.entity.User;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;

import java.util.Date;

public class PaymentDTO {

    private Long id;
    private Double amount;
    @Temporal(TemporalType.TIMESTAMP)
    private Date paymentDate = new Date();
    private String paymentMode;
    private UserDTO user;

    public PaymentDTO() {
    }

    public PaymentDTO(Long id, Double amount, Date paymentDate, String paymentMode, UserDTO user) {
        this.id = id;
        this.amount = amount;
        this.paymentDate = paymentDate;
        this.paymentMode = paymentMode;
        this.user = user;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }

    public Date getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Date paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getPaymentMode() {
        return paymentMode;
    }

    public void setPaymentMode(String paymentMode) {
        this.paymentMode = paymentMode;
    }

    public UserDTO getUser() {
        return user;
    }

    public void setUser(UserDTO user) {
        this.user = user;
    }
}
