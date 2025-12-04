package com.bridgeflow.internalcomms.service;

import com.bridgeflow.internalcomms.dto.LoginRequest;
import com.bridgeflow.internalcomms.dto.LoginResponse;
import com.bridgeflow.internalcomms.dto.RegisterRequest;
import com.bridgeflow.internalcomms.entity.Secretaria;
import com.bridgeflow.internalcomms.entity.Usuario;
import com.bridgeflow.internalcomms.entity.VerificacaoEmail;
import com.bridgeflow.internalcomms.repository.SecretariaRepository;
import com.bridgeflow.internalcomms.repository.UsuarioRepository;
import com.bridgeflow.internalcomms.repository.VerificacaoEmailRepository;
import com.bridgeflow.internalcomms.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final SecretariaRepository secretariaRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final VerificacaoEmailRepository verificacaoEmailRepository;
    private final MqService mqService;

    @Transactional
    public void register(RegisterRequest request) {
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

        String codigo = UUID.randomUUID().toString();
        LocalDateTime dataExpiracao = LocalDateTime.now().plusMinutes(30);
        VerificacaoEmail verificacao = new VerificacaoEmail(codigo, usuario, dataExpiracao);
        verificacaoEmailRepository.save(verificacao);

        mqService.notificar(Map.of(
                "type", "email.verificacao",
                "usuarioEmail", usuario.getEmail(),
                "codigo", codigo,
                "expiresAt", dataExpiracao.toString()
        ));
    }

    @Transactional
    public LoginResponse verificarEmail(String codigo) {
        VerificacaoEmail verificacao = verificacaoEmailRepository.findByCodigo(codigo)
                .orElseThrow(() -> new RuntimeException("Código de verificação inválido"));

        if (verificacao.getDataExpiracao().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Código de verificação expirado");
        }

        Usuario usuario = verificacao.getUsuario();
        usuario.setAtivo(true);
        usuarioRepository.save(usuario);

        verificacaoEmailRepository.delete(verificacao);

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

        if (!usuario.getAtivo()) {
            throw new RuntimeException("Usuário não está ativo. Verifique seu e-mail.");
        }

        // Build UserDetails from the authenticated usuario to generate JWT
        org.springframework.security.core.userdetails.UserDetails userDetails =
            org.springframework.security.core.userdetails.User.builder()
                .username(usuario.getEmail())
                .password(usuario.getSenha())
                .build();

        String jwtToken = jwtService.generateToken(userDetails);

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
