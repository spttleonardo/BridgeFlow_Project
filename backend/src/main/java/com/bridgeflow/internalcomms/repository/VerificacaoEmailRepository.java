package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.VerificacaoEmail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VerificacaoEmailRepository extends JpaRepository<VerificacaoEmail, Long> {
    Optional<VerificacaoEmail> findByCodigo(String codigo);
}

