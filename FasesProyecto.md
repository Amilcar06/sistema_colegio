# 📅 Fases del Proyecto: Sistema "Unidad Educativa"

Este documento detalla la planificación estratégica para completar el sistema, basado en el análisis de estado actual (`EstadoProyecto.md`).

---

## 🏁 Fase 1: Cierre del Ciclo Académico (Prioridad Alta)
**Objetivo:** Garantizar que el flujo principal de la institución funcione de principio a fin: Inscripción -> Asignación -> Avance -> Calificación -> Cobro.

**Estado Actual:** 🟡 **90% Completada** (Faltan detalles críticos de Horarios).

### ✅ Completado
*   **Gestión de Usuarios:** Roles (Director, Secretaria, Profesor, Estudiante) funcionando.
*   **Estructura Académica:** Cursos, Materias, Paralelos.
*   **Inscripciones:** Registro funcional de estudiantes en cursos.
*   **Calificaciones:** Profesores pueden registrar notas; Estudiantes pueden verlas.
*   **Finanzas Básicas:** Generación de deudas y registro de pagos en efectivo.

### 🔴 Pendiente Crítico (Para cerrar Fase 1)
1.  **Gestión de Horarios (Horarios):**
    *   **Backend:** Crear Entidad `Horario` (Día, Hora Inicio, Hora Fin, Aula) vinculada a `AsignacionDocente`.
    *   **Backend:** Endpoint para verificar choques de horario (Validación).
    *   **Frontend (Director):** Interfaz visual (Grid/Calendario) para asignar horarios a materias.
    *   **Frontend (Est/Prof):** Vista de "Mi Horario" en el dashboard.

---

## 🚀 Fase 2: Administración y Reportes (Prioridad Media)
**Objetivo:** Proveer herramientas formales para la administración y respaldo documental (PDFs). Transformar datos en documentos oficiales.

**Estado Actual:** 🔴 **0% Iniciado**

### 1. Generación de Documentos (PDF)
*   **Backend (JasperReports o iText):**
    *   **Boletín de Notas:** Diseño de plantilla oficial. Endpoint para descargar PDF por estudiante/curso.
    *   **Recibo de Pago:** Generación de comprobante tras un pago exitoso.
    *   **Lista de Curso:** Reporte de estudiantes inscritos para impresión (para profesores).
*   **Frontend:**
    *   Botones de "Descargar PDF" en las vistas de Notas, Pagos y Listas.
    *   Manejo de descargas/apertura de blobs en Flutter Web.

### 2. Facturación y Comprobantes
*   **Backend:**
    *   Historial de transacciones inmutable.
    *   Numeración correlativa de recibos.
*   **Frontend (Secretaria):**
    *   Vista de historial de pagos (Buscador por fecha/alumno).
    *   Opción de re-imprimir recibos.

---

## 📢 Fase 3: Comunicación y Comunidad (Prioridad Baja/Final)
**Objetivo:** Mejorar la interacción entre los actores del sistema y optimizar la experiencia de usuario.

**Estado Actual:** 🔴 **0% Iniciado**

### 1. Módulo de Comunicados
*   **Backend:**
    *   Entidad `Comunicado` (Título, Cuerpo, Fecha, Adjunto?).
    *   Lógica de destinatarios: `GLOBAL` (todos), `POR_CURSO` (ej. solo 1ro A), `INDIVIDUAL`.
*   **Frontend:**
    *   **Director:** Editor de texto enriquecido para crear noticias.
    *   **Todos:** Bandeja de entrada de comunicados/noticias en el Dashboard.

### 2. Agenda de Eventos
*   **Backend:** Entidad `Evento` (Fecha, Título, Descripción).
*   **Frontend:** Calendario interactivo en la pantalla de inicio mostrando feriados, exámenes, actividades cívicas.

### 3. Optimizaciones UX
*   **Dashboard:** Widgets con contadores reales (Total Alumnos, Pagos del día, etc.) en lugar de datos estáticos.
*   **Perfil:** Permitir a usuarios cambiar su foto de perfil y contraseña.
*   **Notificaciones:** Alertas visuales (Badge en campana) en Flutter.
