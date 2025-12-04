package com.bridgeflow.internalcomms.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "verificacao_email")
@Data
@NoArgsConstructor
public class VerificacaoEmail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String codigo;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;

    @Column(name = "data_expiracao", nullable = false)
    private LocalDateTime dataExpiracao;

    public VerificacaoEmail(String codigo, Usuario usuario, LocalDateTime dataExpiracao) {
        this.codigo = codigo;
        this.usuario = usuario;
        this.dataExpiracao = dataExpiracao;
    }
}

