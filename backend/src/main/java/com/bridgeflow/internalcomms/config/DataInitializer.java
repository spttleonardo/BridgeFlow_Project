package com.bridgeflow.internalcomms.config;

import com.bridgeflow.internalcomms.entity.Secretaria;
import com.bridgeflow.internalcomms.repository.SecretariaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final SecretariaRepository secretariaRepository;

    @Override
    public void run(String... args) throws Exception {
        if (secretariaRepository.count() == 0) {
            criarSecretariasIniciais();
        }
    }

    private void criarSecretariasIniciais() {
        Secretaria[] secretarias = {
            buildSecretaria("Administration Department", "ADMIN", "Responsible for administrative management"),
            buildSecretaria("Education Department", "EDU", "Responsible for education services"),
            buildSecretaria("Health Department", "HEALTH", "Responsible for public health"),
            buildSecretaria("Public Works Department", "WORKS", "Responsible for public infrastructure"),
            buildSecretaria("Finance Department", "FINANCE", "Responsible for financial management"),
            buildSecretaria("Environment Department", "ENV", "Responsible for environmental protection"),
            buildSecretaria("Social Development Department", "SOCIAL", "Responsible for social services")
        };

        for (Secretaria secretaria : secretarias) {
            secretariaRepository.save(secretaria);
        }
    }

    private Secretaria buildSecretaria(String nome, String sigla, String descricao) {
        Secretaria secretaria = new Secretaria();
        secretaria.setNome(nome);
        secretaria.setSigla(sigla);
        secretaria.setDescricao(descricao);
        secretaria.setAtivo(true);
        secretaria.setDataCriacao(java.time.LocalDateTime.now());
        secretaria.setDataAtualizacao(null);
        return secretaria;
    }
}
