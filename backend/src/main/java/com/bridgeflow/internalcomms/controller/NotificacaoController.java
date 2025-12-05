package com.bridgeflow.internalcomms.controller;

import com.bridgeflow.internalcomms.dto.NotificacaoDTO;
import com.bridgeflow.internalcomms.service.NotificacaoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/notificacoes")
@RequiredArgsConstructor
public class NotificacaoController {

    private final NotificacaoService notificacaoService;

    @PostMapping
    public ResponseEntity<NotificacaoDTO> criarNotificacao(
            @Valid @RequestBody NotificacaoDTO.Create request,
            Authentication authentication) {

        String emailUsuario = authentication.getName();
        NotificacaoDTO notificacao = notificacaoService.criar(request, emailUsuario);
        return ResponseEntity.ok(notificacao);
    }

    @GetMapping
    public ResponseEntity<List<NotificacaoDTO>> listarNotificacoes(
            @RequestParam(name = "apenasNaoLidas", defaultValue = "false") boolean apenasNaoLidas,
            Authentication authentication) {

        String emailUsuario = authentication.getName();
        List<NotificacaoDTO> notificacoes = notificacaoService.listar(emailUsuario, apenasNaoLidas);
        return ResponseEntity.ok(notificacoes);
    }
}
