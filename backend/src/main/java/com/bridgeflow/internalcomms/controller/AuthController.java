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
    public ResponseEntity<Void> register(@Valid @RequestBody RegisterRequest request) {
        authService.register(request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/verify")
    public ResponseEntity<LoginResponse> verify(@RequestParam String code) {
        LoginResponse response = authService.verificarEmail(code);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> authenticate(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.authenticate(request);
        return ResponseEntity.ok(response);
    }
}
