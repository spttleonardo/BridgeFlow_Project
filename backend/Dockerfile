# Usa o JDK 17 (necessário para rodar Spring Boot moderno)
FROM eclipse-temurin:17-jdk

# Cria um diretório de trabalho dentro do container
WORKDIR /app

# Copia o arquivo .jar gerado pelo Spring Boot
COPY target/*.jar app.jar

# Expõe a porta do backend
EXPOSE 8080

# Comando que inicia a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
