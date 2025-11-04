package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.CompanyVoltAccount;
import com.sadiar.insurancemangement.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ICompanyVoltRepository extends JpaRepository<CompanyVoltAccount,Long> {
    Optional<CompanyVoltAccount> findById(long id);
}
