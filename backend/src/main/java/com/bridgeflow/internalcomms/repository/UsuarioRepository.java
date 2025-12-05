package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByEmail(String email);

    boolean existsByEmail(String email);

    List<Usuario> findByAtivoTrue();

    List<Usuario> findBySecretaria_IdAndAtivoTrue(Long secretariaId);
}
