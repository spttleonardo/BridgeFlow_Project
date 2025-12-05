package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.UsuarioResumoDTO;
import com.bridgeflow.internalcomms.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping
    public ResponseEntity<List<UsuarioResumoDTO>> listarUsuarios(
            @RequestParam(value = "secretariaId", required = false) Long secretariaId) {
        List<UsuarioResumoDTO> usuarios = usuarioService.listarUsuarios(secretariaId);
        return ResponseEntity.ok(usuarios);
    }
}
