package com.sadiar.insurancemangement.restcontroller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sadiar.insurancemangement.dto.AuthenticationResponse;
import com.sadiar.insurancemangement.dto.UserDTO;
import com.sadiar.insurancemangement.entity.User;
import com.sadiar.insurancemangement.repository.ITokenRepository;
import com.sadiar.insurancemangement.repository.IUserRepository;
import com.sadiar.insurancemangement.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/user")
public class UserRestController {
    @Autowired
    private AuthService authService;

    @Autowired
    private IUserRepository userReporisitoryo;

    @Autowired
    ITokenRepository tokenRepository;
    @Autowired
    private ObjectMapper objectMapper;


    @PostMapping("/register/user")
    public ResponseEntity<Map<String, String>> registerUser(
            @RequestPart("user") String userJson,
            @RequestParam(value = "photo", required = false) MultipartFile file
    ) throws JsonProcessingException {

        User user = objectMapper.readValue(userJson, User.class);
        authService.registerUser(user, file, false);

        Map<String, String> response = new HashMap<>();
        response.put("message", "User registered successfully. Please check your email for activation.");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register/admin")
    public ResponseEntity<Map<String, String>> registerAdmin(
            @RequestPart("user") String userJson,
            @RequestParam(value = "photo", required = false) MultipartFile file,
            @RequestParam("adminCode") String adminCode
    ) throws JsonProcessingException {


        if (!"SECRET123".equals(adminCode)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Invalid Admin Code"));
        }

        User user = objectMapper.readValue(userJson, User.class);
        authService.registerUser(user, file, true);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Admin registered successfully.");
        return ResponseEntity.ok(response);
    }



//    @GetMapping("all")
//    public ResponseEntity<List<User>> getAllUsers() {
//        List<User> users = authService.findAll();
//        return ResponseEntity.ok(users);
//
//    }

    @GetMapping("/all")
    public List<UserDTO> getAllUserDetails() {
        return authService.getAllUserDetails();
    }
    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("User not authenticated");
        }

        String email = authentication.getName();
        Optional<User> user = userReporisitoryo.findByEmail(email);

        if (user.isPresent()) {
            return ResponseEntity.ok(user.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }
    }



    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse>  login(@RequestBody User request){
        return ResponseEntity.ok(authService.authenticate(request));

    }


    @GetMapping("/active/{id}")
    public ResponseEntity<String> activeUser(@PathVariable("id") int id){

        String response= authService.activeUser(id);
        return  ResponseEntity.ok(response);
    }


    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpServletRequest request) {
        final String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().body("Missing or invalid Authorization header.");
        }

        String token = authHeader.substring(7);  // Strip "Bearer "

        tokenRepository.findByToken(token).ifPresent(savedToken -> {
            savedToken.setLogout(true);  // Mark token as logged out
            tokenRepository.save(savedToken);
        });

        return ResponseEntity.ok("Logged out successfully.");
    }
}
