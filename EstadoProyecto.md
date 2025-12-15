# 📊 Estado del Proyecto: Sistema "Unidad Educativa"

Este documento detalla la funcionalidad esperada vs. el estado actual del sistema, desglosado por roles.

**Leyenda:**
*   ✅ **Completado**: Funcionalidad implementada y verificable.
*   ⚠️ **Parcial**: Implementado pero con limitaciones o bugs conocidos.
*   ❌ **Pendiente**: No implementado o solo bocetado.

---

## 👨‍🎓 Rol: Estudiante

El estudiante debe poder consultar su información académica y financiera.

| Funcionalidad | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :--- |
| **Login** | ✅ | ✅ | Acceso con correo y contraseña. |
| **Ver Notas** | ✅ | ✅ | Consulta de notas por trimestre. (Recién corregido). |
| **Ver Deudas/Pensiones** | ✅ | ✅ | Consulta de mensualidades pendientes. |
| **Ver Horarios** | ❌ | ⚠️ | Frontend tiene placeholder, backend falta endpoints específicos. |
| **Ver Comunicados** | ❌ | ⚠️ | Frontend tiene placeholder, backend falta lógica de destinatarios. |
| **Ver Eventos** | ❌ | ⚠️ | Frontend tiene placeholder. |
| **Descargar Boletín** | ⚠️ | ❌ | Backend genera datos, falta generación PDF. Frontend sin botón. |

---

## 👨‍🏫 Rol: Profesor

El profesor debe gestionar sus clases y calificar a los estudiantes.

| Funcionalidad | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :--- |
| **Login** | ✅ | ✅ |  |
| **Mis Cursos** | ✅ | ✅ | Lista cursos asignados (Ej. 1ro Sec - Matemáticas). |
| **Registrar Notas** | ✅ | ✅ | Ingreso de notas por estudiante y trimestre. |
| **Ver Lista Estudiantes** | ✅ | ✅ | Ve quiénes están inscritos en sus materias. |
| **Ver Horarios** | ❌ | ⚠️ | Placeholder. |
| **Enviar Comunicados** | ❌ | ❌ | No implementado. |
| **Toma de Asistencia** | ❌ | ❌ | No implementado ni planificado en fase 1. |

---

## 👩‍💼 Rol: Secretaria

La secretaria gestiona la operatividad diaria: inscripciones y cobros.

| Funcionalidad | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :--- |
| **Login** | ✅ | ✅ |  |
| **Gestionar Estudiantes** | ✅ | ✅ | CRUD Estudiantes. Lista recién implementada. |
| **Inscribir Estudiantes** | ✅ | ✅ | Registro en cursos. (Recién corregido error 404). |
| **Cobro de Pensiones** | ✅ | ✅ | Registro de pagos y cálculo de deuda. |
| **Facturación** | ❌ | ⚠️ | Frontend tiene placeholder. Backend sin módulo de facturación. |
| **Emitir Comprobantes** | ❌ | ⚠️ | Frontend tiene placeholder. |

---

## 👨‍💼 Rol: Director (Admin)

El director tiene control total y gestiona la estructura de la institución.

| Funcionalidad | Backend | Frontend | Comentarios |
| :--- | :---: | :---: | :--- |
| **Login** | ✅ | ✅ |  |
| **Gestión Usuarios** | ✅ | ✅ | Crear/Editar Director, Secretaria, Prof, Est. |
| **Gestión Académica** | ✅ | ✅ | Crear Cursos, Materias, Paralelos. |
| **Asignación Docente** | ✅ | ✅ | Asignar materias a profesores. |
| **Gestión Horarios** | ❌ | ⚠️ | Frontend tiene página, pero falta lógica backend. |
| **Config. Pensiones** | ✅ | ✅ | Definir costos y tipos de pago. |
| **Reportes/KPIs** | ❌ | ⚠️ | Dashboard principal es estático. Falta data real. |

---

## 🛠️ Resumen Técnico

### ✅ Lo que Funciona Bien
1.  **Autenticación y Seguridad:** Roles y protección de rutas.
2.  **Flujo Académico Básico:** Materias -> Cursos -> Inscripción -> Calificación.
3.  **Flujo Financiero Básico:** Deuda -> Pago.
4.  **Estructura del Proyecto:** Backend (Spring Boot) y Frontend (Flutter) bien organizados.

### ⚠️ Áreas Críticas a Mejorar (Próximos Pasos)
1.  **Horarios:** Es un hueco funcional importante para todos los roles.
2.  **Comunicados:** Necesario para la interacción Institución-Comunidad.
3.  **Reportes PDF:** Esencial para imprimir libretas y recibos.
4.  **Validaciones de Negocio:**
    *   Controlar cupos en cursos.
    *   Validar choques de horarios.
    *   Bloquear notas fuera de fecha.

---
*Última actualización: 15 Diciembre 2025*
