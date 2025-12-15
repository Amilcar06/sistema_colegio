# Unidad Educativa - Backend (SaaS)

Sistema de gestión académica y financiera multi-tenant para unidades educativas.

## 🚀 Inicio Rápido

### 1. Requisitos
*   Java 21
*   Docker & Docker Compose

### 2. Configuración de Base de Datos
El proyecto usa PostgreSQL en un contenedor Docker.
```bash
# Levantar la base de datos en segundo plano (puerto 5434)
docker-compose up -d unidadeducativa_db
```

### 3. Ejecución Local
Puedes correr el proyecto directamente con Maven Wrapper:

```bash
# Linux/Mac
./mvnw spring-boot:run

# Windows
mvnw spring-boot:run
```

O compilar y ejecutar el JAR:
```bash
./mvnw clean package -DskipTests
java -jar target/backend-0.0.1-SNAPSHOT.jar
```

La aplicación estará disponible en: `http://localhost:8080`

### 4. Documentación API
Swagger UI está habilitado para probar endpoints:
👉 **[http://localhost:8080/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html)**

---

## 🛠 Estado del Proyecto

### Módulos Completados
- **Auth & Multitenancy**: Registro de colegios, usuarios y roles.
- **Académico**: Gestión de cursos, materias, profesores y estudiantes.
- **Financiero**: Control de pensiones, pagos y reportes de ingresos.

### Tecnologías
- **Core**: Spring Boot 3, Java 21.
- **DB**: PostgreSQL 16.
- **Tools**: MapStruct (DTO mapping), Lombok, JWT (Security).
