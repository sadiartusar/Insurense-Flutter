package com.sadiar.insurancemangement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "bills")
public class FireBill {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private  double fire;
    private  double rsd;
    private  double netPremium;
    private  double tax;
    private  double grossPremium;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "policyId", nullable = false)
    private FirePolicy firePolicy;

    @JsonIgnore
    @OneToMany(mappedBy = "fireBill", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<FireMoneyReceipt> fireMoneyReceipts;

    public FireBill() {
    }

    public FireBill(int id, double fire, double rsd, double netPremium, double tax, double grossPremium, FirePolicy firePolicy, List<FireMoneyReceipt> fireMoneyReceipts) {
        this.id = id;
        this.fire = fire;
        this.rsd = rsd;
        this.netPremium = netPremium;
        this.tax = tax;
        this.grossPremium = grossPremium;
        this.firePolicy = firePolicy;
        this.fireMoneyReceipts = fireMoneyReceipts;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public double getFire() {
        return fire;
    }

    public void setFire(double fire) {
        this.fire = fire;
    }

    public double getRsd() {
        return rsd;
    }

    public void setRsd(double rsd) {
        this.rsd = rsd;
    }

    public double getNetPremium() {
        return netPremium;
    }

    public void setNetPremium(double netPremium) {
        this.netPremium = netPremium;
    }

    public double getTax() {
        return tax;
    }

    public void setTax(double tax) {
        this.tax = tax;
    }

    public double getGrossPremium() {
        return grossPremium;
    }

    public void setGrossPremium(double grossPremium) {
        this.grossPremium = grossPremium;
    }

    public FirePolicy getFirePolicy() {
        return firePolicy;
    }

    public void setFirePolicy(FirePolicy firePolicy) {
        this.firePolicy = firePolicy;
    }

    public List<FireMoneyReceipt> getFireMoneyReceipts() {
        return fireMoneyReceipts;
    }

    public void setFireMoneyReceipts(List<FireMoneyReceipt> fireMoneyReceipts) {
        this.fireMoneyReceipts = fireMoneyReceipts;
    }
}
