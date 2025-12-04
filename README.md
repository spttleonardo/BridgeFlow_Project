# BridgeFlow

MVP of internal communication platform for government organizations.

## Arquitetura

- **Backend**: Java Spring Boot com autenticação JWT
- **Frontend**: Flutter Web
- **Banco**: PostgreSQL
- **Infraestrutura**: Docker Compose

## Funcionalidades

### Autenticação
- Login e registro de usuários
- JWT para segurança

### Comunicados
- Criar comunicados entre secretarias
- Filtrar por secretaria, status e prioridade
- Atualizar status dos comunicados

### Decisões
- Criar decisões com responsáveis e prazos
- Sistema de comentários
- Acompanhamento de status

### Dashboard
- Métricas gerais do sistema
- Estatísticas de comunicados e decisões

## Como Executar

### Pré-requisitos
- Docker e Docker Compose instalados

### Execução
```bash
# Na raiz do projeto
docker compose up -d --build
```

Healthcheck: o backend expõe `GET /actuator/health` e é monitorado pelo compose.

### Acesso
- **Frontend**: http://localhost:3000 (se estiver rodando o Flutter web server)
- **Backend API**: http://localhost:8080
- **Banco PostgreSQL**: localhost:5432

## Endpoints da API

### Autenticação
- `POST /auth/login` - Login
- `POST /auth/register` - Registro

### Comunicados
- `GET /comunicados` - Listar com filtros
- `POST /comunicados` - Criar comunicado
- `PUT /comunicados/{id}/status` - Atualizar status

### Decisões
- `GET /decisoes` - Listar com filtros
- `POST /decisoes` - Criar decisão
- `POST /decisoes/{id}/comentarios` - Adicionar comentário
- `GET /decisoes/{id}/comentarios` - Listar comentários

### Dashboard
- `GET /dashboard` - Estatísticas

## Initial Data

The system automatically initializes with 7 departments:
- Administration Department (ADMIN)
- Education Department (EDU)
- Health Department (HEALTH)
- Public Works Department (WORKS)
- Finance Department (FINANCE)
- Environment Department (ENV)
- Social Development Department (SOCIAL)

## Desenvolvimento

Para desenvolvimento local:

### Backend
```bash
cd backend
# Configurar PostgreSQL local
# mvn spring-boot:run
```

### Frontend
```bash
cd frontend
flutter run -d web-server --web-port=3000
```

## Estrutura do Banco

### Tabelas Principais
- `usuarios` - Usuários do sistema
- `secretarias` - Government departments
- `comunicados` - Comunicados entre secretarias
- `decisoes` - Decisões e tarefas
- `comentarios` - Discussões em decisões
- `notificacoes` - Sistema de notificações