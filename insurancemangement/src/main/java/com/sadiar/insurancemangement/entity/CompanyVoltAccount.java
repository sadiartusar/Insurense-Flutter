package com.sadiar.insurancemangement.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "company_volt_account")
public class CompanyVoltAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double balance = 0.0;

    private String name; // e.g., "Company Volt Account"

    public CompanyVoltAccount() {
    }

    public CompanyVoltAccount(String name) {
        this.name = name;
        this.balance = 0.0;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Double getBalance() {
        return balance;
    }

    public void setBalance(Double balance) {
        this.balance = balance;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
