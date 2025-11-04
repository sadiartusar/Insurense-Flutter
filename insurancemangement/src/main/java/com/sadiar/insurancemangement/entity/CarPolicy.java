package com.sadiar.insurancemangement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

import java.util.Date;
import java.util.List;

@Entity
@Table(name = "cars")
public class CarPolicy {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    @Temporal(TemporalType.DATE)
    private Date date=new Date();

    private String bankName;
    private String policyholder;
    private String address;
    private String stockInsured;
    private double sumInsured;
    private String interestInsured;
    private String coverage;
    private String location;
    private String construction;
    private String owner;
    private String usedAs;

    @Temporal(TemporalType.DATE)
    private Date periodFrom;

    @Temporal(TemporalType.DATE)
    private Date periodTo;

    @JsonIgnore
    @OneToMany(mappedBy = "carPolicy", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<CarBill> carBills;

    public CarPolicy() {
    }

    public CarPolicy(int id, Date date, String bankName, String policyholder, String address, String stockInsured, double sumInsured, String interestInsured, String coverage, String location, String construction, String owner, String usedAs, Date periodFrom, Date periodTo, List<CarBill> carBills) {
        this.id = id;
        this.date = date;
        this.bankName = bankName;
        this.policyholder = policyholder;
        this.address = address;
        this.stockInsured = stockInsured;
        this.sumInsured = sumInsured;
        this.interestInsured = interestInsured;
        this.coverage = coverage;
        this.location = location;
        this.construction = construction;
        this.owner = owner;
        this.usedAs = usedAs;
        this.periodFrom = periodFrom;
        this.periodTo = periodTo;
        this.carBills = carBills;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
    }

    public String getPolicyholder() {
        return policyholder;
    }

    public void setPolicyholder(String policyholder) {
        this.policyholder = policyholder;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStockInsured() {
        return stockInsured;
    }

    public void setStockInsured(String stockInsured) {
        this.stockInsured = stockInsured;
    }

    public double getSumInsured() {
        return sumInsured;
    }

    public void setSumInsured(double sumInsured) {
        this.sumInsured = sumInsured;
    }

    public String getInterestInsured() {
        return interestInsured;
    }

    public void setInterestInsured(String interestInsured) {
        this.interestInsured = interestInsured;
    }

    public String getCoverage() {
        return coverage;
    }

    public void setCoverage(String coverage) {
        this.coverage = coverage;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getConstruction() {
        return construction;
    }

    public void setConstruction(String construction) {
        this.construction = construction;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getUsedAs() {
        return usedAs;
    }

    public void setUsedAs(String usedAs) {
        this.usedAs = usedAs;
    }

    public Date getPeriodFrom() {
        return periodFrom;
    }

    public void setPeriodFrom(Date periodFrom) {
        this.periodFrom = periodFrom;
    }

    public Date getPeriodTo() {
        return periodTo;
    }

    public void setPeriodTo(Date periodTo) {
        this.periodTo = periodTo;
    }

    public List<CarBill> getCarBills() {
        return carBills;
    }

    public void setCarBills(List<CarBill> carBills) {
        this.carBills = carBills;
    }
}
