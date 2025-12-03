package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.Comentario;
import com.bridgeflow.internalcomms.entity.Decisao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComentarioRepository extends JpaRepository<Comentario, Long> {

    List<Comentario> findByDecisaoOrderByDataCriacaoDesc(Decisao decisao);
}
