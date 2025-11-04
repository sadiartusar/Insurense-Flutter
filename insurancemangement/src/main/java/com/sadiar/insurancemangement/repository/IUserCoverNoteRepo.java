package com.sadiar.insurancemangement.repository;

import com.sadiar.insurancemangement.entity.UserCoverNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IUserCoverNoteRepo extends JpaRepository<UserCoverNote, Long> {

    List<UserCoverNote> findByRecipientEmail(String recipientEmail);
}
