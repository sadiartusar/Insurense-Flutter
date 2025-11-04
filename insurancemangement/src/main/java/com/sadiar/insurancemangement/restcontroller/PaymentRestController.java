package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.dto.PaymentDTO;
import com.sadiar.insurancemangement.dto.UserDTO;
import com.sadiar.insurancemangement.entity.*;
import com.sadiar.insurancemangement.repository.IAccountRepository;
import com.sadiar.insurancemangement.service.AccountService;
import com.sadiar.insurancemangement.service.AuthService;
import com.sadiar.insurancemangement.service.CompanyVoltService;
import com.sadiar.insurancemangement.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/payment")
public class PaymentRestController {

    private final AccountService accountService;
    private final PaymentService paymentService;
    private final CompanyVoltService companyVoltService;
    private final AuthService  authService;

    @Autowired
    private IAccountRepository accountRepository;

    public PaymentRestController(AccountService accountService, PaymentService paymentService,CompanyVoltService companyVoltService, AuthService  authService) {
        this.accountService = accountService;
        this.paymentService = paymentService;
        this.companyVoltService = companyVoltService;
        this.authService = authService;
    }

    // Deposit money into user account
//    @PostMapping("/deposit/{id}")
//    public ResponseEntity<String> deposit(@PathVariable int id, @RequestParam Double amount) {
//        try {
//            accountService.depositMoney(id, amount);
//            return ResponseEntity.ok("Deposit successful. Amount: " + amount);
//        } catch (RuntimeException e) {
//            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
//                    .body("Deposit failed: " + e.getMessage());
//        }
//    }

    @PostMapping("/deposit/{id}")
    public ResponseEntity<String> deposit(
            @PathVariable Long id,
            @RequestParam Double amount) {

        accountService.depositMoney(id, amount);
        return ResponseEntity.ok("Deposit successful");
    }

    //    // User pays to Company Volt Account
//    @PostMapping("/pay/{id}")
//    public ResponseEntity<String> payPremium(@PathVariable int id, @RequestParam Double amount) {
//        try {
//             accountService.payToVolt(id, amount);
//            return ResponseEntity.ok("message");
//        } catch (RuntimeException e) {
//            return ResponseEntity.badRequest().body("Payment failed: " + e.getMessage());
//        }
//    }

    @PostMapping("/pay")
    public ResponseEntity<String> payPremium(
            @RequestParam long senderId,
            @RequestParam long receiverId,
            @RequestParam Double amount) {
        try {
            accountService.payToVolt(senderId, receiverId, amount);
            return ResponseEntity.ok("Payment successful");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("Payment failed: " + e.getMessage());
        }
    }


//    @PostMapping("/pay/{id}")
//    public Account payPremium(@RequestBody FireMoneyReceipt b,
//                            @RequestParam int billId) {
//        return moneyReceiptService.createFireMoneyReceipt( b, billId);
//    }

    // Get user account balance
    @GetMapping("/balance/{id}")
    public ResponseEntity<Double> getUserBalance(@PathVariable long id) {
        try {
            Double balance = accountService.getUserBalance(id);
            return ResponseEntity.ok(balance);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/company-balance")
    public ResponseEntity<Double> getCompanyBalance() {
        try {
            Double balance = companyVoltService.getBalance();
            return ResponseEntity.ok(balance);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/showcompanydetails")
    public List<CompanyVoltAccount> getAll() {

        return companyVoltService.getAllCompanyDetails();
    }

//    @GetMapping("/allpaymentdetails")
//    public List<Payment> getAllPayment() {
//
//        return paymentService.getAllPaymentDetails();
//    }

    @GetMapping("/allpaymentdetails")
    public List<PaymentDTO> getAllPayment() {
        System.out.println("Hello, Fockup...");
        return paymentService.getAllPaymentDetails();
    }

    @GetMapping("")
    public List<UserDTO> getAllUserDetails() {
        return authService.getAllUserDetails();
    }

//    @GetMapping("/{userId}/account")
//    public ResponseEntity<Account> getUserAccountDetails(@PathVariable long userId) {
//
//        Account account = accountService.getUserAccount(userId);
//
//        return ResponseEntity.ok(account);
//
//    }

    @PreAuthorize("#userId == authentication.principal.id")
    @GetMapping("/{userId}")
    public ResponseEntity<?> getAccountByUserId(@PathVariable Long userId) {
        return accountRepository.findByUserId(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }


}
