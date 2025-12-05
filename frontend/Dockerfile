# Build stage: compile the Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.24.3 AS build
WORKDIR /app

# Cache pubspec first to leverage Docker layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the remaining application source and build for the web
COPY . .
RUN flutter build web --release

# Runtime stage: serve static assets with nginx
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
