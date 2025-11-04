package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.Admin;
import com.sadiar.insurancemangement.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IAdminRepository extends JpaRepository<Admin,Integer> {
    Optional<Admin> findByEmail(String email);
}
