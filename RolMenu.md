# 🧭 Estructura del Menú por Rol (Sitemap)

Este documento define la navegación final de la aplicación web y móvil para cada tipo de usuario.

---

## 👨‍💼 1. Rol: Director (Super Admin)
**Objetivo:** Control total, configuración y supervisión estratégica.

### 🏠 Dashboard (Inicio)
*   **KPIs:** Total Estudiantes (Activos/Inactivos), Ingresos del Mes, Profesores Activos.
*   **Gráficos:** Ingresos vs. Gastos (si aplica), tasa de inscripciones.

### 🏫 Gestión Institucional
*   **Gestiones Académicas:** Crear/Cerrar años escolares (e.g., 2024, 2025).
*   **Configuración General:** Datos de la unidad educativa, logo, reglas de negocio.

### 📚 Gestión Académica
*   **Niveles:** (Inicial, Primaria, Secundaria).
*   **Grados/Cursos:** Configuración de 1ro a 6to, etc.
*   **Paralelos:** Asignación de cupos (A, B, C).
*   **Materias:** Catálogo global de asignaturas (Matemáticas, Física).
*   **Horarios:** Matriz general de horarios por curso.

### 👥 Gestión de Usuarios
*   **Personal Administrativo:** Registrar Secretarias/os.
*   **Cuerpo Docente:** Registro de profesores y asignación de materias (Carga Horaria).
*   **Estudiantes:** Vista global (búsqueda avanzada, pero la gestión día a día es de Secretaría).

### 💰 Finanzas
*   **Configurar Pensiones:** Fijar precios de mensualidades, matrículas y multas.
*   **Reportes Económicos:** Ingresos detallados, lista de morosos global.

### 📢 Comunidad
*   **Eventos:** Crear/Actualizar eventos institucionales.
*   **Comunicados:** Crear/Actualizar comunicados institucionales.
---

## 👩‍💼 2. Rol: Secretaria
**Objetivo:** Operatividad diaria, atención al cliente (padres/alumnos) y caja.

### 🏠 Dashboard (Inicio)
*   **Panel Rápido:** Accesos directos a "Cobrar Pensión" e "Inscribir Alumno".
*   **Avisos:** Notificaciones de cumpleaños o pagos vencidos hoy.

### 🎓 Inscripciones
*   **Nueva Inscripción:** Flujo para registrar alumno nuevo + tutor.
*   **Re-inscripción:** Actualizar datos de alumnos antiguos para la nueva gestión.
*   **Lista de Matriculados:** Filtros por curso y paralelo.

### 👥 Estudiantes (Kardex)
*   **Buscador:** Por nombre o CI.
*   **Perfil Alumno:**
    *   *Datos Personales y de Tutores.*
    *   *Historial Académico (Boletines anteriores).*
    *   *Historial Financiero (Estado de cuenta).*
    *   *Documentación (Certificados, RUDE).*

### 💸 Caja / Cobros
*   **Realizar Cobra:** Buscador de alumno -> Selección de concepto (Mensualidad Marzo) -> Pago (Efectivo/QR).
*   **Historial de Transacciones:** Ver recibos emitidos hoy, anular recibo (si tiene permiso).
*   **Cierre de Caja:** Reporte de lo recaudado en su turno.

---

## 👨‍🏫 3. Rol: Profesor
**Objetivo:** Gestión de aula, calificaciones y comunicación.

### 🏠 Dashboard (Inicio)
*   **Mi Agenda:** Clases asignadas para el día de hoy (con hora y curso).
*   **Avisos:** Comunicados de dirección.

### 📘 Mis Cursos
*   **Lista de Asignaturas:** (Ej: Matemáticas - 3ro B - Secundaria).
*   **Dentro de un Curso:**
    *   **Registro de Notas:** Hoja de cálculo web para ingresar notas del trimestre activo.
    *   **Lista de Asistencia:** (Opcional) Marcar presentes/ausentes.
    *   **Estudiantes:** Lista simple de sus alumnos (con foto).

### 📅 Mi Horario
*   **Vista Semanal:** Calendario visual de sus clases.

### 📢 Comunicados
*   **Redactar:** Enviar mensaje a un curso completo o a padres específicos.
*   **Historial:** Ver mensajes enviados.

---

## 👨‍🎓 4. Rol: Estudiante / Padre de Familia
**Objetivo:** Consulta de información y estado de situación.

### 🏠 Dashboard (Inicio)
*   **Resumen:** Próxima materia (según horario), estado de la mensualidad actual (Pagado/Pendiente).
*   **Últimos Avisos:** Comunicados recientes no leídos.

### 📝 Académico
*   **Mis Notas:**
    *   *Boletín Actual:* Notas del trimestre en curso.
    *   *Boletín Final:* Descarga de libreta oficial (PDF).
*   **Mi Horario:** Calendario visual de clases.
*   **Mis Materias:** Lista de asignaturas y profesores asignados.

### 💰 Pagos (Estado de Cuenta)
*   **Historial:** Lista de mensualidades pagadas (ver recibos).
*   **Pendientes:** Mensualidades por vencer.
*   **Métodos de Pago:** Información para transferencias o QR (si se habilita pago online).

### 🔔 Social
*   **Comunicados:** Bandeja de entrada de mensajes de profesores/dirección.
*   **Agenda:** Fechas de exámenes, feriados, actos cívicos.

---

## ⚙️ Común (Todos los Roles)
*   **🔔 Notificaciones:** Panel lateral con alertas en tiempo real.
*   **👤 Perfil:**
    *   Cambiar Foto.
    *   Cambiar Contraseña.
    *   Cerrar Sesión.
