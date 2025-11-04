package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.repository.IFirePolicyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FirePolicyService {

    @Autowired
    private IFirePolicyRepository  firePolicyRepository;

    public List<FirePolicy> getAllFirePolicy(){
        return firePolicyRepository.findAll();
    }

    //save Fire Policy
    public FirePolicy saveFirePolicy(FirePolicy firePolicy){
        if(firePolicy==null){
            throw new NullPointerException("FirePolicy Cannot be null");
        }
        return firePolicyRepository.save(firePolicy);
    }

    //find fire policy by id
    public FirePolicy findById(int id){
        return firePolicyRepository.findById(id).orElseThrow(()->new RuntimeException("FirePolicy Not Found with id"+id));
    }


    public Optional<FirePolicy> getById(Integer id) {
        return firePolicyRepository.findById(id);
    }


    //delete
    public void delete(Integer id) {
        firePolicyRepository.deleteById(id);
    }



}
