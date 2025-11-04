package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.FirePolicy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface IFirePolicyRepository extends JpaRepository<FirePolicy,Integer> {
}
