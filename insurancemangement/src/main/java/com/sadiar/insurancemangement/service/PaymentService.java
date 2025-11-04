package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.dto.PaymentDTO;
import com.sadiar.insurancemangement.dto.UserDTO;
import com.sadiar.insurancemangement.entity.Account;
import com.sadiar.insurancemangement.entity.CompanyVoltAccount;
import com.sadiar.insurancemangement.entity.Payment;
import com.sadiar.insurancemangement.entity.User;
import com.sadiar.insurancemangement.repository.IPaymentRepository;
import jakarta.transaction.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.Date;
import java.util.List;

@Service
public class PaymentService {

    private final AccountService accountService;
    private final IPaymentRepository paymentRepository;

    public PaymentService(AccountService accountService, IPaymentRepository paymentRepository) {
        this.accountService = accountService;
        this.paymentRepository = paymentRepository;
    }

//    // Pay premium from user → company
//    @Transactional
//    public void payPremium(int id, Double amount) {
//
//        Account userAccount = accountService.getUserAccount(id);
//        Account companyAccount = accountService.getCompanyAccount(id);
//
//        if (userAccount.getAmount() < amount) {
//            throw new RuntimeException("Insufficient balance!");
//        }
//
//        // Transfer money
//        userAccount.setAmount(userAccount.getAmount() - amount);
//        companyAccount.setAmount(companyAccount.getAmount() + amount);
//
//        // Save updated accounts
//        accountService.depositMoney(na, 0.0); // saves user account
//        accountService.getCompanyAccount(id); // saves company account via repository
//        // Alternatively, create saveAccount(Account account) method in AccountService for clarity
//
//        // Save payment record
//        Payment payment = new Payment();
//        payment.setUser(userAccount.getUser());
//        payment.setAmount(amount);
//        payment.setPaymentDate(new Date());
//        payment.setPaymentMode("ACCOUNT_TRANSFER"); // or UPI/CARD
//        paymentRepository.save(payment);
//    }


    // Pay premium from user → company
//    @Transactional
//    public void payPremium(long id, Double amount) {
//
//        Account userAccount = accountService.getUserAccount(id);
//        Account companyAccount = accountService.getCompanyAccount(id);
//
//        if (userAccount.getAmount() < amount) {
//            throw new RuntimeException("Insufficient balance!");
//        }
//
//        // Transfer money
//        userAccount.setAmount(userAccount.getAmount() - amount);
//        companyAccount.setAmount(companyAccount.getAmount() + amount);
//
//        // Save updated accounts
//        accountService.depositMoney(id, 0.0); // saves user account
//        accountService.getCompanyAccount(id); // saves company account via repository
//        // Alternatively, create saveAccount(Account account) method in AccountService for clarity
//
//        // Save payment record
//        Payment payment = new Payment();
//        payment.setUser(userAccount.getUser());
//        payment.setAmount(amount);
//        payment.setPaymentDate(new Date());
//        payment.setPaymentMode("ACCOUNT_TRANSFER"); // or UPI/CARD
//        paymentRepository.save(payment);
//    }


//    public List<Payment> getAllPaymentDetails(){
//        return paymentRepository.findAll();
//    }

    public List<PaymentDTO> getAllPaymentDetails() {
        return paymentRepository.findAll().stream().map(atten -> {
            PaymentDTO dto = new PaymentDTO();
            dto.setId(atten.getId());
            dto.setAmount(atten.getAmount());
            dto.setPaymentDate(atten.getPaymentDate());
            dto.setPaymentMode(atten.getPaymentMode());


            User user = atten.getUser();
            if (user != null) {
                UserDTO userDTO = new UserDTO();
                userDTO.setId(user.getId());
                userDTO.setName(user.getName());
                userDTO.setEmail(user.getEmail());
                userDTO.setPhone(user.getPhone());

                dto.setUser(userDTO);


            }
            return dto;
        }).toList();
    }


}
