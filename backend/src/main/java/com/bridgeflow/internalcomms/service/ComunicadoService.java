package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.ComunicadoDTO;
import com.bridgeflow.internalcomms.entity.Comunicado;
import com.bridgeflow.internalcomms.entity.Notificacao;
import com.bridgeflow.internalcomms.entity.Secretaria;
import com.bridgeflow.internalcomms.entity.Usuario;
import com.bridgeflow.internalcomms.repository.ComunicadoRepository;
import com.bridgeflow.internalcomms.repository.NotificacaoRepository;
import com.bridgeflow.internalcomms.repository.SecretariaRepository;
import com.bridgeflow.internalcomms.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ComunicadoService {

    private final ComunicadoRepository comunicadoRepository;
    private final UsuarioRepository usuarioRepository;
    private final SecretariaRepository secretariaRepository;
    private final NotificacaoRepository notificacaoRepository;

    @Transactional
    public ComunicadoDTO criarComunicado(ComunicadoDTO.Create request, String emailUsuario) {
        Usuario usuarioCriador = usuarioRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Secretaria secretariaOrigem = usuarioCriador.getSecretaria();

        Comunicado comunicado = new Comunicado();
        comunicado.setTitulo(request.getTitulo());
        comunicado.setConteudo(request.getConteudo());
        comunicado.setPrioridade(request.getPrioridade());
        comunicado.setSecretariaOrigem(secretariaOrigem);
        comunicado.setUsuarioCriador(usuarioCriador);

        if (request.getSecretariaDestinoId() != null) {
            Secretaria secretariaDestino = secretariaRepository.findById(request.getSecretariaDestinoId())
                    .orElseThrow(() -> new RuntimeException("Secretaria destino não encontrada"));
            comunicado.setSecretariaDestino(secretariaDestino);
        }

        comunicado = comunicadoRepository.save(comunicado);

        // Criar notificações para usuários da secretaria destino
        if (comunicado.getSecretariaDestino() != null) {
            criarNotificacoesComunicado(comunicado);
        }

        return convertToDTO(comunicado);
    }

    public List<ComunicadoDTO> listarComunicados(ComunicadoDTO.Filtros filtros) {
        List<Comunicado> comunicados;

        if (filtros != null && (filtros.getSecretariaOrigemId() != null ||
                               filtros.getSecretariaDestinoId() != null ||
                               filtros.getStatus() != null ||
                               filtros.getPrioridade() != null)) {

            Secretaria secretariaOrigem = filtros.getSecretariaOrigemId() != null ?
                secretariaRepository.findById(filtros.getSecretariaOrigemId()).orElse(null) : null;

            Secretaria secretariaDestino = filtros.getSecretariaDestinoId() != null ?
                secretariaRepository.findById(filtros.getSecretariaDestinoId()).orElse(null) : null;

            comunicados = comunicadoRepository.findWithFilters(
                secretariaOrigem, secretariaDestino, filtros.getStatus(), filtros.getPrioridade());
        } else {
            comunicados = comunicadoRepository.findAll();
        }

        return comunicados.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public ComunicadoDTO atualizarStatus(Long id, ComunicadoDTO.UpdateStatus request, String emailUsuario) {
        Comunicado comunicado = comunicadoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Comunicado não encontrado"));

        Usuario usuario = usuarioRepository.findByEmail(emailUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        // Verificar se usuário pode atualizar status (deve ser da secretaria destino ou criador)
        boolean podeAtualizar = comunicado.getUsuarioCriador().equals(usuario) ||
                               (comunicado.getSecretariaDestino() != null &&
                                comunicado.getSecretariaDestino().equals(usuario.getSecretaria()));

        if (!podeAtualizar) {
            throw new RuntimeException("Usuário não tem permissão para atualizar este comunicado");
        }

        comunicado.setStatus(request.getStatus());

        if (request.getStatus() == Comunicado.StatusComunicado.LIDO && comunicado.getDataLeitura() == null) {
            comunicado.setDataLeitura(LocalDateTime.now());
        }

        comunicado.setDataAtualizacao(LocalDateTime.now());
        comunicado = comunicadoRepository.save(comunicado);

        return convertToDTO(comunicado);
    }

    private void criarNotificacoesComunicado(Comunicado comunicado) {
        // Para MVP, criar notificação simples (em produção seria para todos os usuários da secretaria)
        Notificacao notificacao = new Notificacao();
        notificacao.setTitulo("Novo Comunicado: " + comunicado.getTitulo());
        notificacao.setMensagem("Recebido novo comunicado da " + comunicado.getSecretariaOrigem().getNome());
        notificacao.setTipo(Notificacao.TipoNotificacao.NOVO_COMUNICADO);
        notificacao.setUsuarioDestino(comunicado.getUsuarioCriador()); // Temporário para MVP
        notificacao.setUsuarioOrigem(comunicado.getUsuarioCriador());
        notificacao.setComunicado(comunicado);

        notificacaoRepository.save(notificacao);
    }

    private ComunicadoDTO convertToDTO(Comunicado comunicado) {
        ComunicadoDTO dto = new ComunicadoDTO();
        dto.setId(comunicado.getId());
        dto.setTitulo(comunicado.getTitulo());
        dto.setConteudo(comunicado.getConteudo());
        dto.setPrioridade(comunicado.getPrioridade());
        dto.setStatus(comunicado.getStatus());
        dto.setDataCriacao(comunicado.getDataCriacao());
        dto.setDataLeitura(comunicado.getDataLeitura());

        if (comunicado.getSecretariaOrigem() != null) {
            dto.setSecretariaOrigemId(comunicado.getSecretariaOrigem().getId());
            dto.setSecretariaOrigemNome(comunicado.getSecretariaOrigem().getNome());
        }

        if (comunicado.getSecretariaDestino() != null) {
            dto.setSecretariaDestinoId(comunicado.getSecretariaDestino().getId());
            dto.setSecretariaDestinoNome(comunicado.getSecretariaDestino().getNome());
        }

        if (comunicado.getUsuarioCriador() != null) {
            dto.setUsuarioCriadorId(comunicado.getUsuarioCriador().getId());
            dto.setUsuarioCriadorNome(comunicado.getUsuarioCriador().getNome());
        }

        return dto;
    }
}
