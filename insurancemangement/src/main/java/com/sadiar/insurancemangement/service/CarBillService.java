package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.CarBill;
import com.sadiar.insurancemangement.entity.CarPolicy;
import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.repository.ICarBillRepository;
import com.sadiar.insurancemangement.repository.ICarPolicyRepository;
import com.sadiar.insurancemangement.repository.IFireBillRepository;
import com.sadiar.insurancemangement.repository.IFirePolicyRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CarBillService {

    private final ICarBillRepository carBillRepository;
    private final ICarPolicyRepository carPolicyRepository;

    public CarBillService(ICarBillRepository carBillRepository, ICarPolicyRepository carPolicyRepository) {
        this.carBillRepository = carBillRepository;
        this.carPolicyRepository = carPolicyRepository;
    }

    // Get all bills
    public List<CarBill> getAllBills() {
        return carBillRepository.findAll();
    }

    // Get bill by ID
    public Optional<CarBill> getBillById(int id) {
        return carBillRepository.findById(id);
    }

    // Get bills for a specific policy
    public List<CarBill> getBillsByPolicyId(int carPolicyId) {
        return carBillRepository.findByCarPolicyId(carPolicyId);
    }

    // Create new bill linked to a policy
    public CarBill createBill(CarBill carBill, int carPolicyId) {
        CarPolicy policy = carPolicyRepository.findById(carPolicyId)
                .orElseThrow(() -> new RuntimeException("Policy not found with id " + carPolicyId));
        carBill.setCarPolicy(policy);
        return carBillRepository.save(carBill);
    }

    // Update existing bill
    public CarBill updateBill(int id, CarBill updatedBill) {
        return carBillRepository.findById(id)
                .map(existingBill -> {
                    existingBill.setCarRate(updatedBill.getCarRate());
                    existingBill.setRsd(updatedBill.getRsd());
                    existingBill.setNetPremium(updatedBill.getNetPremium());
                    existingBill.setTax(updatedBill.getTax());
                    existingBill.setGrossPremium(updatedBill.getGrossPremium());
                    return carBillRepository.save(existingBill);
                })
                .orElseThrow(() -> new RuntimeException("Bill not found with id " + id));
    }

    // Delete bill by ID
    public void deleteBill(int id) {
        carBillRepository.deleteById(id);
    }
}
