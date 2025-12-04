package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.ComentarioDTO;
import com.bridgeflow.internalcomms.dto.DecisaoDTO;
import com.bridgeflow.internalcomms.entity.Decisao;
import com.bridgeflow.internalcomms.service.DecisaoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/decisoes")
@RequiredArgsConstructor
public class DecisaoController {

    private final DecisaoService decisaoService;

    @PostMapping
    public ResponseEntity<DecisaoDTO> criarDecisao(
            @Valid @RequestBody DecisaoDTO.Create request,
            Authentication authentication) {

        String emailUsuario = authentication.getName();
        DecisaoDTO decisao = decisaoService.criarDecisao(request, emailUsuario);
        return ResponseEntity.ok(decisao);
    }

    @GetMapping
    public ResponseEntity<List<DecisaoDTO>> listarDecisoes(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long responsavelId) {

        DecisaoDTO.Filtros filtros = new DecisaoDTO.Filtros();

        // Converter string para enum se necessário
        Decisao.StatusDecisao statusEnum = null;
        if (status != null && !status.isEmpty()) {
            try {
                statusEnum = Decisao.StatusDecisao.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                // Status inválido, ignorar
            }
        }

        filtros.setStatus(statusEnum);
        filtros.setResponsavelId(responsavelId);

        List<DecisaoDTO> decisoes = decisaoService.listarDecisoes(filtros);
        return ResponseEntity.ok(decisoes);
    }

    @PostMapping("/{id}/comentarios")
    public ResponseEntity<ComentarioDTO> adicionarComentario(
            @PathVariable Long id,
            @Valid @RequestBody ComentarioDTO.Create request,
            Authentication authentication) {

        String emailUsuario = authentication.getName();
        ComentarioDTO comentario = decisaoService.adicionarComentario(id, request, emailUsuario);
        return ResponseEntity.ok(comentario);
    }

    @GetMapping("/{id}/comentarios")
    public ResponseEntity<List<ComentarioDTO>> listarComentarios(@PathVariable Long id) {
        List<ComentarioDTO> comentarios = decisaoService.listarComentarios(id);
        return ResponseEntity.ok(comentarios);
    }
}
