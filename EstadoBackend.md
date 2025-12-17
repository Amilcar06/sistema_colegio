# 🧠 Análisis Técnico del Backend

Este documento detalla la arquitectura, seguridad y cobertura funcional del backend del sistema "Unidad Educativa", ubicado en `backend/src/main/java/com/unidadeducativa`.

## 1. 🏗️ Arquitectura y Estructura
El proyecto sigue una arquitectura moderna de **"Package by Feature" (Paquete por Funcionalidad)**. En lugar de organizar el código por capas técnicas (controllers, services, repositories), se organiza por dominios de negocio.

### Estructura de Directorios
*   `com.unidadeducativa.auth`: Gestión de seguridad, JWT, login y registro de instituciones.
*   `com.unidadeducativa.personas`: Submódulos para cada actor (`estudiante`, `profesor`, `director`, `secretaria`).
*   `com.unidadeducativa.academia`: El núcleo del negocio (`curso`, `materia`, `inscripcion`, `nota`, `gestion`).
*   `com.unidadeducativa.finanzas`: Gestión de `pago`, `tipo_pago`, `cuenta_cobrar`.
*   `com.unidadeducativa.reportes`: Generación de PDFs y estadísticas (Dashboard).
*   `com.unidadeducativa.notificaciones`: Sistema de mensajería in-app.
*   `com.unidadeducativa.config`: Configuraciones globales (`DataInitializer`, `Swagger`, `WebConfig`).

**Ventajas:**
*   **Escalabilidad:** Añadir o quitar módulos (ej: Eliminar "Finanzas") es limpio y no afecta al resto del sistema.
*   **Mantenibilidad:** Todo lo relacionado con "Estudiantes" (dto, model, repo, service, controller) está en un solo lugar.

## 2. 🛡️ Seguridad
El sistema implementa una seguridad robusta basada en **Spring Security 6** y estándares RESTful.

*   **Autenticación:**
    *   **Stateless:** No mantiene sesiones en servidor, ideal para escalabilidad.
    *   **JWT (JSON Web Token):** El usuario recibe un token al hacer login que debe enviar en la cabecera `Authorization: Bearer <token>` en cada petición.
    *   **BCrypt:** Las contraseñas se almacenan hasheadas en la base de datos.
*   **Autorización:**
    *   **RBAC (Role-Based Access Control):** Control de acceso basado en roles (`DIRECTOR`, `SECRETARIA`, `PROFESOR`, `ESTUDIANTE`).
    *   **Method Security:** Uso de `@PreAuthorize("hasRole('DIRECTOR')")` directamente en los controladores para proteger endpoints específicos.
*   **Configuración:**
    *   `SecurityConfig.java`: Centraliza las reglas de CORS (Permite acceso al Frontend) y la cadena de filtros de seguridad.

## 3. 🔌 Endpoints y Cobertura
El API REST cubre los 4 pilares fundamentales de la gestión escolar:

### A. Autenticación (`/api/auth`)
*   `POST /login`: Ingreso al sistema.
*   `POST /register-school`: Setup inicial de una nueva unidad educativa.

### B. Gestión Académica (`/api/academia`)
*   **Cursos:** CRUD de cursos y paralelos.
*   **Inscripciones:** Matricular estudiantes en cursos.
*   **Notas:** Registrar y consultar calificaciones por trimestre.
*   **Gestión:** Apertura y cierre de años escolares.

### C. Personas (`/api/usuarios`)
*   Gestión completa de perfiles para Director, Secretaria, Profesor y Estudiante.
*   Subida de **Foto de Perfil**.

### D. Finanzas (`/api/finanzas`)
*   **Pagos:** Registro de pagos en efectivo.
*   **Deudas:** Consulta de pensiones pendientes.
*   **Recibos:** Generación automática de historial.

### E. Soporte
*   **Reportes:** Descarga de Boletines, Listas de Curso y Recibos en PDF.
*   **Dashboard:** Estadísticas en tiempo real para la toma de decisiones.
*   **Notificaciones:** Alertas de sistema para usuarios.

## 4. 🎯 Alcance: Lo que Resuelve vs. Fuera de Alcance

| ✅ Resuelve Eficientemente | ❌ Fuera de Alcance (MVP) |
| :--- | :--- |
| **Gestión Académica Central:** Registro de notas, control de avance, boletines oficiales. | **Horarios Automáticos:** No genera horarios inteligente para evitar choques (es carga manual). |
| **Flujo de Caja Institucional:** Control de ingresos diarios y deudas por alumno. | **Contabilidad Fiscal:** No reemplaza un sistema contable (Libros IVA, Balances). |
| **Documentación Oficial:** Generación automática de documentos que antes eran manuales. | **Biometría/Asistencia:** No integra control de asistencia por huella o molinetes. |
| **Seguridad de Datos:** Acceso segmentado por roles estrictos. | **Auditoría Forense:** No tiene logs detallados de cambios históricos en datos sensibles. |

## 5. 💡 Conclusión
La estructura del backend es **sólida, modular y moderna**. Está lista para soportar la carga de datos masiva y el flujo de trabajo completo ("Walkthrough") sin necesidad de refactorización estructural.

**Próximos Pasos Recomendados (Post-Entrega):**
1.  **Tests Unitarios:** Implementar JUnit para la lógica crítica de cálculo de promedios y deudas.
2.  **Validación Robusta:** Añadir anotaciones `@NotNull` y `@Size` en todos los DTOs restantes.
3.  **Documentación API:** Completar las anotaciones Swagger en los nuevos controladores.
