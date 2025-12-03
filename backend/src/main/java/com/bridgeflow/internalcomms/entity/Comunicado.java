package com.bridgeflow.internalcomms.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "comunicados")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Comunicado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String conteudo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Prioridade prioridade = Prioridade.MEDIA;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusComunicado status = StatusComunicado.PENDENTE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "secretaria_origem_id", nullable = false)
    private Secretaria secretariaOrigem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "secretaria_destino_id")
    private Secretaria secretariaDestino;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_criador_id", nullable = false)
    private Usuario usuarioCriador;

    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao = LocalDateTime.now();

    @Column(name = "data_atualizacao")
    private LocalDateTime dataAtualizacao;

    @Column(name = "data_leitura")
    private LocalDateTime dataLeitura;

    public enum Prioridade {
        BAIXA, MEDIA, ALTA, URGENTE
    }

    public enum StatusComunicado {
        PENDENTE, LIDO, RESPONDIDO, ARQUIVADO
    }
}
