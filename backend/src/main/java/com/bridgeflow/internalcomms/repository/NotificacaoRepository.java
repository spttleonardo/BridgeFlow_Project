package com.bridgeflow.internalcomms.repository;

import com.bridgeflow.internalcomms.entity.Notificacao;
import com.bridgeflow.internalcomms.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificacaoRepository extends JpaRepository<Notificacao, Long> {

    List<Notificacao> findByUsuarioDestinoAndLidaFalseOrderByDataCriacaoDesc(Usuario usuarioDestino);

    List<Notificacao> findByUsuarioDestinoOrderByDataCriacaoDesc(Usuario usuarioDestino);
}
