package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.entity.FireMoneyReceipt;
import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.repository.IFireBillRepository;
import com.sadiar.insurancemangement.repository.IFireMoneyReceiptRepository;
import com.sadiar.insurancemangement.repository.IFirePolicyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FireMoneyReceiptService {

//    @Autowired
//    private IFireMoneyReceiptRepository fireMoneyReceiptRepository;
//
//    @Autowired
//    private IFireBillRepository fireBillRepository;

    private final IFireBillRepository fireBillRepository;
    private final IFireMoneyReceiptRepository fireMoneyReceiptRepository;

    public FireMoneyReceiptService(IFireBillRepository fireBillRepository, IFireMoneyReceiptRepository fireMoneyReceiptRepository) {
        this.fireBillRepository = fireBillRepository;
        this.fireMoneyReceiptRepository = fireMoneyReceiptRepository;
    }

    public List<FireMoneyReceipt> getAllMoneyReceipt() {
        return  fireMoneyReceiptRepository.findAll();
    }

    // Create new bill linked to a policy
    public FireMoneyReceipt createFireMoneyReceipt(FireMoneyReceipt fireMoneyReceipt, int billId) {
        FireBill fireBill = fireBillRepository.findById(billId)
                .orElseThrow(() -> new RuntimeException("Policy not found with id " + billId));
        fireMoneyReceipt.setFireBill(fireBill);
        return fireMoneyReceiptRepository.save(fireMoneyReceipt);
    }

//    public void saveMoneyReceipt(FireMoneyReceipt mr) {
//        FireBill fireBill = fireBillRepository.findById(mr.getFireBill().getId())
//                .orElseThrow(
//                        () -> new RuntimeException("Bill not found " + mr.getFireBill().getId())
//                );
//        mr.setFireBill(fireBill);
//        fireMoneyReceiptRepository.save(mr);
//    }


    public FireMoneyReceipt getFireMoneyReceiptById(int id) {
        return fireMoneyReceiptRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("MoneyReceipt not found with ID: " + id));
    }

    public void deleteFireMoneyReceipt(int id) {
        fireMoneyReceiptRepository.deleteById(id);
    }

    public void updateMoneyReceipt(FireMoneyReceipt updatedFireMoneyReceipt, int id) {
        // Fetch the existing MoneyReceipt from the database
        FireMoneyReceipt existingMoneyReceipt = fireMoneyReceiptRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("MoneyReceipt not found with ID: " + id));

        // Update the fields of the existing MoneyReceipt with values from the updated one
        existingMoneyReceipt.setIssuingOffice(updatedFireMoneyReceipt.getIssuingOffice());
        existingMoneyReceipt.setClassOfInsurance(updatedFireMoneyReceipt.getClassOfInsurance());
        existingMoneyReceipt.setDate(updatedFireMoneyReceipt.getDate());
        existingMoneyReceipt.setModeOfPayment(updatedFireMoneyReceipt.getModeOfPayment());
        existingMoneyReceipt.setIssuedAgainst(updatedFireMoneyReceipt.getIssuedAgainst());

        // Check if Bill exists and set it, if necessary
        if (updatedFireMoneyReceipt.getFireBill() != null) {
            FireBill fireBill = fireBillRepository.findById(updatedFireMoneyReceipt.getFireBill().getId())
                    .orElseThrow(() -> new RuntimeException("Bill not found with ID: " + updatedFireMoneyReceipt.getFireBill().getId()));
            existingMoneyReceipt.setFireBill(fireBill);
        }

        // Save the updated MoneyReceipt
        fireMoneyReceiptRepository.save(existingMoneyReceipt);
    }

    // Get bill by ID
    public Optional<FireMoneyReceipt> getReceiptById(int id) {
        return fireMoneyReceiptRepository.findById(id);
    }


}
