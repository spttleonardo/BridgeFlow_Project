# ========== STAGE 1 — BUILD FLUTTER WEB ==========
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copia todo o frontend
COPY . .

# Habilita o web e compila
RUN flutter config --enable-web
RUN flutter build web

# ========== STAGE 2 — SERVIR COM NGINX ==========
FROM nginx:alpine

# Copia os arquivos gerados na build
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
