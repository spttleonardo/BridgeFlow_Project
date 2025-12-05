# BridgeFlow Backend

Plataforma de comunicacao interna desenvolvida com Spring Boot para suportar fluxos de comunicados, decisoes, notificacoes e gestao de usuarios da Prefeitura de Blumenau. Este documento resume como o backend esta organizado, quais dependencias utiliza, os principais fluxos de negocio e como executar o servico localmente ou via Docker.

## Visao Geral da Arquitetura
- **Linguagem e runtime:** Java 17 sobre Spring Boot 3.2.
- **Frameworks:** Spring Web, Spring Data JPA, Spring Security, Bean Validation e Spring AMQP.
- **Persistencia:** PostgreSQL com JPA/Hibernate, modo `ddl-auto=update` no perfil padrao.
- **Mensageria:** RabbitMQ para disparo de e-mails e integracoes assincronas.
- **Autenticacao e autorizacao:** JWT com filtro proprio (`JwtAuthenticationFilter`).
- **Implantacao:** Dockerfile simples que empacota o JAR e `docker-compose` que orquestra banco, RabbitMQ, backend, e-mail service e frontend.

## Estrutura de Pastas
```
backend/
├── Dockerfile
├── pom.xml
├── src/
│   ├── main/java/com/bridgeflow/internalcomms/
│   │   ├── config/            # Carga inicial de dados
│   │   ├── controller/        # REST controllers
│   │   ├── dto/               # Objetos de entrada/saida
│   │   ├── entity/            # Modelos JPA
│   │   ├── repository/        # Interfaces Spring Data
│   │   ├── security/          # Autenticacao e JWT
│   │   └── service/           # Regras de negocio e integracoes
│   └── main/resources/
│       ├── application.properties
│       └── application-docker.properties
└── target/                    # Artefato gerado apos build
```

## Dominio e Modelos de Dados
- `Usuario`: representa colaboradores. Implementa `UserDetails` e armazena dados de secretaria, cargo e status de ativacao.
- `Secretaria`: unidades organizacionais. Populadas automaticamente por `DataInitializer` se o banco estiver vazio.
- `Comunicado`: mensagens formais entre secretarias, com prioridade, status e opcionalmente destinatario.
- `Decisao`: itens de acompanhamento com responsavel, prazo e status.
- `Comentario`: registro textual associado a uma decisao.
- `Notificacao`: alertas direcionados a usuarios, com tipo (`NOVO_COMUNICADO`, `NOVA_DECISAO`, etc.) e integracao com comunicados ou decisoes.
- `VerificacaoEmail`: codigo temporario para ativacao de conta.

## Fluxos Principais
- **Cadastro e ativacao de usuarios:** `AuthService.register` cria o usuario, gera codigo de verificacao e envia evento RabbitMQ (`email.verificacao`). `AuthController` oferece endpoints para registro, login, verificacao e reenvio de e-mail.
- **Comunicados:** `ComunicadoService` cria comunicados, gera notificacoes para a secretaria destino e dispara evento de e-mail (`comunicado.criado`) quando informado um destinatario. Permite filtrar por secretaria, status e prioridade e atualizar status com controle de permissao.
- **Decisoes e comentarios:** `DecisaoService` registra decisoes atribuidas a um responsavel, notifica o destinatario, envia e-mail (`decisao.criada`) e permite comentar (`decisao/{id}/comentarios`).
- **Notificacoes manuais:** `NotificacaoService` cria alertas customizados, relaciona opcionalmente a comunicados/decisoes e garante disparo de e-mail (`notificacao.manual`) mesmo sem e-mail informado (usa e-mail do destinatario como fallback).
- **Dashboard:** `DashboardService` agrega estatisticas de comunicados, decisoes e notificacoes para alimentar a tela principal do frontend.

## Integracao RabbitMQ e Email Service
Os servicos que dependem do `MqService` publicam mensagens JSON no `exchange` configurado (`bridgeflow.exchange`, `routing-key` `bridgeflow.routingkey`). O microservico de e-mail consome e interpreta as chaves `type` para montar o e-mail:
- `email.verificacao`: ativacao de conta.
- `comunicado.criado`: resumo do comunicado enviado.
- `decisao.criada`: nova decisao atribuida.
- `notificacao.manual`: alerta customizado enviado por usuarios.

## Seguranca
- JWT configurado via `JwtService`, com chave em `jwt.secret` e expiracao configuravel (`jwt.expiration`).
- Filtro `JwtAuthenticationFilter` extrai o token do cabecalho `Authorization` e injeta a autenticacao no contexto.
- `SecurityConfig` libera apenas:
  - `POST /auth/register`, `POST /auth/login`, `GET /auth/verify`, `POST /auth/resend-verification`.
  - `GET /comunicados`, `GET /secretarias`, `GET /secretarias/**`.
  - Endpoints sob `/actuator/**`.
- Demais endpoints exigem `Authorization: Bearer <token>`.

