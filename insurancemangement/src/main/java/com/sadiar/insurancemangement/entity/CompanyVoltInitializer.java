package com.sadiar.insurancemangement.entity;

import com.sadiar.insurancemangement.repository.ICompanyVoltRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
public class CompanyVoltInitializer implements ApplicationRunner{

    private final ICompanyVoltRepository voltRepository;

    public CompanyVoltInitializer(ICompanyVoltRepository voltRepository) {
        this.voltRepository = voltRepository;
    }

    @Override
    public void run(ApplicationArguments args) throws Exception {
        if (voltRepository.count() == 0) {
            CompanyVoltAccount voltAccount = new CompanyVoltAccount();
            voltAccount.setName("Company Volt Account");
            voltAccount.setBalance(0.0);
            voltRepository.save(voltAccount);
        }

    }


}
