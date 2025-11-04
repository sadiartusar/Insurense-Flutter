package com.sadiar.insurancemangement.restcontroller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sadiar.insurancemangement.dto.AuthenticationResponse;
import com.sadiar.insurancemangement.entity.Admin;
import com.sadiar.insurancemangement.repository.ITokenRepository;
import com.sadiar.insurancemangement.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminRestController {

    @Autowired
    private AuthService authService;

    @Autowired
    private ITokenRepository  tokenRepository;

    //Method for only user Save,update or register (Method number -1)
    @PostMapping("/add")
    public ResponseEntity<Map<String,String>> saveUser(
            @RequestPart(value = "admin")String adminJson,
            @RequestParam(value = "photo") MultipartFile file
    ) throws JsonProcessingException {
        ObjectMapper objectMapper = new ObjectMapper();
        Admin admin = objectMapper.readValue(adminJson, Admin.class);

        try {
            authService.saveAdmin(admin, file);
            Map<String, String> response = new HashMap<>();
            response.put("Message", "Admin Added Successfully ");

            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (Exception e) {

            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("Message", "Admin Add Faild " + e);
            return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse>  login(@RequestBody Admin request){
        return ResponseEntity.ok(authService.authenticateForAdmin(request));

    }
}
