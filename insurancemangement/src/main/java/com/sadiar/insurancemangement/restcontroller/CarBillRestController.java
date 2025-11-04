package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.CarBill;
import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.service.CarBillService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/carbill")

public class CarBillRestController {

    @Autowired
    private CarBillService carBillService;

    // Get all bills
    @GetMapping("")
    public ResponseEntity<List<CarBill>> getAllBills() {
        List<CarBill> bills = carBillService.getAllBills();
        return ResponseEntity.ok(bills);
    }

    @PostMapping("/add")
    public CarBill saveBill(@RequestBody CarBill b,
                             @RequestParam int carPolicyId) {
        return carBillService.createBill(b, carPolicyId);
    }

    // Update an existing bill
    @PutMapping("/{id}")
    public ResponseEntity<CarBill> updateBill(@PathVariable int id, @RequestBody CarBill b) {
        try {
            CarBill carBill = carBillService.updateBill(id, b);
            return ResponseEntity.ok(carBill);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

//    // Delete a bill by ID
//    @DeleteMapping("/{id}")
//    public ResponseEntity<String> deleteBillById(@PathVariable int id) {
//        try {
//            carBillService.deleteBill(id);
//            return ResponseEntity.ok("Bill deleted successfully.");
//        } catch (RuntimeException e) {
//            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
//        }
//    }

    @DeleteMapping("/{id}")
    public void deleteBillById(@PathVariable int id) {
        carBillService.deleteBill(id);
    }
    // Get bill by ID
    @GetMapping("/{id}")
    public ResponseEntity<Optional<CarBill>> getBillById(@PathVariable int id) {
        try {
            Optional<CarBill> bill = carBillService.getBillById(id);
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
