# 📊 Estado del Proyecto: Sistema "Unidad Educativa"

Este documento detalla la funcionalidad esperada vs. el estado actual del sistema, desglosado por roles, incluyendo el alcance de las operaciones (CRUD).

**Leyenda:**
*   ✅ **Completado**: Funcionalidad implementada y verificable.
*   ⚠️ **Parcial**: Implementado pero con limitaciones o bugs conocidos.
*   ❌ **Pendiente**: No implementado o solo bocetado.
*   **CRUD**: **C** (Crear), **R** (Leer), **U** (Actualizar), **D** (Eliminar).

---

## 👨‍🎓 Rol: Estudiante

El estudiante tiene un perfil principalmente de **consulta (Read-Only)**.

| Funcionalidad | CRUD Esperado | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :---: | :--- |
| **Login** | - | ✅ | ✅ | Acceso seguro (Refactorizado a `ROLE_ESTUDIANTE`). |
| **Ver Notas** | R | ✅ | ✅ | Consulta por año + **Descarga PDF oficial** (Verificado). |
| **Ver Deudas/Pensiones** | R | ✅ | ✅ | Consulta de mensualidades y estados. |
| **Ver Horarios** | R | ✅ | ✅ | Visualización de horario semanal. |
| **Ver Comunicados** | R | ✅ | ✅ | Bandeja de entrada (Global + Curso). |
| **Ver Eventos** | R | ✅ | ✅ | Agenda de actividades. |

---

## 👨‍🏫 Rol: Profesor

El profesor gestiona la información académica de sus asignaturas.

| Funcionalidad | CRUD Esperado | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :---: | :--- |
| **Login** | - | ✅ | ✅ | . |
| **Mis Cursos** | R | ✅ | ✅ | Ver lista de cursos asignados. |
| **Registrar Notas** | C R U | ✅ | ✅ | Carga y edición de notas por trimestre. |
| **Ver Lista Estudiantes** | R | ✅ | ✅ | Listado visual OK. Descarga PDF operativa. |
| **Ver Horarios** | R | ✅ | ✅ | **Nuevo:** Visualización de su carga horaria. |
| **Enviar Comunicados** | C R | ✅ | ✅ | Enviar notas a sus cursos. |

---

## 👩‍💼 Rol: Secretaria

La secretaria tiene control operativo sobre alumnos y pagos.

| Funcionalidad | CRUD Esperado | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :---: | :--- |
| **Login** | - | ✅ | ✅ | . |
| **Gestionar Estudiantes** | C R U D | ✅ | ✅ | Gestión completa de legajos. |
| **Inscribir Estudiantes** | C R | ✅ | ✅ | Matricular alumnos en cursos. |
| **Cobro de Pensiones** | C R | ✅ | ✅ | Registrar pagos (Crear Transacción). |
| **Gestionar Horarios** | R | ✅ | ⚠️ | Puede ver, pero la gestión es del Director. |
| **Facturación** | C R | ✅ | ✅ | Backend Logic/Reporte listo. Integración UI completada. |

---

## 👨‍💼 Rol: Director (Admin)

El director tiene control total (Full Access) sobre la configuración institucional.

| Funcionalidad | CRUD Esperado | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :---: | :--- |
| **Login** | - | ✅ | ✅ | . |
| **Gestión Usuarios** | C R U D | ✅ | ✅ | ABM Total de personal y alumnos. |
| **Gestión Académica** | C R U D | ✅ | ✅ | Cursos, Materias, Paralelos, Gestión. |
| **Asignación Docente** | C R U D | ✅ | ✅ | Asignar materias a profesores. |
| **Gestión Horarios** | C R U D | ✅ | ✅ | **Nuevo:** Asignar días/horas a materias. |
| **Config. Pensiones** | C R U D | ✅ | ✅ | Definir costos anuales. |
| **Reportes/KPIs** | R | ✅ | ✅ | Dashboard estadístico + Reportes PDF. |

---

## 🛠️ Resumen Técnico & Próximos Pasos

### ✅ Completado (Fase 1)
Todo el flujo "Core" operativo está funcionando:
1.  **Usuarios y Seguridad.**
2.  **Inscripciones y Academia.**
3.  **Calificaciones y Avance.**
4.  **Horarios y Asignaciones.**
5.  **Caja y Pensiones.**

### ✅ Completado (Fase 2 - Documental)
El sistema genera documentos oficiales y métricas básicas.
1.  **Reportes PDF (Read):** ✅ Boletines, Recibos y Listas de Curso operativos.
2.  **Facturación (Create):** ✅ Recibos PDF tras cada pago.
3.  **KPIs Director:** ✅ Dashboard con contadores (Estudiantes, Profesores, Ingresos).

### ✅ Completado (Fase 3 - Comunidad)
Funcionalidades sociales/comunicativas.
1.  **Comunicados (Create/Read):** ✅ Sistema de mensajería interna (Global y Por Curso).
2.  **Eventos (Create/Read):** ✅ Agenda académica y feriados.
3.  **Notificaciones In-App:** ✅ Alertas de sistema leídas/no leídas.
4.  **Perfil Usuario:** ✅ Foto de Perfil y Cambio de Contraseña.

---
*Última actualización: 17 Diciembre 2025*
