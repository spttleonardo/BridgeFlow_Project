package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.ComunicadoDTO;
import com.bridgeflow.internalcomms.entity.Comunicado;
import com.bridgeflow.internalcomms.service.ComunicadoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/comunicados")
@RequiredArgsConstructor
public class ComunicadoController {

    private final ComunicadoService comunicadoService;

    @PostMapping
    public ResponseEntity<ComunicadoDTO> criarComunicado(
            @Valid @RequestBody ComunicadoDTO.Create request,
            Authentication authentication) {

        String emailUsuario = authentication.getName();
        ComunicadoDTO comunicado = comunicadoService.criarComunicado(request, emailUsuario);
        return ResponseEntity.ok(comunicado);
    }

    @GetMapping
    public ResponseEntity<List<ComunicadoDTO>> listarComunicados(
            @RequestParam(required = false) Long secretariaOrigemId,
            @RequestParam(required = false) Long secretariaDestinoId,
            @RequestParam(required = false) Comunicado.StatusComunicado status,
            @RequestParam(required = false) Comunicado.Prioridade prioridade) {

        ComunicadoDTO.Filtros filtros = new ComunicadoDTO.Filtros();
        filtros.setSecretariaOrigemId(secretariaOrigemId);
        filtros.setSecretariaDestinoId(secretariaDestinoId);
        filtros.setStatus(status);
        filtros.setPrioridade(prioridade);

        List<ComunicadoDTO> comunicados = comunicadoService.listarComunicados(filtros);
        return ResponseEntity.ok(comunicados);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<ComunicadoDTO> atualizarStatus(
            @PathVariable Long id,
            @Valid @RequestBody ComunicadoDTO.UpdateStatus request,
            Authentication authentication) {

        String emailUsuario = authentication.getName();
        ComunicadoDTO comunicado = comunicadoService.atualizarStatus(id, request, emailUsuario);
        return ResponseEntity.ok(comunicado);
    }
}
