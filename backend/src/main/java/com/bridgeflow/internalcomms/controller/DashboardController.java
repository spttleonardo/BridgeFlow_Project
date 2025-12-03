package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.DashboardDTO;
import com.bridgeflow.internalcomms.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    public ResponseEntity<DashboardDTO> getDashboardStats(Authentication authentication) {
        String emailUsuario = authentication.getName();
        DashboardDTO stats = dashboardService.getDashboardStats(emailUsuario);
        return ResponseEntity.ok(stats);
    }
}
