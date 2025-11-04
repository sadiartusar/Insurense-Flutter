package com.sadiar.insurancemangement.security;

import com.sadiar.insurancemangement.jwt.JwtAuthenticationFilter;
import com.sadiar.insurancemangement.jwt.JwtService;
import com.sadiar.insurancemangement.service.AuthService;
import com.sadiar.insurancemangement.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http,
                                           JwtAuthenticationFilter jwtAuthenticationFilter,
                                           UserService userService) throws Exception {

        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .authorizeHttpRequests(req -> req

                        .requestMatchers(
                                "/api/user/login",
                                "/api/user",
                                "/api/user/register/user",
                                "/api/user/register/admin",
                                "/auth/login",
                                "/images/**",
                                "/api/user/active/**"


                        ).permitAll()
                        .requestMatchers("/api/user/logout",
                                "/api/payment/pay").hasAnyRole("ADMIN", "USER")



                        .requestMatchers(
                                "/api/user/register/admin",
                                "/api/firepolicy/**",
                                "/api/firepolicy/add",
                                "/api/firebill/add",
                                "/api/firebill/**",
                                "/api/firemoneyreciept/**",
                                "/api/firemoneyreciept/add",
                                "/api/carpolicy/**",
                                "/api/carpolicy/add",
                                "/api/carbill/**",
                                "/api/carbill/add",
                                "/api/carmoneyreciept/**",
                                "/api/carmoneyreciept/add",
                                "/api/payment/deposit/**",
//                                "/api/payment/balance/**",
//                                "/api/payment/pay",
                                "/api/payment/company-balance/**",
                                "/api/payment/showcompanydetails",
                                "/api/payment/allpaymentdetails",
                                "/api/user/all",
                                "/api/usercovernotes/save-for-user"
//                                "/api/user/profile"
                        ).hasRole("ADMIN")


                        .requestMatchers("/api/user/register/user",
                                "/api/user/profile",
                                "/api/firemoneyreciept/**",
                                "/api/payment/deposit/**",
                                "/api/payment/{userId}/account",
                                "/api/payment/{userId}",
                                "/api/usercovernotes/my",
                                "/api/payment/balance/**").hasRole("USER")


                        .anyRequest().authenticated()
                )
                .userDetailsService(userService)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter(com.sadiar.insurancemangement.jwt.JwtService jwtService,
                                                           UserService userService) {
        return new JwtAuthenticationFilter(jwtService, userService);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("http://localhost:4200","http://localhost:5000/"));
        configuration.setAllowedMethods(List.of("GET", "POST", "DELETE", "PUT", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("Authorization", "Cache-Control", "Content-Type"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
