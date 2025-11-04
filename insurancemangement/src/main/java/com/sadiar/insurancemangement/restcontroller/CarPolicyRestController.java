package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.CarPolicy;
import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.service.CarPolicyService;
import com.sadiar.insurancemangement.service.FirePolicyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/carpolicy")

public class CarPolicyRestController {

    @Autowired
    private CarPolicyService carPolicyService;

//    @GetMapping
//    public ResponseEntity<List<FirePolicy>> getAllFirePolicy() {
//        List<FirePolicy> firePolicies = firePolicyService.getAllFirePolicy();
//
//        return ResponseEntity.ok(firePolicies);
//    }
//
//    @PostMapping("")
//    public ResponseEntity<String> saveFirePolicy(@RequestBody FirePolicy firePolicy) {
//        firePolicyService.saveFirePolicy(firePolicy);
//        return ResponseEntity.status(HttpStatus.CREATED).body("Policy saved successfully.");
//    }

    @PostMapping("/add")
    public void save(@RequestBody CarPolicy cp) {
        carPolicyService.saveCarPolicy(cp);
    }

    @GetMapping("")
    public List<CarPolicy> getAll() {

        return carPolicyService.getAllCarPolicy();
    }

    @GetMapping("{id}")
    public CarPolicy getById(@PathVariable Integer id) {

        return carPolicyService.getById(id).get();
    }

    @DeleteMapping("/{id}")
    public void deleteById(@PathVariable Integer id) {

        carPolicyService.delete(id);
    }

    @PutMapping("/{id}")
    public void Update(@RequestBody CarPolicy cp) {

        carPolicyService.saveCarPolicy(cp);

    }
}
