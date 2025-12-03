package com.prefeitura.blumenau.comunicacaointerna.config;

import com.prefeitura.blumenau.comunicacaointerna.entity.Secretaria;
import com.prefeitura.blumenau.comunicacaointerna.repository.SecretariaRepository;
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
            new Secretaria(null, "Administration Department", "ADMIN", "Responsible for administrative management", true, null, null),
            new Secretaria(null, "Education Department", "EDU", "Responsible for education services", true, null, null),
            new Secretaria(null, "Health Department", "HEALTH", "Responsible for public health", true, null, null),
            new Secretaria(null, "Public Works Department", "WORKS", "Responsible for public infrastructure", true, null, null),
            new Secretaria(null, "Finance Department", "FINANCE", "Responsible for financial management", true, null, null),
            new Secretaria(null, "Environment Department", "ENV", "Responsible for environmental protection", true, null, null),
            new Secretaria(null, "Social Development Department", "SOCIAL", "Responsible for social services", true, null, null)
        };

        for (Secretaria secretaria : secretarias) {
            secretariaRepository.save(secretaria);
        }
    }
}
