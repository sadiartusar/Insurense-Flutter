package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.repository.IFireBillRepository;
import com.sadiar.insurancemangement.repository.IFirePolicyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FireBillService {

    private final IFireBillRepository fireBillRepository;
    private final IFirePolicyRepository firePolicyRepository;

    public FireBillService(IFireBillRepository fireBillRepository, IFirePolicyRepository firePolicyRepository) {
        this.fireBillRepository = fireBillRepository;
        this.firePolicyRepository = firePolicyRepository;
    }



    // Get all bills
    public List<FireBill> getAllBills() {
        return fireBillRepository.findAll();
    }

    // Get bill by ID
    public Optional<FireBill> getBillById(int id) {
        return fireBillRepository.findById(id);
    }

    // Get bills for a specific policy
    public List<FireBill> getBillsByPolicyId(int policyId) {
        return fireBillRepository.findByFirePolicyId(policyId);
    }

    // Create new bill linked to a policy
    public FireBill createBill(FireBill fireBill, int policyId) {
        FirePolicy policy = firePolicyRepository.findById(policyId)
                .orElseThrow(() -> new RuntimeException("Policy not found with id " + policyId));
        fireBill.setFirePolicy(policy);
        return fireBillRepository.save(fireBill);
    }

    // Update existing bill
    public FireBill updateBill(int id, FireBill updatedBill) {
        return fireBillRepository.findById(id)
                .map(existingBill -> {
                    existingBill.setFire(updatedBill.getFire());
                    existingBill.setRsd(updatedBill.getRsd());
                    existingBill.setNetPremium(updatedBill.getNetPremium());
                    existingBill.setTax(updatedBill.getTax());
                    existingBill.setGrossPremium(updatedBill.getGrossPremium());
                    return fireBillRepository.save(existingBill);
                })
                .orElseThrow(() -> new RuntimeException("Bill not found with id " + id));
    }

    // Delete bill by ID
    public void deleteBill(int id) {
        fireBillRepository.deleteById(id);
    }

}
