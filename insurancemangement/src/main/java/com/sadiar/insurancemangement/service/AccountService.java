package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.Account;
import com.sadiar.insurancemangement.entity.CompanyVoltAccount;
import com.sadiar.insurancemangement.entity.Payment;
import com.sadiar.insurancemangement.entity.User;
import com.sadiar.insurancemangement.repository.IAccountRepository;
import com.sadiar.insurancemangement.repository.ICompanyVoltRepository;
import com.sadiar.insurancemangement.repository.IPaymentRepository;
import com.sadiar.insurancemangement.repository.IUserRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class AccountService {
    private final IAccountRepository accountRepository;
    private final IUserRepository userRepository;
    private final String COMPANY_EMAIL = "admin@insurance.com"; // Fixed admin email
    private final ICompanyVoltRepository voltRepository;
    private final IPaymentRepository paymentRepository;

    public AccountService(IAccountRepository accountRepository, IUserRepository userRepository, ICompanyVoltRepository  voltRepository, IPaymentRepository paymentRepository) {
        this.accountRepository = accountRepository;
        this.userRepository = userRepository;
        this.voltRepository = voltRepository;
        this.paymentRepository = paymentRepository;



    }



//    @PostConstruct
//    private void init() {
//        createVoltAccountIfNotExist();
//    }

    // Ensure Volt account exists after bean is created
//    @PostConstruct
//    private void initVoltAccount() {
//        if (voltRepository.findById().isEmpty()) {
//            CompanyVoltAccount voltAccount = new CompanyVoltAccount();
//            voltAccount.setId(); // fixed id
//            voltAccount.setName("Company Volt Account");
//            voltAccount.setBalance(0.0);
//            voltRepository.save(voltAccount);
//        }
//    }

    // Get user balance
    public Double getUserBalance(long id) {
        Account account = accountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User account not found"));
        return account.getAmount();
    }

//    // Deposit money into user account
//    public void depositMoney(long id, Double amount) {
//        Account account = accountRepository.findByUserId(id)
//                .orElseGet(() -> {
//
////                    Account newAccount = new Account();
//
//                    account.setAmount(0.0); // start with 0
//                    return accountRepository.save(account);
//                });
//
//        // Deposit amount add
//        account.setAmount(account.getAmount() + amount);
//        accountRepository.save(account);
//    }

//    // Deposit money into user account
//    public void depositMoney(long id, Double amount) {
//        Account account = accountRepository.findByUserId(id)
//                .orElseGet(() -> {
//                    Account account1 = accountRepository.findById(id)
//                            .orElseThrow(() -> new RuntimeException("User not found"));
//                    Account newAccount = new Account();
//                    newAccount.setId(account1);
//                    newAccount.setAmount(0.0); // start with 0
//                    return accountRepository.save(newAccount);
//                });
//
//        // Deposit amount add
//        account.setAmount(account.getAmount() + amount);
//        accountRepository.save(account);
//    }

// Deposit money into an account using the Account's primary key (ID)
public void depositMoney(Long id, Double amount) {
    Account account = accountRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Account not found with ID: " + id));

    // Add the deposit amount to the existing balance
    account.setAmount(account.getAmount() + amount);

    // Save the updated account
    accountRepository.save(account);
}


    // Fetch user account by userId
    public Account getUserAccount(long id) {
        return accountRepository.findByUserId(id)
                .orElseThrow(() -> new RuntimeException("User account not found"));
    }

    // Fetch company account
    public Account getCompanyAccount(long id) {
        CompanyVoltAccount company = voltRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Company user not found"));

        return accountRepository.findByUserId(company.getId())
                .orElseThrow(() -> new RuntimeException("Company account not found"));
    }

    // Get company balance
    public Double getCompanyBalance(long id) {
        return getCompanyAccount(id).getAmount();
    }

//    // User pays to Volt Account
//    public void payToVolt(long id, Double amount) {
//        // User account
//        Account userAccount = accountRepository.findByUserId(id)
//                .orElseThrow(() -> new RuntimeException("User account not found"));
//
//        // Volt account
//        CompanyVoltAccount voltAccount = voltRepository.findAll().stream().findFirst()
//                .orElseThrow(() -> new RuntimeException("Volt account not found"));
//
//        if (userAccount.getAmount() < amount) {
//            throw new RuntimeException("Insufficient balance in user account");
//        }
//
//        // Deduct from user
//        userAccount.setAmount(userAccount.getAmount() - amount);
//        accountRepository.save(userAccount);
//
//        // Add to Volt account
//        voltAccount.setBalance(voltAccount.getBalance() + amount);
//        voltRepository.save(voltAccount);
//
//        // Save payment record
//        Payment payment = new Payment();
//        payment.setUser(userAccount.getUser());
//        payment.setAmount(amount);
//        payment.setPaymentDate(new Date());
//        payment.setPaymentMode("ACCOUNT_TRANSFER");
//        paymentRepository.save(payment);
//    }

    // Transfer money from one user account to another (or Volt)
    public void payToVolt(long senderId, long receiverId, Double amount) {
        // Sender account
        Account senderAccount = accountRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender account not found"));

        // Receiver account
        CompanyVoltAccount receiverAccount = voltRepository.findById(receiverId)
                .orElseThrow(() -> new RuntimeException("Receiver account not found"));

        // Balance check
        if (senderAccount.getAmount() < amount) {
            throw new RuntimeException("Insufficient balance in sender account");
        }

        // Deduct from sender
        senderAccount.setAmount(senderAccount.getAmount() - amount);
        accountRepository.save(senderAccount);

        // Add to receiver
        receiverAccount.setBalance(receiverAccount.getBalance() + amount);
        voltRepository.save(receiverAccount);

        // Save payment record
        Payment payment = new Payment();
        payment.setUser(senderAccount.getUser());
        payment.setAmount(amount);
        payment.setPaymentDate(new Date());
        payment.setPaymentMode("ACCOUNT_TRANSFER");
        paymentRepository.save(payment);
    }





    // Ensure Volt account exists

//    private void createVoltAccountIfNotExist() {
//        if (voltRepository.findById(1L).isEmpty()) {
//            CompanyVoltAccount voltAccount = new CompanyVoltAccount();
//            voltAccount.setId(1L); // fixed id
//            voltAccount.setName("Company Volt Account");
//            voltRepository.save(voltAccount);
//        }
//    }
}
