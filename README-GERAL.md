# BridgeFlow Project - Documentação Geral

Este documento apresenta uma visão completa do sistema BridgeFlow, incluindo arquitetura, componentes, fluxo de dados, tecnologias, execução e integração dos módulos backend, frontend e email-service.

---

## Visão Geral
BridgeFlow é uma solução para comunicação interna, gestão de comunicados, decisões, comentários e notificações em ambientes corporativos. O sistema é composto por três módulos principais:
- **Backend:** API REST, lógica de negócio, autenticação, integração com RabbitMQ e PostgreSQL.
- **Frontend:** Interface web para usuários finais, consumo das APIs do backend.
- **Email-Service:** Serviço dedicado ao envio de emails e registro de logs, integrado via RabbitMQ.

---

## Arquitetura
```
[Usuário] ⇄ [Frontend] ⇄ [Backend] ⇄ [RabbitMQ] ⇄ [Email-Service]
                                 ⇄ [PostgreSQL]
```
- O usuário interage via frontend (web).
- O frontend consome APIs REST do backend.
- O backend processa requisições, autentica usuários (JWT), gerencia comunicados, decisões e envia notificações via RabbitMQ.
- O email-service consome mensagens do RabbitMQ, envia emails via SMTP e registra logs em banco.

---

## Tecnologias Utilizadas
- **Backend:** Java 17, Spring Boot 3.2, RabbitMQ, PostgreSQL, Docker
- **Frontend:** (Preencher: React/Angular/Vue), JavaScript/TypeScript, Docker
- **Email-Service:** Java 17, Spring Boot, RabbitMQ, SMTP, Docker

---

## Componentes
### Backend
- API REST para comunicados, decisões, comentários, autenticação
- Segurança via JWT
- Integração com RabbitMQ para notificações
- Persistência em PostgreSQL
- Dockerfile para empacotamento

### Frontend
- Interface web responsiva
- Autenticação, dashboards, envio/visualização de comunicados
- Consumo das APIs do backend
- Dockerfile para empacotamento

### Email-Service
- Listener RabbitMQ para mensagens de email
- Envio de emails via SMTP
- Registro de logs de envio
- API REST para consulta de logs
- Dockerfile e docker-compose para execução

---

## Fluxo de Dados
1. Usuário acessa o frontend e realiza login.
2. Frontend envia requisições para o backend (ex: criar comunicado).
3. Backend processa, salva no banco e publica mensagem no RabbitMQ.
4. Email-service consome mensagem, envia email e registra log.
5. Usuário pode consultar status e logs via frontend/backend.

---

## Execução do Sistema
### Pré-requisitos
- Docker e Docker Compose
- Node.js (para execução local do frontend)
- Java 17 (para execução local dos serviços)

### Subindo com Docker Compose
Na raiz do projeto:
```sh
docker compose up -d
```
Isso irá subir todos os serviços (backend, frontend, email-service, RabbitMQ, PostgreSQL).

### Execução Manual
- Backend: `cd backend && ./mvnw spring-boot:run`
- Frontend: `cd frontend && npm start`
- Email-Service: `cd email-service && ./mvnw spring-boot:run`

---

## Integração e Configuração
- Configure variáveis de ambiente nos arquivos `.env` (frontend) e `application.properties`/`application.yml` (backend/email-service).
- URLs de integração:
  - Backend: `http://localhost:8080`
  - Frontend: `http://localhost:3000`
  - Email-Service: Porta configurada no Docker Compose
  - RabbitMQ: `amqp://localhost:5672`
  - PostgreSQL: `jdbc:postgresql://localhost:5432/bridgeflow`

---

## APIs Principais
- Backend: `/api/auth`, `/api/comunicados`, `/api/decisoes`, `/api/dashboard`, etc.
- Email-Service: `/api/email-logs`

---

## Sugestões de Evolução
- Implementar testes automatizados (backend, frontend)
- Adicionar monitoramento (Prometheus, Grafana)
- Internacionalização (i18n)
- Deploy em nuvem (Azure, AWS)

---

## Contato e Suporte
Para dúvidas, sugestões ou suporte, entre em contato com o time de desenvolvimento.
