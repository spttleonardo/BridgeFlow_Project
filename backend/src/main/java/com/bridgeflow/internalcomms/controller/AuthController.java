package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.LoginRequest;
import com.bridgeflow.internalcomms.dto.LoginResponse;
import com.bridgeflow.internalcomms.dto.RegisterRequest;
import com.bridgeflow.internalcomms.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            authService.register(request);
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            if ("Email já cadastrado".equals(e.getMessage())) {
                return ResponseEntity.status(409).body(e.getMessage());
            }
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/verify")
    public ResponseEntity<LoginResponse> verify(@RequestParam String code,
                                                @RequestParam(required = false) String email) {
        LoginResponse response = authService.verificarEmail(code, email);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<?> authenticate(@Valid @RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.authenticate(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().toLowerCase().contains("não verificado")) {
                return ResponseEntity.status(403).body("E-mail não verificado");
            }
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/resend-verification")
    public ResponseEntity<?> resendVerification(@RequestBody RegisterRequest request) {
        try {
            authService.reenviarEmailVerificacao(request.getEmail());
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
