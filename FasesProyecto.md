# 📅 Fases del Proyecto: Sistema "Unidad Educativa"

Este documento detalla la planificación estratégica para completar el sistema, basado en el análisis de estado actual (`EstadoProyecto.md`).

---

## 🏁 Fase 1: Cierre del Ciclo Académico (Prioridad Alta)
**Objetivo:** Garantizar que el flujo principal de la institución funcione de principio a fin: Inscripción -> Asignación -> Avance -> Calificación -> Cobro.

**Estado Actual:** ✅ **100% Completada** (Fase Cerrada).

### ✅ Completado
*   **Gestión de Usuarios:** Roles (Director, Secretaria, Profesor, Estudiante) funcionando.
*   **Estructura Académica:** Cursos, Materias, Paralelos.
*   **Inscripciones:** Registro funcional de estudiantes en cursos.
*   **Calificaciones:** Profesores pueden registrar notas; Estudiantes pueden ver las mismas.
*   **Finanzas Básicas:** Generación de deudas y registro de pagos en efectivo.
*   **Gestión de Horarios:**
    *   Backend: Entidad `Horario` y validaciones implementadas.
    *   Frontend: Director asigna horarios; Profesores y Estudiantes visualizan su agenda.

### 🔴 Pendiente Crítico (Para cerrar Fase 1)
*   *Ninguno. Fase cerrada exitosamente.*

---

## 🚀 Fase 2: Administración y Reportes (Prioridad Media)
**Objetivo:** Proveer herramientas formales para la administración y respaldo documental (PDFs). Transformar datos en documentos oficiales.

**Estado Actual:** ✅ **100% Completada** (Fase Cerrada).

### 1. Generación de Documentos (PDF)
*   **Backend (JasperReports):**
    *   ✅ **Boletín de Notas:** Completado. Incluye corrección de materias duplicadas y validación de deudas.
    *   ✅ **Endpoint Seguro:** Acceso restringido (`@PreAuthorize`) y descarga optimizada.
    *   ✅ **Recibo de Pago:** Implementado y verificado. Se descarga desde Historial o tras Pago.
    *   ✅ **Lista de Curso:** Implementado. Profesores descargar desde su mis cursos.
*   **Frontend:**
    *   ✅ **Descarga Web:** Funcionalidad implementada en todos los roles (Estudiante, Profesor, Secretaria).
    *   ✅ **Vistas Administrativas:** Integración UI completada.

### 2. Facturación y Comprobantes
*   **Backend:**
    *   ✅ Historial de transacciones inmutable.
    *   ✅ Numeración correlativa de recibos.
*   **Frontend (Secretaria):**
    *   ✅ Vista de historial de pagos (Buscador por fecha/alumno) con reimpresión.
    *   ✅ Opción de re-imprimir recibos (PDF).

---

## 📣 Fase 3: Comunicación y Comunidad (Prioridad Baja)
**Objetivo:** Fomentar la interacción entre los actores de la comunidad educativa.

**Estado Actual:** ✅ **Completado (100%)**

### 1. Sistema de Comunicados (Noticias)
*   **Backend:**
    *   ✅ **Modelo de Datos:** Entidad `Comunicado` implementada.
    *   ✅ **API Rest:** Endpoints `/api/comunicados` operativos.
*   **Frontend:**
    *   ✅ **Director:** Publicación de noticias generales.
    *   ✅ **Profesor:** Envío de comunicados por curso.
    *   ✅ **Estudiante:** Bandeja de entrada filtrada (Global + Curso).

### 2. Agenda de Eventos
*   **Backend:**
    *   ✅ **Modelo:** Entidad `Evento`.
    *   ✅ **API:** Endpoints `/api/eventos`.
*   **Frontend:**
    *   ✅ **Calendario/Lista:** Visualización de agenda escolar (Feriados, Exámenes).

### 3. Optimizaciones UX
*   **Dashboard:** Widgets con contadores reales (Total Alumnos, Pagos del día, etc.) en lugar de datos estáticos.
*   **Perfil:** Permitir a usuarios cambiar su foto de perfil y contraseña.
*   **Notificaciones:** Alertas visuales (Badge en campana) en Flutter.

---

## 🔄 Sincronización con Estado Actual

Para una lista detallada de qué funcionalidades están operativas hoy, consulta **[EstadoProyecto.md](EstadoProyecto.md)**.

*   **Fase 1 (Core):** Corresponde a las columnas marcadas con ✅ en `EstadoProyecto.md`.
*   **Fase 2 (Documental):** Corresponde a las funcionalidades de **Reportes** y **Facturación** marcadas con ❌ o ⚠️.
*   **Fase 3 (Comunidad):** Corresponde a **Comunicados** y **Eventos**.

