package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.service.FirePolicyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/firepolicy")

public class FirePolicyRestController {

    @Autowired
    private FirePolicyService firePolicyService;

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
    public void save(@RequestBody FirePolicy ps) {
        firePolicyService.saveFirePolicy(ps);
    }

    @GetMapping("")
    public List<FirePolicy> getAll() {

        return firePolicyService.getAllFirePolicy();
    }

    @GetMapping("{id}")
    public FirePolicy getById(@PathVariable Integer id) {

        return firePolicyService.getById(id).get();
    }

    @DeleteMapping("/{id}")
    public void deleteById(@PathVariable Integer id) {

        firePolicyService.delete(id);
    }

    @PutMapping("/{id}")
    public void Update(@RequestBody FirePolicy ps) {

        firePolicyService.saveFirePolicy(ps);

    }
}
