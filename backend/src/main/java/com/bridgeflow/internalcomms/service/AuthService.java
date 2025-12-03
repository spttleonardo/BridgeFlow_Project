package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.LoginRequest;
import com.bridgeflow.internalcomms.dto.LoginResponse;
import com.bridgeflow.internalcomms.dto.RegisterRequest;
import com.bridgeflow.internalcomms.entity.Secretaria;
import com.bridgeflow.internalcomms.entity.Usuario;
import com.bridgeflow.internalcomms.repository.SecretariaRepository;
import com.bridgeflow.internalcomms.repository.UsuarioRepository;
import com.bridgeflow.internalcomms.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final SecretariaRepository secretariaRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public LoginResponse register(RegisterRequest request) {
        if (usuarioRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email já cadastrado");
        }

        Secretaria secretaria = secretariaRepository.findById(request.getSecretariaId())
                .orElseThrow(() -> new RuntimeException("Secretaria não encontrada"));

        Usuario usuario = new Usuario();
        usuario.setNome(request.getNome());
        usuario.setEmail(request.getEmail());
        usuario.setSenha(passwordEncoder.encode(request.getSenha()));
        usuario.setSecretaria(secretaria);
        usuario.setDepartamento(request.getDepartamento());
        usuario.setCargo(request.getCargo());

        usuarioRepository.save(usuario);

        String jwtToken = jwtService.generateToken(
            org.springframework.security.core.userdetails.User.builder()
                .username(usuario.getEmail())
                .password(usuario.getSenha())
                .build()
        );

        LoginResponse.UsuarioDTO usuarioDTO = new LoginResponse.UsuarioDTO(
            usuario.getId(),
            usuario.getNome(),
            usuario.getEmail(),
            usuario.getSecretaria().getNome(),
            usuario.getCargo()
        );

        return new LoginResponse(jwtToken, "Bearer", 86400000L, usuarioDTO);
    }

    public LoginResponse authenticate(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                request.getEmail(),
                request.getSenha()
            )
        );

        Usuario usuario = usuarioRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        String jwtToken = jwtService.generateToken(authentication);

        LoginResponse.UsuarioDTO usuarioDTO = new LoginResponse.UsuarioDTO(
            usuario.getId(),
            usuario.getNome(),
            usuario.getEmail(),
            usuario.getSecretaria() != null ? usuario.getSecretaria().getNome() : null,
            usuario.getCargo()
        );

        return new LoginResponse(jwtToken, "Bearer", 86400000L, usuarioDTO);
    }
}
