package com.sadiar.insurancemangement.service;

import com.sadiar.insurancemangement.entity.CarPolicy;
import com.sadiar.insurancemangement.entity.FirePolicy;
import com.sadiar.insurancemangement.repository.ICarPolicyRepository;
import com.sadiar.insurancemangement.repository.IFirePolicyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CarPolicyService {

    @Autowired
    private ICarPolicyRepository carPolicyRepository;

    public List<CarPolicy> getAllCarPolicy(){
        return carPolicyRepository.findAll();
    }

    //save Car Policy
    public CarPolicy saveCarPolicy(CarPolicy carPolicy){
        if(carPolicy==null){
            throw new NullPointerException("FirePolicy Cannot be null");
        }
        return carPolicyRepository.save(carPolicy);
    }

    //find fire policy by id
    public CarPolicy findById(int id){
        return carPolicyRepository.findById(id).orElseThrow(()->new RuntimeException("CarPolicy Not Found with id"+id));
    }


    public Optional<CarPolicy> getById(Integer id) {
        return carPolicyRepository.findById(id);
    }


    //delete
    public void delete(Integer id) {
        carPolicyRepository.deleteById(id);
    }
}
