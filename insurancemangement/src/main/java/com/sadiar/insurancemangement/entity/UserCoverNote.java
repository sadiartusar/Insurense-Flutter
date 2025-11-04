package com.sadiar.insurancemangement.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_cover")
public class UserCoverNote{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String recipientEmail;

    private String coverNoteNo;
    private String policyholder;
    private double sumInsured;
    private double grossPremium;
    private double monthlyPremium;
    private LocalDateTime issuedAt;

    public UserCoverNote() {
    }

    public UserCoverNote(Long id, String recipientEmail, String coverNoteNo, String policyholder, double sumInsured, double grossPremium, double monthlyPremium, LocalDateTime issuedAt) {
        this.id = id;
        this.recipientEmail = recipientEmail;
        this.coverNoteNo = coverNoteNo;
        this.policyholder = policyholder;
        this.sumInsured = sumInsured;
        this.grossPremium = grossPremium;
        this.monthlyPremium = monthlyPremium;
        this.issuedAt = issuedAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRecipientEmail() {
        return recipientEmail;
    }

    public void setRecipientEmail(String recipientEmail) {
        this.recipientEmail = recipientEmail;
    }

    public String getCoverNoteNo() {
        return coverNoteNo;
    }

    public void setCoverNoteNo(String coverNoteNo) {
        this.coverNoteNo = coverNoteNo;
    }

    public String getPolicyholder() {
        return policyholder;
    }

    public void setPolicyholder(String policyholder) {
        this.policyholder = policyholder;
    }

    public double getSumInsured() {
        return sumInsured;
    }

    public void setSumInsured(double sumInsured) {
        this.sumInsured = sumInsured;
    }

    public double getGrossPremium() {
        return grossPremium;
    }

    public void setGrossPremium(double grossPremium) {
        this.grossPremium = grossPremium;
    }

    public double getMonthlyPremium() {
        return monthlyPremium;
    }

    public void setMonthlyPremium(double monthlyPremium) {
        this.monthlyPremium = monthlyPremium;
    }

    public LocalDateTime getIssuedAt() {
        return issuedAt;
    }

    public void setIssuedAt(LocalDateTime issuedAt) {
        this.issuedAt = issuedAt;
    }
}
