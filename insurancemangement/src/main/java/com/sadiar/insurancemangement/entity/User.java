package com.sadiar.insurancemangement.entity;

import jakarta.persistence.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;
    private String name;


    @Column(unique = true)
    private String email;


    private String password;
    private String phone;
    private String photo;

    @Enumerated(EnumType.STRING)
    private Role role;



    @Column(nullable = false)
    private boolean active;
    private boolean isLock;


    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Token> tokens;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Account account;

    @OneToOne(mappedBy = "user", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private FireMoneyReceipt fireMoneyReceipt;

    @OneToOne(mappedBy = "user", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private CarMoneyReceipt carMoneyReceipt;



    public User() {
    }

    public User(int id, String name, String email, String password, String phone, String photo, Role role, boolean active, boolean isLock, List<Token> tokens, Account account, FireMoneyReceipt fireMoneyReceipt, CarMoneyReceipt carMoneyReceipt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.photo = photo;
        this.role = role;
        this.active = active;
        this.isLock = isLock;
        this.tokens = tokens;
        this.account = account;
        this.fireMoneyReceipt = fireMoneyReceipt;
        this.carMoneyReceipt = carMoneyReceipt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public boolean isLock() {
        return isLock;
    }

    public void setLock(boolean lock) {
        isLock = lock;
    }

    public List<Token> getTokens() {
        return tokens;
    }

    public void setTokens(List<Token> tokens) {
        this.tokens = tokens;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public FireMoneyReceipt getFireMoneyReceipt() {
        return fireMoneyReceipt;
    }

    public void setFireMoneyReceipt(FireMoneyReceipt fireMoneyReceipt) {
        this.fireMoneyReceipt = fireMoneyReceipt;
    }

    public CarMoneyReceipt getCarMoneyReceipt() {
        return carMoneyReceipt;
    }

    public void setCarMoneyReceipt(CarMoneyReceipt carMoneyReceipt) {
        this.carMoneyReceipt = carMoneyReceipt;
    }

    // implements Methods ----------------------------------------------------
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority(role.name()));
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return !isLock;
    }


    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return active;
    }

}
