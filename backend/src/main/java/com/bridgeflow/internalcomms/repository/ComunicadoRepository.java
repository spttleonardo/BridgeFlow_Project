package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.Comunicado;
import com.bridgeflow.internalcomms.entity.Secretaria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComunicadoRepository extends JpaRepository<Comunicado, Long> {

    List<Comunicado> findBySecretariaOrigem(Secretaria secretaria);

    List<Comunicado> findBySecretariaDestino(Secretaria secretaria);

    List<Comunicado> findByPrioridade(Comunicado.Prioridade prioridade);

    List<Comunicado> findByStatus(Comunicado.StatusComunicado status);

    @Query("SELECT c FROM Comunicado c WHERE " +
           "(:secretariaOrigem IS NULL OR c.secretariaOrigem = :secretariaOrigem) AND " +
           "(:secretariaDestino IS NULL OR c.secretariaDestino = :secretariaDestino) AND " +
           "(:status IS NULL OR c.status = :status) AND " +
           "(:prioridade IS NULL OR c.prioridade = :prioridade)")
    List<Comunicado> findWithFilters(@Param("secretariaOrigem") Secretaria secretariaOrigem,
                                     @Param("secretariaDestino") Secretaria secretariaDestino,
                                     @Param("status") Comunicado.StatusComunicado status,
                                     @Param("prioridade") Comunicado.Prioridade prioridade);
}
