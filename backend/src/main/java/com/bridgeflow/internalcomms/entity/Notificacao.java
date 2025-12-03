package com.bridgeflow.internalcomms.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "notificacoes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notificacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String mensagem;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoNotificacao tipo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_destino_id", nullable = false)
    private Usuario usuarioDestino;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_origem_id")
    private Usuario usuarioOrigem;

    @Column(nullable = false)
    private Boolean lida = false;

    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao = LocalDateTime.now();

    @Column(name = "data_leitura")
    private LocalDateTime dataLeitura;

    // Referências opcionais para diferentes tipos de notificações
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comunicado_id")
    private Comunicado comunicado;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "decisao_id")
    private Decisao decisao;

    public enum TipoNotificacao {
        NOVO_COMUNICADO, NOVA_DECISAO, PRAZO_DECISAO, COMENTARIO_DECISAO, SISTEMA
    }
}
