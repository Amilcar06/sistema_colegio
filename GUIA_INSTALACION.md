# Guía de Instalación y Despliegue - Sistema Educativo

Esta guía detalla cómo instalar, configurar y desplegar el sistema tanto en entornos de desarrollo local como en producción usando Docker.

## Requisitos Previos
- **Java JDK 21** (Backend)
- **Flutter 3.x** (Frontend)
- **PostgreSQL 15+** (Base de Datos)
- **Docker & Docker Compose** (Opcional, recomendado para despliegue)

---

## 1. Despliegue Rápido con Docker (Recomendado)
El proyecto incluye configuración para despliegue contenerizado.

1. **Clonar el repositorio:**
   ```bash
   git clone <URL_REPOSITORIO>
   cd sistema
   ```

2. **Configurar Variables de Entorno:**
   Edite el archivo `docker-compose.prod.yml` (o cree un `.env`) con sus credenciales seguras.

3. **Ejecutar con Docker Compose:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d --build
   ```
   
   Esto levantará:
   - **Backend:** Puerto `8080`
   - **Frontend:** Puerto `80` (Nginx)
   - **Base de Datos:** Puerto `5432`

---

## 2. Desarrollo Local (Manual)

### Backend (Spring Boot)
1. Navegue a la carpeta `backend`.
2. Configure `src/main/resources/application.properties` si es necesario (Base de datos local).
3. Ejecute la aplicación:
   ```bash
   ./mvnw spring-boot:run
   ```
   El servidor iniciará en `http://localhost:8080`.

### Frontend (Flutter)
1. Navegue a la carpeta `frontend`.
2. Instale dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecute en modo desarrollo (Chrome):
   ```bash
   flutter run -d chrome --dart-define=BASE_URL=http://localhost:8080
   ```

---

## 3. CI/CD (GitHub Actions)
El proyecto cuenta con un pipeline automatizado en `.github/workflows/ci-cd.yml`.

### Flujo de Trabajo
- **Pull Request / Push a Main:**
    1. Ejecuta Tests de Backend (`mvn test`).
    2. Ejecuta Tests de Frontend (`flutter test`).
    3. Construye imágenes Docker optimizadas (Multi-stage).

### Configuración de Secretos
Para que el pipeline publique imágenes en DockerHub, configure los siguientes **Secrets** en GitHub:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

---

## 4. Monitoreo
El backend incluye **Spring Boot Actuator**.
- **Estado del sistema:** `GET /actuator/health`
- **Métricas:** `GET /actuator/metrics`

---

## 5. Operaciones de Mantenimiento (Docker)

### Ver Logs en Tiempo Real
Para ver los logs del backend:
```bash
docker logs -f unidad_edu_backend_prod
```

Para ver los logs del frontend (Nginx):
```bash
docker logs -f unidad_edu_frontend_prod
```

### Detener el Entorno
Para detener los servicios:
```bash
docker-compose -f docker-compose.prod.yml down
```

⚠️ **Nota:** Esto detiene los contenedores pero mantiene los volúmenes de datos (`postgres_data_prod`). Si deseas eliminar también la base de datos (¡Cuidado!):
```bash
docker-compose -f docker-compose.prod.yml down -v
```

### Variables de Entorno de Producción
El archivo `docker-compose.prod.yml` trae valores por defecto. Para un entorno real seguro, crea un archivo `.env` en la raíz y define:
- `DB_PASSWORD=tu_password_seguro`
- `JWT_SECRET=tu_secreto_jwt_largo`

