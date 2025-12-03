package com.bridgeflow.internalcomms.dto;

import lombok.Data;

import java.util.Map;

@Data
public class DashboardDTO {

    private int totalComunicados;
    private int comunicadosPendentes;
    private int comunicadosLidos;
    private int totalDecisoes;
    private Map<String, Integer> decisoesPorStatus;
    private Map<String, Integer> atividadesPorSecretaria;
    private int notificacoesNaoLidas;

    @Data
    public static class Stats {
        private String label;
        private int value;
    }
}
