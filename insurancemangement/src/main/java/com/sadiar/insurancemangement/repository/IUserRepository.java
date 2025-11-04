package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.dto.UserDTO;
import com.sadiar.insurancemangement.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IUserRepository extends JpaRepository<User,Integer> {

    Optional<User> findByEmail(String email);
//    Optional<UserDTO> findByEmail(String email);

}
