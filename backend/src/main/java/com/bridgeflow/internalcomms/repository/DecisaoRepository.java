package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.Decisao;
import com.bridgeflow.internalcomms.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DecisaoRepository extends JpaRepository<Decisao, Long> {

    List<Decisao> findByResponsavel(Usuario responsavel);

    List<Decisao> findByUsuarioCriador(Usuario usuarioCriador);

    List<Decisao> findByStatus(Decisao.StatusDecisao status);

    @Query("SELECT d FROM Decisao d WHERE " +
           "(:status IS NULL OR d.status = :status) AND " +
           "(:responsavel IS NULL OR d.responsavel = :responsavel)")
    List<Decisao> findWithFilters(@Param("status") Decisao.StatusDecisao status,
                                  @Param("responsavel") Usuario responsavel);
}
