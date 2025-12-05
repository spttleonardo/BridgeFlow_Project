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
        // Recria secretarias iniciais em PT-BR para garantir tradução
        // (remove as existentes e insere novamente)
        secretariaRepository.deleteAll();
        criarSecretariasIniciais();
    }

    private void criarSecretariasIniciais() {
        Secretaria[] secretarias = {
            buildSecretaria("Secretaria de Administração", "ADMIN", "Responsável pela gestão administrativa"),
            buildSecretaria("Secretaria de Educação", "EDU", "Responsável pelos serviços de educação"),
            buildSecretaria("Secretaria de Saúde", "HEALTH", "Responsável pela saúde pública"),
            buildSecretaria("Secretaria de Obras", "WORKS", "Responsável pela infraestrutura pública"),
            buildSecretaria("Secretaria de Finanças", "FINANCE", "Responsável pela gestão financeira"),
            buildSecretaria("Secretaria de Meio Ambiente", "ENV", "Responsável pela proteção ambiental"),
            buildSecretaria("Secretaria de Desenvolvimento Social", "SOCIAL", "Responsável pelos serviços sociais")
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
