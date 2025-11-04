package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.CarBill;
import com.sadiar.insurancemangement.entity.CarMoneyReceipt;
import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.entity.FireMoneyReceipt;
import com.sadiar.insurancemangement.repository.ICarBillRepository;
import com.sadiar.insurancemangement.repository.ICarMoneyReceiptRepository;
import com.sadiar.insurancemangement.repository.IFireBillRepository;
import com.sadiar.insurancemangement.repository.IFireMoneyReceiptRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CarMoneyReceiptService {

    //    @Autowired
//    private IFireMoneyReceiptRepository fireMoneyReceiptRepository;
//
//    @Autowired
//    private IFireBillRepository fireBillRepository;

    private final ICarBillRepository carBillRepository;
    private final ICarMoneyReceiptRepository carMoneyReceiptRepository;

    public CarMoneyReceiptService(ICarBillRepository carBillRepository, ICarMoneyReceiptRepository carMoneyReceiptRepository) {
        this.carBillRepository = carBillRepository;
        this.carMoneyReceiptRepository = carMoneyReceiptRepository;
    }

    public List<CarMoneyReceipt> getAllMoneyReceipt() {
        return  carMoneyReceiptRepository.findAll();
    }

    // Create new bill linked to a policy
    public CarMoneyReceipt createCarMoneyReceipt(CarMoneyReceipt carMoneyReceipt, int carBillId) {
        CarBill carBill = carBillRepository.findById(carBillId)
                .orElseThrow(() -> new RuntimeException("Policy not found with id " + carBillId));
        carMoneyReceipt.setCarBill(carBill);
        return carMoneyReceiptRepository.save(carMoneyReceipt);
    }

//    public void saveMoneyReceipt(FireMoneyReceipt mr) {
//        FireBill fireBill = fireBillRepository.findById(mr.getFireBill().getId())
//                .orElseThrow(
//                        () -> new RuntimeException("Bill not found " + mr.getFireBill().getId())
//                );
//        mr.setFireBill(fireBill);
//        fireMoneyReceiptRepository.save(mr);
//    }


    public CarMoneyReceipt getCarMoneyReceiptById(int id) {
        return carMoneyReceiptRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("MoneyReceipt not found with ID: " + id));
    }

    public void deleteCarMoneyReceipt(int id) {
        carMoneyReceiptRepository.deleteById(id);
    }

    public void updateMoneyReceipt(CarMoneyReceipt updatedCarMoneyReceipt, int id) {
        // Fetch the existing MoneyReceipt from the database
        CarMoneyReceipt existingMoneyReceipt = carMoneyReceiptRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("MoneyReceipt not found with ID: " + id));

        // Update the fields of the existing MoneyReceipt with values from the updated one
        existingMoneyReceipt.setIssuingOffice(updatedCarMoneyReceipt.getIssuingOffice());
        existingMoneyReceipt.setClassOfInsurance(updatedCarMoneyReceipt.getClassOfInsurance());
        existingMoneyReceipt.setDate(updatedCarMoneyReceipt.getDate());
        existingMoneyReceipt.setModeOfPayment(updatedCarMoneyReceipt.getModeOfPayment());
        existingMoneyReceipt.setIssuedAgainst(updatedCarMoneyReceipt.getIssuedAgainst());

        // Check if Bill exists and set it, if necessary
        if (updatedCarMoneyReceipt.getCarBill() != null) {
            CarBill carBill = carBillRepository.findById(updatedCarMoneyReceipt.getCarBill().getId())
                    .orElseThrow(() -> new RuntimeException("Bill not found with ID: " + updatedCarMoneyReceipt.getCarBill().getId()));
            existingMoneyReceipt.setCarBill(carBill);
        }

        // Save the updated MoneyReceipt
        carMoneyReceiptRepository.save(existingMoneyReceipt);
    }

    // Get bill by ID
    public Optional<CarMoneyReceipt> getReceiptById(int id) {
        return carMoneyReceiptRepository.findById(id);
    }
}
