package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.FireBill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IFireBillRepository extends JpaRepository<FireBill,Integer> {

    // Custom query to find bills by policyholder in the associated policy
    @Query("SELECT b FROM FireBill b  WHERE LOWER(b.firePolicy.policyholder) LIKE LOWER(CONCAT('%', :policyholder, '%'))")
    List<FireBill> findBillsByPolicyholder(@Param("policyholder") String policyholder);

    List<FireBill> findByFirePolicyId(int policyId);



    // Custom query to find bills by policy ID
    @Query("SELECT b FROM FireBill b WHERE b.firePolicy.id = :policyId")
    List<FireBill> findBillsByPolicyId(@Param("policyId") int policyId);

}
