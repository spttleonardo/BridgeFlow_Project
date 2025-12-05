package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.UsuarioResumoDTO;
import com.bridgeflow.internalcomms.entity.Usuario;
import com.bridgeflow.internalcomms.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    @Transactional(readOnly = true)
    public List<UsuarioResumoDTO> listarUsuarios(Long secretariaId) {
        List<Usuario> usuarios = secretariaId != null
                ? usuarioRepository.findBySecretaria_IdAndAtivoTrue(secretariaId)
                : usuarioRepository.findByAtivoTrue();

        return usuarios.stream()
                .map(this::convertToResumo)
                .collect(Collectors.toList());
    }

    private UsuarioResumoDTO convertToResumo(Usuario usuario) {
        String secretariaNome = usuario.getSecretaria() != null
                ? usuario.getSecretaria().getNome()
                : null;
        return new UsuarioResumoDTO(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getCargo(),
                secretariaNome
        );
    }
}
