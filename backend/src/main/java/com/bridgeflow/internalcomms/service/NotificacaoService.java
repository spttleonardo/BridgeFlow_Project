package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.NotificacaoDTO;
import com.bridgeflow.internalcomms.entity.Comunicado;
import com.bridgeflow.internalcomms.entity.Decisao;
import com.bridgeflow.internalcomms.entity.Notificacao;
import com.bridgeflow.internalcomms.entity.Usuario;
import com.bridgeflow.internalcomms.repository.ComunicadoRepository;
import com.bridgeflow.internalcomms.repository.DecisaoRepository;
import com.bridgeflow.internalcomms.repository.NotificacaoRepository;
import com.bridgeflow.internalcomms.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificacaoService {

    private final NotificacaoRepository notificacaoRepository;
    private final UsuarioRepository usuarioRepository;
    private final DecisaoRepository decisaoRepository;
    private final ComunicadoRepository comunicadoRepository;
    private final MqService mqService;

    @Transactional
    public NotificacaoDTO criar(NotificacaoDTO.Create request, String emailUsuario) {
        Usuario usuarioOrigem = usuarioRepository.findByEmail(emailUsuario)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário de origem não encontrado"));

        Usuario usuarioDestino = usuarioRepository.findById(request.getUsuarioDestinoId())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário destino não encontrado"));

        Notificacao notificacao = new Notificacao();
        notificacao.setTitulo(request.getTitulo());
        notificacao.setMensagem(request.getMensagem());
        notificacao.setTipo(request.getTipo());
        notificacao.setUsuarioOrigem(usuarioOrigem);
        notificacao.setUsuarioDestino(usuarioDestino);
        notificacao.setLida(Boolean.FALSE);

        if (request.getDecisaoId() != null) {
            Decisao decisao = decisaoRepository.findById(request.getDecisaoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Decisão não encontrada"));
            notificacao.setDecisao(decisao);
        }

        if (request.getComunicadoId() != null) {
            Comunicado comunicado = comunicadoRepository.findById(request.getComunicadoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Comunicado não encontrado"));
            notificacao.setComunicado(comunicado);
        }

        notificacao = notificacaoRepository.save(notificacao);

        String emailDestino = request.getEmailNotificacao();
        if (emailDestino == null || emailDestino.isBlank()) {
            emailDestino = usuarioDestino.getEmail();
        }

        if (emailDestino != null && !emailDestino.isBlank()) {
            mqService.notificar(Map.of(
                "type", "notificacao.manual",
                "emailNotificacao", emailDestino,
                "titulo", notificacao.getTitulo(),
                "mensagem", notificacao.getMensagem(),
                "destinatario", usuarioDestino.getNome()
            ));
        }

        return convertToDTO(notificacao);
    }

    @Transactional(readOnly = true)
    public List<NotificacaoDTO> listar(String emailUsuario, boolean apenasNaoLidas) {
        Usuario usuarioDestino = usuarioRepository.findByEmail(emailUsuario)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário destino não encontrado"));

        List<Notificacao> notificacoes = apenasNaoLidas
            ? notificacaoRepository.findByUsuarioDestinoAndLidaFalseOrderByDataCriacaoDesc(usuarioDestino)
            : notificacaoRepository.findByUsuarioDestinoOrderByDataCriacaoDesc(usuarioDestino);

        return notificacoes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private NotificacaoDTO convertToDTO(Notificacao notificacao) {
        NotificacaoDTO dto = new NotificacaoDTO();
        dto.setId(notificacao.getId());
        dto.setTitulo(notificacao.getTitulo());
        dto.setMensagem(notificacao.getMensagem());
        dto.setTipo(notificacao.getTipo());
        dto.setLida(notificacao.getLida());
        dto.setDataCriacao(notificacao.getDataCriacao());

        if (notificacao.getUsuarioDestino() != null) {
            dto.setUsuarioDestinoId(notificacao.getUsuarioDestino().getId());
            dto.setUsuarioDestinoNome(notificacao.getUsuarioDestino().getNome());
        }

        if (notificacao.getUsuarioOrigem() != null) {
            dto.setUsuarioOrigemId(notificacao.getUsuarioOrigem().getId());
            dto.setUsuarioOrigemNome(notificacao.getUsuarioOrigem().getNome());
        }

        return dto;
    }
}
