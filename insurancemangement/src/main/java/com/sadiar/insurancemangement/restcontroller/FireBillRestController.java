package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.service.FireBillService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/firebill")

public class FireBillRestController {

    @Autowired
    private FireBillService fireBillService;

    // Get all bills
    @GetMapping("")
    public ResponseEntity<List<FireBill>> getAllBills() {
        List<FireBill> bills = fireBillService.getAllBills();
        return ResponseEntity.ok(bills);
    }

    @PostMapping("/add")
    public FireBill saveBill(@RequestBody FireBill b,
                             @RequestParam int policyId) {
        return fireBillService.createBill(b, policyId);
    }

    // Update an existing bill
//    @PutMapping("/{id}")
//    public ResponseEntity<String> updateBill(@PathVariable int id, @RequestBody FireBill b) {
//        try {
//            fireBillService.updateBill(id, b);
//            return ResponseEntity.ok("Bill updated successfully.");
//        } catch (RuntimeException e) {
//            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
//        }
//    }

    @PutMapping("/{id}")
    public ResponseEntity<FireBill> updateBill(@PathVariable int id, @RequestBody FireBill updatedBill) {
        try {
            FireBill bill = fireBillService.updateBill(id, updatedBill);
            return ResponseEntity.ok(bill);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

//    // Delete a bill by ID
//    @DeleteMapping("/{id}")
//    public ResponseEntity<String> deleteBillById(@PathVariable int id) {
//        try {
//            fireBillService.deleteBill(id);
//            return ResponseEntity.ok("Bill deleted successfully.");
//        } catch (RuntimeException e) {
//            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
//        }
//    }

    @DeleteMapping("/{id}")
    public void deleteBillById(@PathVariable int id) {
        fireBillService.deleteBill(id);
    }
    // Get bill by ID
    @GetMapping("/{id}")
    public ResponseEntity<Optional<FireBill>> getBillById(@PathVariable int id) {
        try {
            Optional<FireBill> bill = fireBillService.getBillById(id);
            return ResponseEntity.ok(bill);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

//    // Search bills by policyholder name
//    @GetMapping("/searchpolicyholder")
//    public ResponseEntity<List<FireBill>> getBillsByPolicyholder(@RequestParam String policyholder) {
//        List<FireBill> bills = fireBillService.getBillsByPolicyholder(policyholder);
//        return ResponseEntity.ok(bills);
//    }
//
//    // Search bills by policy ID
//    @GetMapping("/searchpolicyid")
//    public ResponseEntity<List<FireBill>> findBillsByPolicyId(@RequestParam("policyid") int policyid) {
//        List<FireBill> bills = fireBillService.findBillByPolicyId(policyid);
//        return ResponseEntity.ok(bills);
//    }
}
