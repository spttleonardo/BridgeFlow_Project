package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.Secretaria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SecretariaRepository extends JpaRepository<Secretaria, Long> {

    List<Secretaria> findByAtivoTrue();
}
