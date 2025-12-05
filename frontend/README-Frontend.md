# BridgeFlow Frontend

Este documento explica a arquitetura, configuração, execução e integração do frontend do projeto BridgeFlow.

## Visão Geral
O frontend do BridgeFlow é responsável pela interface do usuário, permitindo interação com os módulos de comunicação interna, notificações, autenticação e dashboards. Ele se comunica com o backend via API REST e pode ser executado localmente ou em ambiente Docker.

## Tecnologias Utilizadas
- Framework: (Preencher: React, Angular, Vue, etc.)
- Linguagem: JavaScript/TypeScript
- Gerenciador de pacotes: npm/yarn
- Docker para empacotamento e execução

## Estrutura de Pastas
```
frontend/
  Dockerfile
  ... (outros arquivos e pastas do frontend)
```

## Principais Funcionalidades
- Autenticação de usuários
- Visualização e envio de comunicados
- Dashboard de decisões e comentários
- Integração com notificações e email

## Configuração
1. **Pré-requisitos:**
   - Node.js >= 16
   - npm ou yarn
   - Docker (opcional)

2. **Instalação local:**
   ```sh
   cd frontend
   npm install
   # ou
   yarn install
   ```

3. **Configuração de ambiente:**
   - Crie um arquivo `.env` com as variáveis de ambiente necessárias, por exemplo:
     ```env
     REACT_APP_API_URL=http://localhost:8080
     ```

## Execução
### Local
```sh
npm start
# ou
yarn start
```
O frontend estará disponível em `http://localhost:3000` (ou porta configurada).

### Docker
1. **Build da imagem:**
   ```sh
docker build -t bridgeflow-frontend .
```
2. **Execução do container:**
   ```sh
docker run -p 3000:3000 bridgeflow-frontend
```
3. **Via Docker Compose:**
   - Se houver um arquivo `docker-compose.yml`:
     ```sh
docker compose up -d frontend
```

## Integração com Backend
- O frontend consome as APIs REST do backend para autenticação, comunicados, dashboard, etc.
- Configure a URL do backend nas variáveis de ambiente (`REACT_APP_API_URL`).

## Exemplos de Consumo de API
```js
// Exemplo usando fetch
fetch(`${process.env.REACT_APP_API_URL}/api/comunicados`)
  .then(res => res.json())
  .then(data => console.log(data));
```

## Deploy
- O frontend pode ser hospedado em serviços como Azure Web App, AWS Elastic Beanstalk, Vercel, Netlify, etc.
- Para produção, gere o build:
  ```sh
  npm run build
  # ou
  yarn build
  ```
  O conteúdo da pasta `build/` pode ser publicado em servidores web.

## Sugestões de Evolução
- Implementar testes automatizados (Jest, Cypress)
- Adicionar internacionalização (i18n)
- Melhorar responsividade e acessibilidade
- Integrar monitoramento de erros (Sentry, etc.)

## Contato e Suporte
Para dúvidas ou sugestões, entre em contato com o time de desenvolvimento.
