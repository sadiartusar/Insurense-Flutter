package com.sadiar.insurancemangement.restcontroller;

import com.sadiar.insurancemangement.entity.UserCoverNote;
import com.sadiar.insurancemangement.repository.IUserCoverNoteRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usercovernotes")
public class UserCoverNoteRestController {

    // ✅ Repository ইনজেক্ট করা
    private final IUserCoverNoteRepo coverNoteRepository;

    @Autowired
    public UserCoverNoteRestController(IUserCoverNoteRepo coverNoteRepository) {
        this.coverNoteRepository = coverNoteRepository;
    }

    // ① ডেটা সেভ করার এন্ডপয়েন্ট (অ্যাডমিন থেকে ডেটা গ্রহণ করবে)
    @PostMapping("/save-for-user")
    public ResponseEntity<String> saveCoverNote(@RequestBody UserCoverNote note) {
        // ডেটাবেসে সেভ করা
        coverNoteRepository.save(note);
        return ResponseEntity.status(HttpStatus.CREATED).body("Cover Note saved successfully.");
    }


    @GetMapping("/my")
    public ResponseEntity<List<UserCoverNote>> getMyCoverNotes(@AuthenticationPrincipal UserDetails userDetails) {

        String loggedInUserEmail = userDetails.getUsername();

        List<UserCoverNote> notes = coverNoteRepository.findByRecipientEmail(loggedInUserEmail);

        return ResponseEntity.ok(notes);
    }
}
