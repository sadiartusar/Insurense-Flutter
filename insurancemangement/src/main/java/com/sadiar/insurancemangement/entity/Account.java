package com.sadiar.insurancemangement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.Date;

@Entity
@Table(name = "accounts")
public class Account {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double amount;
    private String name;

    @Temporal(TemporalType.TIMESTAMP)
    private Date paymentDate = new Date();

    private String paymentMode; // UPI, CARD, CASH

    @OneToOne
    @JsonIgnore
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;



    @ManyToOne
    @JoinColumn(name = "fire_policy_id")
    private FirePolicy firePolicy;

    @ManyToOne
    @JoinColumn(name = "car_policy_id")
    private CarPolicy carPolicy;

    public Account() {
    }

    public Account(Long id, Double amount,String name, Date paymentDate, String paymentMode, User user, FirePolicy firePolicy, CarPolicy carPolicy) {
        this.id = id;
        this.amount = amount;
        this.name = name;
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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