## API REST
| Metodo | Rota | Descricao | Autenticacao |
| --- | --- | --- | --- |
| POST | `/auth/register` | Cadastra usuario e dispara e-mail de verificacao | Nao |
| POST | `/auth/login` | Autentica e retorna token JWT | Nao |
| GET | `/auth/verify` | Valida codigo de verificacao | Nao |
| POST | `/auth/resend-verification` | Reenvia codigo de ativacao | Nao |
| GET | `/secretarias` | Lista secretarias ativas | Nao |
| POST | `/comunicados` | Cria comunicado e notifica destino | Sim |
| GET | `/comunicados` | Lista comunicados com filtros | Opcional |
| PUT | `/comunicados/{id}/status` | Atualiza status (criador ou secretaria destino) | Sim |
| POST | `/decisoes` | Cria decisao com responsavel | Sim |
| GET | `/decisoes` | Lista decisoes (filtra por status/responsavel) | Sim |
| POST | `/decisoes/{id}/comentarios` | Adiciona comentario na decisao | Sim |
| GET | `/decisoes/{id}/comentarios` | Lista comentarios da decisao | Sim |
| POST | `/notificacoes` | Cria notificacao manual e dispara e-mail | Sim |
| GET | `/notificacoes` | Lista notificacoes do usuario (filtro `apenasNaoLidas`) | Sim |
| GET | `/dashboard/stats` | Retorna estatisticas de painel | Sim |
| GET | `/usuarios` | Lista usuarios ativos (filtro `secretariaId`) | Sim |

## Objetos de Transferencia (DTOs)
- **ComunicadoDTO:** `Create` (titulo, conteudo, prioridade, secretaria destino, e-mail opcional) e `UpdateStatus`.
- **DecisaoDTO:** `Create` (titulo, descricao, responsavel, prazo, e-mail) e filtros por status/responsavel.
- **NotificacaoDTO:** `Create` (titulo, mensagem, tipo, destinatario, opcional decisao/comunicado e e-mail).
- **LoginRequest/LoginResponse, RegisterRequest:** usados no fluxo de autenticacao.
- **DashboardDTO:** agrega contagens e mapas de status.
- **UsuarioResumoDTO, SecretariaDTO, ComentarioDTO:** saidas simplificadas.

## Configuracoes
- `src/main/resources/application.properties`: padrao para execucao local ou via Compose. Parametriza banco, RabbitMQ, logging e JWT.
- `src/main/resources/application-docker.properties`: perfil alternativo com credenciais prontas para ambiente dockerizado.
- Arquivo `.env` (na raiz de backend) espelha variaveis usadas no Compose.

### Variaveis sensiveis
| Variavel | Funcao |
| --- | --- |
| `SPRING_DATASOURCE_URL`/`USERNAME`/`PASSWORD` | Conexao com PostgreSQL |
| `SPRING_RABBITMQ_HOST`/`PORT`/`USERNAME`/`PASSWORD` | Broker de mensagens |
| `JWT_SECRET` | Chave de assinatura HMAC do JWT (>= 64 bytes recomendados) |
| `JWT_EXPIRATION` | Tempo de vida do token em milissegundos |

## Execucao Local
### Pre-requisitos
- Java 17+
- Maven 3.9+
- PostgreSQL e RabbitMQ (locais ou via Docker Compose)

### Via Maven
```bash
cd backend
mvn clean package
java -jar target/bridgeflow-0.0.1-SNAPSHOT.jar
```
Ou, durante desenvolvimento:
```bash
mvn spring-boot:run
```
Certifique-se de que as variaveis de ambiente (ou `.env`) apontem para instancias validas de PostgreSQL e RabbitMQ.

### Via Docker Compose
Com o repositorio na raiz do projeto:
```bash
docker compose up -d --build backend
```
O Compose provisiona Postgres, RabbitMQ, backend, email-service e frontend (porta 3000). O backend fica disponivel em `http://localhost:8080`.

## Dados Iniciais
`DataInitializer` cria secretarias padrao quando o banco esta vazio. Ajuste o seeder conforme necessidades reais (por exemplo, migrar para scripts Flyway/Liquibase em producao).

## Testes
Nao ha testes automatizados no momento. Utilize:
```bash
mvn test
```
para garantir que builds futuros mantenham cobertura e validacoes.

## Observabilidade e Health Check
- Endpoint `GET /actuator/health` usado no health check do Docker Compose (`curl -f http://localhost:8080/actuator/health`).
- Ajuste logging em `application.properties` (`logging.level.com.bridgeflow`).

## Sugestoes de Evolucao
- Introduzir migracoes de banco (Flyway/Liquibase) para maior controle de esquema.
- Expandir notificacoes para enviar para todos os membros da secretaria destino.
- Adicionar testes unitarios e de integracao para os principais servicos.
- Externalizar configuracoes sensiveis (JWT, SMTP) para um Secret Manager em producao.
