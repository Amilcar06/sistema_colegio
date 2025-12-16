# 📅 Fases del Proyecto: Sistema "Unidad Educativa"

Este documento detalla la planificación estratégica para completar el sistema, basado en el análisis de estado actual (`EstadoProyecto.md`).

---

## 🏁 Fase 1: Cierre del Ciclo Académico (Prioridad Alta)
**Objetivo:** Garantizar que el flujo principal de la institución funcione de principio a fin: Inscripción -> Asignación -> Avance -> Calificación -> Cobro.

**Estado Actual:** � **100% Completada** (Fase Cerrada).

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

**Estado Actual:** 🟡 **30% En Progreso**

### 1. Generación de Documentos (PDF)
*   **Backend (JasperReports):**
    *   ✅ **Boletín de Notas:** Plantilla `boletin_notas.jrxml` integrada, con cálculo dinámico de promedios.
    *   ✅ **Endpoint Seguro:** Acceso restringido (`@PreAuthorize`) y descarga optimizada.
    *   ⚪ **Recibo de Pago:** Pendiente validación final.
    *   ⚪ **Lista de Curso:** Pendiente validación final.
*   **Frontend:**
    *   ✅ **Descarga Web:** Funcionalidad implementada en el Dashboard de Estudiante.
    *   ⚪ **Vistas Administrativas:** Botones de descarga para Secretaria/Profesor pendientes.

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
    *   Lógica de destinatarios: `GLOBAL` (todos), `POR_CURSO` (ej. solo 1ro A), `INDIVIDUAL` (solo un estudiante).
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

---

## 🔄 Sincronización con Estado Actual

Para una lista detallada de qué funcionalidades están operativas hoy, consulta **[EstadoProyecto.md](EstadoProyecto.md)**.

*   **Fase 1 (Core):** Corresponde a las columnas marcadas con ✅ en `EstadoProyecto.md`.
*   **Fase 2 (Documental):** Corresponde a las funcionalidades de **Reportes** y **Facturación** marcadas con ❌ o ⚠️.
*   **Fase 3 (Comunidad):** Corresponde a **Comunicados** y **Eventos**.

