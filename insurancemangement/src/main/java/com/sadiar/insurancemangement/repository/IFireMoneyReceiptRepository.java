package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.FireMoneyReceipt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IFireMoneyReceiptRepository extends JpaRepository<FireMoneyReceipt, Integer> {
}
