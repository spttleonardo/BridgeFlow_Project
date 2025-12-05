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
            new Secretaria(null, "Secretaria de Administração", "ADMIN", "Responsável pela gestão administrativa", true, null, null),
            new Secretaria(null, "Secretaria de Educação", "EDU", "Responsável pelos serviços de educação", true, null, null),
            new Secretaria(null, "Secretaria de Saúde", "HEALTH", "Responsável pela saúde pública", true, null, null),
            new Secretaria(null, "Secretaria de Obras", "WORKS", "Responsável pela infraestrutura pública", true, null, null),
            new Secretaria(null, "Secretaria de Finanças", "FINANCE", "Responsável pela gestão financeira", true, null, null),
            new Secretaria(null, "Secretaria de Meio Ambiente", "ENV", "Responsável pela proteção ambiental", true, null, null),
            new Secretaria(null, "Secretaria de Desenvolvimento Social", "SOCIAL", "Responsável pelos serviços sociais", true, null, null)
        };

        for (Secretaria secretaria : secretarias) {
            secretariaRepository.save(secretaria);
        }
    }
}
