package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.SecretariaDTO;
import com.bridgeflow.internalcomms.entity.Secretaria;
import com.bridgeflow.internalcomms.repository.SecretariaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/secretarias")
@RequiredArgsConstructor
public class SecretariaController {

    private final SecretariaRepository secretariaRepository;

    @GetMapping
    public ResponseEntity<List<SecretariaDTO>> listarTodas() {
        List<SecretariaDTO> secretarias = secretariaRepository.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
        return ResponseEntity.ok(secretarias);
    }

    private SecretariaDTO toDTO(Secretaria secretaria) {
        SecretariaDTO dto = new SecretariaDTO();
        dto.setId(secretaria.getId());
        dto.setNome(secretaria.getNome());
        dto.setSigla(secretaria.getSigla());
        dto.setDescricao(secretaria.getDescricao());
        return dto;
    }
}
