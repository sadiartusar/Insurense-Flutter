package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.CarBill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ICarBillRepository extends JpaRepository<CarBill,Integer> {
    List<CarBill> findByCarPolicyId(int carPolicyId);
}
