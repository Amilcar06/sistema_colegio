# Dockerfile para Spring Boot app
FROM eclipse-temurin:21-jdk-alpine

# Crear un directorio para la app
WORKDIR /app

# Copiar el archivo jar (ajusta el nombre si es necesario)
COPY target/backend-0.0.1-SNAPSHOT.jar app.jar

# Exponer el puerto (ajusta si usas otro puerto)
EXPOSE 8080

# Comando para ejecutar el jar
ENTRYPOINT ["java", "-jar", "app.jar"]