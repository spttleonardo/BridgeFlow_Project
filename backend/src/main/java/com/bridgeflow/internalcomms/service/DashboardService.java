package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.DashboardDTO;
import com.bridgeflow.internalcomms.entity.Comunicado;
import com.bridgeflow.internalcomms.entity.Decisao;
import com.bridgeflow.internalcomms.repository.ComunicadoRepository;
import com.bridgeflow.internalcomms.repository.DecisaoRepository;
import com.bridgeflow.internalcomms.repository.NotificacaoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final ComunicadoRepository comunicadoRepository;
    private final DecisaoRepository decisaoRepository;
    private final NotificacaoRepository notificacaoRepository;

    public DashboardDTO getDashboardStats(String emailUsuario) {
        DashboardDTO dashboard = new DashboardDTO();

        // Estatísticas de comunicados
        List<Comunicado> comunicados = comunicadoRepository.findAll();
        dashboard.setTotalComunicados(comunicados.size());
        dashboard.setComunicadosPendentes((int) comunicados.stream()
            .filter(c -> c.getStatus() == Comunicado.StatusComunicado.PENDENTE)
            .count());
        dashboard.setComunicadosLidos((int) comunicados.stream()
            .filter(c -> c.getStatus() == Comunicado.StatusComunicado.LIDO)
            .count());

        // Estatísticas de decisões
        List<Decisao> decisoes = decisaoRepository.findAll();
        dashboard.setTotalDecisoes(decisoes.size());

        // Decisões por status
        Map<String, Integer> decisoesPorStatus = new HashMap<>();
        decisoes.stream()
            .collect(java.util.stream.Collectors.groupingBy(
                d -> d.getStatus().toString(),
                java.util.stream.Collectors.counting()))
            .forEach((status, count) -> decisoesPorStatus.put(status, count.intValue()));
        dashboard.setDecisoesPorStatus(decisoesPorStatus);

        // Atividades por secretaria (baseado em comunicados criados)
        Map<String, Integer> atividadesPorSecretaria = new HashMap<>();
        comunicados.stream()
            .filter(c -> c.getSecretariaOrigem() != null)
            .collect(java.util.stream.Collectors.groupingBy(
                c -> c.getSecretariaOrigem().getNome(),
                java.util.stream.Collectors.counting()))
            .forEach((secretaria, count) -> atividadesPorSecretaria.put(secretaria, count.intValue()));
        dashboard.setAtividadesPorSecretaria(atividadesPorSecretaria);

        // Notificações não lidas (simplificado para MVP)
        dashboard.setNotificacoesNaoLidas((int) notificacaoRepository.findAll().stream()
            .filter(n -> !Boolean.TRUE.equals(n.getLida()))
            .count());

        return dashboard;
    }
}
