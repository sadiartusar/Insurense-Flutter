package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IAccountRepository extends JpaRepository<Account, Long> {
    Optional<Account> findByUserId(long id);
    Optional<Account> findByUserEmail(String name);
}
