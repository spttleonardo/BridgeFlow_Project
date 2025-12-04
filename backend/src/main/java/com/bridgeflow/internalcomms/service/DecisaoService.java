package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.ComentarioDTO;
import com.bridgeflow.internalcomms.dto.DecisaoDTO;
import com.bridgeflow.internalcomms.entity.Comentario;
import com.bridgeflow.internalcomms.entity.Decisao;
import com.bridgeflow.internalcomms.entity.Notificacao;
import com.bridgeflow.internalcomms.entity.Usuario;
import com.bridgeflow.internalcomms.repository.ComentarioRepository;
import com.bridgeflow.internalcomms.repository.DecisaoRepository;
import com.bridgeflow.internalcomms.repository.NotificacaoRepository;
import com.bridgeflow.internalcomms.repository.UsuarioRepository;
import com.bridgeflow.internalcomms.service.MqService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DecisaoService {

    private final DecisaoRepository decisaoRepository;
    private final ComentarioRepository comentarioRepository;
    private final UsuarioRepository usuarioRepository;
    private final NotificacaoRepository notificacaoRepository;
    private final MqService mqService;

    @Transactional
    public DecisaoDTO criarDecisao(DecisaoDTO.Create request, String emailUsuario) {
        Usuario usuarioCriador = usuarioRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário criador não encontrado"));

        Usuario responsavel = usuarioRepository.findById(request.getResponsavelId())
                .orElseThrow(() -> new RuntimeException("Responsável não encontrado"));

        Decisao decisao = new Decisao();
        decisao.setTitulo(request.getTitulo());
        decisao.setDescricao(request.getDescricao());
        decisao.setResponsavel(responsavel);
        decisao.setUsuarioCriador(usuarioCriador);
        decisao.setPrazo(request.getPrazo());

        decisao = decisaoRepository.save(decisao);

        // Criar notificação para o responsável
        criarNotificacaoDecisao(decisao, "Nova decisão atribuída: " + decisao.getTitulo());

        // Enviar notificação por e-mail
        if (request.getEmailNotificacao() != null && !request.getEmailNotificacao().isBlank()) {
            mqService.notificar(Map.of(
                    "type", "decisao.criada",
                    "emailNotificacao", request.getEmailNotificacao(),
                    "decisaoTitulo", decisao.getTitulo(),
                    "responsavelNome", decisao.getResponsavel().getNome(),
                    "prazo", decisao.getPrazo() != null ? decisao.getPrazo().toString() : "N/A"
            ));
        }

        return convertToDTO(decisao);
    }

    public List<DecisaoDTO> listarDecisoes(DecisaoDTO.Filtros filtros) {
        List<Decisao> decisoes;

        if (filtros != null && (filtros.getStatus() != null || filtros.getResponsavelId() != null)) {
            Usuario responsavel = filtros.getResponsavelId() != null ?
                usuarioRepository.findById(filtros.getResponsavelId()).orElse(null) : null;

            decisoes = decisaoRepository.findWithFilters(filtros.getStatus(), responsavel);
        } else {
            decisoes = decisaoRepository.findAll();
        }

        return decisoes.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public ComentarioDTO adicionarComentario(Long decisaoId, ComentarioDTO.Create request, String emailUsuario) {
        Decisao decisao = decisaoRepository.findById(decisaoId)
                .orElseThrow(() -> new RuntimeException("Decisão não encontrada"));

        Usuario usuario = usuarioRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Comentario comentario = new Comentario();
        comentario.setConteudo(request.getConteudo());
        comentario.setDecisao(decisao);
        comentario.setUsuario(usuario);

        comentario = comentarioRepository.save(comentario);

        // Criar notificação para o responsável se não for ele quem comentou
        if (!decisao.getResponsavel().equals(usuario)) {
            criarNotificacaoComentario(decisao, usuario);
        }

        return convertComentarioToDTO(comentario);
    }

    public List<ComentarioDTO> listarComentarios(Long decisaoId) {
        Decisao decisao = decisaoRepository.findById(decisaoId)
                .orElseThrow(() -> new RuntimeException("Decisão não encontrada"));

        List<Comentario> comentarios = comentarioRepository.findByDecisaoOrderByDataCriacaoDesc(decisao);

        return comentarios.stream()
                .map(this::convertComentarioToDTO)
                .collect(Collectors.toList());
    }

    private void criarNotificacaoDecisao(Decisao decisao, String mensagem) {
        Notificacao notificacao = new Notificacao();
        notificacao.setTitulo("Nova Decisão");
        notificacao.setMensagem(mensagem);
        notificacao.setTipo(Notificacao.TipoNotificacao.NOVA_DECISAO);
        notificacao.setUsuarioDestino(decisao.getResponsavel());
        notificacao.setUsuarioOrigem(decisao.getUsuarioCriador());
        notificacao.setDecisao(decisao);

        notificacaoRepository.save(notificacao);
    }

    private void criarNotificacaoComentario(Decisao decisao, Usuario usuarioComentario) {
        Notificacao notificacao = new Notificacao();
        notificacao.setTitulo("Novo comentário em decisão");
        notificacao.setMensagem("Novo comentário na decisão: " + decisao.getTitulo());
        notificacao.setTipo(Notificacao.TipoNotificacao.COMENTARIO_DECISAO);
        notificacao.setUsuarioDestino(decisao.getResponsavel());
        notificacao.setUsuarioOrigem(usuarioComentario);
        notificacao.setDecisao(decisao);

        notificacaoRepository.save(notificacao);
    }

    private DecisaoDTO convertToDTO(Decisao decisao) {
        DecisaoDTO dto = new DecisaoDTO();
        dto.setId(decisao.getId());
        dto.setTitulo(decisao.getTitulo());
        dto.setDescricao(decisao.getDescricao());
        dto.setStatus(decisao.getStatus());
        dto.setPrazo(decisao.getPrazo());
        dto.setDataConclusao(decisao.getDataConclusao());
        dto.setDataCriacao(decisao.getDataCriacao());

        if (decisao.getResponsavel() != null) {
            dto.setResponsavelId(decisao.getResponsavel().getId());
            dto.setResponsavelNome(decisao.getResponsavel().getNome());
        }

        if (decisao.getUsuarioCriador() != null) {
            dto.setUsuarioCriadorId(decisao.getUsuarioCriador().getId());
            dto.setUsuarioCriadorNome(decisao.getUsuarioCriador().getNome());
        }

        return dto;
    }

    private ComentarioDTO convertComentarioToDTO(Comentario comentario) {
        ComentarioDTO dto = new ComentarioDTO();
        dto.setId(comentario.getId());
        dto.setConteudo(comentario.getConteudo());
        dto.setDecisaoId(comentario.getDecisao().getId());
        dto.setDataCriacao(comentario.getDataCriacao());

        if (comentario.getUsuario() != null) {
            dto.setUsuarioId(comentario.getUsuario().getId());
            dto.setUsuarioNome(comentario.getUsuario().getNome());
        }

        return dto;
    }
}
