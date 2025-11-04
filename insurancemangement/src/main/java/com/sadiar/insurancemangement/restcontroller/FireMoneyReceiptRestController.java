package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.FireBill;
import com.sadiar.insurancemangement.entity.FireMoneyReceipt;
import com.sadiar.insurancemangement.service.FireMoneyReceiptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/firemoneyreciept")

public class FireMoneyReceiptRestController {

    @Autowired
    private FireMoneyReceiptService moneyReceiptService;

    // Get all Receipt
    @GetMapping("")
    public List<FireMoneyReceipt> getAllFireMoneyReceipt() {
        return moneyReceiptService.getAllMoneyReceipt();
    }


//    // Create a new Receipt
//    @PostMapping("")
//    public void saveFireMoneyReceipt(@RequestBody FireMoneyReceipt mr) {
//        moneyReceiptService.createFireMoneyReceipt(mr);
//    }

    @PostMapping("/add")
    public FireMoneyReceipt saveBill(@RequestBody FireMoneyReceipt b,
                             @RequestParam int billId) {
        return moneyReceiptService.createFireMoneyReceipt( b, billId);
    }


    @PutMapping("/{id}")
    public ResponseEntity<String> updateFireMoneyReceipt(@PathVariable int id, @RequestBody FireMoneyReceipt mr) {
        try {
            moneyReceiptService.updateMoneyReceipt(mr, id);
            return ResponseEntity.ok("Money  Receipt updated successfully.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }



    // Delete a Receipt by ID
    @DeleteMapping("/{id}")
    public void deleteMoneyReceiptById(@PathVariable int id) {
        moneyReceiptService.deleteFireMoneyReceipt(id);
    }


    @GetMapping("/{id}")
    public ResponseEntity<FireMoneyReceipt> getMoneyReceiptById(@PathVariable int id) {
        FireMoneyReceipt mr = moneyReceiptService.getFireMoneyReceiptById(id);
        return ResponseEntity.ok(mr);
    }
}
