# 📋 Plan de Implementación: Finalización del Rol Profesor

Este documento detalla la hoja de ruta estratégica para completar el 100% de las funcionalidades del **Profesor** en el sistema "Unidad Educativa". El objetivo central es dotar al docente de herramientas eficientes para la gestión de aula y calificación.

---

## 🏃 Sprint 1: Acceso y Gestión de Carga Horaria (Prioridad Alta)
**Objetivo:** Permitir al profesor visualizar claramente sus responsabilidades académicas.

### 1.1 Dashboard Personalizado
- [x] **Backend:** Endpoint `GET /api/profesor/dashboard-stats` (Total cursos asignados, próximas clases hoy).
- [x] **Frontend:** Implementar widgets de acceso rápido en `DashboardProfesor`.
- [x] **Funcionalidad:** Ver horario del día actual y avisos importantes de Dirección.

### 1.2 Mis Cursos (Asignaciones)
- [x] **Backend:** Optimizar `GET /api/profesor/cursos-asignados` para traer detalles del curso (Nombre, Paralelo, Gestión).
- [x] **Frontend:** Pantalla `CursosAsignadosPage` con tarjetas para cada materia asignada.
- [x] **UX:** Al hacer click en una materia, navegar al detalle del curso (Notas/Estudiantes).

---

## 🏃 Sprint 2: Núcleo Académico - Registro de Notas (Bloque Crítico)
**Objetivo:** Reemplazar el registro manual/Excel con un sistema web ágil y seguro.

### 2.1 Gestión de Trimestres
- [ ] **Backend:** Validar que el profesor solo pueda editar notas del **Trimestre Activo** según configuración de Dirección.
- [ ] **Frontend:** Selector de Trimestre en la pantalla de notas (Bloquear edición en trimestres cerrados).

### 2.2 Hoja de Calificaciones (Gradebook)
- [ ] **Frontend:** Implementar tabla editable ("DataGrid") en `RegistroNotasPage`.
    - Columnas: Ser (10pt), Saber (35pt), Hacer (35pt), Decidir (10pt), Auto-evaluación (10pt).
    - Cálculo automático de promedios en tiempo real.
- [ ] **Backend:** Endpoint `POST /api/notas/batch` para guardar notas masivamente por curso.
- [ ] **Validación:** Controlar rango de notas (0-100) y prevenir pérdida de datos.

### 2.3 Listado de Estudiantes
- [ ] **Frontend:** Visualizar la lista de alumnos inscritos en el curso seleccionado (`DashboardProfesorInscritosPage`).
- [ ] **Funcionalidad:** Acceso rápido al perfil básico del estudiante (Nombre, Foto) para identificación.

---

## 🏃 Sprint 3: Planificación y Horarios
**Objetivo:** Organización del tiempo docente.

### 3.1 Mi Horario
- [ ] **Backend:** Endpoint `GET /api/profesor/horario` filtrando la matriz general por el ID del profesor.
- [ ] **Frontend:** Visualización de calendario semanal en `DashboardProfesorHorariosPage`.
- [ ] **UX:** Colores distintivos por materia o curso.

---

## 🏃 Sprint 4: Comunicación (Comunidad)
**Objetivo:** Facilitar el flujo de información Profesor <-> Dirección <-> Padres.

### 4.1 Comunicados
- [ ] **Backend:** Endpoint `GET /api/comunicados/profesor` (Recibidos) y `POST /api/comunicados` (Enviar a curso).
- [ ] **Frontend:** Pantalla `DashboardProfesorComunicadosPage`.
- [ ] **Funcionalidad:**
    - Bandeja de entrada (Circulares de Dirección).
    - Redactar aviso para un curso entero (ej: "Examen el viernes").

---

## 📝 Resumen del Estado Actual vs. Meta

| Módulo | Característica | Estado Actual | Meta del Plan |
| :--- | :--- | :--- | :--- |
| **Acceso** | Cursos Asignados | ✅ Completado | ✅ Lista detallada y navegable |
| **Académico** | **Registro de Notas** | 🚧 En Progreso | ✅ DataGrid Web Agil |
| **Organización** | Horario Personal | ⚪ Pendiente | ✅ Calendario Semanal |
| **Comunidad** | Comunicados | ⚪ Pendiente | ✅ Comunicación fluida |

Siguiente paso: **Iniciar Sprint 2 (Registro de Notas)**
