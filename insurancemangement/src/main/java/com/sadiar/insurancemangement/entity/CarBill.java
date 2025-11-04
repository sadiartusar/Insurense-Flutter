package com.sadiar.insurancemangement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "carbill")
public class CarBill {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private double carRate;
    private  double rsd;
    private  double netPremium;
    private  double tax;
    private  double grossPremium;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "carPolicyId", nullable = false)
    private CarPolicy carPolicy;

    @JsonIgnore
    @OneToMany(mappedBy = "carBill", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<CarMoneyReceipt> carMoneyReceipts;

    public CarBill() {
    }

    public CarBill(int id, double carRate, double rsd, double netPremium, double tax, double grossPremium, CarPolicy carPolicy, List<CarMoneyReceipt> carMoneyReceipts) {
        this.id = id;
        this.carRate = carRate;
        this.rsd = rsd;
        this.netPremium = netPremium;
        this.tax = tax;
        this.grossPremium = grossPremium;
        this.carPolicy = carPolicy;
        this.carMoneyReceipts = carMoneyReceipts;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public double getCarRate() {
        return carRate;
    }

    public void setCarRate(double carRate) {
        this.carRate = carRate;
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

    public CarPolicy getCarPolicy() {
        return carPolicy;
    }

    public void setCarPolicy(CarPolicy carPolicy) {
        this.carPolicy = carPolicy;
    }

    public List<CarMoneyReceipt> getCarMoneyReceipts() {
        return carMoneyReceipts;
    }

    public void setCarMoneyReceipts(List<CarMoneyReceipt> carMoneyReceipts) {
        this.carMoneyReceipts = carMoneyReceipts;
    }
}
