package com.sadiar.insurancemangement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.Date;

@Entity
@Table(name = "payments")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double amount;

    @Temporal(TemporalType.TIMESTAMP)
    private Date paymentDate = new Date();

    private String paymentMode; // UPI, CARD, CASH

    @ManyToOne
    @JsonIgnore
    @JoinColumn(name = "user_id")
    private User user; // যিনি payment করছেন

    @ManyToOne
    @JsonIgnore
    @JoinColumn(name = "fire_policy_id")
    private FirePolicy firePolicy;

    @ManyToOne
    @JsonIgnore
    @JoinColumn(name = "car_policy_id")
    private CarPolicy carPolicy;

    public Payment() {
    }

    public Payment(Long id, Double amount, Date paymentDate, String paymentMode, User user, FirePolicy firePolicy, CarPolicy carPolicy) {
        this.id = id;
        this.amount = amount;
        this.paymentDate = paymentDate;
        this.paymentMode = paymentMode;
        this.user = user;
        this.firePolicy = firePolicy;
        this.carPolicy = carPolicy;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public FirePolicy getFirePolicy() {
        return firePolicy;
    }

    public void setFirePolicy(FirePolicy firePolicy) {
        this.firePolicy = firePolicy;
    }

    public CarPolicy getCarPolicy() {
        return carPolicy;
    }

    public void setCarPolicy(CarPolicy carPolicy) {
        this.carPolicy = carPolicy;
    }
}
