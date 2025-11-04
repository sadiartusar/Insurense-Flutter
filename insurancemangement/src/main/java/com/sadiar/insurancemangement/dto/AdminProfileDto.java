package com.sadiar.insurancemangement.dto;

public class AdminProfileDto {

        private String email;
        private String role;
        private String photo;


        public AdminProfileDto(String email, String role, String photo) {
            this.email = email;
            this.role = role;
            this.photo = photo;
        }

        // Getters and Setters
        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }

        public String getPhoto() {
            return photo;
        }

        public void setPhoto(String photo) {
            this.photo = photo;
        }
    }


