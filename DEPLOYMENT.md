# Guía de Despliegue (Producción)

Este proyecto está configurado para desplegarse utilizando Docker y Docker Compose. La configuración de producción levanta 3 contenedores:
1. **Base de Datos**: PostgreSQL 15
2. **Backend**: Spring Boot 3 (Java 21)
3. **Frontend**: Flutter Web servido por Nginx

## Requisitos Previos
- Docker Desktop instalado y corriendo.
- Git (para clonar el repositorio si es necesario).

## Instrucciones de Ejecución

1. **Detener servicios locales**:
   Asegúrate de no tener el backend (puerto 8080) o alguna base de datos (puerto 5432) corriendo en tu máquina local para evitar conflictos de puertos.
   ```bash
   # Si usas mvn spring-boot:run, ctr+c para detenerlo.
   # Si tienes un postgres local, deten servicio.
   ```

2. **Construir y Levantar contenedores**:
   Desde la raíz del proyecto (donde está `docker-compose.prod.yml`):

   ```bash
   docker-compose -f docker-compose.prod.yml up --build -d
   ```
   
   - `-f docker-compose.prod.yml`: Indica usar el archivo de producción.
   - `--build`: Fuerza la re-construcción de las imágenes (útil si cambiaste código).
   - `-d`: Ejecuta en segundo plano (detached mode).

3. **Verificar Estado**:
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   ```
   Deberías ver 3 servicios (`unidad_edu_db_prod`, `unidad_edu_backend_prod`, `unidad_edu_frontend_prod`) con estado `Up`.

4. **Acceder a la Aplicación**:
   - **Frontend**: Abre tu navegador en `http://localhost`
   - **Backend API**: Disponible en `http://localhost:8080/api`
   - **Swagger UI**: `http://localhost:8080/swagger-ui.html`

## Logs y Monitoreo

Para ver los logs del backend:
```bash
docker logs -f unidad_edu_backend_prod
```

Para ver los logs del frontend (Nginx):
```bash
docker logs -f unidad_edu_frontend_prod
```

## Detener el Entorno
```bash
docker-compose -f docker-compose.prod.yml down
```
⚠️ Esto detiene los contenedores pero mantiene el volumen de datos (`postgres_data_prod`). Si quieres borrar también la base de datos:
```bash
docker-compose -f docker-compose.prod.yml down -v
```

## Variables de Entorno
El archivo `docker-compose.prod.yml` tiene valores por defecto. Para mayor seguridad en producción real, crea un archivo `.env` y define:
- `DB_PASSWORD`
- `JWT_SECRET`
