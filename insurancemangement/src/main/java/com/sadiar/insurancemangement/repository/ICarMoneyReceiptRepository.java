package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.CarMoneyReceipt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ICarMoneyReceiptRepository extends JpaRepository<CarMoneyReceipt, Integer> {
}
