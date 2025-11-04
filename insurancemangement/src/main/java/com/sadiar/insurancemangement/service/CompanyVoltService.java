package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.CompanyVoltAccount;
import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.repository.ICompanyVoltRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CompanyVoltService {
    @Autowired
    private ICompanyVoltRepository voltRepository;

    // Volt account get (id=1 ধরে নিচ্ছি)
    public CompanyVoltAccount getVoltAccount() {
        return voltRepository.findById(1L)
                .orElseThrow(() -> new RuntimeException("Volt Account not found"));
    }

//    // Volt account auto-create যদি না থাকে
//    @PostConstruct
//    public void createVoltAccountIfNotExist() {
//        if (voltRepository.count() == 0) {
//            CompanyVoltAccount volt = new CompanyVoltAccount();
//            volt.setId(1L); // fixed id
//            volt.setBalance(0.0);
//            voltRepository.save(volt);
//        }
//    }

    // Deposit to volt account
    public void addMoney(Double amount) {
        CompanyVoltAccount volt = getVoltAccount();
        volt.setBalance(volt.getBalance() + amount);
        voltRepository.save(volt);
    }

    // Get balance
    public Double getBalance() {
        return getVoltAccount().getBalance();

    }

    public List<CompanyVoltAccount> getAllCompanyDetails(){
        return voltRepository.findAll();
    }
}
