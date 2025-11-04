package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.CarMoneyReceipt;
import com.sadiar.insurancemangement.entity.FireMoneyReceipt;
import com.sadiar.insurancemangement.service.CarMoneyReceiptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/carmoneyreciept")

public class CarMoneyReceiptRestController {

    @Autowired
    private CarMoneyReceiptService carMoneyReceiptService;

    // Get all Receipt
    @GetMapping("")
    public List<CarMoneyReceipt> getAllCarMoneyReceipt() {
        return carMoneyReceiptService.getAllMoneyReceipt();
    }


//    // Create a new Receipt
//    @PostMapping("")
//    public void saveFireMoneyReceipt(@RequestBody FireMoneyReceipt mr) {
//        moneyReceiptService.createFireMoneyReceipt(mr);
//    }

    @PostMapping("/add")
    public CarMoneyReceipt saveBill(@RequestBody CarMoneyReceipt b,
                                     @RequestParam int carBillId) {
        return carMoneyReceiptService.createCarMoneyReceipt( b, carBillId);
    }


    @PutMapping("/{id}")
    public ResponseEntity<String> updateCarMoneyReceipt(@PathVariable int id, @RequestBody CarMoneyReceipt mr) {
        try {
            carMoneyReceiptService.updateMoneyReceipt(mr, id);
            return ResponseEntity.ok("Money  Receipt updated successfully.");
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }



    // Delete a Receipt by ID
    @DeleteMapping("/{id}")
    public void deleteMoneyReceiptById(@PathVariable int id) {
        carMoneyReceiptService.deleteCarMoneyReceipt(id);
    }


    @GetMapping("/{id}")
    public ResponseEntity<CarMoneyReceipt> getMoneyReceiptById(@PathVariable int id) {
        CarMoneyReceipt mr = carMoneyReceiptService.getCarMoneyReceiptById(id);
        return ResponseEntity.ok(mr);
    }
}
