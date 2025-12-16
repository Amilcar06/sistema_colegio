# Sistema de Gestión Académica - "Unidad Educativa"

Este proyecto es un sistema integral para la administración de unidades educativas, cubriendo procesos académicos, financieros y administrativos.

## 🏗 Arquitectura del Sistema

El proyecto está diseñado como un **Monorepo** que contiene dos componentes principales:

### 🔙 Backend (Spring Boot)
*   **Lenguaje:** Java 21
*   **Framework:** Spring Boot 3
*   **Seguridad:** Spring Security + JWT
*   **Base de Datos:** PostgreSQL
*   **Ubicación:** `/backend`

### 📱 Frontend (Flutter)
*   **Framework:** Flutter (Soporte Web y Mobile)
*   **Gestión de Estado:** `provider` / `go_router`
*   **Ubicación:** `/frontend`

---

## 🚀 Requisitos Previos

*   **Java JDK 21+**
*   **Flutter SDK** (Versión Stable)
*   **Docker** (Para la base de datos PostgreSQL)
*   **Maven** (Incluido `mvnw`)

---

## 🛠️ Instalación y Ejecución

### 1. Base de Datos
Asegúrate de tener Docker corriendo y levanta la base de datos:
```bash
cd backend
docker-compose up -d
```

### 2. Backend
Iniciar el servidor Spring Boot (puerto 8080):
```bash
cd backend
./mvnw spring-boot:run
```
*El sistema cargará automáticamente datos de prueba (Director, Profesores, Estudiantes) si la base de datos está vacía.*

### 3. Frontend
Iniciar la aplicación web (puerto ~5000-6000):
```bash
cd frontend
flutter run -d chrome
```

---

## 👥 Usuarios de Prueba (Data Seeding)

| Rol | Correo | Contraseña |
| :--- | :--- | :--- |
| **Director** | `director@gmail.com` | `123456` |
| **Secretaria** | `secretaria@gmail.com` | `123456` |
| **Profesor** | `profesor@gmail.com` | `123456` |
| **Estudiante** | `estudiante1@gmail.com` | `123456` |

---

## 📊 Estado del Proyecto

Para ver el detalle de funcionalidades implementadas y la hoja de ruta, consulta:
*   [Estado del Proyecto](EstadoProyecto.md) - Semaforización de features. (Fase 1 y 2 Completadas)
*   [Fases del Proyecto](FasesProyecto.md) - Planificación actual y futura. (Fase 3 Pendiente)

---

## © Autor
**Amilcar Yujra** - Proyecto Personal
