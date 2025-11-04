package com.sadiar.insurancemangement.entity;

import jakarta.persistence.*;

import java.util.Date;

@Entity
@Table(name = "moneyreceipts")
public class FireMoneyReceipt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private String issuingOffice;
    private String classOfInsurance;

    @Temporal(TemporalType.DATE)
    private Date date = new Date();
    private String modeOfPayment;
    private String issuedAgainst;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "billId")
    private FireBill fireBill;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private User user;



    public FireMoneyReceipt() {
    }

    public FireMoneyReceipt(int id, String issuingOffice, String classOfInsurance, Date date, String modeOfPayment, String issuedAgainst, FireBill fireBill, User user) {
        this.id = id;
        this.issuingOffice = issuingOffice;
        this.classOfInsurance = classOfInsurance;
        this.date = date;
        this.modeOfPayment = modeOfPayment;
        this.issuedAgainst = issuedAgainst;
        this.fireBill = fireBill;
        this.user = user;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getIssuingOffice() {
        return issuingOffice;
    }

    public void setIssuingOffice(String issuingOffice) {
        this.issuingOffice = issuingOffice;
    }

    public String getClassOfInsurance() {
        return classOfInsurance;
    }

    public void setClassOfInsurance(String classOfInsurance) {
        this.classOfInsurance = classOfInsurance;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getModeOfPayment() {
        return modeOfPayment;
    }

    public void setModeOfPayment(String modeOfPayment) {
        this.modeOfPayment = modeOfPayment;
    }

    public String getIssuedAgainst() {
        return issuedAgainst;
    }

    public void setIssuedAgainst(String issuedAgainst) {
        this.issuedAgainst = issuedAgainst;
    }

    public FireBill getFireBill() {
        return fireBill;
    }

    public void setFireBill(FireBill fireBill) {
        this.fireBill = fireBill;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
