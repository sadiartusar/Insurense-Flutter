package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.CarPolicy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ICarPolicyRepository extends JpaRepository<CarPolicy, Integer> {
}
